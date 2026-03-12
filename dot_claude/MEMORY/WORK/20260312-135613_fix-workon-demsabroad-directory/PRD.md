---
task: Fix workon script not finding demsabroad projects
slug: 20260312-135613_fix-workon-demsabroad-directory
effort: standard
phase: complete
progress: 8/8
mode: interactive
started: 2026-03-12T06:56:12Z
updated: 2026-03-12T07:02:00Z
---

## Context

`workon athena` fails because `athena` lives at `~/Projects/demsabroad/athena`, not `~/Projects/athena`. The script's project listing (`ls -d "$PROJECTS_DIR"/*/`) only finds depth-1 dirs. Need to add a `_list_projects()` helper that detects group dirs (non-git dirs whose children are git repos) and lists their children as `group/child`. Also need to handle derived names (SESSION, OBSIDIAN_NOTE, JOURNAL_PATH) that need basename only.

### Risks

- Heuristic for group detection (no .git + children have .git) could misfire on edge cases
- Session name collision if two groups share a child name (low risk for now)

## Criteria

- [x] ISC-1: `_list_projects` function added to script
- [x] ISC-2: Dirs with `.git` listed as bare name (e.g., `learn-rust`)
- [x] ISC-3: Non-git dirs with git children listed as `group/child` (e.g., `demsabroad/athena`)
- [x] ISC-4: fzf no-arg picker uses `_list_projects` instead of `ls -d`
- [x] ISC-5: Partial name fzf search uses `_list_projects` instead of `ls -d`
- [x] ISC-6: `SESSION` uses `SHORT_NAME` (basename) not full path
- [x] ISC-7: `OBSIDIAN_NOTE` uses `SHORT_NAME` (basename) not full path
- [x] ISC-8: `JOURNAL_PATH` and jrnl calls use `SHORT_NAME` (basename)

## Decisions

## Verification
