---
capture_type: LEARNING
timestamp: 2026-02-11 13:05:24 GMT+7
auto_captured: true
tags: [auto-capture]
---

# Quick Learning: Task Completion

**Date:** 2026-02-11
**Auto-captured:** Yes

---

## Summary

N/A

## Analysis

N/A

## Actions Taken

N/A

## Results

N/A

## Current Status

N/A

## Next Steps

N/A

---

<details>
<summary>Full Response</summary>

Great question, Brett. Let me think through this properly.

## Root Cause Analysis

**What happened:** `.beads/issues.jsonl` was committed to a feature branch commit. Removing it was a 15-minute fight against three layers of beads infrastructure:

1. **Beads daemon** - continuously overwrites the working tree JSONL from the DB
2. **Pre-commit hook** - flushes DB to JSONL before every commit, undoing restores
3. **Pre-push hook** - flushes again and blocks push if JSONL doesn't match DB

**Why it happened in the first place:** Someone (likely a prior session) ran `git add .` or staged the file alongside other changes. The CLAUDE.md warns against this, but warnings aren't enforcement.

**The deeper problem:** `.beads/issues.jsonl` is tracked on `main`. It shouldn't be. The entire beads design says this file belongs only on the `beads-metadata` branch, yet git is tracking it on main, which means every `git add .` or `git add -A` can modify it.

## The Fix

The real fix is to remove it from tracking on main and add it to `.gitignore`:

1. Remove `.beads/issues.jsonl` from git tracking on `main`
2. Add `.beads/` to `.gitignore` so it can never be accidentally staged again

Want me to create a PR to do that? It would be a one-time fix that permanently prevents this from happening again.

## Memory Update

Let me save this lesson for future sessions.

</details>
