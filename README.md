# OpenCode Container

A Docker container for running OpenCode in an isolated environment to protect your host system from potential AI-executed commands.

## Overview

This project provides a containerized OpenCode installation that:

- Isolates OpenCode execution from your host system
- Restricts AI operations to mounted project directories only
- Preserves OpenCode configuration across container restarts
- Includes common development tools (git, Python, npm, curl, etc.)

## Prerequisites

- Docker installed and running
- Basic familiarity with Docker and command-line tools

## Quick Start

```bash
# Clone this repository
git clone <repository-url>
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

### Basic Usage

```bash
# Run OpenCode on the current directory
./run_opencode_container.sh

# Force rebuild the image (useful after updating the Dockerfile)
./run_opencode_container.sh -b

# Show help
./run_opencode_container.sh -h
```

### Volume Mounts

The script automatically mounts:

- **Current directory** → `/app` (your working project)
- `~/.local/share/opencode` → `/root/.local/share/opencode` (OpenCode data)
- `~/.config/opencode` → `/root/.config/opencode` (OpenCode configuration)

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
    opencode \
    opencode
```

## Security Benefits

- **Isolation**: AI commands execute only within the container
- **Limited scope**: Only mounted directories are accessible
- **Host protection**: No direct access to host system files outside mounted volumes
- **Easy cleanup**: Remove container to eliminate all traces

## Included Tools

The container comes pre-installed with:

- Git
- Bash
- SSH client
- curl, wget
- Python 3 (with pip and venv)
- Node.js and npm
- jq, unzip, file utilities
- OpenCode CLI

## Troubleshooting

### Image build fails

- Ensure you have a stable internet connection (downloads OpenCode installer)
- Try rebuilding with `./run_opencode_container.sh -b`

### Permission issues

- Ensure Docker is running and you have proper permissions
- On Linux, you may need to add your user to the `docker` group

### OpenCode not found

- The installer runs during build; if it fails, check Docker build logs
- Verify the OpenCode install script is accessible at `https://opencode.ai/install`

## Contributing

Contributions welcome! Please ensure:

- Changes are documented in `Changelog.md`
- The convenience script remains user-friendly
- Security isolation is not compromised

## License

See LICENSE file for details.
