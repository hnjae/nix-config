#!/usr/bin/env python3

import binascii
import sys
from datetime import datetime
from pathlib import Path
from typing import cast
from zipfile import ZipFile

import magic
from rarfile import RarFile  # type: ignore[import]
from tabulate import tabulate


def print_rar(file: Path) -> None:
    with RarFile(file) as archive:
        if archive.needs_password():
            print("Password required")
            return

        if archive.is_solid():
            print("Solid archive")
            return

        table = [
            [
                entry.file_size,
                entry.is_file() and datetime(*entry.date_time) or "-",
                (
                    entry.is_file()
                    and (
                        entry.CRC
                        and format(entry.CRC, "08X")
                        or format(binascii.crc32(entry.blake2sp_hash), "016X")
                    )
                    or "-"
                ),
                entry.filename,
            ]
            for entry in archive.infolist()
        ]

        print(f"Num of files: {len(table)}")
        print(
            tabulate(
                sorted(
                    table,
                    key=(lambda x: cast(list, x)[-1]),
                ),
                headers=["Size", "Datetime", "Hash", "Filename"],
            )
        )


def print_zip(file: Path) -> None:
    with ZipFile(file) as archive:
        table = [
            [
                info.file_size,
                info.is_dir() and "-" or datetime(*info.date_time),
                info.is_dir() and "-" or format(info.CRC, "08X"),
                info.filename,
            ]
            for info in archive.infolist()
        ]

        print(f"Num of files: {len(table)}")
        print(
            tabulate(
                sorted(table, key=(lambda x: cast(list, x)[-1])),
                headers=["Size", "Datetime", "Hash", "Filename"],
            )
        )


def entrypoint():
    if len(sys.argv) != 2:
        print("Usage: <script> <archive_path>")
        return 1

    file = Path(sys.argv[1])
    mime = magic.from_file(file, mime=True)
    if mime == "application/x-rar" or mime == "application/vnd.rar":
        print_rar(file)
    elif mime == "application/zip":
        print_zip(file)
    else:
        print(f"Unsupported file type: {mime}")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(entrypoint())
