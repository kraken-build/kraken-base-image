
# ==== Base layers for Pyenv and Python versions.

${{ shell bin/pyenv-dockerfile-generator.py --from ubuntu:focal --as pyenv_all --versions 3.6.15,3.7.13,3.8.13,3.9.12,3.10.4,3.11-dev --default 3.10.4 }}

# == Install additional tools for the final layer.

FROM pyenv_all as final

# Install additional system dependencies.
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y docker.io nodejs

# Install Rust
RUN apt update && apt install -y xxd cmake
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install Pipx, and with it Poetry and Slap.
ENV PATH="$PATH:/root/.local/bin"
RUN python -m pip install --user pipx -v
RUN pipx install poetry
RUN pipx install slap-cli

# Install Kubectl
RUN apt-get install -y apt-transport-https ca-certificates curl
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && apt-get install -y kubectl

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Docker Buildx.
COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx

ARG CACHE_BUSTER
RUN echo "CACHE_BUSTER"

# Install kraken-cli
RUN pipx install kraken-cli
