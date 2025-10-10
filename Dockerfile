FROM ubuntu:22.04

# Install system dependencies in a separate layer for better caching
# This layer will only rebuild if the package list changes
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
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
        ripgrep \
        gosu \
    && apt-get clean

# Create a user with placeholder UID and GID that will be updated at runtime
RUN groupadd -g 1000 opencode && \
    useradd -m -u 1000 -g opencode -s /bin/bash opencode

# Install OpenCode globally via npm (more reliable in containers)
RUN npm install -g opencode-ai

RUN mkdir -p /cursor/rules
COPY .cursor/rules/notes.mdc /cursor/rules/notes.mdc
COPY .cursor/rules/changelog-conventions.mdc /cursor/rules/changelog-conventions.mdc

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh


WORKDIR /app

ENTRYPOINT ["/usr/local/bin/startup.sh"]
