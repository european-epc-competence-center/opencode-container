FROM ubuntu:26.04

# Remove the default ubuntu user/group (UID/GID 1000) to avoid conflicts
# when remapping the opencode user to match the host user's UID/GID.
# Ubuntu 26.04 ships with a 'ubuntu' user that occupies 1000:1000.
RUN userdel -r ubuntu 2>/dev/null || true && \
    groupdel ubuntu 2>/dev/null || true

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
        zip \
        sudo \
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
RUN groupadd -g 10000 opencode && \
    useradd -m -u 10000 -g opencode -s /bin/bash opencode

# Install OpenCode globally via npm (more reliable in containers)
RUN npm install -g opencode-ai

RUN mkdir -p /cursor/rules
COPY .cursor/rules/notes.mdc /cursor/rules/notes.mdc
COPY .cursor/rules/changelog-conventions.mdc /cursor/rules/changelog-conventions.mdc

COPY docker_scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh


WORKDIR /app

ENTRYPOINT ["/usr/local/bin/startup.sh"]
