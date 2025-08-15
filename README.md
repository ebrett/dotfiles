# Dotfiles Management with Chezmoi

This repository contains my personal dotfiles managed with [chezmoi](https://chezmoi.io/).

## Quick Commands

| Alias | Command | Description |
|-------|---------|-------------|
| `cm` | `chezmoi` | Main chezmoi command |
| `cms` | `chezmoi status` | See what files have changed |
| `cmd` | `chezmoi diff` | See detailed differences |
| `cma` | `chezmoi apply` | Apply changes from source to home |
| `cmra` | `chezmoi re-add` | Update source from modified home file |
| `cme` | `chezmoi edit` | Edit the source file directly |
| `cmcd` | `cd ~/.local/share/chezmoi` | Navigate to chezmoi source directory |
| `cmup` | `chezmoi update` | Update chezmoi and apply changes |

## Workflow

### Daily Usage
1. Edit dotfiles normally in your home directory
2. Run `cms` (`chezmoi status`) to see what has changed
3. Run `cmd` (`chezmoi diff`) to review the exact changes
4. Run `cmra <file>` (`chezmoi re-add <file>`) to sync changes to chezmoi
5. Commit and push changes to git repository

### Adding New Dotfiles
```bash
chezmoi add ~/.newdotfile
```

### Editing Source Files Directly
```bash
chezmoi edit ~/.zshrc  # Opens ~/.local/share/chezmoi/dot_zshrc
```

## File Organization

### Key Files Managed:
- **Shell Configuration**: `.zshrc`, `.aliases`, `.p10k.zsh`, `.zprofile`
- **Development Tools**: 
  - Git: `.gitconfig`, `.gitignore_global`, `.gitmessage`
  - Tmux: `.tmux.conf`
  - Neovim: `.config/nvim/`
  - Starship: `.config/starship.toml`
  - Mise: `.tool-versions`, `.config/mise/config.toml`
- **Security**: SSH configuration (encrypted), Git secrets hooks
- **Aider**: `.aider.conf.yml` for AI coding assistant

### Naming Convention:
- `dot_filename` → `.filename`
- `private_dot_filename` → `.filename` (not world-readable)
- `encrypted_private_filename.age` → `.filename` (encrypted with age)
- `executable_filename` → executable file
- `empty_filename` → empty file

## Recovery

### On a New Machine:
1. Install chezmoi: `brew install chezmoi`
2. Initialize with this repository: `chezmoi init --apply git@github.com:yourusername/dotfiles.git`

### If You Lose Local Changes:
1. Check what files have changed: `chezmoi status`
2. See the differences: `chezmoi diff`
3. Apply the chezmoi version: `chezmoi apply` (this overwrites local changes)
4. Or apply specific files: `chezmoi apply ~/.zshrc`

## Prevention of Data Loss

### Automatic Reminders:
The `dotfile_check()` function (available after sourcing aliases) will warn you if there are unsynced changes:
```bash
dotfile_check  # Check for unsynced changes
```

### Before Making Major Changes:
```bash
# Always check status first
chezmoi status

# Review what would change
chezmoi diff

# Make a backup if needed
cp ~/.important_file ~/.important_file.backup
```

## Troubleshooting

### "File is not managed by chezmoi":
```bash
chezmoi add ~/.filename
```

### "File has been modified":
```bash
# To keep your local version:
chezmoi re-add ~/.filename

# To use chezmoi version:
chezmoi apply ~/.filename
```

### Merge Conflicts:
```bash
# Edit the source file directly
chezmoi edit ~/.filename

# Or resolve manually and re-add
chezmoi re-add ~/.filename
```

## Best Practices

1. **Always check status before major system changes**: `cms`
2. **Review diffs before applying**: `cmd`
3. **Commit frequently** with descriptive messages
4. **Use descriptive commit messages** explaining what changed and why
5. **Test configuration changes** before committing
6. **Keep sensitive data encrypted** (SSH keys, API tokens)

## Configuration

### Auto-commit Settings:
The chezmoi configuration includes:
- Automatic commits when files are re-added
- Manual push required (for review)

### Machine-Specific Variables:
Use `.chezmoi.toml.tmpl` for machine-specific settings and templating.

---

*Generated on: $(date)*  
*chezmoi version: $(chezmoi --version)*
