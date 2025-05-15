# kraken-base-image

  [pkg]: https://github.com/kraken-build/kraken-base-image/pkgs/container/kraken-base-image

The [`kraken-base-image`][pkg] provides a Docker image for AMD64 and ARM64 platforms that comes pre-bundled with
a lot of different common programming language runtimes and toolchains, intended to be used as a runtime
image for continuous integration pipelines. The image is currently base on `ubuntu:20.04`.

    $ docker pull ghcr.io/kraken-build/kraken-base-image:develop

## Versioning

Aside from the `develop` tag, exact image versions can be pinned based on `git tag --describe`. The Kraken base image
is built from various Ubuntu starting images. We use semantic versioning in the form of `x.y.z` and `x.y` tags.

| Starting Image | Kraken base image tags                                                                      | Notes |
|----------------|---------------------------------------------------------------------------------------------|-------|
| `ubuntu:22.04` | `develop-ubuntu_22.04`, `x.y.z-ubuntu_22.04`, `x.y-ubuntu_22.04`                            |       |
| `ubuntu:24.04` | `develop`, `x.y.z`, `x.y`, `develop-ubuntu_24.04`, `x.y.z-ubuntu_24.04`, `x.y-ubuntu_24.04` |       |

### Versioning rules

New versions of the base image must adhere to the [Semantic Versioning](https://semver.org/) scheme. Any upgraded software
that is no longer backwards compatible must be released as a minor version upgrade (we use major version 0). This is to prevent
(non backwards-compatible) software ugprades from blocking the release of backwards compatible upgrades or hotfixes.

Only when absolutely necessary, we introduce a branch for hot fixing older versions,. such as `0.17.x` to release versions of
the base image in that minor version range besides a higher minor having already been released.

## Image contents

### General tools

| Software                               | Installed via                                                                                   | Version |
|----------------------------------------|-------------------------------------------------------------------------------------------------|---------|
| ansible                                | Pipx                                                                                            | 11.5.0  |
| build-essential                        | apt-get                                                                                         | latest  |
| BuildKit                               | GitHub Releases                                                                                 | 0.15.1  |
| clang                                  | apt-get                                                                                         | latest  |
| cloud-utils                            | apt-get                                                                                         | latest  |
| cURL                                   | apt-get                                                                                         | latest  |
| Git                                    | apt-get                                                                                         | latest  |
| Git LFS                                | apt-get                                                                                         | latest  |
| GraphViz                               | apt-get                                                                                         | latest  |
| jq                                     | apt-get                                                                                         | latest  |
| kraken-wrapper                         | uv                                                                                              | 0.43.0  |
| libffi                                 | apt-get                                                                                         | latest  |
| libssl                                 | apt-get                                                                                         | latest  |
| openssh-client                         | apt-get                                                                                         | latest  |
| pkg-config                             | apt-get                                                                                         | latest  |
| QEMU (kvm, x86_64, aarch64)            | apt-get                                                                                         | latest  |
| sccache                                | [GitHub releases](https://github.com/mozilla/sccache/releases) ([formula](formulae/sccache.py)) | 0.10.0  |
| sqlx-cli                               | cargo                                                                                           | 0.8.5   |
| [UPX](https://upx.github.io/)          | apt-get                                                                                         | latest  |
| wget                                   | apt-get                                                                                         | latest  |
| [yq](https://mikefarah.gitbook.io/yq/) | [GitHub releases](https://github.com/mikefarah/yq/releases)                                     | 4.44.3  |

### Language runtimese and tools

| Software                                               | Installed via                                                                                                      | Version                                             |
|--------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|
| buf                                                    | [GitHub releases](https://github.com/bufbuild/buf/releases)                                                        | 1.35.1                                              |
| buffrs                                                 | cargo                                                                                                              | 0.10.0                                              |
| cargo-deny                                             | cargo                                                                                                              | 0.18.2                                              |
| cargo-hack                                             | cargo                                                                                                              | 0.6.36                                              |
| cargo-llvm-cov                                         | cargo                                                                                                              | 0.6.16                                              |
| cargo-semver-checks                                    | cargo                                                                                                              | 0.41.0                                              |
| cmake                                                  | apt-get                                                                                                            | latest                                              |
| gcc, g++                                               | apt-get                                                                                                            | latest                                              |
| grcov                                                  | [GitHub releases](https://github.com/mozilla/grcov/releases) ([formula](formulae/grcov.py))                        | 0.8.19                                              |
| lcov                                                   | apt-get                                                                                                            | latest                                              |
| llvm                                                   | apt-get                                                                                                            | latest                                              |
| Nix                                                    | `https://nixos.org/nix/install`                                                                                    | latest                                              |
| NodeJS                                                 | apt-get (via [nodesource install](https://github.com/nodesource/distributions#debinstall))                         | 18                                                  |
| PDM                                                    | uv (Python 3.12)                                                                                                   | 2.24.1                                              |
| Pipx                                                   | uv                                                                                                                 | 1.6.0                                               |
| Poetry                                                 | uv                                                                                                                 | 2.1.3                                               |
| protobuf-compiler                                      | [GitHub releases](https://github.com/protocolbuffers/protobuf/releases) ([formula](formulae/protobuf-compiler.py)) | 3.20.3                                              |
| Python                                                 | `uv python install`                                                                                                | 3.8, 3.9, 3.10, 3.11, 3.12 <sup>default</sup>, 3.13 |
| Rust / Cargo                                           | Rustup                                                                                                             | 1.86.0                                              |
| rustfmt                                                | rustup                                                                                                             | nightly (additionally)                              |
| Rustup                                                 | rustup.rs                                                                                                          | latest                                              |
| Slap ([link](https://github.com/python-slap/slap-cli)) | uv                                                                                                                 | 1.15.0                                              |
| Terraform                                              | Hashicorp releases                                                                                                 | 1.9.3                                               |
| [uv](https://astral.sh/blog/uv)                        | docker.io                                                                                                          | 0.7.3                                               |

### Container tools

| Software      | Installed via                                                                                              | Version |
|---------------|------------------------------------------------------------------------------------------------------------|---------|
| Docker        | apt-get (`docker.io` package)                                                                              | latest  |
| Docker Buildx | DockerHub                                                                                                  | latest  |
| manifest-tool | [GitHub releases](https://github.com/estesp/manifest-tool/releases) ([formula](formulae/manifest-tool.py)) | 2.1.7   |

### Kubernetes

| Software                                | Installed via                                                                                 | Version |
|-----------------------------------------|-----------------------------------------------------------------------------------------------|---------|
| argocd (CLI)                            | [GitHub releases](https://github.com/argoproj/argo-cd/releases)                               | 2.12.0  |
| conntrack                               | apt-get                                                                                       | latest  |
| ContainerNetworkingPlugins (CNI)        | [GitHub releases](https://github.com/containernetworking/plugins/releases)                    | 1.5.1   |
| cri-dockerd                             | [GitHub releases](https://github.com/Mirantis/cri-dockerd/releases)                           | 0.3.14  |
| crictl                                  | [GitHub releases](https://github.com/kubernetes-sigs/cri-tools/releases)                      | 1.30.1  |
| Helm                                    | get-helm-3                                                                                    | latest  |
| kubectl                                 | apt-get (`apt.kubernetes.io`)                                                                 | 1.30.3  |
| minikube                                | `storage.googleapis.com/minikube/releases` ([docs](https://minikube.sigs.k8s.io/docs/start/)) | 1.33.1  |
| [stern](https://github.com/stern/stern) | [GitHub releases](https://github.com/stern/stern/releases/)                                   | 1.30.0  |
