from __future__ import annotations

import heapq
import json
import logging
import re
import subprocess
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from typing import TYPE_CHECKING, Annotated, cast

import isodate
from isodate import ISO8601Error
from tabulate import tabulate

from .snapshot_utils import Period, keep_within_period, localtz
from .zfs_snapshot import ZfsSnapshot

if TYPE_CHECKING:
    from collections.abc import Iterable, Mapping

    from .types import ZfsListResponse

from typer import BadParameter, Option, Typer

logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s: %(message)s",
)
logger = logging.getLogger(__name__)


app = Typer(rich_markup_mode=None)


def get_snapshots(
    dataset: str,
    *,
    recursive: bool,
    offset: timedelta | None,
    filter_: str | None,
) -> Mapping[str, set[ZfsSnapshot]]:
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

    ret: Mapping[str, set[ZfsSnapshot]] = defaultdict(set)

    args = ["zfs", "list", "-t", "snapshot", "-p", "-o", "creation", "--json"]
    if recursive:
        args.append("-r")
    args += ["--", dataset]

    proc = subprocess.run(args, check=True, capture_output=True)

    data = cast("ZfsListResponse", json.loads(proc.stdout))
    for snapdata in data["datasets"].values():
        if (
            filter_ is not None
            and re.fullmatch(filter_, snapdata["snapshot_name"]) is None
        ):
            continue

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


def validate_keep_last(number: int) -> int:
    """Validate that keep_last value."""
    if number < -1:
        msg = "Number must be -1 or greater."
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
            "--keep-last",
            callback=validate_keep_last,
            help="Keep the last N snapshots (-1 means all)",
            metavar="N",
        ),
    ] = -1,
    hourly_duration: Annotated[
        timedelta | None,
        Option(
            "--keep-within-hourly",
            parser=parse_timedelta,
            help="Keep hourly snapshots within DURATION (ISO-8601 format, e.g. P4M5DT6H)",
            metavar="DURATION",
        ),
    ] = None,
    daily_duration: Annotated[
        timedelta | None,
        Option(
            "--keep-within-daily",
            parser=parse_timedelta,
            help="Keep daily snapshots within DURATION (ISO-8601 format, e.g. P4M5DT6H)",
            metavar="DURATION",
        ),
    ] = None,
    weekly_duration: Annotated[
        timedelta | None,
        Option(
            "--keep-within-weekly",
            parser=parse_timedelta,
            help="Keep weekly snapshots within DURATION (ISO-8601 format, e.g. P4M5DT6H)",
            metavar="DURATION",
        ),
    ] = None,
    monthly_duration: Annotated[
        timedelta | None,
        Option(
            "--keep-within-monthly",
            parser=parse_timedelta,
            help="Keep monthly snapshots within DURATION (ISO-8601 format, e.g. P4M5DT6H)",
            metavar="DURATION",
        ),
    ] = None,
    yearly_duration: Annotated[
        timedelta | None,
        Option(
            "--keep-within-yearly",
            parser=parse_timedelta,
            help="Keep yearly snapshots within DURATION (ISO-8601 format, e.g. P4M5DT6H)",
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
    per_dataset_snapshots = get_snapshots(
        dataset, recursive=recursive, offset=offset, filter_=filter_
    )

    keep: set[ZfsSnapshot] = set()
    for snapshots in per_dataset_snapshots.values():
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

    # Print summary table
    print(
        tabulate(
            [
                (
                    s.name,
                    "keep" if s.keep else "remove",
                    "\n".join(s.keep_reason),
                )
                for s in sorted(
                    {s for ss in per_dataset_snapshots.values() for s in ss},
                    key=lambda x: (x.dataset, -x.created.timestamp()),
                    reverse=False,
                )
            ],
            headers=["Name", "Action", "Reason"],
            tablefmt="presto",
        )
    )

    remove: set[ZfsSnapshot] = {
        snap
        for snapshots in per_dataset_snapshots.values()
        for snap in snapshots.difference(keep)
    }

    if len(remove) == 0:
        logger.info("No snapshots to remove.")
        return

    if dry_run:
        logger.info("Dry-run mode, no changes will be made.")
        return

    for s in remove:
        _ = s.destroy()


if __name__ == "__main__":
    app()
