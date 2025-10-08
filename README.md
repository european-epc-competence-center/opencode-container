# OpenCode Container

A Docker container for running OpenCode in an isolated environment to protect your host system from potential AI-executed commands.

## Overview

This project provides a containerized OpenCode installation that:

- Isolates OpenCode execution from your host system
- Restricts AI operations to mounted project directories only
- Preserves OpenCode configuration across container restarts
- Initializes EECC opencode config, if not already initialized
- Initializes `.cursor/rules` in any workdir, if not already present.

## Quick Start

```bash
# Clone this repository
git clone git@gitlab.eecc.info:eecc-internal/opencode-container.git
cd opencode-container

# Run OpenCode in a container (builds automatically if needed)
./run_opencode_container.sh
```

This will:

1. Build the OpenCode Docker image (if not already built)
2. Mount your current directory to `/app` in the container
3. Mount OpenCode config directories for persistence
4. Start an interactive OpenCode session

## Usage

Recommended: Create a link to the run script in your path. The following creates a bin symlink callen `opencode`, you may of course choose another name.

```
cd opencode-container
ln -s $(pdw)/run_opencode_container.sh ~/.local/bin/opencode
```

then you can run opencode from your project folder

```
cd my_awesome_project
opencode
```

Or also use open code commands like

```
opencode run "analyze project and init or update notes according to @./cusror/rules/notes.md"
```

### Manual Docker Usage

If you prefer to run Docker commands manually:

```bash
# Build the image
docker build -t opencode .

# Run the container
docker run -it --rm \
    --name opencode \
    -v "$(pwd):/app" \
    -v "$HOME/.local/share/opencode:/root/.local/share/opencode" \
    -v "$HOME/.config/opencode:/root/.config/opencode" \
    opencode
```
