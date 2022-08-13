# ::requirements kraken-std kraken-core>=0.8.11 jinja2

import os
import time
import jinja2
from kraken.core import Supplier, Project
from kraken.lib.render_file_task import RenderFileTask
from kraken.std.docker import build_docker_image, manifest_tool
from kraken.std.git.version import git_describe, GitVersion
from pyenv_docker import render_pyenv_dockerfile

project = Project.current()
version = GitVersion.parse(git_describe(project.directory)).format(dirty=False)


def render_dockerfile() -> str:
    jinja_env = jinja2.Environment(loader=jinja2.FileSystemLoader(project.directory))
    jinja_env.globals["pyenv"] = render_pyenv_dockerfile
    template = jinja_env.get_template("Dockerfile.template")
    return template.render()


def get_docker_auth() -> dict[str, tuple[str, str]]:
    username, password = os.getenv("GITHUB_USER"), os.getenv("GITHUB_PASSWORD")
    if username and password:
        return {"ghcr.io": (username, password)}
    if "CI" in os.environ:
        raise Exception("GITHUB_USER/GITHUB_PASSWORD are required in CI")
    return {}


def docker_config(dockerfile: RenderFileTask, platforms: list[str]) -> None:
    image = "ghcr.io/kraken-build/kraken-base-image"
    tags = [version, "develop"]
    auth = get_docker_auth()
    tasks = []
    for platform in platforms:
        task = build_docker_image(
            name=f"buildDocker-{platform}",
            backend="buildx",
            dockerfile=dockerfile.file,
            auth=auth,
            tags=[f"{image}/{platform}:{tag}" for tag in tags],
            platform=platform,
            build_args={"CACHE_BUSTER": str(time.time()), "ARCH": platform.split("/")[1]},
            cache_repo=f"{image}/cache" if auth else None,
            load=False if auth else True,
            push=True if auth else False,
        )
        tasks.append(task)

    for idx, tag in enumerate(tags):
        manifest_tool(
            name=f"buildDocker-manifestTool{idx}",
            group="buildDocker",
            template=f"{image}/OS/ARCH:{version}",
            platforms=platforms,
            target=f"{image}:{tag}",
            inputs=tasks,
        )


dockerfile = project.do(
    "renderDockerfile",
    RenderFileTask,
    file=project.build_directory / "Dockerfile",
    content=Supplier.of_callable(render_dockerfile),
)

docker_config(dockerfile, ["linux/arm64", "linux/amd64"])
