from __future__ import annotations

import json
import logging
import re
import subprocess
from collections import defaultdict
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta, timezone
from typing import TYPE_CHECKING, Annotated, cast, final, override

import isodate
from isodate import ISO8601Error

if TYPE_CHECKING:
    from collections.abc import Mapping

    from .types import ZfsListResponse

from typer import BadParameter, Option, Typer

logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s %(message)s",
)
logger = logging.getLogger(__name__)


app = Typer(rich_markup_mode=None)
now = datetime.now(tz=UTC)


@final
@dataclass(frozen=True, unsafe_hash=False, order=False)
class ZfsSnapshot:
    name: str  # e.g. dataset@snapshotname
    dataset: str
    snapshot_name: str
    created: datetime  # localtimezone+offset

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


def keep_within_hourly(
    snapshots: set[ZfsSnapshot],
    *,
    within: timedelta | None,
) -> set[ZfsSnapshot]:
    """
    Return snapshots to keep within duration.
    """

    def get_hour_key(
        snapshot: ZfsSnapshot,
    ) -> datetime:
        dt = snapshot.created
        return datetime(
            year=dt.year,
            month=dt.month,
            day=dt.day,
            hour=dt.hour,
            tzinfo=dt.tzinfo,
        )

    if within is None:
        return set()

    map_: Mapping[datetime, set[ZfsSnapshot]] = defaultdict(set)
    for snapshot in snapshots:
        if now - snapshot.created > within:
            pass
        map_[get_hour_key(snapshot)].add(snapshot)

    return {max(map_[key]) for key in map_}


def get_snapshots(
    dataset: str, *, recursive: bool, offset: timedelta | None
) -> Mapping[str, set[ZfsSnapshot]]:
    """
    Get ZFS snapshots for a given dataset.

    :return: Mapping with following key-value
        key
            dataset name
        value
            set of snapshots
    """

    localtz = now.astimezone().tzinfo
    if not isinstance(localtz, timezone):
        msg = "Failed to get system local timezone"
        raise RuntimeError(msg)
    offset_tz = (
        timezone(localtz.utcoffset(None) + offset)
        if offset is not None
        else localtz
    )

    ret: Mapping[str, set[ZfsSnapshot]] = defaultdict(set)

    args = ["zfs", "list", "-t", "snapshot", "-p", "-o", "creation", "--json"]
    if recursive:
        args.append("-r")
    args += ["--", dataset]

    proc = subprocess.run(args, check=True, capture_output=True)

    data = cast("ZfsListResponse", json.loads(proc.stdout))
    for snapdata in data["datasets"].values():
        ret[snapdata["dataset"]].add(
            ZfsSnapshot(
                name=snapdata["name"],
                dataset=snapdata["dataset"],
                snapshot_name=snapdata["snapshot_name"],
                created=datetime.fromtimestamp(
                    timestamp=int(snapdata["properties"]["creation"]["value"]),
                    tz=offset_tz,
                ),
            )
        )

    return ret


def validate_non_negative_int(number: int) -> int:
    """Validate that an integer is non-negative."""
    if number < 0:
        msg = "Number must be non-negative"
        raise BadParameter(msg)
    return number


def parse_timedelta(duration_str: str) -> timedelta:
    """Parse ISO-8601 duration string and return timedelta object."""

    try:
        ret = isodate.parse_duration(  # pyright: ignore[reportUnknownMemberType]
            duration_str, as_timedelta_if_possible=True
        )
    except ISO8601Error as e:
        msg = f"Invalid ISO-8601 duration format: {duration_str}"
        raise BadParameter(msg) from e

    if not isinstance(ret, timedelta):
        msg = "Something wrong happened. Parsed duration is not timedelta."
        raise BadParameter(msg)

    return ret


def parse_offset(offset_min_str: str) -> timedelta:
    return timedelta(minutes=int(offset_min_str))


@app.command()
def main(
    *,
    dry_run: Annotated[
        bool, Option("--dry-run", "-n", help="Dry-run operation")
    ] = False,
    keep_last: Annotated[
        int,
        Option(
            callback=validate_non_negative_int,
            help="Keep the last N snapshots",
            metavar="N",
        ),
    ] = 0,
    keep_within_hourly_duration: Annotated[
        timedelta | None,
        Option(
            "--keep-within-hourly",
            parser=parse_timedelta,
            help="Keep hourly snapshots within DURATION (ISO-8601 format, e.g. P4M5DT6H)",
            metavar="DURATION",
        ),
    ] = None,
    keep_within_daily: Annotated[
        timedelta | None,
        Option(
            parser=parse_timedelta,
            help="Keep daily snapshots within DURATION (ISO-8601 format, e.g. P4M5DT6H)",
            metavar="DURATION",
        ),
    ] = None,
    keep_within_weekly: Annotated[
        timedelta | None,
        Option(
            parser=parse_timedelta,
            help="Keep weekly snapshots within DURATION (ISO-8601 format, e.g. P4M5DT6H)",
            metavar="DURATION",
        ),
    ] = None,
    keep_within_monthly: Annotated[
        timedelta | None,
        Option(
            parser=parse_timedelta,
            help="Keep monthly snapshots within DURATION (ISO-8601 format, e.g. P4M5DT6H)",
            metavar="DURATION",
        ),
    ] = None,
    offset: Annotated[
        timedelta | None,
        Option(
            parser=parse_offset,
            help="Delays the starting point of the day by OFFSET minutes.",
            metavar="MINUTES",
        ),
    ] = None,
    recursive: Annotated[bool, Option("--recursive", "-r")] = False,
    filter_: Annotated[
        str | None,
        Option(
            "--filter",
            help="Filter snapshots to progress by REGEX",
            metavar="REGEX",
        ),
    ] = None,
    dataset: str,
) -> None:
    per_ds_snapshots = get_snapshots(
        dataset, recursive=recursive, offset=offset
    )

    keep: set[ZfsSnapshot] = set()
    for snapshots in per_ds_snapshots.values():
        filtered = {
            s
            for s in snapshots
            if filter_ is None
            or re.fullmatch(filter_, s.snapshot_name) is not None
        }
        keep.update(
            keep_within_hourly(
                filtered,
                within=keep_within_hourly_duration,
            )
        )
    for k in keep:
        logger.info(k)


if __name__ == "__main__":
    app()
