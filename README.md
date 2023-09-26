# kraken-base-image

  [pkg]: https://github.com/kraken-build/kraken-base-image/pkgs/container/kraken-base-image

The [`kraken-base-image`][pkg] provides a Docker image for AMD64 and ARM64 platforms that comes pre-bundled with
a lot of different common programming language runtimes and toolchains, intended to be used as a runtime
image for continuous integration pipelines. The image is currently base on `ubuntu:20.04`.

    $ docker pull ghcr.io/kraken-build/kraken-base-image:develop

## Versioning

Aside from the `develop` tag, exact image versions can be pinned based on `git tag --describe`. The Kraken base image
is built from various Ubuntu starting images.

| Starting Image | Kraken base image tags | Notes |
| -------------- | ---------------------- | ----- |
| `ubuntu:18.04` | `develop-ubuntu_18.04`, `x.y.z-ubuntu_18.04` | EOL -- Do not use anymore |
| `ubuntu:20.04` | `develop-ubuntu_20.04`, `x.y.z-ubuntu_20.04`, `x.y-ubuntu_20.04` | |
| `ubuntu:22.04` | `develop`, `x.y.z`, `x.y`, `develop-ubuntu_22.04`, `x.y.z-ubuntu_22.04`, `x.y-ubuntu_22.04` | |

## Image contents

| Software | Installed via | Version |
| -------- | ------------- | ------- |
| ansible | Pipx (Python 3.10) | 8.1.0 |
| ansible-base | Pipx (Python 3.10) | 2.10.17 |
| buf | [GitHub releases](https://github.com/bufbuild/buf/releases) | 1.17.0 |
| buffrs | cargo | 0.6.2 |
| build-essential | apt-get | latest |
| BuildKit | GitHub Releases | 0.12.2 |
| cargo-deny | cargo | latest |
| cargo-llvm-cov | cargo | latest |
| cargo-semver-checks | cargo | latest |
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
| kraken-wrapper | Pipx (Python 3.10) | 0.31.0 |
| Kubectl | apt-get (`apt.kubernetes.io`) | latest |
| lcov | apt-get | latest
| libffi | apt-get | latest |
| libssl | apt-get | latest |
| llvm | apt-get | latest |
| manifest-tool | [GitHub releases](https://github.com/estesp/manifest-tool/releases) ([formula](formulae/manifest-tool.py)) | 2.0.5 |
| NodeJS | apt-get (via [nodesource install](https://github.com/nodesource/distributions#debinstall)) | 16 on `ubuntu:18.04`, 18 elsewhere |
| PDM | Pipx (Python 3.10) | 2.8.2 |
| Pipx | Pip (Python 3.10) | latest |
| pkg-config | apt-get | latest |
| Poetry | Pipx (Python 3.10) | 1.6.0 |
| protobuf-compiler | [GitHub releases](https://github.com/protocolbuffers/protobuf/releases) ([formula](formulae/protobuf-compiler.py)) | 3.20.1 |
| proxy.py | Pipx (Python 3.10) | 2.4.3 |
| pyenv | [pyenv-installer](https://github.com/pyenv/pyenv-installer) | latest |
| Python | [ppa:deadsnakes/ppa](https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa) | 3.6 <sup>1)</sup>, 3.7, 3.8, 3.9, 3.10 <sup>default</sup>, 3.11 |
| Rust | Rustup | latest |
| Rustup | rustup.rs | latest |
| rustfmt | rustup | nightly (additionally) |
| sccache | [GitHub releases](https://github.com/mozilla/sccache/releases) ([formula](formulae/sccache.py)) | 0.5.2 |
| Slap ([link](https://github.com/python-slap/slap-cli)) | Pipx (Python 3.10) | 1.10.2 |
| sqlx-cli | cargo | latest |
| Terraform | Hashicorp releases | 1.3.2 |
| wget | apt-get | latest |
| [yq](https://mikefarah.gitbook.io/yq/) | [GitHub releases](https://github.com/mikefarah/yq/releases) | 4.30.1 |

__Footnotes__

<sup>1)</sup> Python 3.6 is not available on the `ubuntu:22.04` image.
