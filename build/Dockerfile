
# ==== Base layers for Pyenv and Python versions.

FROM ubuntu:focal as pyenv-template-base
ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt install -y curl git openssh-client \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PATH:$PYENV_ROOT/shims:$PYENV_ROOT/bin
RUN curl https://pyenv.run | bash
FROM pyenv-template-base as pyenv-template3_6_15
RUN pyenv install 3.6.15
RUN pyenv global 3.6.15 && python --version && python -m pip install --upgrade pip
FROM pyenv-template-base as pyenv-template3_7_13
RUN pyenv install 3.7.13
RUN pyenv global 3.7.13 && python --version && python -m pip install --upgrade pip
FROM pyenv-template-base as pyenv-template3_8_13
RUN pyenv install 3.8.13
RUN pyenv global 3.8.13 && python --version && python -m pip install --upgrade pip
FROM pyenv-template-base as pyenv-template3_9_12
RUN pyenv install 3.9.12
RUN pyenv global 3.9.12 && python --version && python -m pip install --upgrade pip
FROM pyenv-template-base as pyenv-template3_10_4
RUN pyenv install 3.10.4
RUN pyenv global 3.10.4 && python --version && python -m pip install --upgrade pip
FROM pyenv-template-base as pyenv-template3_11_dev
RUN pyenv install 3.11-dev
RUN pyenv global 3.11-dev && python --version && python -m pip install --upgrade pip
FROM pyenv-template-base as pyenv_all
COPY --from=pyenv-template3_6_15 $PYENV_ROOT $PYENV_ROOT
COPY --from=pyenv-template3_7_13 $PYENV_ROOT $PYENV_ROOT
COPY --from=pyenv-template3_8_13 $PYENV_ROOT $PYENV_ROOT
COPY --from=pyenv-template3_9_12 $PYENV_ROOT $PYENV_ROOT
COPY --from=pyenv-template3_10_4 $PYENV_ROOT $PYENV_ROOT
COPY --from=pyenv-template3_11_dev $PYENV_ROOT $PYENV_ROOT
RUN pyenv update
RUN pyenv global 3.10.4


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

