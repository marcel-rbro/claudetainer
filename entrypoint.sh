#!/bin/bash
set -e

# Create HOME directory if it doesn't exist
mkdir -p "$HOME"

# Create permissive Claude settings if they don't exist
CLAUDE_DIR="${HOME}/.claude"
if [ ! -f "${CLAUDE_DIR}/settings.json" ]; then
    mkdir -p "${CLAUDE_DIR}"
    cat > "${CLAUDE_DIR}/settings.json" <<'EOF'
{
  "permissions": {
    "allow": ["*"]
  }
}
EOF
fi

# Configure git if credentials provided
if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Disable git safe directory checks for workspace
git config --global --add safe.directory /workspace 2>/dev/null || true

# Execute Claude with safety checks disabled
exec claude --dangerously-skip-permissions "$@"
