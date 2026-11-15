#!/usr/bin/env python3
"""Build minimal, ready-to-install CraftAtlas GitHub Release archives."""
import argparse
import re
import sys
import zipfile
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "addon" / "CraftAtlas"
TOC = "CraftAtlas.toc"
LICENSE = "Data/LICENSE-LibProfessionDB.txt"
TAG = re.compile(r"^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$")
VERSION = re.compile(r"^## Version:.*$", re.MULTILINE)


def next_version(tags, bump):
    if bump not in ("patch", "minor", "major"):
        raise ValueError("Invalid increment")
    versions = [tuple(map(int, match.groups()))
                for tag in tags if (match := TAG.fullmatch(tag.strip()))]
    if not versions:
        return "0.1.0"
    major, minor, patch = max(versions)
    if bump == "major":
        major, minor, patch = major + 1, 0, 0
    elif bump == "minor":
        minor, patch = minor + 1, 0
    else:
        patch += 1
    return f"{major}.{minor}.{patch}"


def runtime_files(addon=ADDON):
    toc_file = addon / TOC
    if not toc_file.is_file():
        raise ValueError("Missing CraftAtlas.toc")
    paths = [TOC]
    for raw in toc_file.read_text(encoding="utf-8-sig").splitlines():
        name = raw.strip()
        if not name or name.startswith("#"):
            continue
        name = name.replace("\\", "/")
        path = PurePosixPath(name)
        if (path.is_absolute() or len(path.parts) < 2 or
                any(part in (".", "..") for part in name.split("/")) or
                path.suffix.lower() != ".lua" or
                not re.fullmatch(r"[A-Za-z0-9_./-]+", name)):
            raise ValueError(f"Unsafe or invalid .toc entry: {name}")
        paths.append(str(path))
    if len(paths) < 2:
        raise ValueError("No runtime Lua modules in .toc")
    paths.append(LICENSE)
    if len(paths) != len(set(paths)):
        raise ValueError("Duplicate manifest path")
    for path in paths:
        if not (addon / path).is_file():
            raise ValueError(f"Missing runtime dependency: {path}")
    return paths


def package(version, output, addon=ADDON):
    if not TAG.fullmatch("v" + version):
        raise ValueError("Expected numeric semantic version")
    paths = runtime_files(addon)
    toc = (addon / TOC).read_text(encoding="utf-8-sig")
    if len(VERSION.findall(toc)) != 1:
        raise ValueError("Expected exactly one .toc Version header")
    toc = VERSION.sub("## Version: " + version, toc)
    destination = Path(output)
    destination.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in paths:
            data = toc.encode("utf-8") if path == TOC else (addon / path).read_bytes()
            info = zipfile.ZipInfo("CraftAtlas/" + path, (2020, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            archive.writestr(info, data)
    with zipfile.ZipFile(destination) as archive:
        expected = {"CraftAtlas/" + name for name in paths}
        if set(archive.namelist()) != expected or archive.testzip():
            raise ValueError("Archive verification failed")
    return destination


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bump", choices=("patch", "minor", "major"))
    parser.add_argument("--tags-file", type=Path)
    parser.add_argument("--version")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.bump:
        if not args.tags_file or args.version or args.output:
            parser.error("--bump requires --tags-file, without --version/--output")
        print(next_version(args.tags_file.read_text().splitlines(), args.bump))
    elif args.version and args.output and not args.tags_file:
        print(package(args.version, args.output))
    else:
        parser.error("Use --bump and --tags-file OR --version and --output")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, zipfile.BadZipFile) as exc:
        sys.exit(str(exc))
