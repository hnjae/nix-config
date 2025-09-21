from __future__ import annotations

import logging
from datetime import timedelta
from typing import Annotated

import isodate
from isodate import ISO8601Error
from typer import BadParameter, Option, Typer

from .zfs_snapshot import get_snapshots

logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s: %(message)s",
)
logger = logging.getLogger(__name__)


app = Typer(rich_markup_mode=None)


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
    store = get_snapshots(
        dataset, recursive=recursive, offset=offset, filter_=filter_
    )

    store.apply_retention_policy(
        keep_last=keep_last,
        hourly_duration=hourly_duration,
        daily_duration=daily_duration,
        weekly_duration=weekly_duration,
        monthly_duration=monthly_duration,
        yearly_duration=yearly_duration,
    )
    store.print_summary()
    store.destroy(
        dry_run=dry_run,
    )


if __name__ == "__main__":
    app()
