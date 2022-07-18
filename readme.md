# kraken

This repository, despite the name, does not contain the main components for the Kraken build system. Instead, it
provides tools to _use_ Kraken. Currently, these tools are just one Docker image that contains all kinds of software
that may be required to successfully build projects with Kraken, such as multiple Python versions, Rust, Docker, etc.

## Docker image

The Docker image provided by this repository is accessible under `ghcr.io/kraken-build/kraken-base-image`. No `:latest`
tag is published, instead consumers should pin the exact image version according to Git tags in this repository.

The image is currently built for `linux/amd64` and `linux/arm64`. It contains the following software:

* Starting from `ubuntu:focal`
* [x] curl, Git, oppenssh-client, wget, xdd, cmake, pyenv
* [x] Python 3.6.15, 3.7.13, 3.8.13, 3.9.12, 3.10.4 and 3.11-dev installed via pyenv (default: 3.10.4)
* [x] NodeJS 18
* [x] Docker (installed via `docker.io` package)
* [x] Rustup and Rust
* [x] Pipx, Poetry, [Slap][]
* [ ] Kubectl, Helm, manifest-tool

[Slap]: https://github.com/python-slap/slap-cli
