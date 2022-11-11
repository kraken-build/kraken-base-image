
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y curl git wget libssl-dev libffi-dev llvm clang gcc g++ pkg-config build-essential

# Install Python versions with deadsnakes.
SHELL [ "/bin/bash", "-c" ]
RUN : \
    && set -x \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt update \
    && apt-get install -y python{3.6,3.7,3.8,3.9,3.10,3.11}{,-venv} \
    && rm -rf ~/.cache /var/cache/apt/archives /var/lib/apt/lists/*

RUN : \
    && set -x \
    && python3.6 --version \
    && python3.7 --version \
    && python3.8 --version \
    && python3.9 --version \
    && python3.10 --version \
    && python3.11 --version \
    && ln -svf $(which python3.10) /usr/bin/python \
    && ln -svf $(which python3.10) /usr/bin/python3 \
    && ln -svf $(which pip3.10) /usr/bin/pip \

# Install Pyenv.
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN curl https://pyenv.run | bash

# Copy Pyenv folders from other images.
# PYTHON_VERSIONS_NOT_HERE  # COMMENTED OUT IN FAVOR OF deadsnakes

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="$PATH:/root/.cargo/bin:/root/.local/bin"

RUN ( curl -fsSL https://deb.nodesource.com/setup_18.x | bash - )

COPY formulae /tmp/formulae
COPY src /tmp/src
RUN : \
    #
    # install from custom formulae
    #
    && python /tmp/src/main.py /tmp/formulae/grcov.py \
    && python /tmp/src/main.py /tmp/formulae/kubectl.py \
    && python /tmp/src/main.py /tmp/formulae/manifest-tool.py \
    && python /tmp/src/main.py /tmp/formulae/protobuf-compiler.py \
    && python /tmp/src/main.py /tmp/formulae/sccache.py \
    && python /tmp/src/main.py /tmp/formulae/terraform.py \
    && rm -r /tmp/src /tmp/formulae \
    #
    # more APT packages
    #
    && apt-get update \
    && apt-get install -y docker.io nodejs graphviz unzip lcov \
    #
    # Rust
    #
    && apt-get install -y xxd cmake \
    && ( curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y ) \
    #
    # helm
    #
    && ( curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash ) \
    #
    # [cleanup]
    #
    && rm -rf ~/.cache /var/cache/apt/archives /var/lib/apt/lists/*

#
# docker-buildx
#
COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx

#
# Python tools
#
RUN : \
    && python -m pip install pipx -v \
    && pipx install poetry==1.2.2 \
    && pipx install slap-cli==1.6.30 \
    && pipx install kraken-wrapper==0.1.22 \
    && pipx install proxy.py==2.4.3 && pipx inject proxy.py certifi \
    && pipx install ansible-base==2.10.17 && pipx inject ansible-base ansible==6.6.0 \
    && rm -rf ~/.cache/pip
