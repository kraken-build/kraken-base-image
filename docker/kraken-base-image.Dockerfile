
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y curl git wget libssl-dev libffi-dev llvm pkg-config

# Install Pyenv.
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN curl https://pyenv.run | bash

# Copy Pyenv folders from other images.
# PYTHON_VERSIONS_HERE

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
    && python /tmp/src/main.py /tmp/formulae/manifest-tool.py \
    && python /tmp/src/main.py /tmp/formulae/protobuf-compiler.py \
    && python /tmp/src/main.py /tmp/formulae/sccache.py \
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
    # kubectl
    #
    && apt-get install -y apt-transport-https ca-certificates curl \
    && curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update && apt-get install -y kubectl \
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
# Pipx, poetry, slap, kraken
#
ARG CACHE_BUSTER
RUN : \
    echo ${CACHE_BUSTER} \
    && python -m pip install --user pipx -v \
    && pipx install poetry \
    && pipx install "slap-cli>=1.6.27" \
    && pipx install kraken-wrapper \
    && pipx install proxy.py \
    && pipx inject proxy.py certifi \
    && rm -rf ~/.cache/pip
