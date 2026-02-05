#!/bin/bash
set -e

echo "=== Claudetainer Build Script ==="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    echo "Please install Docker and try again"
    exit 1
fi

# Detect Claude binary location
CLAUDE_BIN=""

echo "Detecting Claude binary location..."

# Method 1: Use CLAUDE_BIN_PATH if set
if [ -n "$CLAUDE_BIN_PATH" ] && [ -f "$CLAUDE_BIN_PATH" ]; then
    CLAUDE_BIN="$CLAUDE_BIN_PATH"
    echo "  Using CLAUDE_BIN_PATH: $CLAUDE_BIN"

# Method 2: Use which command
elif command -v claude &> /dev/null; then
    CLAUDE_BIN=$(which claude)
    echo "  Found via 'which': $CLAUDE_BIN"

# Method 3: Check common paths
elif [ -f "/usr/local/bin/claude" ]; then
    CLAUDE_BIN="/usr/local/bin/claude"
    echo "  Found at: $CLAUDE_BIN"
elif [ -f "/opt/homebrew/bin/claude" ]; then
    CLAUDE_BIN="/opt/homebrew/bin/claude"
    echo "  Found at: $CLAUDE_BIN"
elif [ -f "$HOME/.local/bin/claude" ]; then
    CLAUDE_BIN="$HOME/.local/bin/claude"
    echo "  Found at: $CLAUDE_BIN"
else
    echo ""
    echo "Error: Could not find Claude binary"
    echo ""
    echo "Please specify the path to your Claude binary:"
    echo "  export CLAUDE_BIN_PATH=/path/to/claude"
    echo "  ./build.sh"
    echo ""
    echo "Or install Claude Code from: https://claude.com/claude-code"
    exit 1
fi

# Verify the binary exists and is executable
if [ ! -f "$CLAUDE_BIN" ]; then
    echo "Error: Claude binary not found at: $CLAUDE_BIN"
    exit 1
fi

if [ ! -x "$CLAUDE_BIN" ]; then
    echo "Error: Claude binary is not executable: $CLAUDE_BIN"
    exit 1
fi

echo "  Verified: $CLAUDE_BIN"
echo ""

# Create tmp directory for staging
echo "Staging Claude binary for Docker build..."
mkdir -p tmp
cp "$CLAUDE_BIN" tmp/claude
chmod +x tmp/claude
echo "  Staged to: ./tmp/claude"
echo ""

# Build Docker image
echo "Building Docker image..."
docker build -t claudetainer:latest .

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Build Successful ==="
    echo ""
    echo "Docker image 'claudetainer:latest' created successfully"
    echo ""
    echo "Next steps:"
    echo "  1. Set your API key: export ANTHROPIC_API_KEY=sk-ant-..."
    echo "  2. Test: docker run --rm -it -e ANTHROPIC_API_KEY claudetainer:latest --version"
    echo "  3. Install: ./install.sh"
    echo ""
else
    echo ""
    echo "Error: Docker build failed"
    exit 1
fi

# Clean up tmp directory
rm -rf tmp
