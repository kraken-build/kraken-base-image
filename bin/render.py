#!/usr/bin/env python

import argparse
import re
import subprocess as sp
from pathlib import Path

REGEX = r"\$\{\{\s*shell\s+(.*?)\}\}"

parser = argparse.ArgumentParser()
parser.add_argument("file", type=Path)


def replace(match: re.Match) -> str:
    return sp.check_output(match.group(1), shell=True).decode()


def main() -> None:
    args = parser.parse_args()
    content = args.file.read_text()
    content = re.sub(REGEX, replace, content)
    print(content)


if __name__ == "__main__":
    main()
