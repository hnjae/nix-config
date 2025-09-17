from typing import Annotated

from typer import BadParameter, Option, Typer

app = Typer(rich_markup_mode=None)


class ZfsSnapshot:
    def __init__(
        self,
        name: str,
        createtxg: int,
        snapshot_name: str,
        dataset: str,
        pool: str,
    ):
        self.name = name
        # self.createtxg = datetime.fromtimestamp(ts, tz=timezone.utc)
        self.snapshot_name = snapshot_name
        self.dataset = dataset
        self.pool = pool

    def __repr__(self):
        return self.name


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
    pass


if __name__ == "__main__":
    app()
