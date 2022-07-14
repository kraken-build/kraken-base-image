
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
