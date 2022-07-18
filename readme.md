# kraken-base-image

This repository provides a Docker image with the latest `kraken-cli` and loads of common programming language
runtimes and toolchains for effectively executing project builds with Kraken.

## Platforms

Currently, the image is only available for `linux/amd64`. This is because compiling Python on `linux/arm64` via
QEMU is impossibly slow on GitHub actions and I have yet to see it complete successfully.

## Overview

| Software | Installed via | Version |
| -------- | ------------- | ------- |
| cmake | apt-get | latest |
| cURL | apt-get | latest |
| Docker | apt-get (`docker.io` package) | latest |
| Docker Buildx | DockerHub | latest |
| Git | apt-get | latest |
| Helm | get-helm-3 | latest |
| Kubectl | apt-get (`apt.kubernetes.io`) | latest |
| manifest-tool | n/a | |
| NodeJS | apt-get (`deb.nodesource.com/setup_18.x`) | latest (18) |
| Pipx | Pip | latest |
| pyenv | [pyenv-installer](https://github.com/pyenv/pyenv-installer) | latest |
| Python | Pyenv | 3.6.15, 3.7.13, 3.8.13, 3.9.12, 3.10.4 <sup>default</sup>, 3.11-dev |
| Rust | Rustup | latest |
| Rustup | rustup.rs | latest |
| Slap ([link](https://github.com/python-slap/slap-cli)) | Pip | latest |
| wget | apt-get | latest |
| Kraken CLI | Pip | latest |
