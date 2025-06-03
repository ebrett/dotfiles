# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a chezmoi dotfiles repository that manages personal development environment configuration across macOS systems. Chezmoi is a tool for managing dotfiles across multiple machines by using templates and state management.

## File Naming Convention

Chezmoi uses a specific naming convention:
- `dot_` prefix represents a `.` in the actual filename (e.g., `dot_zshrc` → `.zshrc`)
- `private_` prefix marks files as private (not world-readable)
- `empty_` prefix creates empty files
- `.tmpl` suffix indicates template files that use Go text templates

## Key Configuration Files

- `dot_zshrc`: Main zsh shell configuration with oh-my-zsh, plugins, aliases, and environment setup
- `dot_aider.conf.yml`: Aider AI coding assistant configuration (using Sonnet model, auto-commits disabled)
- `private_dot_gitconfig`: Git configuration with signing, credentials, and git-secrets integration
- `run_once_before_install-packages-darwin.sh.tmpl`: macOS package installation script using Homebrew
- `dot_railsrc`: Rails application generation defaults (PostgreSQL, Tailwind CSS, importmap)

## Common Operations

### Testing Configuration Changes
```bash
# Dry run to see what would change
chezmoi diff

# Apply changes
chezmoi apply

# Apply specific file
chezmoi apply ~/.zshrc
```

### Managing Dotfiles
```bash
# Add new dotfile to chezmoi
chezmoi add ~/.newconfig

# Edit a managed file
chezmoi edit ~/.zshrc

# Re-add file after manual changes
chezmoi re-add ~/.zshrc
```

### Template Variables
Template files can access chezmoi data:
- `.chezmoi.os` - Operating system (darwin, linux, etc.)
- `.chezmoi.arch` - Architecture (amd64, arm64, etc.)

## Development Environment

The configuration sets up a full development environment with:
- **Shell**: zsh with oh-my-zsh, extensive plugins (git, docker, rails, python, etc.)
- **Editor**: Neovim (nvim) as default, with VSCode integration
- **Version Management**: mise for runtime version management, nvm for Node.js
- **Package Management**: Homebrew for macOS packages
- **Security**: 1Password SSH signing, git-secrets for AWS credential scanning
- **Development Tools**: Docker, tmux, direnv, fzf, Google Cloud SDK

## Important Paths and Aliases

The zsh configuration includes key aliases:
- `gam`: Google Admin SDK tool
- `dc`: docker-compose shorthand
- `fabric`: fabric-ai tool
- Custom Git aliases and Docker workflows

Environment variables point to:
- GOPATH: `$HOME/go`
- Obsidian vault: `$HOME/Documents/Personal`
- Custom binary paths in `$PATH`