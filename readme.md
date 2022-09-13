# kraken-base-image

  [pkg]: https://github.com/kraken-build/kraken-base-image/pkgs/container/kraken-base-image

The [`kraken-base-image`][pkg] provides a Docker image for AMD64 and ARM64 platforms that comes pre-bundled with
a lot of different common programming language runtimes and toolchains, intended to be used as a runtime
image for continuous integration pipelines. The image is currently base on `ubuntu:focal`.

    $ docker pull ghcr.io/kraken-build/kraken-base-image:develop

## Versioning

Aside from the `develop` tag, exact image versions can be pinned based on `git tag --describe`.

## Image contents

| Software | Installed via | Version |
| -------- | ------------- | ------- |
| cmake | apt-get | latest |
| cURL | apt-get | latest |
| Docker | apt-get (`docker.io` package) | latest |
| Docker Buildx | DockerHub | latest |
| Git | apt-get | latest |
| GraphViz | apt-get | latest |
| grcov | [GitHub releases](https://github.com/mozilla/grcov/releases) | 0.8.11 |
| Helm | get-helm-3 | latest |
| kraken-wrapper | Pipx (3.10.4) | latest |
| Kubectl | apt-get (`apt.kubernetes.io`) | latest |
| lcov | apt-get | latest
| libffi | apt-get | latest |
| libssl | apt-get | latest |
| llvm | apt-get | latest |
| manifest-tool | [Releases](https://github.com/estesp/manifest-tool/releases) | 2.0.4 |
| NodeJS | apt-get (`deb.nodesource.com/setup_18.x`) | latest (18) |
| Pipx | Pip (3.10.4) | latest |
| pkg-config | apt-get | latest |
| Poetry | Pipx (3.10.4) | latest |
| protobuf-compiler | [GitHub releases](https://github.com/protocolbuffers/protobuf/releases) | 3.15.1 |
| proxy.py | Pipx (3.10.4) | latest |
| pyenv | [pyenv-installer](https://github.com/pyenv/pyenv-installer) | latest |
| Python | Pyenv | 3.6.15, 3.7.13, 3.8.13, 3.9.12, 3.10.4 <sup>default</sup>, 3.11-dev |
| Rust | Rustup | latest |
| Rustup | rustup.rs | latest |
| sccache | [Github releases](https://github.com/mozilla/sccache/releases) | 0.3.0 |
| Slap ([link](https://github.com/python-slap/slap-cli)) | Pipx (3.10.4) | `>= 1.6.27` |
| wget | apt-get | latest |
