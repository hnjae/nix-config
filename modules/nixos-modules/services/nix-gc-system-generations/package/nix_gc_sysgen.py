#!/usr/bin/env python3

from __future__ import annotations

import argparse
import logging
import os
import subprocess
import sys
from argparse import Namespace
from collections import defaultdict
from datetime import UTC, datetime, timedelta, timezone
from pathlib import Path
from typing import TYPE_CHECKING, override

if TYPE_CHECKING:
    from collections.abc import Iterable, Mapping
    from datetime import date
    from typing import Final, Literal

NIX_ENV_BIN: Final = "/run/current-system/sw/bin/nix-env"
NIX_BIN: Final = "/run/current-system/sw/bin/nix"

BOOT_ENTRY_PATH: Final = "/boot/loader/entries"
BOOT_ENTRY_PREFIX: Final = "nixos-generation-"
PROFILE_PATH: Final = "/nix/var/nix/profiles"


BOOTED_SYS_NIX_PATH: Final[Path] = Path("/run/booted-system").readlink()
CURRENT_SYS_NIX_PATH: Final[Path] = Path("/run/current-system").readlink()

logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s: %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S%z",
)
logger = logging.getLogger(__name__)

localtz = datetime.now(tz=UTC).astimezone().tzinfo
if not isinstance(localtz, timezone):
    msg = "Failed to get system local timezone"
    raise RuntimeError(msg)


# NOTE: ArgsNamespace 를 사용하는 경우 `parser.add_argument` 의 `default` 는 무시됨. <Python 3.12>
class ArgsNamespace(Namespace):
    keep_days: int = 100
    run: bool = False
    offset_tz: timezone = timezone(
        localtz.utcoffset(None) + timedelta(hours=4)
    )

    @override
    def __repr__(self) -> str:
        attrs = {
            k: getattr(self, k) for k in ("keep_days", "run", "offset_tz")
        }
        items = ", ".join(f"{k}={v!r}" for k, v in sorted(attrs.items()))
        return f"{self.__class__.__name__}({items})"


def get_args() -> ArgsNamespace:
    def check_args(args: ArgsNamespace) -> Literal[True]:
        if args.keep_days < 0:
            msg = (
                "--delete-older-than-days must be greater than or equal to 0."
            )
            raise ValueError(msg)

        # if not (timedelta() <= args.offset_tz < timedelta(hours=24)):
        #     msg = "--day-rollover-hour must be between 0 and 23."
        #     raise ValueError(msg)

        return True

    def parse_offset_tz(hour_str: str) -> timezone:
        return timezone(
            localtz.utcoffset(None) + timedelta(hours=int(hour_str))
        )

    parser = argparse.ArgumentParser()
    _ = parser.add_argument(
        "--delete-older-than-days",
        dest="keep_days",
        type=int,
        help="Deletes generations older than this number of days.",
        nargs="?",  # consume 1 or 0 argument
    )

    _ = parser.add_argument(
        "--offset-hour",
        type=parse_offset_tz,
        help="The time in hours to considered as the change of day.",
        nargs="?",  # consume 1 or 0 argument
    )

    _ = parser.add_argument(
        "--run",
        action="store_true",
        help="Run the script in actual mode, not dry-run.",
    )

    args_ns = ArgsNamespace()
    args = parser.parse_args(namespace=args_ns)

    _ = check_args(args)

    return args


def check_condition() -> Literal[True]:
    # check if is running as root:
    if os.geteuid() != 0:
        msg = "This script must be run as root."
        raise PermissionError(msg)

    for bin in (NIX_ENV_BIN, NIX_BIN):
        if not Path(bin).is_file():
            msg = f"{bin} does not exist."
            raise FileNotFoundError(msg)

    return True


class NixGeneration:
    def __init__(
        self,
        number: int,
        datestr: str,
        timestr: str,  # NOTE: local-timezone 임
        offset_tz: timezone,
        *,
        is_current_profile: bool,
    ):
        self.number: Final[int] = number
        self.profile_path: Final[Path] = Path(
            PROFILE_PATH, f"system-{number}-link"
        )

        self.nix_path: Final[Path] = self.profile_path.readlink()
        # or run nix path-info <path>

        # is this generations /run/booted-system points
        self.is_booted_sys: Final[bool] = self.nix_path == BOOTED_SYS_NIX_PATH
        # is this generations /run/current-system points (is_current_profile 과 일치 해야하나, 별도로 체크)
        self.is_current_sys: Final[bool] = (
            self.nix_path == CURRENT_SYS_NIX_PATH
        )
        # whether there is current tags in nix-env --profile
        self.is_current_profile: Final[bool] = is_current_profile

        self.datetime_: Final[datetime] = datetime.fromisoformat(
            f"{datestr}T{timestr}"
        ).astimezone(offset_tz)

        self.entry_name: Final[str] = f"{BOOT_ENTRY_PREFIX}{self.number}.conf"
        self.entry_path: Final[Path] = Path(BOOT_ENTRY_PATH, self.entry_name)

    @override
    def __repr__(self):
        return f"{self.number} ({self.datetime_.astimezone().isoformat()})"

    def __lt__(self, other: NixGeneration):
        return self.datetime_ < other.datetime_

    @override
    def __hash__(self):
        return hash(frozenset({self.datetime_, self.number}))

    @override
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, NixGeneration):
            return False

        return self.__hash__ == other.__hash__

    def remove_boot_entry(self, *, run: bool = False):
        if not self.entry_path.is_file():
            logger.warning(
                "%s does not exists or is not a file.", self.entry_name
            )
            return

        if not run:
            logger.info(
                "DRY-RUN: Would remove boot entry %s (%s).",
                self.entry_name,
                self.entry_path,
            )
            return

        if run:
            logger.info("Removing %s.", self.entry_path)
            self.entry_path.unlink()
            return


def get_generations(offset_tz: timezone) -> set[NixGeneration]:
    ret: set[NixGeneration] = set()

    args = (
        NIX_ENV_BIN,
        "--profile",
        "/nix/var/nix/profiles/system",
        "--list-generations",
    )  # NOTE: local timezone 으로 출력함.

    proc = subprocess.run(args, check=True, capture_output=True, text=True)

    is_current_profile: bool
    is_current_profile_generated: bool = False
    for line in proc.stdout.splitlines():
        if line.endswith("(current)"):
            if is_current_profile_generated:
                msg = "Multiple current generation in output"
                raise RuntimeError(msg)

            is_current_profile_generated = True
            is_current_profile = True
            number, datestr, timestr, _ = line.split()
        else:
            is_current_profile = False
            number, datestr, timestr = line.split()

        gen = NixGeneration(
            int(number),
            datestr,
            timestr,
            offset_tz,
            is_current_profile=is_current_profile,
        )

        if gen.is_current_profile:
            logger.info("Current generation: %s", gen)
        if gen.is_booted_sys:
            logger.info("Booted generation: %s", gen)

        ret.add(gen)

    if not is_current_profile_generated:
        msg = "No current generation in output"
        raise RuntimeError(msg)

    return ret


def remove_profiles(
    generations: Iterable[NixGeneration], *, run: bool = False
) -> bool:
    """Return true if success."""
    if not generations:
        logger.info("No generations to delete.")
        return True

    args = [
        NIX_ENV_BIN,
        "--profile",
        "/nix/var/nix/profiles/system",
    ]

    if not run:
        args.append("--dry-run")

    for g in generations:
        args.extend(["--delete-generations", f"{g.number}"])

    _ = subprocess.run(args, check=True)

    return True


def main() -> int:
    _ = check_condition()
    args = get_args()

    logger.debug("Arguments: %s", args)

    all_generations = get_generations(args.offset_tz)

    current_profile_generation: NixGeneration | None = None
    generations_to_keep: set[NixGeneration] = set()
    date_map: Mapping[date, set[NixGeneration]] = defaultdict(set)

    for gen in all_generations:
        if gen.is_current_profile or gen.is_booted_sys or gen.is_current_sys:
            generations_to_keep.add(gen)

        date_ = gen.datetime_.date()
        date_map[date_].add(gen)

        if gen.is_current_profile:
            current_profile_generation = gen

    if current_profile_generation is None:
        msg = "No current profile generation found."
        raise RuntimeError(msg)

    today = datetime.now(tz=args.offset_tz).date()
    current_profile_date = current_profile_generation.datetime_.date()
    for date_, generations in date_map.items():
        if today <= date_:
            # generations created today
            generations_to_keep.update(generations)
            continue

        if current_profile_date <= date_:
            # keep future of current
            generations_to_keep.update(
                gen
                for gen in generations
                if (current_profile_generation.datetime_ <= gen.datetime_)
            )

        if (today - date_ <= timedelta(days=args.keep_days)) and generations:
            # Keep the newest generation created that day.
            generations_to_keep.add(max(generations))

    generations_to_remove = all_generations - generations_to_keep
    is_success = remove_profiles(generations_to_remove, run=args.run)
    if is_success:
        for g in generations_to_remove:
            g.remove_boot_entry(run=args.run)

    return 0


if __name__ == "__main__":
    sys.exit(main())
