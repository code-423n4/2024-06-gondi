FROM ubuntu:latest AS base
SHELL ["/bin/bash", "-c", "-l"]
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN add-apt-repository -y ppa:ethereum/ethereum
RUN apt-get install -y ethereum
RUN apt-get update && \
    apt-get install -y curl python3.11 python3.11-dev python3-pip python-is-python3 \
    zsh openssl openssh-client git iproute2 \
    software-properties-common procps vim iputils-ping unzip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2
RUN useradd -ms /bin/zsh ubuntu
RUN mkdir $HOME/.ssh
ENV HOME /home/ubuntu
ENV PATH $HOME/.local/bin:$PATH
USER ubuntu
RUN curl -sSL https://install.python-poetry.org | python3 -
RUN poetry config virtualenvs.in-project true
RUN poetry config installer.modern-installation false
WORKDIR $HOME

FROM base AS blockchain
USER ubuntu
WORKDIR $HOME
ADD --chown=ubuntu:ubuntu https://foundry.paradigm.xyz foundry_installer
RUN bash foundry_installer
ENV PATH $PATH:$HOME/.foundry/bin
RUN foundryup

COPY --chown=ubuntu:ubuntu . $HOME/florida-contracts

WORKDIR $HOME/florida-contracts/deploy
RUN poetry install
RUN forge install
RUN forge build