# Changelog

## WIP

- Improved argument parsing in `run_opencode_container.sh` to properly handle `--` separator
  - All arguments after `--` are now forwarded to opencode without interpretation by the script
  - Allows passing options like `-b` or `-h` to opencode instead of the wrapper script
  - Added `-i` option to specify custom Docker image name (default: `opencode:local`)
  - Updated help text with clearer explanation and additional usage examples
- Fixed `init_rules()` in `startup.sh` to check individual rule files instead of just the directory, ensuring rules are copied even if directory exists but files are missing
- Enhanced `run_opencode_container.sh` to pass all positional arguments to the docker run command, allowing arguments to be forwarded to the container
- Improved script directory detection in `run_opencode_container.sh` to follow symlinks using `pwd -P`
- If the workdir does not already have .cursor/rules, init with notes and changelog rule

## 1.0.0+2025-10-08

- Modified `startup.sh` to prompt user for API key when auth file doesn't exist, instead of using hardcoded key
- Fixed syntax error in `startup.sh` (missing bracket in file check condition)
- Changed Dockerfile to use `ENTRYPOINT` instead of `CMD` to properly support argument forwarding to opencode
- Fixed `.dockerignore` to include `startup.sh` in build context (was being excluded by `*.sh` pattern)
- Initial project setup with OpenCode Docker container
- Created Dockerfile based on Ubuntu 22.04 with essential development tools
- Added convenience script `run_opencode_container.sh` with:
  - Automatic image building
  - Force rebuild option (`-b`)
  - Help documentation (`-h`)
  - Volume mounting for current directory and OpenCode config
- Enhanced README.md with comprehensive documentation:
  - Quick start guide
  - Usage examples
  - Security benefits explanation
  - Troubleshooting section
- Initialized AI notes in `.cursor/notes/index.md`
- Established changelog tracking
- Added `--progress=plain` flag to docker build commands for full build output
- Optimized Docker build caching:
  - Added `.dockerignore` to prevent unnecessary build context changes
  - Enabled BuildKit with cache mounts for apt packages
  - Ensures apt-get install layer is properly cached between builds
- Fixed OpenCode installation to use `npm install -g opencode-ai` instead of curl script for better PATH compatibility in containers
