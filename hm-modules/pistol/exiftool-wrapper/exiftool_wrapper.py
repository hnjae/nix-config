#!/usr/bin/env python3

from __future__ import annotations

import json
import re
import subprocess
import sys
from json import JSONDecodeError
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from typing import Final


from tabulate import tabulate

EXCLUDED_METADATA_FIELDS: Final[set[str]] = {
    "SourceFile",
    "ExifToolVersion",
    "FileName",
    "Directory",
    "FileSize",
    "FileModifyDate",
    "FileAccessDate",
    "FileInodeChangeDate",
    "FilePermissions",
    "FileType",
    "FileTypeExtension",
    # "MIMEType",
}


def camel_to_title(text: str) -> str:
    # 연속된 대문자 처리 (예: XMLParser -> XML Parser)
    text = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1 \2", text)
    # 일반적인 CamelCase 처리
    text = re.sub(r"([a-z])([A-Z])", r"\1 \2", text)
    return text


def print_single_entry(entry: dict[str, str | int | float | bool]) -> None:
    table = [
        [camel_to_title(k), v]
        for k, v in entry.items()
        if k not in EXCLUDED_METADATA_FIELDS
    ]
    print(tabulate(table, tablefmt="plain"))


def entrypoint():
    if len(sys.argv) < 2:
        print("Usage: exiftool-wrapper FILE...", file=sys.stderr)
        return 1

    args = ["exiftool", "-json", "--"]
    args.extend(sys.argv[1:])

    proc = subprocess.run(args, check=False, capture_output=True, text=False)
    if proc.returncode != 0 or proc.stdout == b"":
        _ = sys.stderr.buffer.write(proc.stderr)
        return 0

    try:
        out = json.loads(proc.stdout)  # pyright: ignore[reportAny]
    except JSONDecodeError:
        print("Unexpected output from exiftool:", file=sys.stderr)
        _ = sys.stderr.buffer.write(proc.stdout)
        return 1

    if not isinstance(out, list):
        print("Unexpected output from exiftool", file=sys.stderr)
        _ = sys.stderr.buffer.write(proc.stdout)
        return 1

    for entry in out:
        if len(out) != 1:
            print(f"======== {entry.get('FileName')}")
        print_single_entry(entry)

    if proc.stderr != b"":
        _ = sys.stderr.buffer.write(proc.stderr)

    return 0


if __name__ == "__main__":
    sys.exit(entrypoint())
