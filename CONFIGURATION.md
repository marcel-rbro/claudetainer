# Configuration Guide

Detailed configuration options for claudetainer.

## Environment Variables

### Anthropic API Key (Required)

Claudetainer checks for API keys in this order:

1. `ANTHROPIC_API_KEY` (recommended - official Anthropic SDK variable)
2. `CLAUDE_API_KEY`
3. `ANTHROPIC_API`
4. `CLAUDE_API`

**Setup:**

```bash
export ANTHROPIC_API_KEY='sk-ant-api03-your-key-here'
```

### GitHub Token (Optional)

For gh CLI support in the container:

1. `GH_TOKEN` (recommended - official gh CLI variable)
2. `GITHUB_TOKEN`
3. `GITHUB_PAT`

**Setup:**

```bash
export GH_TOKEN='ghp_your-token-here'
```

### Default Prompt (Optional)

Set a default prompt used when no command line argument is provided:

```bash
export CLAUDETAINER_DEFAULT_PROMPT='Read the .claude instructions.'
```

## Config File

Location: `~/.claudetainer/config`

### Format

The config file uses bash syntax:

```bash
# Default prompt to use when no command line argument is provided
DEFAULT_PROMPT='Read the provided .claude instructions.'
```

### Creating Config File

**Interactive (recommended):**

```bash
claudetainer --set-prompt
```

**Manual:**

```bash
mkdir -p ~/.claudetainer
cat > ~/.claudetainer/config << 'EOF'
DEFAULT_PROMPT='You are a helpful coding assistant.'
EOF
```

**Using install script:**

```bash
./install.sh --api-key "..." --default-prompt "Your prompt"
```

## Command Line Options

### Available Commands

```bash
claudetainer                        # Run with default prompt (if set)
claudetainer "your prompt"          # Run with specific prompt
claudetainer --set-prompt           # Set default prompt (persistent)
claudetainer --show-config          # Show current configuration
claudetainer --help                 # Show help message
```

## Priority Order

When multiple prompt sources are configured:

1. **Command line argument** (highest priority)
   ```bash
   claudetainer "Override prompt"
   ```

2. **Environment variable**
   ```bash
   export CLAUDETAINER_DEFAULT_PROMPT="Environment prompt"
   ```

3. **Config file** (lowest priority)
   ```bash
   # ~/.claudetainer/config
   DEFAULT_PROMPT='Config file prompt'
   ```

## Advanced Configuration

### Multiple Profiles

Create shell aliases for different use cases:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias claude-review='CLAUDETAINER_DEFAULT_PROMPT="Review this code" claudetainer'
alias claude-docs='CLAUDETAINER_DEFAULT_PROMPT="Update documentation" claudetainer'
alias claude-debug='CLAUDETAINER_DEFAULT_PROMPT="Help debug issues" claudetainer'
alias claude-test='CLAUDETAINER_DEFAULT_PROMPT="Write tests" claudetainer'
```

Usage:

```bash
cd ~/project
claude-review  # Automatically uses review prompt
```

### Project-Specific Config

Use different config for different projects:

```bash
# In project directory
cat > .claudetainer-config << 'EOF'
DEFAULT_PROMPT='You are a Python expert. Help with this Django project.'
EOF

# Use it
CONFIG_FILE=".claudetainer-config" claudetainer
```

Or create an alias:

```bash
alias django-claude='CONFIG_FILE=.claudetainer-config claudetainer'
```

### CI/CD Integration

Use in automated pipelines:

```bash
#!/bin/bash
# .github/workflows/claude-review.sh

export ANTHROPIC_API_KEY="${ANTHROPIC_API_SECRET}"
export GH_TOKEN="${GITHUB_TOKEN}"

claudetainer "Review the changes in this pull request"
```

## Shell Configuration Example

Complete example for `~/.zshrc`:

```bash
# ============================================
# Claudetainer Configuration
# ============================================

# API Keys
export ANTHROPIC_API_KEY='sk-ant-api03-...'
export GH_TOKEN='ghp_...'

# Default prompt
export CLAUDETAINER_DEFAULT_PROMPT='Read the .claude instructions in the current project.'

# Convenient aliases
alias claude-review='CLAUDETAINER_DEFAULT_PROMPT="Review this code" claudetainer'
alias claude-docs='CLAUDETAINER_DEFAULT_PROMPT="Update documentation" claudetainer'
alias claude-debug='CLAUDETAINER_DEFAULT_PROMPT="Help debug" claudetainer'

# Add to PATH if using custom location
export PATH="$HOME/.local/bin:$PATH"
```

Apply changes:

```bash
source ~/.zshrc
```

## Viewing Current Configuration

Check your current configuration:

```bash
claudetainer --show-config
```

Output shows:
- Which API key variables are set
- Which GitHub token variables are set
- Default prompt configuration
- Config file location
- Effective settings

## Configuration Files Location

- **Config directory**: `~/.claudetainer/`
- **Config file**: `~/.claudetainer/config`
- **Shell config**: `~/.zshrc` or `~/.bashrc`
- **Backups**: Created with timestamp when modified by install script

## Best Practices

1. **Use environment variables** for API keys (don't commit to git)
2. **Use config file** for default prompts (can commit to git if desired)
3. **Use command line** for one-off prompt overrides
4. **Create aliases** for frequently used prompt patterns
5. **Keep API keys secure** - never commit them or share them
6. **Use .gitignore** to exclude config files with secrets
