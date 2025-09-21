from __future__ import annotations

import heapq
import json
import logging
import re
import subprocess
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from typing import TYPE_CHECKING, cast, final, override

from tabulate import tabulate

from .snapshot_utils import Period, keep_within_period, localtz

if TYPE_CHECKING:
    from collections.abc import Iterable, Mapping

    from .types import ZfsListResponse

logger = logging.getLogger(__name__)


@final
@dataclass(frozen=False, unsafe_hash=False, order=False)
class ZfsSnapshot:
    name: str  # e.g. dataset@snapshotname
    dataset: str
    snapshot_name: str
    created: datetime  # localtimezone+offset
    keep: bool | None = None
    keep_reason: list[str] = field(
        default_factory=list
    )  # 해당 snapshot 을 보존한다면 그 이유들
    is_root: bool = False  # --recursive 옵션이 주어졌을 때, 최상위 dataset 의 snapshot 인지 여부
    is_destroyed: bool = False  # snapshot 이 파괴되었는지 여부, 상위 dataset 의 recursive destroy 로 인해 파괴되었을 수도 있음

    @override
    def __str__(self) -> str:
        return self.name

    @override
    def __hash__(self):
        return self.name.__hash__()

    @override
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, ZfsSnapshot):
            msg = "Cannot compare ZfsSnapshot with non-ZfsSnapshot"
            raise TypeError(msg)

        return self.name == other.name

    def __lt__(self, other: object) -> bool:
        if not isinstance(other, ZfsSnapshot):
            msg = "Cannot compare ZfsSnapshot with non-ZfsSnapshot"
            raise TypeError(msg)

        if self.dataset != other.dataset:
            msg = "Cannot compare ZfsSnapshot of different datasets"
            raise ValueError(msg)

        return self.created < other.created

    def destroy(self, *, recursive: bool = False, dry_run: bool = True) -> int:
        if self.is_destroyed:
            msg = f"Snapshot {self.name} is already destroyed"
            raise RuntimeError(msg)

        if self.keep:
            msg = f"Snapshot {self.name} is marked to keep, cannot destroy"
            raise RuntimeError(msg)

        if recursive and not self.is_root:
            msg = f"Snapshot {self.name} is not root snapshot provided, cannot destroy with --recursive"
            raise RuntimeError(msg)

        self.is_destroyed = True
        if dry_run:
            logger.info("Would destroy snapshot %s (%s)", self.name, recursive)
            return 0

        logger.info("Destroying snapshot %s", self.name)

        args = ["zfs", "destroy"]
        if recursive:
            args.append("-r")
        args.extend(["--", self.name])

        proc = subprocess.run(args, check=True, capture_output=False)
        return proc.returncode


@final
class _ZfsSnapshotStore:
    def __init__(
        self: _ZfsSnapshotStore,
        *,
        root_dataset: str,
        snapshots: frozenset[ZfsSnapshot],
        by_dataset: Mapping[str, frozenset[ZfsSnapshot]],
        by_name: Mapping[str, frozenset[ZfsSnapshot]],
        is_recursive: bool,
    ) -> None:
        self._root_dataset = root_dataset
        self._snapshots = snapshots
        self._by_dataset = by_dataset
        self._by_snapshot_name = by_name
        self._is_recursive = is_recursive

    @classmethod
    def from_snapshots(
        cls,
        *,
        snapshots: Iterable[ZfsSnapshot],
        root_dataset: str,
        is_recursive: bool,
    ) -> _ZfsSnapshotStore:
        snapshot_set = frozenset(snapshots)

        by_dataset: defaultdict[str, set[ZfsSnapshot]] = defaultdict(set)
        by_name: defaultdict[str, set[ZfsSnapshot]] = defaultdict(set)

        for snapshot in snapshot_set:
            by_dataset[snapshot.dataset].add(snapshot)
            by_name[snapshot.snapshot_name].add(snapshot)

        return cls(
            root_dataset=root_dataset,
            snapshots=snapshot_set,
            is_recursive=is_recursive,
            by_dataset={k: frozenset(v) for k, v in by_dataset.items()},
            by_name={k: frozenset(v) for k, v in by_name.items()},
        )

    def apply_retention_policy(
        self: _ZfsSnapshotStore,
        *,
        keep_last: int,
        hourly_duration: timedelta | None,
        daily_duration: timedelta | None,
        weekly_duration: timedelta | None,
        monthly_duration: timedelta | None,
        yearly_duration: timedelta | None,
    ):
        for dataset in self._by_dataset:
            keep = self._update_keep_by_dataset(
                dataset,
                keep_last=keep_last,
                hourly_duration=hourly_duration,
                daily_duration=daily_duration,
                weekly_duration=weekly_duration,
                monthly_duration=monthly_duration,
                yearly_duration=yearly_duration,
            )

            if dataset == self._root_dataset:
                for k in keep:
                    for s in self._by_snapshot_name[k.snapshot_name]:
                        if not s.is_root:
                            s.keep = True
                            s.keep_reason.append(
                                f"kept in {self._root_dataset}"
                            )

    def _update_keep_by_dataset(
        self: _ZfsSnapshotStore,
        dataset: str,
        *,
        keep_last: int,
        hourly_duration: timedelta | None,
        daily_duration: timedelta | None,
        weekly_duration: timedelta | None,
        monthly_duration: timedelta | None,
        yearly_duration: timedelta | None,
    ):
        snapshots = self._by_dataset[dataset]
        keep: set[ZfsSnapshot] = set()
        if keep_last != 0:
            last_keep: Iterable[ZfsSnapshot]
            if keep_last == -1:
                last_keep = snapshots
            else:
                last_keep = heapq.nlargest(keep_last, snapshots)

            for k in last_keep:
                k.keep = True
                k.keep_reason.append("last")
            keep.update(last_keep)

        for within, period in [
            (hourly_duration, Period.HOURLY),
            (daily_duration, Period.DAILY),
            (weekly_duration, Period.WEEKLY),
            (monthly_duration, Period.MONTHLY),
            (yearly_duration, Period.YEARLY),
        ]:
            period_keep = keep_within_period(
                snapshots, within=within, period=period
            )
            for k in period_keep:
                k.keep = True
                k.keep_reason.append(f"within {period.value}")
            keep.update(period_keep)

        return keep

    def print_summary(self: _ZfsSnapshotStore):
        print(
            tabulate(
                [
                    (
                        s.name,
                        "keep" if s.keep else "remove",
                        "\n".join(s.keep_reason),
                    )
                    for s in sorted(
                        self._snapshots,
                        key=lambda x: (x.dataset, -x.created.timestamp()),
                        reverse=False,
                    )
                ],
                headers=["Name", "Action", "Reason"],
                tablefmt="presto",
            )
        )

    def destroy(
        self: _ZfsSnapshotStore,
        *,
        dry_run: bool = True,
    ):
        """
        Destroy snapshots that are not marked to keep.
        """

        for sr in self._by_dataset[self._root_dataset]:
            if sr.keep is True:
                continue
            _ = sr.destroy(recursive=self._is_recursive, dry_run=dry_run)

            if self._is_recursive:
                # Mark all snapshots with the same snapshot_name as destroyed
                for sc in self._by_snapshot_name[sr.snapshot_name]:
                    sc.is_destroyed = True

        if not self._is_recursive:
            return

        for s in self._snapshots:
            if not s.keep and not s.is_destroyed:
                _ = s.destroy(recursive=False, dry_run=dry_run)


def get_snapshots(
    dataset: str,
    *,
    recursive: bool,
    offset: timedelta | None,
    filter_: str | None,
) -> _ZfsSnapshotStore:
    """
    Get ZFS snapshots for a given dataset.

    :return: Mapping with following key-value
        key
            dataset name
        value
            set of snapshots
    """

    if not isinstance(localtz, timezone):
        msg = "Failed to get system local timezone"
        raise RuntimeError(msg)
    offset_tz = (
        timezone(localtz.utcoffset(None) + offset)
        if offset is not None
        else localtz
    )

    args = ["zfs", "list", "-t", "snapshot", "-p", "-o", "creation", "--json"]
    if recursive:
        args.append("-r")
    args.extend(["--", dataset])

    proc = subprocess.run(args, check=True, capture_output=True)

    snapshots: set[ZfsSnapshot] = set()
    data = cast("ZfsListResponse", json.loads(proc.stdout))
    for snapdata in data["datasets"].values():
        if (
            filter_ is not None
            and re.fullmatch(filter_, snapdata["snapshot_name"]) is None
        ):
            continue

        snapshots.add(
            ZfsSnapshot(
                name=snapdata["name"],
                dataset=snapdata["dataset"],
                snapshot_name=snapdata["snapshot_name"],
                created=datetime.fromtimestamp(
                    timestamp=int(snapdata["properties"]["creation"]["value"]),
                    tz=offset_tz,
                ),
                is_root=snapdata["dataset"] == dataset,
            )
        )

    return _ZfsSnapshotStore.from_snapshots(
        snapshots=snapshots, root_dataset=dataset, is_recursive=recursive
    )
