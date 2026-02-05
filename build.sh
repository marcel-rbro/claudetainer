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

echo "Building Docker image with Node.js and npm..."
echo "Claude Code will be installed via npm (@anthropic-ai/claude-code)"
echo ""

# Build Docker image
docker build -t claudetainer:latest .

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Build Successful ==="
    echo ""
    echo "Docker image 'claudetainer:latest' created successfully"
    echo ""
    echo "Claude Code installed via npm (@anthropic-ai/claude-code)"
    echo "Works on any platform - no binary compatibility issues!"
    echo ""
    echo "Next steps:"
    echo "  1. Set your API key: export ANTHROPIC_API_KEY=sk-ant-..."
    echo "  2. Test: claudetainer --version"
    echo "  3. Install: ./install.sh (optional)"
    echo ""
else
    echo ""
    echo "Error: Docker build failed"
    exit 1
fi
