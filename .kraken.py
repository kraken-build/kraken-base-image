# ::requirements kraken-std jinja2

import os
import time
import jinja2
import sys
from kraken.api import project
from kraken.std.generic.render_file import RenderFileTask
from kraken.std.docker import build_docker_image


def render_dockerfile() -> str:
    sys.path.append(str(project.directory / "build-support"))
    from pyenv_docker import render_pyenv_dockerfile

    jinja_env = jinja2.Environment(loader=jinja2.FileSystemLoader(project.directory))
    jinja_env.globals["pyenv"] = render_pyenv_dockerfile
    template = jinja_env.get_template("Dockerfile.template")
    return template.render()


def docker_config(dockerfile: RenderFileTask) -> None:
    image = "ghcr.io/kraken-build/kraken-base-image"
    tag = "develop"
    auth = {}

    cache_repo: str | None = None
    load: bool = True
    username, password = os.getenv("GITHUB_USER"), os.getenv("GITHUB_PASSWORD")
    if username and password:
        auth["ghcr.io"] = (username, password)
        load = False
        cache_repo = f"{image}:cache"
    else:
        load = True

    build_docker_image(
        backend="kaniko",
        dockerfile=dockerfile.file,
        tags=[f"{image}:{tag}"],
        build_args={"CACHE_BUSTER": str(time.time())},
        cache_repo=cache_repo,
        cache=False,
        auth=auth,
        load=load,
    )


dockerfile = project.do(
    "renderDockerfile",
    RenderFileTask,
    file=project.build_directory / "Dockerfile",
    content=render_dockerfile,
)


docker_config(dockerfile)
