# Claudetainer

Run Claude Code in a Docker container from any directory with all safety checks disabled.

## Features

- 🐳 **Dockerized**: Run Claude Code in an isolated container
- 🚀 **Universal**: Launch from any directory on your system
- 🔓 **Unrestricted**: Safety checks and permissions disabled
- 🔑 **API Key Auth**: Uses ANTHROPIC_API_KEY (no keychain needed)
- 📁 **File Ownership**: Created files match your user ID (not root)
- 🔧 **Git Support**: Commit, push, and manage git operations
- 🌐 **Cross-Platform**: Works on macOS, Linux, and any system with Docker

## Prerequisites

- Docker installed and running
- Claude Code binary on your system
- Anthropic API key

## Installation

### 1. Clone or download this repository

```bash
git clone <repository-url>
cd claudetainer
```

### 2. Set up your API key

```bash
export ANTHROPIC_API_KEY=sk-ant-your-key-here
```

Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.) to make it permanent:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-your-key-here' >> ~/.zshrc
```

### 3. Run the installation script

```bash
./install.sh
```

This will:
- Detect your Claude binary location
- Build the Docker image
- Install the `claudetainer` command to `/usr/local/bin`

## Usage

### Basic Usage

From any directory, run:

```bash
claudetainer "your prompt here"
```

### Examples

```bash
# Get help with code
cd ~/my-project
claudetainer "help me fix this bug"

# Use different Claude models
claudetainer --model opus "review this code"

# Interactive mode
claudetainer

# Pass any Claude Code flags
claudetainer --help
```

### Git Operations

Git operations work automatically if you have git configured:

```bash
claudetainer "create a commit with these changes"
```

The container will use your system's git configuration and SSH keys.

## How It Works

### Architecture

1. **build.sh**: Detects your Claude binary and builds the Docker image
2. **Dockerfile**: Creates Ubuntu container with git and Claude
3. **entrypoint.sh**: Initializes container with disabled safety checks
4. **claudetainer**: Wrapper script that mounts your current directory
5. **install.sh**: Installs everything system-wide

### Volume Mounts

The claudetainer script automatically mounts:

- **Current directory** → `/workspace` (read-write)
- **~/.claude** → `/root/.claude` (for config/history)
- **~/.gitconfig** → `/root/.gitconfig` (read-only)
- **~/.ssh** → `/root/.ssh` (read-only)

### File Ownership

Files created by Claude will be owned by your user, not root. This is achieved using Docker's `--user` flag to map the container's user ID to your host user ID.

## Configuration

### Environment Variables

See `.env.example` for available options:

```bash
# Required
ANTHROPIC_API_KEY=sk-ant-...

# Optional
CLAUDE_BIN_PATH=/custom/path/to/claude
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your@email.com"
```

### Custom Claude Binary Path

If Claude is not in your PATH:

```bash
export CLAUDE_BIN_PATH=/path/to/claude
./build.sh
```

## Troubleshooting

### "Docker is not running"

Start Docker Desktop or the Docker daemon:

```bash
# macOS with Docker Desktop
open -a Docker

# Linux with systemd
sudo systemctl start docker
```

### "ANTHROPIC_API_KEY environment variable is not set"

Set your API key:

```bash
export ANTHROPIC_API_KEY=sk-ant-your-key-here
```

### "Could not find Claude binary"

Specify the path explicitly:

```bash
export CLAUDE_BIN_PATH=/path/to/claude
./build.sh
```

### Permission Issues with ~/.claude

If you get permission errors:

```bash
chmod -R 755 ~/.claude
```

### Git Operations Not Working

Ensure your git config is set:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

## Security Considerations

⚠️ **Important Security Notes:**

- This tool disables ALL Claude Code safety checks using `--dangerously-skip-permissions`
- Only use in trusted environments and directories
- The container has full access to your current directory
- SSH keys are mounted read-only but are still accessible to Claude
- API keys are passed via environment variables

**Only use Claudetainer if you understand and accept these risks.**

## Limitations

- macOS keychain authentication not available (use API key)
- Container cannot access files outside current directory tree
- No GUI support (Claude Code is CLI-only)
- Requires rebuilding image if Claude binary is updated

## Transferring to Another System

To use Claudetainer on a different machine:

1. Copy the repository to the new system
2. Ensure Docker and Claude Code are installed
3. Run `./install.sh`

The build script will automatically detect the Claude binary location on the new system.

## Uninstallation

```bash
# Remove the command
sudo rm /usr/local/bin/claudetainer

# Remove Docker image
docker rmi claudetainer:latest

# Remove repository
rm -rf /path/to/claudetainer
```

## Building Without Installing

To build the Docker image without installing system-wide:

```bash
./build.sh

# Run directly with docker
docker run -it --rm \
  --user $(id -u):$(id -g) \
  -v "$(pwd):/workspace" \
  -e ANTHROPIC_API_KEY \
  claudetainer:latest "your prompt"
```

## License

MIT License - see LICENSE file for details

## Contributing

Contributions welcome! Please open an issue or pull request.

## Acknowledgments

Built for the Claude Code community. Inspired by the need to run AI assistants in isolated, reproducible environments.
