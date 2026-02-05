#!/bin/bash
set -e

echo "=== Claudetainer Installation Script ==="
echo ""

# Check if running with appropriate privileges for /usr/local/bin
if [ ! -w "/usr/local/bin" ] && [ "$EUID" -ne 0 ]; then
    echo "Error: Cannot write to /usr/local/bin"
    echo "Please run with sudo:"
    echo "  sudo ./install.sh"
    exit 1
fi

# Build Docker image first
echo "Step 1: Building Docker image..."
./build.sh

if [ $? -ne 0 ]; then
    echo "Error: Build failed"
    exit 1
fi

echo ""
echo "Step 2: Installing claudetainer command..."

# Copy wrapper script to /usr/local/bin
cp claudetainer /usr/local/bin/claudetainer
chmod +x /usr/local/bin/claudetainer

echo "  Installed to: /usr/local/bin/claudetainer"
echo ""

# Verify installation
if command -v claudetainer &> /dev/null; then
    echo "=== Installation Successful ==="
    echo ""
    echo "Claudetainer is now available system-wide!"
    echo ""
    echo "Setup:"
    echo "  1. Set your API key:"
    echo "     export ANTHROPIC_API_KEY=sk-ant-..."
    echo ""
    echo "  2. Add to your shell profile (~/.bashrc, ~/.zshrc, etc):"
    echo "     export ANTHROPIC_API_KEY=sk-ant-..."
    echo ""
    echo "Usage:"
    echo "  cd /path/to/your/project"
    echo "  claudetainer \"help me with this code\""
    echo ""
    echo "For more information, see README.md"
    echo ""
else
    echo "Warning: claudetainer command not found in PATH"
    echo "You may need to restart your shell or add /usr/local/bin to PATH"
fi
