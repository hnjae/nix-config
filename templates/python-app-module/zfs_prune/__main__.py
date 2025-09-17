from typing import Annotated

from typer import Argument, Option, Typer

app = Typer(rich_markup_mode=None)


@app.command()
def main(
    *,
    dry_run: Annotated[
        bool, Option("--dry-run", "-n", help="Dry-run operation")
    ] = False,
    foos: Annotated[list[str], Argument(help="List of foos")],
) -> None:
    pass


if __name__ == "__main__":
    app()
