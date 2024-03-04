
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ARG BASE_IMAGE

ENV DEBIAN_FRONTEND noninteractive
RUN : \
    && apt-get update \
    && apt-get install -y curl git wget libssl-dev libffi-dev llvm clang gcc g++ pkg-config build-essential jq sudo cloud-utils qemu-utils qemu-kvm qemu-system-x86-64 qemu-system-aarch64 \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# Install Python versions with deadsnakes.
SHELL [ "/bin/bash", "-c" ]
RUN : \
    && set -x \
    && apt-get update \
    && apt-get install -y software-properties-common --no-install-recommends \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt update \
    && apt-get install -y python{3.8,3.9,3.10,3.11,3.12}{,-venv,-dev} --no-install-recommends \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

RUN : \
    # Install Pip for all other Python versions.
    && set -x \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.8 - \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9 - \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 - \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 - \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 - \
    # Install Python 3.10 as the default version.
    && ln -svf $(which python3.10) /usr/bin/python \
    && ln -svf $(which python3.10) /usr/bin/python3

ENV PATH="$PATH:/root/.cargo/bin:/root/.local/bin"

COPY formulae /tmp/formulae
COPY src /tmp/src
RUN : \
    #
    # install from custom formulae
    #
    && python /tmp/src/main.py /tmp/formulae/buildkit.py \
    && python /tmp/src/main.py /tmp/formulae/grcov.py \
    && python /tmp/src/main.py /tmp/formulae/kubectl.py \
    && python /tmp/src/main.py /tmp/formulae/manifest-tool.py \
    && python /tmp/src/main.py /tmp/formulae/protobuf-compiler.py \
    && python /tmp/src/main.py /tmp/formulae/sccache.py \
    && python /tmp/src/main.py /tmp/formulae/terraform.py \
    && python /tmp/src/main.py /tmp/formulae/yq.py \
    #
    # more APT packages
    #
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update \
    && apt-get install -y docker.io nodejs graphviz unzip lcov git-lfs \
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
    && rm -r /tmp/src /tmp/formulae \
    && rm -rf ~/.cache /var/cache/apt/archives /var/lib/apt/lists/*

#
# docker-buildx
#
COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx

#
# Rust tools
#
ARG ACTIONS_CACHE_URL
RUN --mount=type=secret,id=ACTIONS_RUNTIME_TOKEN : \
    && rustup toolchain install 1.75.0 \
    && rustup toolchain install nightly --component rustfmt \
    && rustup default 1.75.0 \
    #&& ( \
    #    SCCACHE_GHA_ENABLED=true \
    #    ACTIONS_CACHE_URL=$ACTIONS_CACHE_URL \
    #    ACTIONS_RUNTIME_TOKEN=$(cat /run/secrets/ACTIONS_RUNTIME_TOKEN) \
    #    sccache --start-server \
    #) \
    && sccache --start-server \
    && export RUSTC_WRAPPER=sccache CARGO_INCREMENTAL=0 \
    && cargo install cargo-deny --version 0.14.3 \
    && cargo install cargo-semver-checks --version 0.26.0 \
    && cargo install sqlx-cli --version 0.7.3 \
    && cargo install cargo-llvm-cov --version 0.5.39 \
    && cargo install cargo-hack --version 0.6.15 \
    && cargo install buffrs --version 0.8.0 \
    && sccache --stop-server

#
# Buf
#
RUN : \
    && BIN="/usr/bin"  \
    && VERSION="1.17.0"  \
    && curl -sSL \
    "https://github.com/bufbuild/buf/releases/download/v${VERSION}/buf-$(uname -s)-$(uname -m)" \
    -o "${BIN}/buf" && \
    chmod +x "${BIN}/buf"

#
# Python tools
#
RUN : \
    && python -m pip install pipx==1.3.3 -v \
    && pipx install poetry==1.7.1 \
    && pipx install pdm==2.12.1 \
    && pipx install slap-cli==1.12.0 \
    && pipx install kraken-wrapper==0.34.1 \
    && pipx install uv==0.1.1 \
    && pipx install ansible-base==2.10.17 && pipx inject ansible-base ansible==9.2.0 \
    && rm -rf ~/.cache/pip

#
# Nix
#
RUN : \
    && sh <(curl -L https://nixos.org/nix/install) --daemon \
    && echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf \
    && echo "max-jobs = auto" >> /etc/nix/nix.conf
