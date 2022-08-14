
FROM ubuntu:focal

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y curl git wget

# Install Pyenv.
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN curl https://pyenv.run | bash

# Copy Pyenv folders from other images.
# PYTHON_VERSIONS_HERE

ARG ARCH
ARG MANIFEST_TOOL_VERSION=2.0.4
ARG PROTOCOL_BUF_VERSION=3.15.1
ARG SCCACHE_VERSION=0.3.0
ARG SCCACHE_ARCH

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="$PATH:/root/.cargo/bin:/root/.local/bin"

RUN ( curl -fsSL https://deb.nodesource.com/setup_18.x | bash - )

RUN : \
    && apt-get update \
    && apt-get install -y docker.io nodejs graphviz unzip \
    #
    # Rust
    #
    && apt-get install -y xxd cmake \
    && ( curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y ) \
    #
    # sccache
    #
    && curl -qfSL https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-aarch64-unknown-linux-musl.tar.gz \
        | tar xzvf - -C /usr/local/bin sccache-v${SCCACHE_VERSION}-aarch64-unknown-linux-musl/sccache --strip-components 1 \
    #
    # kubectl
    #
    && apt-get install -y apt-transport-https ca-certificates curl \
    && curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update && apt-get install -y kubectl \
    #
    # protobuf-compiler; need to translate `aarch64` to `aarch_64`
    #
    && PROTOC_ARCH=$(uname -i | perl -pe 's/(?<!_)64/_64/') \
    && wget -q https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOCOL_BUF_VERSION/protoc-$PROTOCOL_BUF_VERSION-linux-${PROTOC_ARCH}.zip \
    && unzip -o protoc-$PROTOCOL_BUF_VERSION-linux-${PROTOC_ARCH}.zip -d /usr/local bin/protoc \
    && unzip -o protoc-$PROTOCOL_BUF_VERSION-linux-${PROTOC_ARCH}.zip -d /usr/local 'include/*' \
    && rm protoc-$PROTOCOL_BUF_VERSION-linux-${PROTOC_ARCH}.zip \
    #
    # helm
    #
    && ( curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash ) \
    #
    # manifest-tool
    #
    && wget -q https://github.com/estesp/manifest-tool/releases/download/v${MANIFEST_TOOL_VERSION}/binaries-manifest-tool-${MANIFEST_TOOL_VERSION}.tar.gz \
    && tar -xvf binaries-manifest-tool-${MANIFEST_TOOL_VERSION}.tar.gz -C /usr/local/bin manifest-tool-linux-${ARCH} \
    && chmod +x /usr/local/bin/manifest-tool-linux-${ARCH} \
    && mv /usr/local/bin/manifest-tool-linux-${ARCH} /usr/local/bin/manifest-tool \
    && rm binaries-manifest-tool-${MANIFEST_TOOL_VERSION}.tar.gz \
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
    && pipx install slap-cli \
    && pipx install kraken-wrapper \
    && rm -rf ~/.cache/pip
