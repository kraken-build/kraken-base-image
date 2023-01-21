
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ARG BASE_IMAGE

ENV DEBIAN_FRONTEND noninteractive
RUN : \
    && apt-get update \
    && apt-get install -y curl git wget libssl-dev libffi-dev llvm clang gcc g++ pkg-config build-essential jq \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# Install Python versions with deadsnakes.
SHELL [ "/bin/bash", "-c" ]
RUN : \
    && set -x \
    && apt-get update \
    && apt-get install -y software-properties-common --no-install-recommends \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt update \
    # Install Python 3.6 - 3.10, and Pip for the system default Python version.
    # Note that deadsnakes does not provide Python 3.6 on Jammy.
    &&  if [ "${BASE_IMAGE}" == "ubuntu:jammy" ]; then \
            apt-get install -y python{3.7,3.8,3.9,3.10,3.11}{,-venv,-dev} --no-install-recommends; \
        else \
            apt-get install -y python{3.6,3.7,3.8,3.9,3.10,3.11}{,-venv,-dev} --no-install-recommends; \
        fi \
    && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

RUN : \
    # Install Pip for all other Python versions.
    && set -x \
    # NOTE(NiklasRosenstein): get-pip.py is not supported for Python 3.6. And we don't have Python3.6 on Jammy.
    && if [ "${BASE_IMAGE}" != "ubuntu:bionic" ] && [ "${BASE_IMAGE}" != "ubuntu:jammy" ]; then python3.6 -m ensurepip && python3.6 -m pip install --upgrade pip; fi \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.7 - \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.8 - \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.9 - \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 - \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 - \
    # Install Python 3.10 as the default version.
    && ln -svf $(which python3.10) /usr/bin/python \
    && ln -svf $(which python3.10) /usr/bin/python3

ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
ENV PATH="$PATH:/root/.cargo/bin:/root/.local/bin"

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
    && python /tmp/src/main.py /tmp/formulae/yq.py \
    #
    # more APT packages
    #
    && ( curl -fsSL https://deb.nodesource.com/setup_18.x | bash - ) \
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
    # Pyenv
    #
    && curl https://pyenv.run | bash \
    #
    # [cleanup]
    #
    && rm -r /tmp/src /tmp/formulae \
    && rm -rf ~/.cache /var/cache/apt/archives /var/lib/apt/lists/*

#
# Enable sparse registry support without having to move to nightly
# Enable registry-auth, if required, without having to move to nightly
#
ENV CARGO_UNSTABLE_SPARSE_REGISTRY true
ENV CARGO_UNSTABLE_REGISTRY_AUTH true

#
# docker-buildx
#
COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx

#
# Python tools
#
RUN : \
    && python -m pip install pipx -v \
    && pipx install poetry==1.3.1 \
    && pipx install slap-cli==1.6.30 \
    && pipx install kraken-wrapper==0.2.0 \
    && pipx install proxy.py==2.4.3 && pipx inject proxy.py certifi \
    && pipx install ansible-base==2.10.17 && pipx inject ansible-base ansible==6.6.0 \
    && rm -rf ~/.cache/pip
