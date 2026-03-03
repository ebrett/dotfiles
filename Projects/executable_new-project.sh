#!/bin/bash
# new-project.sh — Minimal project scaffolding for ~/Projects/
# Usage: ./new-project.sh <project-name>
# Or add to .zshrc: alias newproject="~/Projects/new-project.sh"
set -euo pipefail

NAME="${1:?Usage: new-project.sh <project-name>}"
DIR="$HOME/Projects/$NAME"
VAULT="$HOME/vaults/knowledge-base"
TODAY=$(date +%Y-%m-%d)

# Validate name (no spaces, lowercase-friendly)
if [[ "$NAME" =~ [[:space:]] ]]; then
  echo "Error: project name should not contain spaces (use-hyphens-instead)"
  exit 1
fi

# Create project directory
if [[ -d "$DIR" ]]; then
  echo "Error: $DIR already exists"
  exit 1
fi

mkdir -p "$DIR"
cd "$DIR"

# Initialize git
git init --quiet

# Scaffold the three required files
cat > README.md << TMPL
# $NAME

> [One sentence: what this is and why it exists]

## Overview

[2-3 sentences of context]

## Getting Started

[How to set up and run this project]
TMPL

cat > TASKS.md << TMPL
# Tasks — $NAME

## Active

- [ ] [First task]

## Backlog

## Done

TMPL

cat > CLAUDE.md << TMPL
# Project: $NAME

## What This Is

[Fill in: purpose, scope, what problem it solves]

## Architecture

[Key technical decisions and structure]

## How to Run

[Commands to start, test, build]

## Key Files

| File | Purpose |
|------|---------|
| README.md | Public-facing overview |
| TASKS.md | Active work items |

## Key Decisions

| Date | Decision | Why |
|------|----------|-----|
| $TODAY | Started project | [Reason] |
TMPL

# Initial commit
git add .
git commit --quiet -m "Initial scaffold: $NAME"

echo ""
echo "✓ Created: $DIR"
echo "✓ Git initialized with initial commit"
echo ""

# Create Obsidian anchor note (if vault exists)
if [[ -d "$VAULT/01_Projects" ]]; then
  ANCHOR="$VAULT/01_Projects/${NAME}.md"
  if [[ ! -f "$ANCHOR" ]]; then
    cat > "$ANCHOR" << ANCHOR
---
status: active
location: ~/Projects/$NAME
created: $TODAY
---

# $NAME

[One sentence: what this is and why it exists]

## Quick Access

\`\`\`bash
cd ~/Projects/$NAME
\`\`\`

## Decision Log

- $TODAY: Started project — [reason]

ANCHOR
    echo "✓ Obsidian anchor: $ANCHOR"
  fi
elif [[ -d "$VAULT" ]]; then
  echo "! Obsidian vault found but no 01_Projects/ subfolder."
  echo "  Create $VAULT/01_Projects/ to enable anchor note creation."
else
  echo "! No Obsidian vault found at $VAULT"
  echo "  Skipping anchor note. Update VAULT path in new-project.sh if needed."
fi

# Update PROJECTS.md index
echo ""
echo "→ Remember to update ~/Projects/PROJECTS.md with this project entry:"
echo "  | $NAME | active | [description] | $TODAY |"
echo ""
echo "Done. Open project:"
echo "  cd ~/Projects/$NAME"
