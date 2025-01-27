#!/usr/bin/env python3

from __future__ import annotations

import argparse
import subprocess
import sys
from collections import defaultdict
from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from argparse import Namespace
    from typing import Final
    from collections.abc import Iterable, Mapping

# ruff: noqa: ANN204, D107, D105

NIX_ENV_BIN: Final = "/run/current-system/sw/bin/nix-env"
NIX_BIN: Final = "/run/current-system/sw/bin/nix"

BOOT_ENTRY_PATH: Final = "/boot/loader/entries"
BOOT_ENTRY_PREFIX: Final = "nixos-generation-"
PROFILE_PATH: Final = "/nix/var/nix/profiles"


BOOTED_SYS_NIX_PATH: Final[Path] = Path("/run/booted-system").readlink()
CURRENT_SYS_NIX_PATH: Final[Path] = Path("/run/current-system").readlink()


class NixGeneration:
    def __init__(
        self, number: int, datetime_: datetime, *, is_current_profile: bool
    ):
        self.number = number
        self.profile_path = Path(PROFILE_PATH, f"system-{number}-link")

        self.nix_path = self.profile_path.readlink()
        # or run nix path-info <path>

        # is this generations /run/booted-system points
        self.is_booted_sys: bool = self.nix_path == BOOTED_SYS_NIX_PATH
        # is this generations /run/current-system points
        self.is_current_sys: bool = self.nix_path == CURRENT_SYS_NIX_PATH
        # whether there is current tags in nix-env --profile
        self.is_current_profile: bool = is_current_profile

        self.datetime_ = datetime_

        self.entry_name = f"{BOOT_ENTRY_PREFIX}{self.number}.conf"
        self.entry_path = Path(BOOT_ENTRY_PATH, self.entry_name)

    def __str__(self):
        return f"{self.number} {self.datetime_}"

    def __lt__(self, other):
        return self.datetime_ < other.datetime_

    def __hash__(self):
        return hash(frozenset({self.datetime_, self.number}))

    def __eq__(self, other):
        return self.__hash == other.__hash__

    def remove_boot_entry(self, *, run: bool = False):
        if not self.entry_path.is_file():
            msg = (
                f"WARNING: {self.entry_name} does not exists or is not a file"
            )
            print(msg)
            return

        if not run:
            msg = f"INFO: Would remove boot entry {self.entry_name} ({self.entry_path})"
            print(msg)
            return

        if run:
            msg = f"INFO: Removing {self.entry_path}"
            print(msg)
            self.entry_path.unlink()
            return


def get_generations() -> (
    tuple[
        NixGeneration,
        NixGeneration | None,
        NixGeneration | None,
        Mapping[date, set[NixGeneration]],
    ]
):
    """
    Return (current_profile_gen, booted_sys_gen, current_sys_gen generation_map[key: date, list[generations]])
    """

    args = (
        NIX_ENV_BIN,
        "--profile",
        "/nix/var/nix/profiles/system",
        "--list-generations",
    )

    proc = subprocess.run(args, check=True, capture_output=True, text=True)

    generations_by_date: Mapping[date, set[NixGeneration]] = defaultdict(set)

    # special_nix_gens: Mapping[str, Optional[NixGeneration]]

    # NOTE: 아래 3개는 모두 다를 수 있음
    current_profile_gen: NixGeneration | None = None
    booted_sys_gen: NixGeneration | None = None
    current_sys_gen: NixGeneration | None = None

    for line in proc.stdout.splitlines():
        gen: NixGeneration

        if line.endswith("(current)"):
            if current_profile_gen is not None:
                msg = "Multiple current generation in output"
                raise Exception(msg)

            number, date_, time, _ = line.split()
            gen = NixGeneration(
                int(number),
                datetime.fromisoformat(f"{date_}T{time}"),
                is_current_profile=True,
            )
        else:
            number, date_, time = line.split()
            gen = NixGeneration(
                int(number),
                datetime.fromisoformat(f"{date_}T{time}"),
                is_current_profile=False,
            )

        if gen.is_current_profile:
            current_profile_gen = gen

        if gen.is_booted_sys:
            booted_sys_gen = gen

        if gen.is_current_sys:
            current_sys_gen = gen

        generations_by_date[date.fromisoformat(f"{date_}")].add(gen)

    if booted_sys_gen is None:
        msg = "WARNING: Boot system's generation does not exists"
        print(msg)

    if current_sys_gen is None:
        msg = "WARNING: Current system's generation does not exists"
        print(msg)

    if current_profile_gen is None:
        msg = "ERROR: No current generation in output"
        raise Exception(msg)

    return (
        current_profile_gen,
        booted_sys_gen,
        current_sys_gen,
        generations_by_date,
    )


def remove_boot_entries(
    generations: Iterable[NixGeneration], *, run: bool = False
) -> None:
    if not generations:
        return

    for g in generations:
        g.remove_boot_entry(run=run)


def remove_profile(
    generations: Iterable[NixGeneration], *, run: bool = False
) -> bool:
    """Return true if success."""
    if not generations:
        msg = "INFO: No generations to delete."
        print(msg)
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

    subprocess.run(args, check=True)

    return True


def get_args() -> Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("delThreshold", default=14, type=int)
    parser.add_argument("--run", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = get_args()
    generations_to_remove: set[NixGeneration] = set()

    current_profile_gen, booted_sys_gen, current_sys_gen, map_ = (
        get_generations()
    )
    current_profile_date = current_profile_gen.datetime_.date()

    today = datetime.now(timezone.utc).astimezone().date()

    # remove generations without boot-entry
    # for generations in map_.values():
    #     generations_to_remove.update(
    #         {g for g in generations if not g.entry_path.is_file()}
    #     )

    for date_, generations in map_.items():
        if today <= date_:
            # generations created today
            continue

        if current_profile_date < date_:
            # future of current, expect not to exists
            continue

        if today - date_ > timedelta(days=args.delThreshold):
            # old generations
            generations_to_remove.update(generations)
            continue

        if len(generations) > 1:
            # multiple generations in one day
            gens = generations.copy()

            for gen in (booted_sys_gen, current_sys_gen, current_profile_gen):
                if gen is None:
                    continue
                gens.discard(gen)

            if len(generations) == len(gens):
                # keep latest
                gens.remove(max(gens))

            generations_to_remove.update(gens)
            continue

    # remove current_profile, current_sys, booted_sys from set if exists
    for gen in (booted_sys_gen, current_sys_gen, current_profile_gen):
        if gen is None:
            continue
        generations_to_remove.discard(gen)

    is_success = remove_profile(generations_to_remove, run=args.run)
    if is_success:
        remove_boot_entries(generations_to_remove, run=args.run)

    return 0


if __name__ == "__main__":
    sys.exit(main())
