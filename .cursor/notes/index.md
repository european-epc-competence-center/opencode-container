# Notes Index

## Project Overview

Docker containerization for OpenCode to isolate AI code execution from the host system. Configured for EECC API with Claude Sonnet models.

## Project Structure

```
/
├── Dockerfile                      # Ubuntu 22.04 + OpenCode + dev tools
├── startup.sh                      # Container entrypoint (config init + OpenCode launch)
├── run_opencode_container.sh       # Build & run convenience script
├── .dockerignore                   # Optimizes Docker build context
├── README.md                       # User documentation
├── Changelog.md                    # Version history
└── .cursor/
    ├── notes/index.md              # This file
    └── rules/                      # AI conventions (copied to container)
        ├── notes.mdc
        └── changelog-conventions.mdc
```

## Key Components

### Dockerfile (`/app/Dockerfile`)

- **Base:** Ubuntu 22.04
- **Tools:** git, bash, openssh-client, curl, python3, npm, ripgrep, jq, wget, unzip, file, gosu
- **OpenCode:** Installed globally via `npm install -g opencode-ai` (better PATH handling than curl install)
- **Build optimization:** BuildKit cache mounts for apt packages (speeds up rebuilds)
- **Rules injection:** Copies `.cursor/rules/*.mdc` to `/cursor/rules/` in image
- **User setup:** Creates `opencode` user with placeholder UID/GID 1000 (updated at runtime to match host user)
- **Entrypoint:** `/usr/local/bin/startup.sh` (allows arg forwarding to OpenCode)

### startup.sh (`/app/startup.sh`)

Container initialization with three main functions:

1. **configure_user():**

   - Runs as root to update container user UID/GID
   - Reads `HOST_UID` and `HOST_GID` environment variables (defaults to 1000)
   - Updates `opencode` user and group to match host user credentials
   - Fixes ownership of `/home/opencode` directory
   - Prevents permission issues with mounted volumes

2. **check_config():**

   - Creates `~/.config/opencode/config.json` if missing
   - Preconfigured for EECC API (baseURL: `https://api.eecc.ai/v1`)
   - Models: `claude-sonnet-4-20250514`, `claude-sonnet-4-5-20250929`
   - If `~/.local/share/opencode/auth.json` missing, asks user via yes/no question if they want to connect to EECC API
     - If yes: prompts for API key from `https://portal.eecc.ai/`
     - If no: runs `opencode auth login` for standard authentication

3. **init_rules():**
   - Checks each rule file individually and copies from `/cursor/rules/` only if missing
   - Ensures workdir has notes and changelog conventions without overwriting existing files

**Execution flow:**

- If running as root: configures user → re-execs script as `opencode` user via `gosu`
- If running as `opencode`: proceeds with config/rules setup → launches `opencode "$@"`
- Uses script re-execution to avoid code duplication (cleaner than heredoc approach)

### run_opencode_container.sh (`/app/run_opencode_container.sh`)

Wrapper script with:

- **Options:** `-b` (force rebuild), `-i IMAGE` (custom image name), `-h` (help)
- **Argument parsing:** Manual parsing (not getopts) to properly handle `--` separator
  - Arguments after `--` are forwarded to opencode without interpretation
  - Allows passing options like `-b` or `-h` to opencode instead of the wrapper script
  - Image name defaults to `opencode:local` but can be overridden with `-i` or `IMAGE` env var
- **Logic:**
  - Detects script dir via `readlink -f` (follows symlinks)
  - Builds `opencode` image if missing or if `-b` specified
  - Uses `DOCKER_BUILDKIT=1` with `--progress=plain` for full build logs
  - Creates `~/.local/share/opencode` and `~/.config/opencode` on host
- **User mapping:**
  - Passes `HOST_UID` and `HOST_GID` environment variables (from `$(id -u)` and `$(id -g)`)
  - Container runs as matching user to prevent permission issues with mounted volumes
- **Volume mounts:**
  - `$(pwd) → /app` (working directory)
  - `~/.local/share/opencode → /home/opencode/.local/share/opencode` (auth persistence)
  - `~/.config/opencode → /home/opencode/.config/opencode` (config persistence)
- **Container:** Interactive (`-it`), auto-cleanup (`--rm`), named `opencode`
- **Args:** Forwards all positional args to container

### .dockerignore (`/app/.dockerignore`)

Excludes from build context:

- `.git`, documentation (README.md, Changelog.md)
- `run_opencode_container.sh` (not needed in image)
- Editor files (`.vscode/`, `*.swp`)
- Local config (`.env`, `*.log`)

**Purpose:** Prevents unnecessary layer invalidation when docs/scripts change.

## Security Model

- **Isolation:** AI commands execute inside container, not on host
- **Access control:** Only mounted directories accessible (current dir + OpenCode config)
- **State persistence:** Config/auth survive container restarts via volume mounts
- **No network restrictions:** Container has full network access for OpenCode operations
- **User mapping:** Container runs as host user (not root) to prevent permission issues with created files

## Development Workflow

1. **Make changes** to Dockerfile, scripts, or rules
2. **Test locally:** `./run_opencode_container.sh -b` (force rebuild)
3. **Update Changelog.md** (see `changelog-conventions.mdc`)
4. **Update notes** (this file) if architecture changes
5. **Update README.md** for user-facing changes

## Typical User Workflow

1. Symlink script to PATH: `ln -s $(pwd)/run_opencode_container.sh ~/.local/bin/`
2. Navigate to project: `cd ~/my_project`
3. Run: `run_opencode_container.sh`
4. First run: Answer yes/no to EECC API question and follow prompts
5. Container inits rules in workdir, launches OpenCode

## Troubleshooting Notes

- **PATH issues:** npm global install preferred over curl (containerization)
- **Build caching:** `.dockerignore` critical for fast rebuilds
- **Symlinks:** Script uses `readlink -f` to resolve path correctly
- **ENTRYPOINT vs CMD:** ENTRYPOINT allows `docker run` args to pass through
- **Rules initialization:** Each rule file checked individually, copied only if missing (won't overwrite existing files)
- **Permission issues:** Container uses `gosu` to match host user UID/GID, preventing root-owned files in mounted volumes
- **User mapping:** Uses `HOST_UID` and `HOST_GID` env vars to dynamically configure container user at runtime

## Related Files

- `changelog-conventions.mdcg format rules
- `notes.mdc`: Notes maintenance guidelines
