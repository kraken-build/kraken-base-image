# kraken-base-image

  [pkg]: https://github.com/kraken-build/kraken-base-image/pkgs/container/kraken-base-image

The [`kraken-base-image`][pkg] provides a Docker image for AMD64 and ARM64 platforms that comes pre-bundled with
a lot of different common programming language runtimes and toolchains, intended to be used as a runtime
image for continuous integration pipelines. The image is currently base on `ubuntu:focal`.

    $ docker pull ghcr.io/kraken-build/kraken-base-image:develop

## Versioning

Aside from the `develop` tag, exact image versions can be pinned based on `git tag --describe`. The Kraken base image
is built from various Ubuntu starting images.

| Starting Image | Kraken base image tags |
| -------------- | ---------------------- |
| `ubuntu:bionic` | `develop-ubuntu_bionic`, `x.y.z-ubuntu_bionic` |
| `ubuntu:focal` | `develop`, `x.y.z`, `develop-ubuntu_focal`, `x.y.z-ubuntu_focal` |
| `ubuntu:jammy` | `develop-ubuntu_jammy`, `x.y.z-ubuntu_jammy` |

## Image contents

| Software | Installed via | Version |
| -------- | ------------- | ------- |
| ansible | Pipx (Python 3.10) | 6.6.0 |
| ansible-base | Pipx (Python 3.10) | 2.10.17 |
| build-essential | apt-get | latest |
| clang | apt-get | latest |
| cmake | apt-get | latest |
| cURL | apt-get | latest |
| Docker | apt-get (`docker.io` package) | latest |
| Docker Buildx | DockerHub | latest |
| gcc, g++ | apt-get | latest |
| Git | apt-get | latest |
| Git LFS | apt-get | latest |
| GraphViz | apt-get | latest |
| grcov | [GitHub releases](https://github.com/mozilla/grcov/releases) ([formula](formulae/grcov.py)) | 0.8.11 |
| jq | apt-get | latest |
| Helm | get-helm-3 | latest |
| kraken-wrapper | Pipx (Python 3.10) | 0.2.0 |
| Kubectl | apt-get (`apt.kubernetes.io`) | latest |
| lcov | apt-get | latest
| libffi | apt-get | latest |
| libssl | apt-get | latest |
| llvm | apt-get | latest |
| manifest-tool | [Releases](https://github.com/estesp/manifest-tool/releases) ([formula](formulae/manifest-tool.py)) | 2.0.5 |
| NodeJS | apt-get (`deb.nodesource.com/setup_18.x`) | latest (18) |
| Pipx | Pip (Python 3.10) | latest |
| pkg-config | apt-get | latest |
| Poetry | Pipx (Python 3.10) | 1.3.1 |
| protobuf-compiler | [GitHub releases](https://github.com/protocolbuffers/protobuf/releases) ([formula](formulae/protobuf-compiler.py)) | 3.20.1 |
| proxy.py | Pipx (Python 3.10) | 2.4.3 |
| pyenv | [pyenv-installer](https://github.com/pyenv/pyenv-installer) | latest |
| Python | [ppa:deadsnakes/ppa](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa) | 3.6 <sup>1)</sup>, 3.7, 3.8, 3.9, 3.10 <sup>default</sup>, 3.11 |
| Rust | Rustup | latest |
| Rustup | rustup.rs | latest |
| sccache | [Github releases](https://github.com/mozilla/sccache/releases) ([formula](formulae/sccache.py)) | 0.3.0 |
| Slap ([link](https://github.com/python-slap/slap-cli)) | Pipx (Python 3.10) | 1.6.30 |
| Terraform | Hashicorp releases | 1.3.2 |
| wget | apt-get | latest |
| [yq](https://mikefarah.gitbook.io/yq/) | [Github releases](https://github.com/mikefarah/yq/releases) | 4.30.1 |

__Footnotes__

<sup>1)</sup> Python 3.6 is not available on the `ubuntu:jammy` image.
