#!/usr/bin/env python

import builtins
import dataclasses
import io
import re
import textwrap
from functools import partial


@dataclasses.dataclass
class PyenvDockerfileGenerator:
    result_stage: str
    source_stage: str
    python_versions: list[str]
    default_python_version: str
    temp_stage_prefix: str = "pyenv-template"

    def generate(self) -> str:
        if self.default_python_version not in self.python_versions:
            raise RuntimeError("default_python_version must appear in python_versions")

        fp = io.StringIO()
        print = partial(builtins.print, file=fp)
        print(
            textwrap.dedent(
                f"""
                FROM {self.source_stage} as {self.temp_stage_prefix}-base
                ENV DEBIAN_FRONTEND noninteractive
                RUN apt-get update && apt-get install -y curl git openssh-client \\
                    build-essential libssl-dev zlib1g-dev libbz2-dev \\
                    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \\
                    xz-utils tk-dev libffi-dev liblzma-dev
                ENV PYENV_ROOT /root/.pyenv
                ENV PATH $PATH:$PYENV_ROOT/shims:$PYENV_ROOT/bin
                RUN curl https://pyenv.run | bash
                """
            ).strip()
        )

        stages = []
        for version in self.python_versions:
            minor_version = re.match(r"\d+\.\d+", version).group(0)
            stage_name = self.temp_stage_prefix + version.replace(".", "_").replace("-", "_")
            # NOTE (@NiklasRosenstein): We remove the test/ and config.../ directory as they are quite large
            #       and are not needed usually at runtime.
            print(
                textwrap.dedent(
                    f"""
                    # FROM {self.temp_stage_prefix}-base as {stage_name}
                    RUN : \\
                        && pyenv install --verbose {version} \\
                        # Remove elements from the standard library that are not needed at runtime but are very large.
                        && rm -r /root/.pyenv/versions/{version}/lib/python{minor_version}/test/ \\
                        && rm -r /root/.pyenv/versions/{version}/lib/python{minor_version}/config-{minor_version}*/ \\
                        # Upgrade Pip
                        && pyenv global {version} \\
                        && python --version \\
                        && python -m pip install --upgrade pip \\
                        # Create a minor version shim.
                        && ln -s $(python -c 'import sys; print(sys.executable)') /usr/local/bin/python{minor_version}
                    """
                ).strip()
            )
            stages.append(stage_name)

        print(f"FROM {self.temp_stage_prefix}-base as {self.result_stage}")
        # for stage_name in stages:
        #     print(f"COPY --from={stage_name} $PYENV_ROOT $PYENV_ROOT")
        print("RUN pyenv update")
        print(f"RUN pyenv global {self.default_python_version}")

        return fp.getvalue()


def render_pyenv_dockerfile(from_: str, as_: str, versions: list[str], default_version: str) -> str:
    generator = PyenvDockerfileGenerator(
        result_stage=as_,
        source_stage=from_,
        python_versions=versions,
        default_python_version=default_version,
    )
    return generator.generate()
