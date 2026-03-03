# Projects Root — Shared Context for All Projects

This file is loaded by Claude Code whenever working in any project under ~/Projects/.
It defines Brett's preferences, environment, and conventions that apply across all projects.

## Who I Am

- **Name:** Brett
- **Shell:** zsh on macOS
- **Runtime management:** mise (not nvm/pyenv directly)
- **JS/TS:** bun (not npm/yarn)
- **Python:** uv
- **Secrets:** 1Password (never hardcode secrets)
- **Editor:** Neovim as primary, VS Code for GUI needs
- **Git signing:** 1Password SSH signing

## How I Like to Work

- Prefer simple over clever. The right amount of abstraction is the minimum needed.
- Don't add error handling for scenarios that can't happen.
- Don't create helpers for one-time operations.
- Commit messages should explain *why*, not *what*.
- No auto-commit unless I explicitly ask.
- Test-driven when working on anything non-trivial.

## Environment

- Obsidian vault: ~/vaults/knowledge-base/ (PARA structure)
- Projects index: ~/Projects/PROJECTS.md
- New project script: ~/Projects/new-project.sh

## Project Conventions

Every project in ~/Projects/ should have:
- `README.md` — what it is and why it exists (1-2 paragraphs max)
- `TASKS.md` — current work items (the source of truth for tasks)
- `CLAUDE.md` — project-specific context (architecture, how to run, key decisions)

## When to Use Projects/ vs Obsidian

**Use ~/Projects/ when:**
- The project requires tool-mediated work producing artifacts beyond prose
- You need a terminal, build tool, or Claude working on multiple files
- You would benefit from `git log` on the project

**Stay in Obsidian PARA when:**
- The primary artifact is prose/notes
- The project is planning, research, or journaling
- No code or structured data is involved

**Hard cases:**
- Writing projects: start in Obsidian, graduate to Projects/ when you need git history or Claude restructuring files
- Research: stays in Obsidian unless the research involves scraping, data processing, or code

## Cross-Project Memory

See ~/.claude/projects/-Users-bmc-Projects/memory/ for session-level memory about work done across projects.
