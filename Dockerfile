FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y \
        git \   
        bash \
        openssh-client \
        curl \
        ca-certificates \
        file \
        unzip \
        wget \
        jq \
        python3 \
        python3-pip \
        python3-venv \
        npm \
        node \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://opencode.ai/install | bash

WORKDIR /app


CMD ["opencode"]
