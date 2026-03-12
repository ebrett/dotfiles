# PAI Intelligent Merge Installation Design

**Date**: 2026-02-04
**Author**: Architect Agent
**Status**: Proposed Architecture

---

## Architectural Analysis

### Problem Statement

PAI's current installation follows a replacement model that prioritizes safety and simplicity:
1. Detect existing ~/.claude directory
2. Create timestamped backup
3. Replace entire directory with PAI structure
4. User manually restores personal content afterward

This approach is safe but creates friction for experienced users who have:
- Per-project CLAUDE.md configurations (in `projects/`)
- Custom commands (in `commands/`)
- Installed plugins with marketplace data (in `plugins/`)
- MCP server configurations (in `mcpServers`)
- Enabled plugins (in `enabledPlugins`)
- Custom agents (in `agents/`)
- Work history and session state

**Observed merge case** (Brett's backup from 2026-02-03):
- Backup contained: projects/, commands/, plugins/, agents/, mcpServers, enabledPlugins
- PAI provided: skills/, hooks/, MEMORY/, VoiceServer/, statusline, settings.json structure
- Successful merge combined both

### Design Requirements

1. **Preserve current simple path** - Full replacement should remain default/safe option
2. **Add intelligent merge option** - For users who want automatic restoration
3. **Clear tradeoffs** - User must understand risks vs. benefits
4. **Rollback safety** - If merge fails, clean recovery to either backup or fresh PAI
5. **Conflict detection** - Identify and surface conflicts for user decision
6. **Post-install verification** - Test that both PAI and user workflow function

---

## Proposed Solution

### Three-Path Installation Flow

```
                    ┌─────────────────────────────────────┐
                    │   PAI Installation Wizard v3.0      │
                    │   Detect: ~/.claude exists?         │
                    └────────────────┬────────────────────┘
                                     │
                    ┌────────────────┴────────────────────┐
                    │           YES                        │
                    ▼                                      ▼
    ┌───────────────────────────────────┐   ┌─────────────────────────────┐
    │   Analyze Existing Installation   │   │   NO existing installation   │
    │   - Scan directory contents       │   │   → Fresh Install            │
    │   - Detect user content types     │   │   (Standard path)            │
    │   - Classify as PAI or User       │   └─────────────────────────────┘
    └────────────────┬──────────────────┘
                     │
    ┌────────────────▼────────────────────────────────────────────────┐
    │                   Present Three Options                          │
    └──────────────────────────────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
   ┌─────────┐  ┌─────────┐  ┌─────────┐
   │ OPTION 1│  │ OPTION 2│  │ OPTION 3│
   │  Fresh  │  │  Smart  │  │  Manual │
   │ Install │  │  Merge  │  │ Restore │
   └────┬────┘  └────┬────┘  └────┬────┘
        │            │            │
        ▼            ▼            ▼
   Backup &      Backup &      Backup &
   Replace       Merge         Replace +
   (current)     (new)         Show Restore
                               Instructions
```

---

## Design Details

### Phase 1: Pre-Installation Analysis

Before presenting options, the installer performs deep analysis:

```typescript
interface InstallationAnalysis {
  existingDir: string;
  backupPath: string;

  // Detected content categories
  userContent: {
    projects: string[];        // Per-project CLAUDE.md configs
    commands: string[];        // Custom command directories
    plugins: PluginState;      // Installed plugins and marketplace data
    agents: string[];          // Custom agent configurations
    skills: string[];          // User-created skills (non-PAI)
  };

  settingsState: {
    hasEnabledPlugins: boolean;
    hasMcpServers: boolean;
    hasCustomHooks: boolean;
    hasCustomPermissions: boolean;
  };

  // Content that would conflict with PAI
  conflicts: {
    hooks: ConflictDetail[];       // User hooks vs PAI hooks
    skills: ConflictDetail[];      // User skills vs PAI skills
    settings: ConflictDetail[];    // Settings key conflicts
  };

  // Recommendation
  recommendation: 'fresh' | 'merge' | 'manual';
  confidence: 'high' | 'medium' | 'low';
  reason: string;
}
```

### Phase 2: Content Classification

The algorithm classifies every item in ~/.claude:

```typescript
interface ContentClassification {
  category: 'pai_core' | 'pai_optional' | 'user_content' | 'transient' | 'unknown';
  action: 'replace' | 'preserve' | 'merge' | 'ask_user';
  risk: 'none' | 'low' | 'medium' | 'high';
}

const CLASSIFICATION_RULES: Record<string, ContentClassification> = {
  // PAI Core - Always replace with new PAI version
  'skills/PAI/': { category: 'pai_core', action: 'replace', risk: 'none' },
  'skills/*/SKILL.md': { category: 'pai_core', action: 'replace', risk: 'none' },
  'hooks/': { category: 'pai_core', action: 'replace', risk: 'low' },
  'MEMORY/': { category: 'pai_core', action: 'replace', risk: 'none' },
  'VoiceServer/': { category: 'pai_core', action: 'replace', risk: 'none' },
  'statusline-*.sh': { category: 'pai_core', action: 'replace', risk: 'none' },
  'lib/': { category: 'pai_core', action: 'replace', risk: 'none' },
  'INSTALL.*': { category: 'pai_core', action: 'replace', risk: 'none' },

  // User Content - Always preserve
  'projects/': { category: 'user_content', action: 'preserve', risk: 'none' },
  'commands/': { category: 'user_content', action: 'preserve', risk: 'none' },
  'agents/': { category: 'user_content', action: 'preserve', risk: 'low' },
  'plugins/': { category: 'user_content', action: 'preserve', risk: 'low' },

  // Merge candidates - Combine user and PAI content
  'settings.json': { category: 'pai_optional', action: 'merge', risk: 'medium' },

  // Transient - Can be regenerated
  'cache/': { category: 'transient', action: 'replace', risk: 'none' },
  'session-env/': { category: 'transient', action: 'replace', risk: 'none' },
  'shell-snapshots/': { category: 'transient', action: 'replace', risk: 'none' },
  'todos/': { category: 'transient', action: 'replace', risk: 'none' },
  'debug/': { category: 'transient', action: 'replace', risk: 'none' },
  'history.jsonl': { category: 'transient', action: 'replace', risk: 'low' },

  // Unknown - User decision required
  '*': { category: 'unknown', action: 'ask_user', risk: 'high' }
};
```

### Phase 3: Merge Algorithm

For settings.json specifically:

```typescript
interface SettingsMergeStrategy {
  // PAI takes precedence - these define PAI functionality
  paiOwned: [
    'paiVersion',
    'contextFiles',
    'daidentity',      // Merged with user name preference
    'principal',       // Merged with user name preference
    'pai',
    'techStack',
    'hooks',
    'statusLine',
    '_docs'
  ];

  // User takes precedence - personal customizations
  userOwned: [
    'enabledPlugins',
    'mcpServers',
    'permissions.allow',  // Extend, don't replace
    'permissions.deny',   // Extend, don't replace
    'permissions.ask',    // PAI defaults + user additions
  ];

  // Intelligent merge - combine both
  merged: [
    'env',              // PAI env + user env
    'permissions',      // PAI structure + user customizations
  ];
}

function mergeSettings(paiSettings: object, userSettings: object): object {
  const result = { ...paiSettings };

  // Preserve user plugins and MCP servers
  if (userSettings.enabledPlugins) {
    result.enabledPlugins = userSettings.enabledPlugins;
  }
  if (userSettings.mcpServers) {
    result.mcpServers = userSettings.mcpServers;
  }

  // Merge permissions (PAI base + user additions)
  if (userSettings.permissions) {
    result.permissions.allow = [
      ...new Set([...paiSettings.permissions.allow, ...(userSettings.permissions.allow || [])])
    ];
    result.permissions.ask = [
      ...new Set([...paiSettings.permissions.ask, ...(userSettings.permissions.ask || [])])
    ];
  }

  // Preserve user's custom hooks if they existed
  if (userSettings.hooks && !isPAIHooksOnly(userSettings.hooks)) {
    // Flag for conflict resolution
    result._userHooksDetected = true;
  }

  return result;
}
```

### Phase 4: User Interface

#### Option Display

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃              PAI Installation Wizard v3.0                      ┃
┃       Personal AI Infrastructure - Existing Installation       ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

  Detected in your existing ~/.claude:
    → 7 project configurations
    → 1 custom command directory
    → 9 installed plugins
    → 1 MCP server configuration

  Choose your installation path:

  ┌─────────────────────────────────────────────────────────────┐
  │ 1. Fresh Install (SAFEST)                                   │
  │    Backup existing → Install clean PAI → Manual restore     │
  │    Best for: Uncertain about current config, want control   │
  └─────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────┐
  │ 2. Smart Merge (RECOMMENDED)                                │
  │    Backup existing → Install PAI → Auto-restore user content│
  │    Preserves: projects, commands, plugins, MCP servers      │
  │    Best for: Keep development workflow + add PAI            │
  └─────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────┐
  │ 3. Full Replace (DESTRUCTIVE)                               │
  │    Backup existing → Complete replacement with PAI          │
  │    Warning: All customizations lost (backup available)      │
  │    Best for: Starting completely fresh                      │
  └─────────────────────────────────────────────────────────────┘
```

#### Conflict Resolution UI

When conflicts are detected:

```
  ⚠️  Potential conflicts detected:

  Your settings.json contains custom hooks:
    - PreCompact: "bd prime"
    - SessionStart: "bd prime"

  PAI has its own hooks for these events.

  How should we handle this?

    1. Keep PAI hooks only (recommended)
       Your hooks will be saved in backup

    2. Keep both (may cause issues)
       PAI hooks run first, then your hooks

    3. Keep only my hooks
       Skip PAI lifecycle hooks

  Choose [1-3]:
```

### Phase 5: Rollback Strategy

```typescript
interface RollbackCapability {
  // Backup preservation
  backupPath: string;  // e.g., ~/.claude-backup-20260204-153045
  backupManifest: {
    timestamp: string;
    files: string[];
    originalSettingsJson: string;
    userContentDirs: string[];
  };

  // Recovery commands
  rollbackToBackup(): void;
  rollbackToFreshPAI(): void;
  partialRestore(items: string[]): void;
}

// Rollback script generated during installation
const ROLLBACK_SCRIPT = `
#!/bin/bash
# PAI Installation Rollback
# Generated: {timestamp}
# Backup: {backupPath}

echo "PAI Rollback Options:"
echo "1) Restore pre-PAI installation completely"
echo "2) Remove PAI, keep my content"
echo "3) Reset to fresh PAI"
read -p "Choose [1-3]: " choice

case $choice in
  1) rm -rf ~/.claude && mv {backupPath} ~/.claude ;;
  2) # Selective restore
     rm -rf ~/.claude/skills ~/.claude/hooks ~/.claude/MEMORY
     cp -r {backupPath}/settings.json ~/.claude/ ;;
  3) # Fresh PAI
     rm -rf ~/.claude
     # Re-run PAI installer... ;;
esac
`;
```

### Phase 6: Post-Installation Verification

```typescript
interface VerificationSuite {
  // PAI functionality checks
  paiChecks: [
    { name: 'settings.json valid', test: () => parseJSON('settings.json') },
    { name: 'PAI skill exists', test: () => exists('skills/PAI/SKILL.md') },
    { name: 'Hooks directory exists', test: () => exists('hooks/') },
    { name: 'MEMORY directory exists', test: () => exists('MEMORY/') },
  ];

  // User content preservation checks
  userChecks: [
    { name: 'Projects restored', test: () => exists('projects/') && compareWithBackup('projects/') },
    { name: 'Plugins restored', test: () => exists('plugins/') && pluginsIntact() },
    { name: 'MCP servers in settings', test: () => settings.mcpServers != null },
    { name: 'Enabled plugins in settings', test: () => settings.enabledPlugins != null },
  ];

  // Integration checks
  integrationChecks: [
    { name: 'No permission conflicts', test: () => permissionsValid() },
    { name: 'Hooks executable', test: () => hooksExecutable() },
    { name: 'Voice server starts', test: () => voiceServerStarts() },
  ];
}
```

---

## Trade-offs & Decisions

### What We're Optimizing For

1. **Safety over speed** - Always create backup first
2. **Predictability over magic** - Show user exactly what will happen
3. **Recovery over perfection** - Merge can fail; rollback must not
4. **User agency over automation** - User makes final decisions on conflicts

### What We're Sacrificing

1. **Simplicity** - Three paths instead of one
2. **Installation speed** - Analysis takes time
3. **Complete automation** - Some decisions require user input

### Key Design Decisions

1. **Backup is always mandatory** - No option to skip backup
2. **Fresh Install remains default** - Safest path for uncertain users
3. **Smart Merge is opt-in** - User must understand they're choosing complexity
4. **Conflicts pause installation** - Never silently resolve conflicts
5. **Rollback script generated** - Even if installer fails, recovery is possible

---

## Implementation Plan

### Phase 1: Foundation (Week 1)
- [ ] Create ContentClassifier module
- [ ] Create SettingsMerger module
- [ ] Create RollbackManager module
- [ ] Add backup manifest generation

### Phase 2: Analysis Engine (Week 2)
- [ ] Implement directory scanning
- [ ] Implement conflict detection
- [ ] Create analysis report generator
- [ ] Add recommendation engine

### Phase 3: User Interface (Week 3)
- [ ] Build three-path selection UI
- [ ] Build conflict resolution UI
- [ ] Create post-installation summary
- [ ] Add --non-interactive flag with defaults

### Phase 4: Verification (Week 4)
- [ ] Implement verification suite
- [ ] Add rollback testing
- [ ] Create integration tests
- [ ] Document edge cases

---

## Testing Strategy

### Unit Tests
- ContentClassifier correctly categorizes all known patterns
- SettingsMerger produces valid JSON
- RollbackManager restores exactly

### Integration Tests
- Full flow: Fresh Install path
- Full flow: Smart Merge path
- Full flow: Rollback after failed merge
- Merge with various conflict scenarios

### Manual Testing Checklist
- [ ] Install on clean system (no ~/.claude)
- [ ] Install over minimal ~/.claude
- [ ] Install over complex ~/.claude (Brett's case)
- [ ] Rollback from each installation type
- [ ] Verify PAI skills work post-merge
- [ ] Verify user plugins work post-merge
- [ ] Verify MCP servers work post-merge

---

## Risk Assessment

### High Risk
| Risk | Mitigation |
|------|------------|
| Merge corrupts settings.json | Always validate JSON before writing; backup exists |
| User content lost | Backup manifest lists all content; nothing deleted without backup |
| PAI hooks don't work after merge | Verification suite catches this; rollback available |

### Medium Risk
| Risk | Mitigation |
|------|------------|
| Unknown directory patterns | Default to 'ask_user' for unrecognized content |
| Plugin compatibility | Preserve plugins exactly as-is; don't modify |
| MCP server auth tokens | Copy exactly; warn about potential expiration |

### Low Risk
| Risk | Mitigation |
|------|------------|
| Backup takes too much space | Compress backup; offer cleanup after verification |
| Installation takes longer | Progress indicators; estimated time display |

---

## Appendix: Brett's Merge Case Study

### What Was In Backup
```
~/.claude-backup-20260203/
├── agents/                    # User content - preserved
├── commands/journal/          # User content - preserved
├── plugins/                   # User content - preserved
│   ├── installed_plugins.json
│   ├── known_marketplaces.json
│   └── marketplaces/
├── projects/                  # User content - preserved
│   ├── -Users-bmc/
│   ├── -Users-bmc-Code-Active-Ruby-citizen/
│   └── ... (7 project configs)
└── settings.json              # Merge candidate
    ├── enabledPlugins         # → merged into PAI settings
    └── mcpServers             # → merged into PAI settings
```

### What PAI Provided
```
~/.claude/ (new PAI installation)
├── skills/                    # PAI core - installed fresh
│   ├── PAI/
│   ├── Research/
│   ├── CreateCLI/
│   └── ... (28 skills)
├── hooks/                     # PAI core - installed fresh
├── MEMORY/                    # PAI core - installed fresh
├── VoiceServer/               # PAI core - installed fresh
├── lib/                       # PAI core - installed fresh
├── INSTALL.ts                 # PAI core - installed fresh
└── settings.json              # PAI structure with user values merged
```

### Merge Result
```
~/.claude/ (final merged state)
├── [PAI Core]
│   ├── skills/, hooks/, MEMORY/, VoiceServer/, lib/
│   └── settings.json with PAI structure
├── [User Content Restored]
│   ├── projects/              # All 7 project configs
│   ├── commands/journal/      # Custom command
│   ├── plugins/               # Plugin state
│   └── agents/                # Agent configs
└── [Merged Settings]
    ├── PAI: paiVersion, contextFiles, daidentity, principal, hooks, etc.
    └── User: enabledPlugins (9 plugins), mcpServers (1 server)
```

This case study proves the merge concept works and provides the foundation for the automated implementation.

---

*Architecture designed by Architect Agent using FirstPrinciples thinking and deep analysis of the existing PAI installation flow.*
