
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ARG BASE_IMAGE

ENV DEBIAN_FRONTEND noninteractive
RUN : \
    && apt-get update \
    && apt-get install -y curl git wget libssl-dev libffi-dev llvm clang gcc g++ pkg-config build-essential jq sudo openssh-client conntrack cloud-utils qemu-utils qemu-kvm qemu-system-x86-64 qemu-system-aarch64 upx time \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# Install UV and Python distributions.
COPY --from=ghcr.io/astral-sh/uv:0.6.2 /uv /bin/uv
RUN : \
    # Install Pip for all other Python versions.
    && set -x \
    && uv python install 3.8 3.9 3.10 3.11 3.12 3.13 \
    # Use Python 3.12 as the default version.
    && ln -svf $(uv python find 3.12) /usr/bin/python \
    && ln -svf $(uv python find 3.12) /usr/bin/python3

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
    && upx `which helm` \
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
RUN --mount=type=secret,id=ACTIONS_RUNTIME_TOKEN \
    --mount=type=cache,target=/tmp/sccache,rw : \
    && rustup toolchain install 1.85.0 \
    && rustup default 1.85.0 \
    && SCCACHE_GHA_ENABLED=on ACTIONS_RUNTIME_TOKEN="$(cat /run/secrets/ACTIONS_RUNTIME_TOKEN)" sccache --start-server \
    && export RUSTC_WRAPPER=sccache CARGO_INCREMENTAL=0 \
    && time cargo install cargo-deny --version 0.18.0 --locked \
    && time cargo install cargo-semver-checks --version 0.39.0 --locked \
    && time cargo install sqlx-cli --version 0.8.3 --locked \
    && time cargo install cargo-llvm-cov --version 0.6.16 --locked \
    && time cargo install cargo-hack --version 0.6.35 --locked \
    && time cargo install buffrs --version 0.9.0 --locked \
    && sccache --stop-server \
    && du -hd1 /root

#
# Python tools
#
RUN : \
    && uv tool install pipx==1.7.1 \
    && uv tool install poetry==1.8.3 \
    && uv tool install pdm==2.17.3 \
    && uv tool install slap-cli==1.14.1 \
    && uv tool install kraken-wrapper==0.38.0 \
    # NOTE: Uv does not support --include-deps yet, see https://github.com/astral-sh/uv/issues/6314
    && pipx install ansible==9.8.0 --include-deps \
    && rm -rf ~/.cache

#
# Nix
#
RUN : \
    && bash -c 'sh <(curl -L https://nixos.org/nix/install) --daemon' \
    && echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf \
    && echo "max-jobs = auto" >> /etc/nix/nix.conf
