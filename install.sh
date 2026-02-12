#!/usr/bin/env bash

# Claudetainer Installation Script
# Installs claudetainer and configures shell environment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
INSTALL_METHOD="copy"
INSTALL_PATH="/usr/local/bin"
SHELL_CONFIG=""
API_KEY=""
GITHUB_TOKEN=""
DEFAULT_PROMPT=""
SKIP_SHELL_CONFIG=false
UPDATE_MODE=false
UNINSTALL_MODE=false
REMOVE_CONFIG=false

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Show usage
show_usage() {
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./install.sh --api-key <key> [OPTIONS]"
    echo "  ./install.sh --update [OPTIONS]"
    echo "  ./install.sh --uninstall [OPTIONS]"
    echo ""
    echo -e "${YELLOW}Required (for new installation):${NC}"
    echo "  --api-key <key>              Anthropic API key (required)"
    echo ""
    echo -e "${YELLOW}Update Mode:${NC}"
    echo "  --update                     Update existing installation (no config changes)"
    echo "                               Re-copies the script to installation location"
    echo ""
    echo -e "${YELLOW}Uninstall Mode:${NC}"
    echo "  --uninstall                  Remove claudetainer from system"
    echo "  --remove-config              Also remove shell config and ~/.claudetainer"
    echo ""
    echo -e "${YELLOW}Optional:${NC}"
    echo "  --github-token <token>       GitHub Personal Access Token"
    echo "  --default-prompt <prompt>    Default prompt for claudetainer"
    echo "  --method <copy|symlink>      Installation method (default: copy)"
    echo "  --path <path>                Installation path (default: /usr/local/bin)"
    echo "  --shell-config <file>        Shell config file (auto-detected if not specified)"
    echo "  --skip-shell-config          Don't modify shell config file"
    echo "  --help                       Show this help message"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  # Basic installation"
    echo "  ./install.sh --api-key \"sk-ant-api03-...\""
    echo ""
    echo "  # Full installation with all options"
    echo "  ./install.sh \\"
    echo "    --api-key \"sk-ant-api03-...\" \\"
    echo "    --github-token \"ghp_...\" \\"
    echo "    --default-prompt \"Read the .claude instructions.\" \\"
    echo "    --method symlink"
    echo ""
    echo "  # Install without modifying shell config"
    echo "  ./install.sh --api-key \"sk-ant-api03-...\" --skip-shell-config"
    echo ""
    echo "  # Update existing installation (after git pull)"
    echo "  ./install.sh --update"
    echo ""
    echo "  # Update with specific installation path"
    echo "  ./install.sh --update --path /usr/local/bin"
    echo ""
    echo "  # Uninstall claudetainer"
    echo "  ./install.sh --uninstall"
    echo ""
    echo "  # Uninstall and remove all configuration"
    echo "  ./install.sh --uninstall --remove-config"
    echo ""
    echo -e "${YELLOW}Installation Methods:${NC}"
    echo "  copy      Copy script to installation path (recommended for users)"
    echo "  symlink   Create symlink (recommended for contributors/developers)"
    echo ""
    echo -e "${YELLOW}Notes:${NC}"
    echo "  - API key is required for claudetainer to work"
    echo "  - GitHub token is optional but enables gh CLI support"
    echo "  - Default prompt is optional and can be set later"
    echo "  - Shell config is auto-detected (~/.zshrc or ~/.bashrc)"
    echo ""
    exit 0
}

# Detect shell config file
detect_shell_config() {
    if [ -n "$SHELL_CONFIG" ]; then
        echo "$SHELL_CONFIG"
        return
    fi

    if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
        echo "$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ] || [ -f "$HOME/.bashrc" ]; then
        echo "$HOME/.bashrc"
    else
        echo "$HOME/.profile"
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --update)
                UPDATE_MODE=true
                SKIP_SHELL_CONFIG=true
                shift
                ;;
            --uninstall)
                UNINSTALL_MODE=true
                shift
                ;;
            --remove-config)
                REMOVE_CONFIG=true
                shift
                ;;
            --api-key)
                API_KEY="$2"
                shift 2
                ;;
            --github-token)
                GITHUB_TOKEN="$2"
                shift 2
                ;;
            --default-prompt)
                DEFAULT_PROMPT="$2"
                shift 2
                ;;
            --method)
                INSTALL_METHOD="$2"
                shift 2
                ;;
            --path)
                INSTALL_PATH="$2"
                shift 2
                ;;
            --shell-config)
                SHELL_CONFIG="$2"
                shift 2
                ;;
            --skip-shell-config)
                SKIP_SHELL_CONFIG=true
                shift
                ;;
            --help|-h)
                show_usage
                ;;
            *)
                echo -e "${RED}Error: Unknown option: $1${NC}"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Validate inputs
validate_inputs() {
    # Skip validation in uninstall mode
    if [ "$UNINSTALL_MODE" = true ]; then
        return
    fi

    # Check API key (not required in update mode)
    if [ "$UPDATE_MODE" = false ] && [ -z "$API_KEY" ]; then
        echo -e "${RED}Error: API key is required${NC}"
        echo "Use: ./install.sh --api-key \"your-key-here\""
        echo "Get your API key from: https://console.anthropic.com/settings/keys"
        echo ""
        echo "Or use --update to update existing installation"
        echo "Or use --uninstall to remove claudetainer"
        exit 1
    fi

    # Validate installation method
    if [ "$INSTALL_METHOD" != "copy" ] && [ "$INSTALL_METHOD" != "symlink" ]; then
        echo -e "${RED}Error: Invalid installation method: $INSTALL_METHOD${NC}"
        echo "Valid methods: copy, symlink"
        exit 1
    fi

    # Check if claudetainer script exists
    if [ ! -f "$SCRIPT_DIR/claudetainer" ]; then
        echo -e "${RED}Error: claudetainer script not found in $SCRIPT_DIR${NC}"
        exit 1
    fi

    # Check if install path exists
    if [ ! -d "$INSTALL_PATH" ]; then
        echo -e "${YELLOW}Warning: Install path does not exist: $INSTALL_PATH${NC}"
        echo -n "Create it? (y/n): "
        read -r answer
        if [ "$answer" != "y" ]; then
            echo "Installation cancelled"
            exit 1
        fi
        sudo mkdir -p "$INSTALL_PATH"
    fi
}

# Install claudetainer
install_claudetainer() {
    echo -e "${BLUE}Installing claudetainer...${NC}"

    # Make script executable
    chmod +x "$SCRIPT_DIR/claudetainer"

    # Install based on method
    if [ "$INSTALL_METHOD" = "copy" ]; then
        echo "Copying to $INSTALL_PATH/claudetainer"
        if [ -w "$INSTALL_PATH" ]; then
            cp "$SCRIPT_DIR/claudetainer" "$INSTALL_PATH/claudetainer"
        else
            sudo cp "$SCRIPT_DIR/claudetainer" "$INSTALL_PATH/claudetainer"
        fi
        echo -e "${GREEN}✓ Copied claudetainer to $INSTALL_PATH${NC}"
    else
        echo "Creating symlink at $INSTALL_PATH/claudetainer"
        if [ -w "$INSTALL_PATH" ]; then
            ln -sf "$SCRIPT_DIR/claudetainer" "$INSTALL_PATH/claudetainer"
        else
            sudo ln -sf "$SCRIPT_DIR/claudetainer" "$INSTALL_PATH/claudetainer"
        fi
        echo -e "${GREEN}✓ Created symlink to claudetainer${NC}"
    fi
}

# Configure shell environment
configure_shell() {
    if [ "$SKIP_SHELL_CONFIG" = true ]; then
        echo -e "${YELLOW}Skipping shell configuration (--skip-shell-config specified)${NC}"
        return
    fi

    local shell_config=$(detect_shell_config)
    echo -e "${BLUE}Configuring shell environment...${NC}"
    echo "Shell config file: $shell_config"

    # Backup shell config
    cp "$shell_config" "$shell_config.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✓ Created backup of $shell_config${NC}"

    # Check if claudetainer config already exists
    if grep -q "# Claudetainer configuration" "$shell_config" 2>/dev/null; then
        echo -e "${YELLOW}Warning: Claudetainer configuration already exists in $shell_config${NC}"
        echo -n "Overwrite? (y/n): "
        read -r answer
        if [ "$answer" != "y" ]; then
            echo "Skipping shell configuration"
            return
        fi
        # Remove old configuration
        sed -i.bak '/# Claudetainer configuration/,/# End Claudetainer configuration/d' "$shell_config"
    fi

    # Add configuration to shell config
    cat >> "$shell_config" << EOF

# Claudetainer configuration
export ANTHROPIC_API_KEY='${API_KEY}'
EOF

    if [ -n "$GITHUB_TOKEN" ]; then
        echo "export GH_TOKEN='${GITHUB_TOKEN}'" >> "$shell_config"
    fi

    if [ -n "$DEFAULT_PROMPT" ]; then
        echo "export CLAUDETAINER_DEFAULT_PROMPT='${DEFAULT_PROMPT}'" >> "$shell_config"
    fi

    # Add PATH if not already there and using non-standard location
    if [ "$INSTALL_PATH" != "/usr/local/bin" ] && [ "$INSTALL_PATH" != "/usr/bin" ]; then
        if ! grep -q "$INSTALL_PATH" "$shell_config"; then
            echo "export PATH=\"\$PATH:${INSTALL_PATH}\"" >> "$shell_config"
        fi
    fi

    echo "# End Claudetainer configuration" >> "$shell_config"

    echo -e "${GREEN}✓ Added configuration to $shell_config${NC}"
}

# Create claudetainer config file
create_config_file() {
    if [ -z "$DEFAULT_PROMPT" ]; then
        return
    fi

    echo -e "${BLUE}Creating ~/.claudetainer/config...${NC}"

    mkdir -p "$HOME/.claudetainer"

    cat > "$HOME/.claudetainer/config" << EOF
# Claudetainer configuration file
# Created by install.sh

# Default prompt to use when no command line argument is provided
DEFAULT_PROMPT='${DEFAULT_PROMPT}'
EOF

    echo -e "${GREEN}✓ Created config file at ~/.claudetainer/config${NC}"
}

# Test installation
test_installation() {
    echo -e "${BLUE}Testing installation...${NC}"

    # Source the shell config to get environment variables
    local shell_config=$(detect_shell_config)
    if [ -f "$shell_config" ] && [ "$SKIP_SHELL_CONFIG" = false ]; then
        # Export the variables for testing
        export ANTHROPIC_API_KEY="$API_KEY"
        [ -n "$GITHUB_TOKEN" ] && export GH_TOKEN="$GITHUB_TOKEN"
        [ -n "$DEFAULT_PROMPT" ] && export CLAUDETAINER_DEFAULT_PROMPT="$DEFAULT_PROMPT"
    fi

    # Test if command is available
    if command -v claudetainer &> /dev/null; then
        echo -e "${GREEN}✓ claudetainer command is available${NC}"
    else
        echo -e "${RED}✗ claudetainer command not found in PATH${NC}"
        echo "You may need to restart your shell or run: source $shell_config"
    fi

    # Test help command
    if "$INSTALL_PATH/claudetainer" --help &> /dev/null; then
        echo -e "${GREEN}✓ claudetainer --help works${NC}"
    else
        echo -e "${RED}✗ claudetainer --help failed${NC}"
    fi

    # Test configuration
    if "$INSTALL_PATH/claudetainer" --show-config &> /dev/null; then
        echo -e "${GREEN}✓ claudetainer --show-config works${NC}"
    else
        echo -e "${YELLOW}⚠ claudetainer --show-config returned an error${NC}"
    fi
}

# Uninstall claudetainer
uninstall_claudetainer() {
    echo -e "${BLUE}Uninstalling claudetainer...${NC}"
    echo ""

    local uninstalled_something=false

    # Remove claudetainer from installation path
    local claudetainer_bin="$INSTALL_PATH/claudetainer"
    if [ -e "$claudetainer_bin" ]; then
        echo "Removing $claudetainer_bin"
        if [ -w "$INSTALL_PATH" ]; then
            rm "$claudetainer_bin"
        else
            sudo rm "$claudetainer_bin"
        fi
        echo -e "${GREEN}✓ Removed claudetainer binary${NC}"
        uninstalled_something=true
    else
        echo -e "${YELLOW}⚠ Claudetainer binary not found at $claudetainer_bin${NC}"
    fi

    # Remove config if requested
    if [ "$REMOVE_CONFIG" = true ]; then
        local shell_config=$(detect_shell_config)

        # Remove shell configuration
        if [ -f "$shell_config" ] && grep -q "# Claudetainer configuration" "$shell_config" 2>/dev/null; then
            echo "Removing configuration from $shell_config"
            # Create backup
            cp "$shell_config" "$shell_config.backup.uninstall.$(date +%Y%m%d_%H%M%S)"
            # Remove configuration
            sed -i.bak '/# Claudetainer configuration/,/# End Claudetainer configuration/d' "$shell_config"
            echo -e "${GREEN}✓ Removed shell configuration${NC}"
            echo -e "${BLUE}  Backup created: $shell_config.backup.uninstall.$(date +%Y%m%d_%H%M%S)${NC}"
            uninstalled_something=true
        fi

        # Remove ~/.claudetainer directory
        if [ -d "$HOME/.claudetainer" ]; then
            echo "Removing $HOME/.claudetainer"
            rm -rf "$HOME/.claudetainer"
            echo -e "${GREEN}✓ Removed ~/.claudetainer directory${NC}"
            uninstalled_something=true
        fi
    else
        echo ""
        echo -e "${YELLOW}Note: Shell configuration and ~/.claudetainer preserved${NC}"
        echo "To remove these, run: ./install.sh --uninstall --remove-config"
    fi

    echo ""
    if [ "$uninstalled_something" = true ]; then
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✓ Uninstallation completed${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"

        if [ "$REMOVE_CONFIG" = true ]; then
            echo ""
            echo -e "${YELLOW}Note: You may need to restart your shell or run:${NC}"
            echo "  source $(detect_shell_config)"
        fi
    else
        echo -e "${YELLOW}Nothing to uninstall${NC}"
    fi
    echo ""
}

# Show completion message
show_completion() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    if [ "$UPDATE_MODE" = true ]; then
        echo -e "${GREEN}✓ Update completed successfully!${NC}"
    else
        echo -e "${GREEN}✓ Installation completed successfully!${NC}"
    fi
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo ""

    if [ "$SKIP_SHELL_CONFIG" = false ]; then
        local shell_config=$(detect_shell_config)
        echo -e "${YELLOW}Next steps:${NC}"
        echo "1. Reload your shell configuration:"
        echo "   ${BLUE}source $shell_config${NC}"
        echo ""
        echo "2. Or restart your terminal"
        echo ""
    fi

    echo -e "${YELLOW}Verify installation:${NC}"
    echo "   ${BLUE}claudetainer --help${NC}"
    echo "   ${BLUE}claudetainer --show-config${NC}"
    echo ""

    echo -e "${YELLOW}Usage:${NC}"
    echo "   ${BLUE}cd ~/your-project${NC}"
    echo "   ${BLUE}claudetainer \"Review this code\"${NC}"
    echo ""

    if [ "$INSTALL_METHOD" = "copy" ]; then
        echo -e "${YELLOW}Updating:${NC}"
        echo "   To update claudetainer, run this installer again or:"
        echo "   ${BLUE}cd $SCRIPT_DIR && git pull && cp claudetainer $INSTALL_PATH/${NC}"
        echo ""
    else
        echo -e "${YELLOW}Updating:${NC}"
        echo "   Updates are automatic! Just run:"
        echo "   ${BLUE}cd $SCRIPT_DIR && git pull${NC}"
        echo ""
    fi

    echo "Documentation: https://github.com/marcel-rbro/claudetainer"
}

# Main installation flow
main() {
    echo -e "${GREEN}Claudetainer Installation Script${NC}"
    echo ""

    parse_args "$@"

    # Handle uninstall mode
    if [ "$UNINSTALL_MODE" = true ]; then
        uninstall_claudetainer
        exit 0
    fi

    # Normal installation/update flow
    validate_inputs
    install_claudetainer
    configure_shell
    create_config_file
    test_installation
    show_completion
}

# Run main
main "$@"
