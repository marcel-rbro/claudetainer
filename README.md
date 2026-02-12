# Claudetainer

A simple wrapper for running Claude CLI in a Docker sandbox with automatic API key validation and default prompt support.

## What it does

`claudetainer` is a convenience script that:

- Checks if your Anthropic API key is configured
- Validates Docker is installed
- Supports default prompts via config file or environment variable
- Runs Claude in a Docker sandbox with permissions pre-approved
- Equivalent to: `docker sandbox run claude . -- --allowedTools '*'`

**Note**: Uses `--allowedTools '*'` instead of `--dangerously-skip-permissions` because the latter is blocked when running as root (which Docker containers often do for isolation).

## Quick Start

```bash
# 1. Set your API key
export ANTHROPIC_API_KEY='your-api-key-here'

# 2. Install claudetainer
cd /path/to/claudetainer
chmod +x claudetainer
cp claudetainer /usr/local/bin/claudetainer

# 3. Use from any directory
cd ~/your-project
claudetainer "Review the code in this repository"
```

See [QUICKSTART.md](QUICKSTART.md) for detailed step-by-step instructions.

## Complete Setup

### 1. Get your Anthropic API key

Visit [Anthropic Console](https://console.anthropic.com/settings/keys) to get your API key.

### 2. Add the API key to your shell config

Claudetainer supports multiple environment variable names for flexibility. Use any of these (in priority order):

- `ANTHROPIC_API_KEY` (recommended - official Anthropic SDK variable)
- `CLAUDE_API_KEY`
- `ANTHROPIC_API`
- `CLAUDE_API`

#### For Zsh (macOS default)

```bash
echo "export ANTHROPIC_API_KEY='your-api-key-here'" >> ~/.zshrc
source ~/.zshrc
```

#### For Bash

```bash
echo "export ANTHROPIC_API_KEY='your-api-key-here'" >> ~/.bashrc
source ~/.bashrc
```

**Note:** If you already have your API key in a different variable (like `CLAUDE_API_KEY`), claudetainer will automatically detect and use it.

### 3. Add GitHub Token (Optional - for gh CLI support)

If you want to use GitHub CLI (`gh`) commands from within the Claude container, set up a GitHub Personal Access Token (PAT).

Claudetainer supports these environment variables (in priority order):

- `GH_TOKEN` (recommended - official gh CLI variable)
- `GITHUB_TOKEN`
- `GITHUB_PAT`

#### Get a GitHub Token

1. Go to [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)" or "Fine-grained token"
3. Give it appropriate scopes (e.g., `repo`, `read:org` for basic operations)
4. Copy the token

#### Add to shell config

**For Zsh:**

```bash
echo "export GH_TOKEN='your-github-token-here'" >> ~/.zshrc
source ~/.zshrc
```

**For Bash:**

```bash
echo "export GH_TOKEN='your-github-token-here'" >> ~/.bashrc
source ~/.bashrc
```

**Note:** If you already have a GitHub token in `GITHUB_TOKEN` or `GITHUB_PAT`, claudetainer will automatically detect and use it.

### 4. Install claudetainer globally

**For Most Users (Recommended):**

```bash
cd /path/to/claudetainer
chmod +x claudetainer
cp claudetainer /usr/local/bin/claudetainer
```

Simple one-time installation. When you want to update, just `git pull` and re-copy.

**For Contributors/Developers (Symlink Method):**

If you're contributing to claudetainer or want automatic updates without re-copying:

```bash
# Option 1: Symlink to ~/.local/bin
mkdir -p ~/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
cd /path/to/claudetainer
ln -s "$(pwd)/claudetainer" ~/.local/bin/claudetainer

# Option 2: Symlink to /usr/local/bin
cd /path/to/claudetainer
sudo ln -s "$(pwd)/claudetainer" /usr/local/bin/claudetainer
```

Benefits of symlink:
- ✅ Changes in the repo are immediately available
- ✅ Useful when developing or testing changes
- ✅ No need to re-install after `git pull`

**Alternative: Add to PATH**

```bash
echo 'export PATH="$PATH:/path/to/claudetainer"' >> ~/.zshrc
source ~/.zshrc
```

### 5. Test the installation

```bash
# Check help
claudetainer --help

# Check configuration
claudetainer --show-config

# Test in a project directory
cd ~/your-project
claudetainer "Hello, can you see this project?"
```

## Usage

### Basic usage

Navigate to any project/repository on your filesystem and run:

```bash
cd /path/to/your/project
claudetainer
```

This will start Claude in a Docker sandbox with the current directory as the working directory.

### Running with a specific prompt

You can pass a prompt directly:

```bash
claudetainer "Review the code in this repository"
claudetainer "Help me debug the authentication issue"
claudetainer "Read the .claude instructions and help me"
```

### Setting a default prompt

You can set a default prompt that will be used every time you run `claudetainer` without arguments.

**Interactive setup (recommended):**

```bash
claudetainer --set-prompt
```

**Environment variable:**

```bash
# Add to ~/.zshrc or ~/.bashrc
echo 'export CLAUDETAINER_DEFAULT_PROMPT="Read the .claude instructions."' >> ~/.zshrc
source ~/.zshrc
```

**Config file:**

```bash
mkdir -p ~/.claudetainer
echo "DEFAULT_PROMPT='You are a helpful coding assistant.'" > ~/.claudetainer/config
```

### Using GitHub CLI inside the container

If you've configured a GitHub token, Claude can use `gh` CLI commands within the container:

```bash
# Example prompts that use gh CLI
claudetainer "List all open pull requests using gh CLI"
claudetainer "Create a new GitHub issue for the bug we just discussed"
claudetainer "Show me the latest releases using gh"
```

When claudetainer detects a GitHub token, you'll see:

```text
✓ GitHub token detected - gh CLI will be available
```

### Viewing configuration

To see your current configuration:

```bash
claudetainer --show-config
```

Output shows:
- Which API key variables are set
- Which GitHub token variables are set
- Default prompt configuration
- Config file location

### Command reference

```bash
claudetainer                        # Run with default prompt (if set)
claudetainer "your prompt"          # Run with specific prompt
claudetainer --set-prompt           # Set default prompt (persistent)
claudetainer --show-config          # Show current configuration
claudetainer --help                 # Show help message
```

### Priority order for prompts

When multiple prompt sources are available, they are used in this order:

1. Command line argument (highest priority)
2. Environment variable (`CLAUDETAINER_DEFAULT_PROMPT`)
3. Config file (`~/.claudetainer/config`)

## Requirements

- **Docker Desktop or Docker CLI** with `docker sandbox` support
- **Anthropic API key** (required)
- **GitHub Personal Access Token** (optional - for `gh` CLI support)
- **Bash or Zsh shell**

## Configuration

### Config File Location

- Config directory: `~/.claudetainer/`
- Config file: `~/.claudetainer/config`

### Environment Variables

#### Anthropic API Key (Required)

Checked in this order:

1. `ANTHROPIC_API_KEY` (recommended)
2. `CLAUDE_API_KEY`
3. `ANTHROPIC_API`
4. `CLAUDE_API`

#### GitHub Token (Optional)

Checked in this order:

1. `GH_TOKEN` (recommended)
2. `GITHUB_TOKEN`
3. `GITHUB_PAT`

#### Default Prompt (Optional)

- `CLAUDETAINER_DEFAULT_PROMPT` - Sets a default prompt for all runs

### Config File Format

The `~/.claudetainer/config` file uses bash syntax:

```bash
# Default prompt to use when no command line argument is provided
DEFAULT_PROMPT='Read the provided .claude instructions.'
```

## Troubleshooting

### "ANTHROPIC_API_KEY environment variable is not set"

**Cause**: No API key found in any of the supported environment variables.

**Solution**: Add to your shell config:

```bash
echo "export ANTHROPIC_API_KEY='your-api-key-here'" >> ~/.zshrc
source ~/.zshrc
```

### "docker command not found"

**Cause**: Docker is not installed or not in PATH.

**Solution**: Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) for macOS.

### "unknown option '--skip-config'"

**Cause**: Using an old version of claudetainer that tried to use invalid flags.

**Solution**: Update claudetainer:

```bash
cd /path/to/claudetainer
git pull
cp claudetainer /usr/local/bin/claudetainer

# If you used symlink method (for contributors), updates are automatic!
```

### "Permission denied" when running claudetainer

**Cause**: Script is not executable.

**Solution**:

```bash
chmod +x claudetainer
```

### Script exits immediately with no output

**Possible causes and solutions:**

1. **Old version in PATH**: Check which version is being used:
   ```bash
   which claudetainer
   # Should point to your symlink or installation
   ```

2. **Missing API key**: Run `claudetainer --show-config` to verify API key is detected

3. **Docker not running**: Ensure Docker Desktop is running:
   ```bash
   docker ps
   ```

### claudetainer works with `./claudetainer` but not `claudetainer`

**Cause**: The version in your PATH is outdated or different from the project version.

**Solution**: Update the installed version:

```bash
# Find where it's installed
which claudetainer

# Re-copy the latest version
cd /path/to/claudetainer
git pull
cp claudetainer $(which claudetainer)
```

### GitHub token not detected

**Cause**: Environment variable not set in current shell session.

**Solution**:

1. Verify token is in shell config:
   ```bash
   cat ~/.zshrc | grep GH_TOKEN
   ```

2. Source the config:
   ```bash
   source ~/.zshrc
   ```

3. Verify it's set:
   ```bash
   claudetainer --show-config
   ```

## How It Works

### Command Flow

1. **Argument Parsing**: Parses command line arguments (`--help`, `--set-prompt`, etc.)
2. **API Key Detection**: Searches for Anthropic API key in supported environment variables
3. **GitHub Token Detection**: Searches for GitHub token (optional)
4. **Prompt Loading**: Loads default prompt from config/environment if no argument provided
5. **Docker Execution**: Runs `docker sandbox run claude . -- --allowedTools '*' [prompt]`

### Docker Sandbox

The script uses Docker's `sandbox` feature which:
- Inherits environment variables from your shell automatically
- Mounts your current directory as the workspace
- Runs Claude CLI with specified flags
- Provides isolation while maintaining access to your files

### Permission Handling

Uses `--allowedTools '*'` to auto-approve all Claude tools because:
- `--dangerously-skip-permissions` is blocked when running as root
- Docker containers often run as root for isolation
- `--allowedTools` provides selective approval that works with root

## Security Considerations

### Sandbox Isolation

- Claude runs in a Docker sandbox with access to your **current directory only**
- The `--allowedTools '*'` flag auto-approves tool usage within this sandboxed environment
- Only use claudetainer in directories you trust

### API Keys and Tokens

- **Never commit** API keys or tokens to version control
- Store them in shell config files (`.zshrc`, `.bashrc`)
- These files should be in your home directory and not version controlled
- The `config.example` file is safe to commit (contains no secrets)
- The actual `config` file is git-ignored

### GitHub Token Permissions

When creating a GitHub PAT, only grant necessary scopes:
- `repo` - For repository access
- `read:org` - For organization access (if needed)

Use fine-grained tokens when possible with minimal permissions.

## Advanced Usage

### Custom Config Location

You can use a project-specific config by setting:

```bash
export CONFIG_FILE="/path/to/project/.claudetainer-config"
```

### Multiple Profiles

Create aliases for different use cases:

```bash
# In ~/.zshrc or ~/.bashrc
alias claude-review='CLAUDETAINER_DEFAULT_PROMPT="Review this code" claudetainer'
alias claude-docs='CLAUDETAINER_DEFAULT_PROMPT="Update documentation" claudetainer'
alias claude-debug='CLAUDETAINER_DEFAULT_PROMPT="Help debug issues" claudetainer'
```

### Integration with CI/CD

Claudetainer can be used in CI/CD pipelines:

```bash
#!/bin/bash
# .github/workflows/claude-review.sh

export ANTHROPIC_API_KEY="${ANTHROPIC_API_SECRET}"
export GH_TOKEN="${GITHUB_TOKEN}"

claudetainer "Review the changes in this pull request"
```

## Project Files

```
claudetainer/
├── .gitignore           # Ignores config files with secrets
├── QUICKSTART.md        # Quick setup guide with examples
├── README.md            # This file - complete documentation
├── claudetainer         # Main executable script
└── config.example       # Example configuration file
```

## Contributing

### Development Setup

If you're contributing to claudetainer, use the symlink method for easier development:

```bash
# Clone the repo
git clone https://github.com/yourusername/claudetainer.git
cd claudetainer

# Create symlink for development
mkdir -p ~/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
ln -s "$(pwd)/claudetainer" ~/.local/bin/claudetainer

# Now your changes are immediately available without reinstalling
```

### Reporting Issues

If you find issues or have suggestions:

1. Test with `./claudetainer` directly to ensure issue isn't with PATH version
2. Check `claudetainer --show-config` for configuration status
3. Review this README for troubleshooting steps
4. Report issues with full error output and steps to reproduce

## Version History

### Current Version

- ✅ Uses `--allowedTools '*'` for root compatibility
- ✅ Auto-detects multiple API key variable names
- ✅ Auto-detects multiple GitHub token variable names
- ✅ Supports default prompts via config/environment
- ✅ Interactive prompt configuration
- ✅ Works from any directory
- ✅ Proper error handling and user feedback

## References

- [Claude Code Documentation](https://code.claude.com/docs)
- [Docker Sandbox](https://docs.docker.com/desktop/features/sandbox/)
- [Running Claude in Containers](https://github.com/anthropics/claude-code/issues/16135)

---

**Maintained By**: Community
**License**: MIT
**Last Updated**: 2026-02-12
