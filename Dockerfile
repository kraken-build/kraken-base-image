
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ARG BASE_IMAGE
SHELL [ "/bin/bash", "-c" ]

RUN : \
    && set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt update \
    && apt-get install -y git wget libssl-dev libffi-dev llvm clang gcc g++ pkg-config build-essential jq sudo software-properties-common graphviz unzip lcov git-lfs docker.io nodejs xxd cmake --no-install-recommends \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt update \
    && apt-get install -y python{3.8,3.9,3.10,3.11,3.12}{,-venv,-dev} --no-install-recommends \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# Install docker-buildx
COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx

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

# Nix
RUN : \
    && sh <(curl -L https://nixos.org/nix/install) --daemon \
    && echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf \
    && echo "max-jobs = auto" >> /etc/nix/nix.conf

# Setup the main user which can run apt-get.
RUN useradd -m -s /bin/bash -G sudo,root -u 1000 main
RUN echo "main ALL=NOPASSWD: $(which apt-get)" >> /etc/sudoers
RUN chown main:main -R /usr/local /opt
USER main

# Point CARGO_HOME and PIPX_HOME outside of the home directory as that may get overridden with a mount.
ENV CARGO_HOME=/opt/cargo
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
ENV PIPX_MAN_DIR=/usr/local/share/man
ENV PATH="$PATH:/$CARGO_HOME/bin"

# At runtime many tools install to $HOME/.local/bin, but we don't as home may get overriden.
ENV PATH="$PATH:/$HOME/.local/bin"

RUN --mount=bind,src=formulae,target=/tmp/formulae \
    --mount=bind,src=formulae,target=/tmp/src : \
    && set -x \
    && python /tmp/src/main.py /tmp/formulae/buf.py \
    && python /tmp/src/main.py /tmp/formulae/buildkit.py \
    && python /tmp/src/main.py /tmp/formulae/grcov.py \
    && python /tmp/src/main.py /tmp/formulae/kubectl.py \
    && python /tmp/src/main.py /tmp/formulae/manifest-tool.py \
    && python /tmp/src/main.py /tmp/formulae/protobuf-compiler.py \
    && python /tmp/src/main.py /tmp/formulae/sccache.py \
    && python /tmp/src/main.py /tmp/formulae/terraform.py \
    && python /tmp/src/main.py /tmp/formulae/yq.py \
    && ( curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash ) \
    && ( curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y )

# Rust tools, build with sccache and GHA cache to speed up builds.
ARG ACTIONS_CACHE_URL
RUN --mount=type=secret,id=ACTIONS_RUNTIME_TOKEN : \
    && rustup toolchain install 1.75.0 \
    && rustup toolchain install nightly --component rustfmt \
    && rustup default 1.75.0 \
    && ( \
        SCCACHE_GHA_ENABLED=true \
        ACTIONS_CACHE_URL=$ACTIONS_CACHE_URL \
        ACTIONS_RUNTIME_TOKEN=$(cat /run/secrets/ACTIONS_RUNTIME_TOKEN) \
        sccache --start-server \
    ) \
    && export RUSTC_WRAPPER=sccache CARGO_INCREMENTAL=0 \
    && cargo install cargo-deny --version 0.14.3 \
    && cargo install cargo-semver-checks --version 0.26.0 \
    && cargo install sqlx-cli --version 0.7.3 \
    && cargo install cargo-llvm-cov --version 0.5.39 \
    && cargo install cargo-hack --version 0.6.15 \
    && cargo install buffrs --version 0.7.5 \
    && cargo install cargo-cache --version 0.8.3 \
    && sccache --stop-server \
    && cargo cache --autoclean

# Python tools
RUN : \
    && python -m pip install pipx==1.4.3 -v \
    && pipx install poetry==1.7.1 \
    && pipx install pdm==2.12.1 \
    && pipx install slap-cli==1.11.2 \
    && pipx install kraken-wrapper==0.33.1 \
    && pipx install ansible-base==2.10.17 && pipx inject ansible-base ansible==9.1.0 \
    && rm -rf ~/.cache/pip
