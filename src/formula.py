from __future__ import annotations

import argparse
import contextlib
import functools
import io
import logging
import operator
import os
import platform
import shutil
import stat
import string
import sys
import tarfile
import urllib.request
import zipfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any, BinaryIO, Iterator, Mapping, Sequence

logger = logging.getLogger(__name__)


def chmod_mode_update(mode: int, modstring: str) -> int:
    """Modifies the stat mode according to *modstring*, mirroring the syntax for POSIX `chmod`."""

    mapping = {
        "r": (stat.S_IRUSR, stat.S_IRGRP, stat.S_IROTH),
        "w": (stat.S_IWUSR, stat.S_IWGRP, stat.S_IWOTH),
        "x": (stat.S_IXUSR, stat.S_IXGRP, stat.S_IXOTH),
    }

    target, direction = "a", None
    for c in modstring:
        if c in "+-":
            direction = c
            continue
        if c in "ugoa":
            target = c
            direction = None  # Need a - or + after group specifier.
            continue
        if c in "rwx" and direction and direction in "+-":
            if target == "a":
                mask = functools.reduce(operator.or_, mapping[c])
            else:
                mask = mapping[c]["ugo".index(target)]
            if direction == "-":
                mode &= ~mask
            else:
                mode |= mask
            continue
        raise ValueError("invalid chmod: {!r}".format(modstring))

    return mode


class Context:
    def __init__(self) -> None:
        arch = platform.machine()
        self.vars = {
            "platform": sys.platform,
            "arch": arch,
            "archv1": {"aarch64": "aarch64", "x86_64": "x86_64", "amd64": "x86_64", "arm64": "aarch64"}[arch],
            "archv2": {"aarch64": "arm64", "x86_64": "amd64", "amd64": "amd64", "arm64": "arm64"}[arch],
        }


class Formula:
    """Base class for formulas that can install software components into a system. Inspired by Homebrew."""

    def __init__(self, context: Context) -> None:
        self._context = context

    def _eval(self, template: str, visited: set[str] | None = None) -> str:
        """Evaluate a template string with variable references of the form `${varname}`."""

        if visited is None:
            visited = set()

        class _Mapping(Mapping[str, str]):
            def __len__(self) -> int:
                raise NotImplementedError

            def __iter__(self) -> Iterator[str]:
                raise NotImplementedError

            def __getitem__(_self, key: str) -> str:
                if key in visited:
                    raise RuntimeError(f"recursive template at key {key!r}")
                if hasattr(self, key):
                    value = getattr(self, key)
                    if isinstance(value, str):
                        assert visited is not None
                        return self._eval(value, visited | {key})
                    return str(value)
                if key in self._context.vars:
                    return self._context.vars[key]
                raise KeyError(key)

        return string.Template(template).substitute(_Mapping())

    def _eval_member(self, name: str) -> str:
        return self._eval(getattr(self, name), {name})

    def log(self, msg: str, *args: Any) -> None:
        logger.info("[%s] " + msg, type(self).__name__, *args)

    def chmod(self, op: str, filename: str) -> None:
        path = Path(self._eval(filename))
        self.log('chmod %s "%s"', op, path)
        path.chmod(chmod_mode_update(path.stat().st_mode, op))

    def install(self) -> None:
        raise NotImplementedError

    def finalize(self) -> None:
        pass


class BinaryInstallFormula(Formula):

    archive_type: str | None = None
    archive_url: str
    archive_members: Sequence[str] | Mapping[str, str]
    install_to: str

    @contextlib.contextmanager
    def _read_archive(self, filename: str, fp: BinaryIO) -> Iterator[Archive]:
        if self.archive_type is None:
            archive_type = "zip" if filename.endswith(".zip") else "tar"
        else:
            archive_type = self.archive_type
        if archive_type == "zip":
            yield ZipArchive(io.BytesIO(fp.read()))
        elif archive_type == "tar":
            yield TarArchive(io.BytesIO(fp.read()))
        else:
            raise ValueError(f"invalid archive type: {archive_type!r}")

    # Formula

    def install(self) -> None:
        archive_url = self._eval_member("archive_url")
        install_to = self._eval_member("install_to")

        if isinstance(self.archive_members, Sequence):
            archive_members = {x: os.path.basename(x) for x in (self._eval(x) for x in self.archive_members)}
        else:
            archive_members = {self._eval(k): self._eval(v) for k, v in self.archive_members.items()}

        self.log('fetching archive from url "%s"', archive_url)
        with urllib.request.urlopen(archive_url) as response, self._read_archive(archive_url, response) as archive:
            for archive_member, output_filename in archive_members.items():
                output_path = Path(install_to) / output_filename
                output_path.parent.mkdir(parents=True, exist_ok=True)
                self.log('extracting "%s" to "%s"', archive_member, output_path)
                src, info = archive.get_member(archive_member)
                with src, output_path.open("wb") as dst:
                    shutil.copyfileobj(src, dst)
                output_path.chmod(info.mode)


@dataclass
class ArchiveMemberInfo:
    mode: int


class Archive:
    def get_member(self, name: str) -> tuple[BinaryIO, ArchiveMemberInfo]:
        pass


class TarArchive(Archive):
    def __init__(self, fp: BinaryIO | Path) -> None:
        self._tf = tarfile.open(
            fileobj=None if isinstance(fp, Path) else fp,
            name=fp if isinstance(fp, Path) else None,
            mode="r",
        )

    # Archive

    def get_member(self, name: str) -> tuple[BinaryIO, ArchiveMemberInfo]:
        info = self._tf.getmember(name)
        fp = self._tf.extractfile(info)
        if fp is None:
            raise ValueError(f"no member named {name!r}")
        return fp, ArchiveMemberInfo(mode=info.mode)


class ZipArchive(Archive):
    def __init__(self, fp: BinaryIO | Path) -> None:
        self._zip = zipfile.ZipFile(fp, mode="r")

    # Archive

    def get_member(self, name: str) -> tuple[BinaryIO, ArchiveMemberInfo]:
        info = self._zip.getinfo(name)
        attr = info.external_attr >> 16
        return self._zip.open(info), ArchiveMemberInfo(mode=attr)
