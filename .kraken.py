# ::requirements kraken-std>=0.3.3 kraken-core>=0.8.11 jinja2

from __future__ import annotations
import os
import time
from functools import lru_cache
from pathlib import Path
from kraken.core import Project, Task
from kraken.lib.render_file_task import render_file
from kraken.std.docker import build_docker_image, manifest_tool
from kraken.std.git.version import git_describe, GitVersion

project = Project.current()
version = GitVersion.parse(git_describe(project.directory)).format(dirty=False)
image_prefix = "ghcr.io/kraken-build/kraken-base-image"
cache_repo = f"{image_prefix}/cache"
platforms = ["linux/arm64", "linux/amd64"]
python_versions = ["3.6.15", "3.7.13", "3.8.13", "3.9.12", "3.10.4", "3.11-dev"]
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
    tag = f"{image_prefix}/python-{version}-{platform}:latest"
    task = build_docker_image(
        name=f"docker-python-image-{version}-{platform}",
        backend="buildx",
        dockerfile="docker/build-python.Dockerfile",
        auth=get_docker_auth(),
        tags=[tag],
        platform=platform,
        build_args={"PYTHON_VERSION": version},
        cache_repo=cache_repo,
        push=True,
    )
    return task, tag


def build_kraken_image(platform: str, python_versions: list[str]) -> tuple[Task, list[str]]:

    # Produce the builds for the Python versions and the code to copy the Python versions
    # into the kraken-base-image.
    copy_code = []
    python_tasks = []
    for python_version in python_versions:
        task, tag = build_python_image(platform, python_version)
        python_tasks.append(task)
        copy_code.append(
            f"COPY --from={tag} /root/.pyenv/versions/{python_version} /root/.pyenv/versions/{python_version}"
        )

    # Insert the code to copy the Python versions into the Dockerfile.
    render = render_file(
        name=f"render-kraken-image-Dockerfile-{platform}",
        create_check=False,
        group=None,
        file=project.build_directory / f"kraken-base-image-{platform.replace('/', '-')}.Dockerfile",
        content=Path("docker/kraken-base-image.Dockerfile")
        .read_text()
        .replace("# PYTHON_VERSIONS_HERE", "\n".join(copy_code)),
    )[0]

    tags = [f"{image_prefix}/{platform}:{tag}" for tag in (version, "develop")]
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
        cache_repo=cache_repo,
        push=True,
    )

    for python_task in python_tasks:
        task.add_relationship(python_task)

    return task, tags


build_tasks = [build_kraken_image(platform, python_versions) for platform in platforms]

for idx, tag in enumerate(build_tasks[0][1]):
    manifest_tool(
        name=f"docker-kraken-image-multiarch-{tag.rpartition(':')[-1]}",
        group="docker-kraken-image-multiarch",
        template=f"{image_prefix}/OS/ARCH:{version}",
        platforms=platforms,
        target=f"{image_prefix}:{tag}",
        inputs=[task for task, _tags in build_tasks],
    )
