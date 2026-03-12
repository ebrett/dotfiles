# PAI MEMORY Recovery Procedures

## Quick Recovery (Git-based)

### Scenario 1: Accidental file deletion or modification

```bash
cd ~/.claude/MEMORY
git status                    # See what changed
git diff                      # Review changes
git restore <file>            # Restore specific file
# OR
git reset --hard              # Restore everything to last commit
```

### Scenario 2: Need older version

```bash
cd ~/.claude/MEMORY
git log --oneline -20         # Find commit you want
git show <commit>:<file>      # View file from that commit
git restore --source=<commit> <file>   # Restore from specific commit
```

### Scenario 3: Complete disaster - restore entire MEMORY

```bash
# If MEMORY directory is completely gone
cd ~/.claude
rm -rf MEMORY  # If corrupted
git clone git@github.com:brettmchargue/pai-memory.git MEMORY

# If you just need to reset to remote state
cd ~/.claude/MEMORY
git fetch origin
git reset --hard origin/main
```

## Recovery Time Estimate

- Single file restore: **30 seconds**
- Full MEMORY restore from GitHub: **2-3 minutes** (depends on internet speed)
- Full system restore (if laptop destroyed): **10-15 minutes** (reinstall Claude Code + clone repo)

## Backup Status Check

```bash
# Check last backup time
cd ~/.claude/MEMORY && git log -1 --format="%cd" --date=local

# Check if changes need backing up
cd ~/.claude/MEMORY && git status

# Manually trigger backup
cd ~/.claude/MEMORY && git add -A && git commit -m "Manual backup" && git push

# Check launchd job status
launchctl list | grep pai-memory-backup
tail -20 /tmp/pai-memory-backup.log
```

## What's Backed Up

✅ **Backed up (git + GitHub):**
- WORK/ - All work tracking and artifacts
- LEARNING/ - All learnings, ratings, patterns
- RESEARCH/ - Agent outputs
- README.md, RECOVERY.md

⚠️ **Not backed up (ephemeral state):**
- STATE/ cache files (git-cache, weather-cache, etc.)
- VOICE/ events (high-frequency, low value)

## GitHub Repository

- **Private repo**: https://github.com/ebrett/pai-memory
- **Git URL**: git@github.com:ebrett/pai-memory.git
- **Retention**: Unlimited (full git history)
- **Access**: SSH key authentication

## Monitoring

The launchd job runs twice daily (2 AM and noon Bangkok time). Check logs:

```bash
# View last backup attempt
tail /tmp/pai-memory-backup.log

# View errors (should be empty)
tail /tmp/pai-memory-backup-error.log

# Test backup manually
cd ~/.claude/MEMORY
bash -c 'git add -A && git diff --staged --quiet || git commit -m "Test backup" && git push'
```

## Next Steps (Optional Enhancements)

1. **Set up restic for encrypted cloud backup** (Tier 2)
2. **Fix Time Machine** (Tier 3 - local fast recovery)
3. **Add Slack/email alerts** if backup fails

---

**Created:** 2026-02-04
**Last Updated:** 2026-02-04
