# Contributing to Claudetainer

Thank you for your interest in contributing! This guide will help you get set up for development.

## Development Setup

### Prerequisites

- Git
- Bash or Zsh
- Docker Desktop
- Anthropic API key
- Text editor

### Initial Setup

1. **Fork and Clone**

   ```bash
   git clone https://github.com/yourusername/claudetainer.git
   cd claudetainer
   ```

2. **Install for Development (Symlink Method)**

   Using symlinks allows your changes to be immediately available:

   ```bash
   # Create symlink
   mkdir -p ~/.local/bin
   ln -s "$(pwd)/claudetainer" ~/.local/bin/claudetainer

   # Add to PATH if needed
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

   Benefits:
   - No need to reinstall after making changes
   - Changes are immediately testable
   - Easy to test across different projects

3. **Configure Environment**

   ```bash
   export ANTHROPIC_API_KEY='your-key'
   export GH_TOKEN='your-github-token'
   ```

4. **Test Your Setup**

   ```bash
   claudetainer --help
   claudetainer --show-config
   ```

## Making Changes

### Code Style

- Use bash best practices
- Follow existing code style
- Add comments for complex logic
- Use meaningful variable names

### Testing Changes

1. **Test the script directly:**

   ```bash
   ./claudetainer --help
   ./claudetainer "Test prompt"
   ```

2. **Test from PATH:**

   ```bash
   cd ~/test-project
   claudetainer "Test in different directory"
   ```

3. **Test all options:**

   ```bash
   claudetainer --show-config
   claudetainer --set-prompt
   claudetainer "Custom prompt"
   ```

### Common Changes

#### Adding a New Flag

1. Add to usage/help output
2. Add to argument parsing in `parse_args()`
3. Implement the functionality
4. Test thoroughly

#### Modifying Docker Command

The docker command is built in the main script around line 456+:

```bash
DOCKER_ARGS=(sandbox run)
DOCKER_ARGS+=(claude .)
DOCKER_ARGS+=(-- --allowedTools '*')
```

Be careful when modifying - test with different scenarios.

#### Updating Documentation

- Update relevant .md files
- Keep QUICKSTART.md concise
- Put detailed info in specialized docs
- Update examples if behavior changes

## Submitting Changes

### Before You Submit

1. **Test your changes thoroughly**
   - Test installation
   - Test all command-line options
   - Test in different directories
   - Test error cases

2. **Update documentation**
   - Update README.md if needed
   - Update relevant guide files
   - Add examples for new features

3. **Commit message format**

   ```
   Short descriptive title (50 chars or less)

   More detailed explanation if needed. Explain:
   - What changed
   - Why it changed
   - Any breaking changes

   Co-Authored-By: Your Name <your@email.com>
   ```

### Pull Request Process

1. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**

   ```bash
   git add <files>
   git commit -m "Your commit message"
   ```

3. **Push to your fork**

   ```bash
   git push origin feature/your-feature-name
   ```

4. **Open a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your branch
   - Fill in the PR template

### PR Checklist

- [ ] Code works and has been tested
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented if unavoidable)
- [ ] Commit messages are clear
- [ ] Code follows existing style

## Development Tips

### Quick Test Loop

```bash
# Make changes to claudetainer script
vim claudetainer

# Test immediately (symlink makes changes available)
claudetainer --help

# Test in a project
cd ~/test-project
claudetainer "test"
```

### Debug Mode

Add debug output temporarily:

```bash
# In claudetainer script
echo "DEBUG: Variable value: $SOME_VAR" >&2
```

### Testing Install Script

```bash
# Test help
./install.sh --help

# Test with different options
./install.sh --api-key "test" --skip-shell-config

# Test update mode
./install.sh --update

# Test uninstall
./install.sh --uninstall
```

## Project Structure

```
claudetainer/
├── claudetainer          # Main executable script
├── install.sh           # Installation automation
├── README.md            # Project overview
├── QUICKSTART.md        # Quick 5-minute setup
├── INSTALL.md           # Detailed installation
├── CONFIGURATION.md     # Configuration guide
├── TROUBLESHOOTING.md   # Common issues
├── CONTRIBUTING.md      # This file
├── config.example       # Example config
└── .gitignore          # Git ignore rules
```

## Getting Help

- Open an issue for bugs or feature requests
- Discuss major changes before implementing
- Ask questions in issues if unsure

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers
- Focus on what is best for the project
- Show empathy towards others

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to Claudetainer! 🎉
