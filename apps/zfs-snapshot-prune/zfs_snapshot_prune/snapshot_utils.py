from __future__ import annotations

import logging
from collections import defaultdict
from datetime import UTC, datetime, timedelta
from enum import Enum
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from collections.abc import Mapping

    from .zfs_snapshot import ZfsSnapshot


logger = logging.getLogger(__name__)

_now = datetime.now(tz=UTC)
localtz = _now.astimezone().tzinfo


class Period(Enum):
    HOURLY = "hourly"
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    YEARLY = "yearly"


def _get_hourly_key(
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


def _get_daily_key(
    snapshot: ZfsSnapshot,
) -> datetime:
    dt = snapshot.created
    return datetime(
        year=dt.year,
        month=dt.month,
        day=dt.day,
        tzinfo=dt.tzinfo,
    )


def _get_weekly_key(
    snapshot: ZfsSnapshot,
) -> tuple[int, int]:
    year, week, _ = snapshot.created.isocalendar()
    return year, week


def _get_monthly_key(
    snapshot: ZfsSnapshot,
) -> datetime:
    dt = snapshot.created
    return datetime(
        year=dt.year,
        month=dt.month,
        day=1,
        tzinfo=dt.tzinfo,
    )


def _get_yearly_key(
    snapshot: ZfsSnapshot,
) -> int:
    dt = snapshot.created
    return dt.year


GET_KEY_PERIOD = {
    Period.HOURLY: _get_hourly_key,
    Period.DAILY: _get_daily_key,
    Period.WEEKLY: _get_weekly_key,
    Period.MONTHLY: _get_monthly_key,
    Period.YEARLY: _get_yearly_key,
}


def keep_within_period(
    snapshots: set[ZfsSnapshot],
    *,
    within: timedelta | None,
    period: Period,
) -> set[ZfsSnapshot]:
    """
    Return snapshots to keep within duration.
    """

    if within is None:
        return set()

    map_: Mapping[Any, set[ZfsSnapshot]] = defaultdict(set)  # pyright: ignore[reportExplicitAny]
    for snapshot in snapshots:
        if _now - snapshot.created > within:
            pass
        map_[GET_KEY_PERIOD[period](snapshot)].add(snapshot)

    return {max(map_[key]) for key in map_}  # pyright: ignore[reportAny]
