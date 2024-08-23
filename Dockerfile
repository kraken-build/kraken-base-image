
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ARG BASE_IMAGE

ENV DEBIAN_FRONTEND noninteractive
RUN : \
    && apt-get update \
    && apt-get install -y curl git wget libssl-dev libffi-dev llvm clang gcc g++ pkg-config build-essential jq sudo openssh-client conntrack cloud-utils qemu-utils qemu-kvm qemu-system-x86-64 qemu-system-aarch64 upx \
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

RUN --mount=type=bind,src=formulae,target=/tmp/formulae \
    --mount=type=bind,src=src,target=/tmp/src : \
    #
    # install from custom formulae
    #
    && python /tmp/src/main.py /tmp/formulae/argocd.py \
    && python /tmp/src/main.py /tmp/formulae/buf.py \
    && python /tmp/src/main.py /tmp/formulae/buildkit.py \
    && python /tmp/src/main.py /tmp/formulae/cni.py \
    && python /tmp/src/main.py /tmp/formulae/cri-dockerd.py \
    && python /tmp/src/main.py /tmp/formulae/crictl.py \
    && python /tmp/src/main.py /tmp/formulae/grcov.py \
    && python /tmp/src/main.py /tmp/formulae/kubectl.py \
    && python /tmp/src/main.py /tmp/formulae/manifest-tool.py \
    && python /tmp/src/main.py /tmp/formulae/minikube.py \
    && minikube config set WantUpdateNotification false \
    && python /tmp/src/main.py /tmp/formulae/protobuf-compiler.py \
    && python /tmp/src/main.py /tmp/formulae/sccache.py \
    && python /tmp/src/main.py /tmp/formulae/terraform.py \
    && python /tmp/src/main.py /tmp/formulae/stern.py \
    && python /tmp/src/main.py /tmp/formulae/yq.py \
    #
    # more APT packages
    #
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update \
    && apt-get install -y docker.io nodejs graphviz unzip lcov git-lfs \
    #
    # Rustup (no default toolchain, we pick one below)
    #
    && apt-get install -y xxd cmake \
    && ( curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none ) \
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
# Rust tools
#
ARG ACTIONS_CACHE_URL
RUN --mount=type=secret,id=ACTIONS_RUNTIME_TOKEN : \
    && rustup toolchain install 1.80.0 \
    && rustup default 1.80.0 \
    && upx which `rustc` \
    && upx which `cargo` \
    && export SCCACHE_REDIS_ENDPOINT=redis://redis-headless.sccache:6379 \
    && sccache --start-server \
    && export RUSTC_WRAPPER=sccache CARGO_INCREMENTAL=0 \
    && time cargo install cargo-deny --version 0.14.24 --locked && upx `which cargo-deny `\
    && time cargo install cargo-semver-checks --version 0.33.0 --locked && upx `which cargo-semver-checks` \
    && time cargo install sqlx-cli --version 0.8.0 --locked && upx `which sqlx-cli` \
    && time cargo install cargo-llvm-cov --version 0.6.11 --locked && upx `which cargo-llvm-cov` \
    && time cargo install cargo-hack --version 0.6.30 --locked && upx `which cargo-hack` \
    && time cargo install buffrs --version 0.9.0 --locked && upx `which buffrs` \
    && sccache --stop-server \
    && du -hd1 /root

#
# Python tools
#
RUN : \
    && python -m pip install pipx==1.6.0 -v \
    && pipx install poetry==1.8.3 \
    && pipx install pdm==2.17.3 \
    && pipx install slap-cli==1.14.1 \
    && pipx install kraken-wrapper==0.38.0 \
    && pipx install uv==0.2.33 \
    && pipx install ansible==9.8.0 --include-deps \
    && rm -rf ~/.cache/pip

#
# Nix
#
RUN : \
    && sh <(curl -L https://nixos.org/nix/install) --daemon \
    && echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf \
    && echo "max-jobs = auto" >> /etc/nix/nix.conf
