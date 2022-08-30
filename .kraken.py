# ::requirements kraken-std>=0.3.3 kraken-core>=0.8.11 jinja2

from __future__ import annotations
import os
import re
import time
from functools import lru_cache
from pathlib import Path
from kraken.core import Project, Task
from kraken.core.util.helpers import not_none
from kraken.core.lib.render_file_task import render_file
from kraken.std.docker import build_docker_image, manifest_tool
from kraken.std.git.version import git_describe, GitVersion

project = Project.current()
version = GitVersion.parse(git_describe(project.directory)).format(dirty=False)
image_prefix = "ghcr.io/kraken-build/kraken-base-image"
platforms = ["linux/arm64", "linux/amd64"]
python_versions = ["3.6.15", "3.7.13", "3.8.13", "3.9.12", "3.10.4", "3.11-dev"]
global_python_version = "3.10.4"
sccache_arch = {
    "linux/arm64": "aarch64",
    "linux/amd64": "x86_64",
}


@lru_cache()
def get_docker_auth() -> dict[str, tuple[str, str]]:
    username, password = os.getenv("GITHUB_USER"), os.getenv("GITHUB_PASSWORD")
    if username and password:
        return {"ghcr.io": (username, password)}
    if "CI" in os.environ:
        raise Exception("GITHUB_USER/GITHUB_PASSWORD are required in CI")
    return {}


def build_python_image(platform: str, version: str) -> tuple[Task, str]:
    prefix = f"{image_prefix}/python/{platform}"
    tag = f"{prefix}:{version}"
    task = build_docker_image(
        name=f"docker-python-image-{version}-{platform}",
        backend="buildx",
        dockerfile="docker/build-python.Dockerfile",
        auth=get_docker_auth(),
        tags=[tag],
        platform=platform,
        build_args={"PYTHON_VERSION": version},
        cache_repo=f"{prefix}:cache-{version}",
        push=True,
    )
    return task, tag


def build_kraken_image(platform: str, python_versions: list[str]) -> tuple[Task, list[str]]:

    # Produce the builds for the Python versions and the code to copy the Python versions
    # into the kraken-base-image.
    python_tasks = []
    copy_code = []
    pyenv_code = []
    for python_version in python_versions:
        python_version_major = not_none(re.match(r"\d+\.\d+", python_version)).group(0)
        task, tag = build_python_image(platform, python_version)
        python_tasks.append(task)

        # Copy the Pyenv folder from the image that compiled the given Python version.
        copy_code.append(f"COPY --from={tag} /root/.pyenv /root/.pyenv")

        # NOTE (@NiklasRosenstein): It seems we don't need to manually create links for minor Python versions,
        #       they already exist in the Pyenv shims folder.
        # pyenv_code.append(f"pyenv global {python_version}")
        # pyenv_code.append(
        #     f"ln -s $(python -c 'import sys; print(sys.executable)') /usr/local/bin/python{python_version_major}"
        # )

        # Create a symlink for the minor Python version, allowing to use `pyenv global 3.x` instead of also specifying
        # the patch version.
        pyenv_code.append(f"ln -s /root/.pyenv/versions/{python_version} /root/.pyenv/versions/{python_version_major}")

    # Set the default Python version.
    pyenv_code.append(f"pyenv global {global_python_version} " + " ".join(set(python_versions) - {global_python_version}))

    docker_code = "\n".join(copy_code) + "\n"
    docker_code += "RUN " + " \\\n    && ".join([":"] + pyenv_code) + "\n"

    # Insert the code to copy the Python versions into the Dockerfile.
    render = render_file(
        name=f"render-kraken-image-Dockerfile-{platform}",
        create_check=False,
        group=None,
        file=project.build_directory / f"kraken-base-image-{platform.replace('/', '-')}.Dockerfile",
        content=Path("docker/kraken-base-image.Dockerfile").read_text().replace("# PYTHON_VERSIONS_HERE", docker_code),
    )[0]

    prefix = f"{image_prefix}/{platform}"
    tags = [f"{prefix}:{tag}" for tag in (version, "develop")]
    task = build_docker_image(
        name=f"docker-kraken-image-{platform}",
        backend="buildx",
        dockerfile=render.file,
        auth=get_docker_auth(),
        tags=tags,
        platform=platform,
        build_args={
            "CACHE_BUSTER": str(time.time()),
            "ARCH": platform.split("/")[1],
            "SCCACHE_ARCH": sccache_arch[platform],
        },
        cache_repo=f"{prefix}:cache",
        push=True,
    )

    for python_task in python_tasks:
        task.add_relationship(python_task)

    return task, tags


build_tasks = [build_kraken_image(platform, python_versions) for platform in platforms]

for idx, tag in enumerate(build_tasks[0][1]):
    tag_version = tag.rpartition(":")[-1]
    manifest_tool(
        name=f"docker-kraken-image-multiarch-{tag_version}",
        group="docker-kraken-image-multiarch",
        template=f"{image_prefix}/OS/ARCH:{version}",
        platforms=platforms,
        target=f"{image_prefix}:{tag_version}",
        inputs=[task for task, _tags in build_tasks],
    )
