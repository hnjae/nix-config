#!/usr/bin/env python3

# run this file to gnerate image.nix, archive.nix, ...

from collections import defaultdict
from dataclasses import dataclass, field
from pathlib import Path

import defusedxml.ElementTree as ET

FREEDESKTOP_FILE = (
    "/run/current-system/sw/share/mime/packages/freedesktop.org.xml"
)


@dataclass
class MimeData:
    patterns: set[str] = field(default_factory=set)
    root_class_of: set[str] = field(default_factory=set)
    aliases: set[str] = field(default_factory=set)
    comment: str | None = None


# key: mime_type
_mimes: dict[str, MimeData] = defaultdict(MimeData)


def update_big(group: set[str], mime: str):
    if mime in group:
        return

    group.add(mime)

    if mime in _mimes:
        for x in _mimes[mime].root_class_of:
            update_big(group, x)

        for x in _mimes[mime].aliases:
            update_big(group, x)


def print_to_file(file: Path, group: set[str]):
    # x: open for exclusive creation, failing if the file already exists
    with file.open("x") as f:
        print("[", file=f)
        for mime in sorted(group):
            f.write(f'\t"{mime}"')
            if _mimes[mime].patterns:
                f.write(f"\t# {_mimes[mime].patterns}")
            f.write("\n")
        print("]", file=f)


def update_mimes():
    tree = ET.parse(FREEDESKTOP_FILE)
    root = tree.getroot()

    for mime_type in root:
        type_ = mime_type.get("type")

        _mimes[type_].comment = mime_type.find(
            "{http://www.freedesktop.org/standards/shared-mime-info}comment"
        ).text

        _mimes[type_].patterns.update(
            {
                x.get("pattern")
                for x in mime_type.findall(
                    "{http://www.freedesktop.org/standards/shared-mime-info}glob"
                )
            }
        )

        _mimes[type_].aliases.update(
            {
                x.get("type")
                for x in mime_type.findall(
                    "{http://www.freedesktop.org/standards/shared-mime-info}alias"
                )
            }
        )

        for sub_class_of in mime_type.findall(
            "{http://www.freedesktop.org/standards/shared-mime-info}sub-class-of"
        ):
            _mimes[sub_class_of.get("type")].root_class_of.add(type_)


if __name__ == "__main__":
    text: set[str] = set()
    image: set[str] = set()
    audio: set[str] = set()
    video: set[str] = set()
    archive: set[str] = set()
    archive_pre: set[str] = {
        "application/x-ace",
        "application/x-arc",
        "application/x-alz",
        # from ark's mime
        "application/zip",
        "application/vnd.rar",
        "application/x-7z-compressed",  # .7z
        "application/x-arj",
        "application/x-iso9660-appimage",
        "application/x-deb",
        "application/x-cpio",
        "application/vnd.efi.iso",
        "application/x-bcpio",
        "application/x-cd-image",
        "application/x-stuffit",
        "application/x-sv4cpio",
        "application/x-sv4crc",
        "application/arj",
        "application/vnd.ms-cab-compressed",
        "application/x-archive",
        "application/x-source-rpm",
        "application/x-xar",
        "application/x-rpm",
        "application/vnd.debian.binary-package",
        # tar
        "application/x-tar",  # .tar
        # generic
        "application/x-compress",  # .z
        "application/gzip",  # .gz
        "application/zlib",
        "application/zstd",
        "application/x-xz",
        "application/x-bzip1",
        "application/x-bzip2",
        "application/x-bzip3",
        "application/x-lrzip",
        "application/x-lz4",
        "application/x-lzip",
        "application/x-lzma",
        "application/x-lha",
        "application/x-lhz",
        "application/x-lzop",
    }

    update_mimes()

    for mime, mimeData in _mimes.items():
        if mime.startswith("text/"):
            update_big(text, mime)
            continue

        if mime.startswith("image/"):
            update_big(image, mime)
            continue

        if mime.startswith("audio/"):
            update_big(audio, mime)
            continue

        if mime.startswith("video/"):
            update_big(video, mime)
            continue

        if mime in archive_pre:
            update_big(archive, mime)

    for mime in audio.copy():
        if mime.startswith("video/"):
            audio.discard(mime)

    for mime in video.copy():
        if mime.startswith("audio/"):
            video.discard(mime)

    gen_root = Path("./generated")
    gen_root.mkdir(exist_ok=True)
    for file, group in [
        (gen_root.joinpath(Path("text.nix")), text),
        (gen_root.joinpath(Path("audio.nix")), audio),
        (gen_root.joinpath(Path("video.nix")), video),
        (gen_root.joinpath(Path("archive.nix")), archive),
        (gen_root.joinpath(Path("image.nix")), image),
    ]:
        print_to_file(file, group)
