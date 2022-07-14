#!/usr/bin/env python

import argparse
import textwrap

parser = argparse.ArgumentParser()
parser.add_argument("--as", dest="as_", required=True)
parser.add_argument("--from", dest="from_", required=True)
parser.add_argument("--versions", required=True)
parser.add_argument("--default", required=True)
parser.add_argument("--prefix", default="pyenv-template")


def main() -> None:
    args = parser.parse_args()
    versions = args.versions.split(",")

    if args.default not in versions:
        parser.error("--default must appear in --versions")

    begin_block = textwrap.dedent(
        f"""
        FROM {args.from_} as {args.prefix}-base
        ENV DEBIAN_FRONTEND noninteractive
        RUN apt update && apt install -y curl git openssh-client \\
            build-essential libssl-dev zlib1g-dev libbz2-dev \\
            libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \\
            xz-utils tk-dev libffi-dev liblzma-dev
        ENV PYENV_ROOT /root/.pyenv
        ENV PATH $PATH:$PYENV_ROOT/shims:$PYENV_ROOT/bin
        RUN curl https://pyenv.run | bash
        """
    ).strip()
    print(begin_block)

    stages = []
    for version in versions:
        stage_name = args.prefix + version.replace(".", "_").replace("-", "_")
        version_block = textwrap.dedent(
            f"""
            FROM {args.prefix}-base as {stage_name}
            RUN pyenv install {version}
            RUN pyenv global {version} && python --version && python -m pip install --upgrade pip
            """
        ).strip()
        print(version_block)
        stages.append(stage_name)

    print(f"FROM {args.prefix}-base as {args.as_}")
    for stage_name in stages:
        print(f"COPY --from={stage_name} $PYENV_ROOT $PYENV_ROOT")
    print("RUN pyenv update")
    print(f"RUN pyenv global {args.default}")


if __name__ == "__main__":
    main()
