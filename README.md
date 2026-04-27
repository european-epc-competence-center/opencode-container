[![Docker](https://github.com/european-epc-competence-center/opencode-container/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/european-epc-competence-center/opencode-container/actions/workflows/docker-publish.yml)

# OpenCode Container

A Docker container for running OpenCode in an isolated environment to protect your host system from potential AI-executed commands.

## Overview

This project provides a containerized OpenCode installation that:

- Isolates OpenCode execution from your host system
- Restricts AI operations to mounted project directories only
- Preserves OpenCode configuration across container restarts
- Initializes EECC opencode config, if not already initialized
- Initializes `.cursor/rules` in any workdir, if not already present.

## Usage

Recommended: Create a link to the run script in your path. The following creates a bin symlink callen `opencode`, you may of course choose another name.

```
wget https://github.com/european-epc-competence-center/opencode-container/raw/refs/heads/main/opencode.sh -O ~/.local/bin/opencode.sh && chmod +x ~/.local/bin/opencode.sh
```

then you can run opencode from your project folder

```
cd my_awesome_project
opencode.sh
```

Or also use open code commands like

```
opencode.sh run "analyze project and init or update notes according to @./cusror/rules/notes.md"
```

## Local Build

```bash
# Clone this repository
git clone git@gitlab.eecc.info:eecc-internal/opencode-container.git
cd opencode-container

./opencode.sh -b
```

This will:

1. Build the OpenCode Docker image (if not already built, force with `-b`)
2. Mount your current directory to `/app` in the container
3. Mount OpenCode config directories for persistence
4. Start an interactive OpenCode session

## Mounting Additional Volumes

You can mount additional directories into the container using either command line options or environment variables.

### Using Command Line Options

Use the `-v` option to mount additional volumes (can be specified multiple times):

```bash
# Mount a single additional volume
./build_and_run_opencode_container.sh -v /host/data:/container/data

# Mount multiple volumes
./build_and_run_opencode_container.sh -v /host/data:/data -v /host/logs:/logs
```

### Using Environment Variables

Set the `OPENCODE_EXTRA_MOUNTS` environment variable with semicolon-separated mount specifications:

```bash
# Mount multiple volumes via environment variable
OPENCODE_EXTRA_MOUNTS="/host/data:/data;/host/logs:/logs" ./build_and_run_opencode_container.sh

# Or export it for all subsequent runs
export OPENCODE_EXTRA_MOUNTS="/host/data:/data;/host/logs:/logs"
./build_and_run_opencode_container.sh
```

### Mount Format

Both methods use the Docker volume mount format: `/host/path:/container/path`

For read-only mounts, append `:ro`: `/host/path:/container/path:ro`

## License

Copyright 2025 European EPC Competence Center GmbH (EECC). Corresponding Author: Sebastian Schmittner <sebastian.schmittner@eecc.de>

<a href="https://www.gnu.org/licenses/agpl-3.0.html">
<img alt="AGPLV3" style="border-width:0" src="https://www.gnu.org/graphics/agplv3-with-text-162x68.png" /><br />
</a>

All code published in this repository is free software: you can redistribute it and/or modify it under the terms of the
GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
</a>

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

[See LICENSE for details](./LICENSE)
