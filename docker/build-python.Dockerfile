ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y curl git openssh-client \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PATH:$PYENV_ROOT/shims:$PYENV_ROOT/bin
RUN curl https://pyenv.run | bash
ARG PYTHON_VERSION
RUN : \
    && pyenv install --verbose ${PYTHON_VERSION} \
    # Remove elements from the standard library that are not needed at runtime but are very large.
    && rm -r /root/.pyenv/versions/${PYTHON_VERSION}/lib/python*/test/ \
    && rm -r /root/.pyenv/versions/${PYTHON_VERSION}/lib/python*/config-*/ \
    # Upgrade Pip
    && pyenv global ${PYTHON_VERSION} \
    && python --version \
    && python -m pip install --upgrade pip
