# TODO: use `filter` to filter  <2025-09-17>

from __future__ import annotations

import json
import subprocess
from collections import defaultdict
from dataclasses import dataclass
from datetime import UTC, datetime
from pprint import pp
from typing import TYPE_CHECKING, Annotated, cast, final, override

if TYPE_CHECKING:
    from collections.abc import Mapping

    from .types import ZfsListResponse

from typer import BadParameter, Option, Typer

app = Typer(rich_markup_mode=None)


@final
@dataclass(frozen=True, unsafe_hash=False, order=False)
class ZfsSnapshot:
    name: str  # e.g. dataset@snapshotname
    dataset: str
    created: datetime

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


def get_snapshots(
    dataset: str, *, recursive: bool
) -> Mapping[str, set[ZfsSnapshot]]:
    """
    Get ZFS snapshots for a given dataset.

    key: dataset name
    value: set of snapshots
    """

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
                created=datetime.fromtimestamp(
                    timestamp=int(snapdata["properties"]["creation"]["value"]),
                    tz=UTC,  # NOTE: ASSUME HARDWARE CLOCK IS IN UTC
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
    keep_within_hourly: Annotated[
        int,
        Option(
            callback=is_non_negative_int,
            help="Keep hourly snapshots within DURATION",
            metavar="DURATION",
        ),
    ] = 0,
    keep_within_daily: Annotated[
        int,
        Option(
            callback=is_non_negative_int,
            help="Keep daily snapshots within DURATION",
            metavar="DURATION",
        ),
    ] = 0,
    keep_within_weekly: Annotated[
        int,
        Option(
            callback=is_non_negative_int,
            help="Keep weekly snapshots within DURATION",
            metavar="DURATION",
        ),
    ] = 0,
    keep_within_monthly: Annotated[
        int,
        Option(
            callback=is_non_negative_int,
            help="Keep monthly snapshots within DURATION",
            metavar="DURATION",
        ),
    ] = 0,
    offset: Annotated[
        int,
        Option(
            callback=lambda m: m * 60,  # pyright: ignore[reportUnknownLambdaType, reportUnknownArgumentType]
            help="Delays the starting point of the day by OFFSET minutes.",
            metavar="MINUTES",
        ),
    ] = 0,
    recursive: Annotated[bool, Option("--recursive", "-r")] = False,
    filter: Annotated[
        str | None,
        Option(
            help="Filter snapshots to progress by REGEX",
            metavar="REGEX",
        ),
    ] = None,
    dataset: str,
) -> None:
    snapshots = get_snapshots(dataset, recursive=recursive)


if __name__ == "__main__":
    app()
