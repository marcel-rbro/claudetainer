#!/bin/bash
# Claudetainer Uninstall Script

echo "=== Claudetainer Uninstall ==="
echo ""

# Remove command
if [ -f ~/.local/bin/claudetainer ]; then
    rm ~/.local/bin/claudetainer
    echo "✓ Removed ~/.local/bin/claudetainer"
else
    echo "  claudetainer command not found"
fi

# Remove Docker image
if docker images | grep -q claudetainer; then
    docker rmi claudetainer:latest
    echo "✓ Removed Docker image"
else
    echo "  Docker image not found"
fi

# Remove from PATH
if grep -q ".local/bin.*PATH" ~/.zshrc 2>/dev/null; then
    cp ~/.zshrc ~/.zshrc.backup
    grep -v ".local/bin.*PATH" ~/.zshrc.backup > ~/.zshrc
    echo "✓ Removed from PATH (~/.zshrc)"
    echo "  Backup saved to ~/.zshrc.backup"
else
    echo "  PATH entry not found in ~/.zshrc"
fi

echo ""
echo "=== Uninstall Complete ==="
echo ""
echo "Claudetainer has been removed."
echo "Restart your terminal or run: source ~/.zshrc"
echo ""
echo "Optional cleanup:"
echo "  - Project directory: rm -rf /path/to/claudetainer"
echo "  - Claude config: rm -rf ~/.claude (removes all Claude settings)"
