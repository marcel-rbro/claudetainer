#!/bin/bash
set -e

# Create HOME directory if it doesn't exist (with proper permissions)
# Must be writable by the mapped user
mkdir -p "$HOME" 2>/dev/null || true
chmod 777 "$HOME" 2>/dev/null || true

# Create permissive Claude settings if they don't exist
CLAUDE_DIR="${HOME}/.claude"
if [ ! -f "${CLAUDE_DIR}/settings.json" ]; then
    mkdir -p "${CLAUDE_DIR}"
    cat > "${CLAUDE_DIR}/settings.json" <<EOF
{
  "permissions": {
    "allow": ["*"]
  },
  "apiKey": "${ANTHROPIC_API_KEY}",
  "theme": "dark",
  "hasCompletedSetup": true
}
EOF
fi

# Configure git to use workspace for config (avoid HOME permission issues)
export GIT_CONFIG_GLOBAL=/workspace/.gitconfig-claudetainer

# Set git config if credentials provided
if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.name "$GIT_USER_NAME" 2>/dev/null || true
    git config --global user.email "$GIT_USER_EMAIL" 2>/dev/null || true
fi

# Disable git safe directory checks for workspace
git config --global --add safe.directory /workspace 2>/dev/null || true

# Execute Claude with bypass permissions mode
# Using --permission-mode=bypassPermissions instead of --dangerously-skip-permissions
exec claude --permission-mode=bypassPermissions "$@"
