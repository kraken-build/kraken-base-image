from __future__ import annotations
from kraken.common import buildscript

buildscript(
    requirements=[
        "kraken-core>=0.11.0",
        "kraken-std>=0.5.0",
        "jinja2",
    ],
)

import os
import time
from functools import lru_cache
from kraken.core import Project, Task
from kraken.std.docker import build_docker_image, manifest_tool
from kraken.std.git.version import git_describe, GitVersion

project = Project.current()
version = GitVersion.parse(git_describe(project.directory)).format(dirty=False)
image_prefix = "ghcr.io/kraken-build/kraken-base-image"
default_base_image = "ubuntu:focal"
base_images = {default_base_image, "ubuntu:bionic", "ubuntu:jammy"}
platforms = ["linux/arm64", "linux/amd64"]


@lru_cache()
def get_docker_auth() -> dict[str, tuple[str, str]]:
    username, password = os.getenv("GITHUB_USER"), os.getenv("GITHUB_PASSWORD")
    if username and password:
        return {"ghcr.io": (username, password)}
    if "CI" in os.environ:
        raise Exception("GITHUB_USER/GITHUB_PASSWORD are required in CI")
    return {}


def build_kraken_image(base_image: str, platform: str) -> tuple[Task, list[str]]:

    if os.getenv("GITHUB_REF") == "refs/heads/develop":
        versions = (version, "develop")
    else:
        versions = (version,)

    prefix = f"{image_prefix}/{platform}"
    tag_prefixes = [f"{prefix}:{tag}" for tag in versions]
    tags = [f"{p}-{base_image.replace(':', '_')}" for p in tag_prefixes]
    if base_image == default_base_image:
        tags += tag_prefixes

    task = build_docker_image(
        name=f"docker-kraken-image/{base_image.replace(':', '_')}/{platform}",
        backend="buildx",
        dockerfile=project.directory / "Dockerfile",
        auth=get_docker_auth(),
        tags=tags,
        platform=platform,
        build_args={"CACHE_BUSTER": str(time.time()), "BASE_IMAGE": base_image},
        cache_repo=f"{prefix}:cache",
        push=True,
        load=False,
    )

    return task, tags


for base_image in base_images:
    build_tasks = [build_kraken_image(base_image, platform) for platform in platforms]

    for idx, tag in enumerate(build_tasks[0][1]):
        tag_version = tag.rpartition(":")[-1]
        manifest_tool(
            name=f"docker-kraken-image-multiarch-{tag_version}/{base_image.replace(':', '_')}",
            group="docker-kraken-image-multiarch",
            template=f"{image_prefix}/OS/ARCH:{version}-{base_image.replace(':', '_')}",
            platforms=platforms,
            target=f"{image_prefix}:{tag_version}",
            inputs=[task for task, _tags in build_tasks],
        )
