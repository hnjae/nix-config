# TODO: use `filter` to filter  <2025-09-17>

from __future__ import annotations

import json
import subprocess
from collections import defaultdict
from datetime import UTC, datetime, timezone
from typing import TYPE_CHECKING, Annotated, final, override

if TYPE_CHECKING:
    from collections.abc import Mapping

from typer import BadParameter, Option, Typer

from .types import ZfsListResponse, _SnapshotData

app = Typer(rich_markup_mode=None)


@final
class ZfsSnapshot:
    def __init__(
        self,
        raw: _SnapshotData,
    ):
        self.name = raw["name"]
        self.datetime = datetime.fromtimestamp(
            int(raw["properties"]["creation"]["value"]), tz=UTC
        )

    def __repl__(self):
        return f"ZfsSnapshot(name={self.name!r}, date={self.datetime})"

    @override
    def __str__(self):
        return self.name

    @override
    def __hash__(self):
        return self.name.__hash__()


def get_snapshots(
    dataset: str, *, recursive: bool
) -> Mapping[str, list[ZfsSnapshot]]:
    ret: Mapping[str, list[ZfsSnapshot]] = defaultdict(list)

    args = ["zfs", "list", "-t", "snapshot", "-p", "-o", "creation", "--json"]
    if recursive:
        args.append("-r")
    args += ["--", dataset]

    proc = subprocess.run(args, check=True, capture_output=True)

    data: ZfsListResponse = json.loads(proc.stdout)
    for snapshot_data in data["datasets"].values():
        foo = ZfsSnapshot(raw=snapshot_data)
        print(foo.__repl__())
        ret[snapshot_data["dataset"]].append(ZfsSnapshot(raw=snapshot_data))

    # print(ret)

    return ret


def is_non_negative_int(number: int) -> int:
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
            callback=is_non_negative_int,
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
    get_snapshots(dataset, recursive=recursive)


if __name__ == "__main__":
    app()
