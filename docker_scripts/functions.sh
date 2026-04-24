#!/usr/bin/env bash

# Configure user to match host user UID/GID to avoid permission issues
# This function runs as root and updates the opencode user's UID/GID.
# It expects the base image to have any default 1000:1000 user removed
# (see Dockerfile) so the remapping does not collide.
configure_user() {
    local host_uid=${HOST_UID:-1000}
    local host_gid=${HOST_GID:-1000}

    local current_uid current_gid
    current_uid=$(id -u opencode)
    current_gid=$(id -g opencode)

    echo "Current UID: $current_uid, Current GID: $current_gid"
    echo "Host UID: $host_uid, Host GID: $host_gid"

    if [ "$current_uid" = "$host_uid" ] && [ "$current_gid" = "$host_gid" ]; then
        echo "Container user already matches host user."
    else
        echo "Remapping container user to match host user (UID: $host_uid, GID: $host_gid)..."

        # Change GID first, then UID
        if [ "$current_gid" != "$host_gid" ]; then
            if getent group "$host_gid" >/dev/null 2>&1; then
                echo "Warning: GID $host_gid already exists. Removing conflicting group."
                groupdel "$(getent group "$host_gid" | cut -d: -f1)" 2>/dev/null || true
            fi
            groupmod -g "$host_gid" opencode
        fi

        if [ "$current_uid" != "$host_uid" ]; then
            if getent passwd "$host_uid" >/dev/null 2>&1; then
                echo "Warning: UID $host_uid already exists. Removing conflicting user."
                userdel "$(getent passwd "$host_uid" | cut -d: -f1)" 2>/dev/null || true
            fi
            usermod -u "$host_uid" -g "$host_gid" opencode
        fi
    fi

    # Ensure home directory ownership is correct
    chown -R opencode:opencode /home/opencode
}

check_config() {
    if [ ! -f ~/.local/share/opencode/auth.json ]; then
        echo "Auth file not found."
        mkdir -p ~/.local/share/opencode

        echo ""
        echo -n "Do you want to connect to the EECC AI API at https://portal.eecc.ai/ ? (y/n): "
        read -r use_eecc

        if [ "$use_eecc" = "y" ] || [ "$use_eecc" = "Y" ] || [ "$use_eecc" = "yes" ] || [ "$use_eecc" = "Yes" ] || [ "$use_eecc" = "YES" ]; then
            echo -n "Please enter your EECC API key (generate at https://portal.eecc.ai/ ): "
            read -r api_key

            if [ -z "$api_key" ]; then
                echo "Error: API key cannot be empty."
                exit 1
            fi

            echo "Creating auth file with provided API key..."
            cat >~/.local/share/opencode/auth.json <<EOF
{
  "eecc": {
    "type": "api",
    "key": "$api_key"
  }
}
EOF

            if [ ! -f ~/.config/opencode/config.json ]; then
                echo "Config file not found, creating default config..."
                mkdir -p ~/.config/opencode
                echo '{
            "$schema": "https://opencode.ai/config.json",
            "provider": {
                "eecc": {
                    "npm": "@ai-sdk/openai-compatible",
                    "name": "EECC API",
                    "options": {
                        "baseURL": "https://api.eecc.ai/v1"
                    },
                    "models": {
                        "claude-sonnet-4-6": {
                            "name": "Claude Sonnet 4.6"
                        },
                        "claude-opus-4-7": {
                            "name": "Claude Opus 4.7"
                        },
                        "kimi-k2.6": {
                            "name": "Kimi K 2.6"
                        },
                        "qwen3-coder": {
                            "name": "Qwen3 Coder"
                        },
                        "qwen3-coder-max": {
                            "name": "Qwen3 Coder Max"
                        }
                    }
                }
            }
        }
' >~/.config/opencode/config.json
            else
                echo "Config file already exists."
            fi

        else
            echo "Running standard OpenCode authentication..."
            opencode auth login
        fi
    else
        echo "Auth file already exists."
    fi

}

init_rules() {
    mkdir -p ".cursor/rules"

    if [ ! -f ".cursor/rules/notes.mdc" ]; then
        echo "Initializing notes.mdc rule..."
        cp "/cursor/rules/notes.mdc" ".cursor/rules/notes.mdc"
    fi

    if [ ! -f ".cursor/rules/changelog-conventions.mdc" ]; then
        echo "Initializing changelog-conventions.mdc rule..."
        cp "/cursor/rules/changelog-conventions.mdc" ".cursor/rules/changelog-conventions.mdc"
    fi
}

# Configure passwordless sudo for the opencode user
# Uses a drop-in file under /etc/sudoers.d/ so we never touch the main sudoers file.
configure_sudoers() {
    local drop_in_file="/etc/sudoers.d/opencode"

    if [ -f "$drop_in_file" ]; then
        return 0
    fi

    echo "Configuring passwordless sudo for opencode user..."
    echo "opencode ALL=(ALL) NOPASSWD:ALL" >"$drop_in_file"
    chmod 0440 "$drop_in_file"
    echo "Sudoers configuration complete."
}

change_user_if_necessary() {
    # Check if we're running as the opencode user
    if [ "$(whoami)" != "opencode" ]; then
        echo "Running as root - configure user and re-exec as opencode user"
        configure_sudoers
        configure_user
        exec gosu opencode "$0" "$@"
        exit 0
    fi
    echo "Running as opencode user - proceed with normal startup"
}
