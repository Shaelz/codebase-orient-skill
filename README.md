# Codebase Orient Skill

An Agent Skill for **Claude Code** and **Codex** that turns "scan this repo" into a repeatable codebase orientation workflow.

Instead of asking the model to vaguely "understand the project," this skill guides it to build and maintain a small orientation layer:

- a codebase map
- a change-surface map
- an open-questions list
- confidence labels for architectural claims
- hidden-risk and source-of-truth drift reporting

The goal is simple:

> Help Claude become less stupid before touching your code.

---

## What this skill does

`codebase-orient` helps Claude inspect a repository in a structured way before non-trivial work.

It asks Claude to:

1. Read high-signal files first (project instructions, docs, config).
2. Identify the framework, entrypoints, routes, models, services, UI surfaces, tests, and deployment/config files.
3. Create or refresh repo-local orientation docs.
4. Mark uncertainty explicitly.
5. Identify which files matter for different kinds of changes.
6. Detect hidden risks such as stale docs, multiple active copies, generated/runtime mismatches, and source-of-truth drift.

It is useful before:

- refactors or architecture changes
- unfamiliar-area edits
- data model or schema changes
- deployment or config changes
- any task where source-of-truth drift or hidden risks would matter

---

## Scope and cost

This skill is not a full static analysis tool. It reads selectively, not exhaustively.

- On small repos, it may read a modest number of high-signal files.
- On large repos, it should focus on relevant surfaces rather than reading everything.
- First orientation takes more time than a refresh of existing docs.
- Dry-run mode is useful if you want to review proposed changes before Claude writes anything.

Orientation improves Claude's process, but it does not replace source verification. Claude should verify claims against the actual source before editing.

`docs/ai/` acts as an orientation cache. A fresh cache reduces repeated repo-discovery token cost across sessions. Use the skill when that cost is likely to amortize - before broad work, at the start of a new session, or before agent handoff. Skip it for tiny single-file known edits.

---

## What it creates in a repo

When used in a project, the skill may create or update:

```text
docs/ai/CODEBASE_MAP.md
docs/ai/CHANGE_SURFACES.md
docs/ai/OPEN_QUESTIONS.md
```

When installed into a project (via install scripts or the bootstrap skill), the skill file lives at:

| Tool | Repo-local skill path |
|---|---|
| Claude Code | `.claude/skills/codebase-orient/SKILL.md` |
| Codex | `.agents/skills/codebase-orient/SKILL.md` |

The source of truth is always `skills/codebase-orient/SKILL.md` in this repository. Installed copies are targets - not forks.

The skill works out of the box without editing. `SKILL.md` ships with a broad, generic discovery order that covers most project shapes. You can tune that order for your specific project later, but customization is optional - not required before first use.

### Local tuning after the first orientation pass

The public skill is intentionally generic. After the first orientation pass, you may find that your project has important namespaces, service folders, admin surfaces, workflow directories, or other conventions that the generic probe list did not cover. The skill will propose updating the repo-local `SKILL.md` with those project-specific discovery paths. This is expected and useful - it makes future orientation passes faster and more accurate for that repo. It is not a fork failure. Concrete project-specific paths should stay in the repo-local skill and should not be submitted back to the public skill.

### `CODEBASE_MAP.md`

A high-level architecture map of the project.

Typical sections:

- project identity
- runtime/framework
- entry points/routes
- domain/data model
- services/workflows
- admin/UI surfaces
- public/UI surfaces
- persistence/schema
- tests
- deployment/config
- important docs
- known uncertainty

#### Example excerpt

```markdown
## Runtime / framework
- Framework: Next.js 14 (App Router) - Fact, full-source-read
- Language: TypeScript - Fact, full-source-read
- Package manager: pnpm - Fact, path-confirmed (pnpm-lock.yaml)

## Entry points
- Web app: app/layout.tsx - Fact, path-confirmed
- API routes: app/api/**: Strong inference, inferred from implementation
- Background jobs: jobs/ directory - Weak inference, no scheduler config found

## Authentication
- Auth provider: unclear - Unknown, needs inspection
- Session storage: likely cookie-based - Weak inference, inferred from middleware

## Known uncertainty
- Whether jobs/ is actively used or legacy - Unknown
- Whether app/api/admin routes are gated by middleware - Unknown
```

### `CHANGE_SURFACES.md`

A practical lookup map for future agents.

Example:

```text
If changing routes/pages, inspect these files first.
If changing styling/theme, inspect these files first.
If changing auth, inspect these files first.
If changing tests, inspect these files first.
```

### `OPEN_QUESTIONS.md`

A list of real uncertainties found during inspection.

The skill tries not to invent concerns. Open questions should be useful, grounded, and actionable.

---

## How orientation works (normal mode)

During orientation, Claude follows this sequence:

1. **Reads project instructions and docs first**: CLAUDE.md / AGENTS.md, README, any existing docs/ai files.
2. **Checks framework, config, and entrypoints**: package.json, tsconfig, Dockerfile, CI files, root config.
3. **Maps routes, models, services, UI surfaces, tests, and deployment**: in enough depth to understand the shape, not every implementation detail.
4. **Creates or refreshes the docs/ai files**: CODEBASE_MAP.md, CHANGE_SURFACES.md, OPEN_QUESTIONS.md.
5. **Resolves blocking unknowns when safe**: reads additional files to resolve high-impact uncertainties before stopping.
6. **Reports hidden risks and remaining uncertainty**: source-of-truth drift, confidence gaps, anything that would affect a safe edit.

Claude should not edit source code, run refactors, or make commits during orientation.

---

## Dry-run / report-only mode

Use this when you want Claude to inspect but not write.

Example prompts:

```text
Run codebase-orient in dry-run mode.
```

```text
Use codebase-orient, but report proposed docs changes before writing anything.
```

In dry-run mode, Claude should inspect and report, but not update files without approval.

---

## Confidence labels

The skill asks Claude to label meaningful claims:

| Label | Meaning |
|---|---|
| Fact | Directly verified in code/docs |
| Strong inference | Supported by multiple files or strong implementation evidence |
| Weak inference | Plausible, but not confirmed |
| Unknown | Needs more inspection before relying on it |

It also encourages Claude to distinguish how a claim was verified:

- path-confirmed
- full-source-read
- inferred from implementation
- inferred from comments/tests/fixtures
- behavior-verified-by-test
- unknown

This matters because "file exists" is not the same as "behavior verified."

---

## Hidden-risk reporting

The skill asks Claude to call out hidden risks when depth changes the decision.

Examples:

- source file vs generated file mismatch
- local copy vs packaged copy mismatch
- repo-local config vs global/user config mismatch
- runtime registry vs filesystem source mismatch
- committed source vs ignored runtime artifact mismatch
- docs claiming one thing while code suggests another
- tests passing but not proving the behavior
- behavior inferred from comments rather than implementation
- setup that works now but may fail after restart, reinstall, deploy, rebuild, cache clear, or future Claude session

When this happens, Claude should report:

- evidence
- risk
- confidence
- recommended action
- whether action is needed now or can be deferred

---

## Known limitations and failure modes

- **Monorepos**: orientation may need to be scoped to a sub-package. Running against the entire monorepo at once can produce shallow results.
- **Repos with no docs**: expect more Unknown labels. The skill cannot infer what is not there.
- **Generated output mixed with source**: this can confuse source-of-truth detection. Flag generated directories explicitly in CLAUDE.md (or AGENTS.md for Codex) if possible.
- **Auto-invocation is not guaranteed**: models may invoke this skill automatically when they recognize an orientation request, but explicit invocation is the reliable path. This applies to both Claude Code and Codex.
- **Orientation improves process, not correctness**: the model should still verify claims against the actual source before editing.

---

## Invocation

Auto/implicit invocation is model-driven and not guaranteed in either Claude Code or Codex. Explicit invocation is the reliable path.

**Claude Code**: invoke the skill directly:

```text
/codebase-orient
```

**Codex**: slash commands are not supported; invoke explicitly:

```text
Use codebase-orient to orient yourself to this repo before planning this change.
```

Both tools may invoke the skill automatically when a request matches the skill description (orient, scan, understand, audit, plan changes), but this cannot be relied on for critical work.

---

## Example usage

### Normal mode

```text
/codebase-orient
```

Or:

```text
Use codebase-orient first, then plan a safe refactor of the routing and layout structure. Do not edit yet.
```

### Dry-run mode

```text
Run codebase-orient in dry-run mode. Report proposed docs/ai changes before writing anything.
```

---

## Security and review note

Skills are instructions that affect how Claude behaves.

Before installing any skill from GitHub:

1. Read the `SKILL.md`.
2. Check what files it tells Claude to modify.
3. Check whether it asks Claude to run commands.
4. Check whether it touches global, local, generated, or runtime files.
5. Do not install skills you do not understand.

This skill is designed to be conservative:

- no source-code edits during orientation
- no refactors during orientation
- no commits during orientation
- confidence labels for claims
- explicit hidden-risk reporting
- source-of-truth drift detection

---

## Skills in this repo

| Skill source | Purpose | Tools |
|---|---|---|
| `skills/codebase-orient/` | The orientation skill - installs to `.claude/skills/` (Claude Code) or `.agents/skills/` (Codex) | Claude Code, Codex |
| `skills/install-codebase-orient/` | Bootstrap skill - runs a first-pass orientation and creates the project-local orientation layer | Claude Code only |

`skills/codebase-orient/SKILL.md` is the single canonical source for the orientation skill. Installed copies are targets, not forks. `skills/install-codebase-orient/SKILL.md` is versioned here as tracked source; install it with `scripts/install-bootstrap-user.ps1` / `scripts/install-bootstrap-user.sh`.

---

## Install paths

| Tool | User-level | Project-local |
|---|---|---|
| Claude Code | `~/.claude/skills/codebase-orient/` | `.claude/skills/codebase-orient/` |
| Codex | `~/.agents/skills/codebase-orient/` | `.agents/skills/codebase-orient/` |

There is one `SKILL.md` source - the install scripts copy it to whichever path your tool reads.

---

## Installation

**Which skill should I install?**

- **Most users:** install `codebase-orient` (the sections immediately below). Use `/codebase-orient` to orient Claude to any project.
- **Bootstrap users:** install `install-codebase-orient` if you want Claude to run an orientation pass *and* write a project-local `codebase-orient` skill file into the repo (at `.claude/skills/codebase-orient/SKILL.md`). See [Bootstrap skill: user-level install](#bootstrap-skill-user-level-install-claude-code-only) below.

There are two common install styles for `codebase-orient`:

1. **User-level install**: available across all your projects in that tool.
2. **Project-local install**: available only inside a specific repo.

The `scripts/` directory contains install helpers for both styles and both tools. They refuse to overwrite an existing install unless you pass `-Force` (PowerShell) or `--force` (bash), so they are safe to run on a machine where the skill may already be present.

> **Install refresh semantics:** `-Force` / `--force` is an overlay install - it copies source files over the target but does not remove files that were in a previous install and have since been removed from the source package. For a clean exact-sync reinstall, delete the target directory first, then run the script without `-Force`.

For project-local installs, run the script from your project root - the scripts install relative to the current working directory and do not verify it is a repository root.

---

## Claude Code: user-level install

### Windows PowerShell

```powershell
.\scripts\install-user.ps1
```

Or manually:

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude\skills\codebase-orient" | Out-Null
Copy-Item -Recurse -Force ".\skills\codebase-orient\*" "$HOME\.claude\skills\codebase-orient\"
```

Then restart Claude Code if needed and try:

```text
/codebase-orient
```

### macOS/Linux

```bash
./scripts/install-user.sh
```

Or manually:

```bash
mkdir -p "$HOME/.claude/skills/codebase-orient"
cp -r ./skills/codebase-orient/. "$HOME/.claude/skills/codebase-orient/"
```

Then restart Claude Code if needed and try:

```text
/codebase-orient
```

---

## Claude Code: project-local install

From the root of the target repo:

### Windows PowerShell

```powershell
& "PATH\TO\codebase-orient-skill\scripts\install-project.ps1"
```

Or manually:

```powershell
New-Item -ItemType Directory -Force ".\.claude\skills\codebase-orient" | Out-Null
Copy-Item -Recurse -Force "PATH\TO\codebase-orient-skill\skills\codebase-orient\*" ".\.claude\skills\codebase-orient\"
```

### macOS/Linux

```bash
/path/to/codebase-orient-skill/scripts/install-project.sh
```

Or manually:

```bash
mkdir -p ./.claude/skills/codebase-orient
cp -r /path/to/codebase-orient-skill/skills/codebase-orient/. ./.claude/skills/codebase-orient/
```

Then in Claude Code:

```text
/codebase-orient
```

---

## Codex: user-level install

Codex reads user skills from `$HOME/.agents/skills/` (macOS/Linux) or `$HOME\.agents\skills\` (Windows).

### Windows PowerShell

```powershell
.\scripts\install-codex-user.ps1
```

### macOS/Linux

```bash
./scripts/install-codex-user.sh
```

After installing, restart or reload Codex if it is currently running, then invoke the skill explicitly:

```text
Use codebase-orient to orient yourself to this repo.
```

---

## Codex: project-local install

Codex reads project skills from `.agents/skills/` in the repo root.

From the root of the target repo:

### Windows PowerShell

```powershell
& "PATH\TO\codebase-orient-skill\scripts\install-codex-project.ps1"
```

### macOS/Linux

```bash
/path/to/codebase-orient-skill/scripts/install-codex-project.sh
```

After installing, restart or reload Codex if it is currently running, then invoke the skill explicitly:

```text
Use codebase-orient to orient yourself to this repo.
```

> **Codex lifecycle note:** Codex project-local installs get the generic `codebase-orient` skill. Two features are Claude Code only and are not available for Codex: (1) the bootstrap skill (`install-codebase-orient`), which runs a first-pass orientation and writes a project-local skill file; and (2) post-orientation project-local specialization, where the skill auto-updates `.claude/skills/codebase-orient/SKILL.md` with repo-specific discovery paths. For Codex, install via the scripts above and invoke the skill explicitly.

---

## Bootstrap skill: user-level install (Claude Code only)

`skills/install-codebase-orient/` is the **bootstrap skill**: a different skill from `codebase-orient`. It runs a first-pass orientation and generates a project-local `codebase-orient` skill inside the target repo. It is Claude Code only; there are no Codex or project-local install scripts for it.

To install the bootstrap skill at the Claude Code user level:

### Windows PowerShell

```powershell
.\scripts\install-bootstrap-user.ps1
```

### macOS/Linux

```bash
./scripts/install-bootstrap-user.sh
```

After installing, restart Claude Code if it is running, then open any project and type:

```text
/install-codebase-orient
```

The bootstrap skill will orient Claude to that project and generate `docs/ai/` and `.claude/skills/codebase-orient/SKILL.md` inside it.

> **Note:** For most users, installing the plain `codebase-orient` skill (via `install-user.ps1` / `install-user.sh`) is sufficient. The bootstrap skill is for users who also want a project-local `codebase-orient` skill file written into each repo's `.claude/skills/codebase-orient/SKILL.md` when they run orientation.

---

## Project-instruction snippet (AGENTS.md / CLAUDE.md)

You can improve automatic invocation odds by adding a short trigger hint to your project's instruction file. Automatic invocation is model-driven and not guaranteed - this snippet makes the intention explicit to the model without requiring a slash command every time.

**For Codex**: add to `AGENTS.md`:

```markdown
When starting in this repo, before broad changes, before agent handoff, or when docs/ai/ may be stale, consider using the codebase-orient skill before implementation. Do not invoke it for tiny local edits where targeted reads are cheaper.
```

**For Claude Code**: add to `CLAUDE.md`:

```markdown
When starting in this repo, before broad changes, before agent handoff, or when docs/ai/ may be stale, consider using the /codebase-orient skill before implementation. Do not invoke it for tiny local edits where targeted reads are cheaper.
```

This is optional. The skill works on demand without any instruction-file reference. Adding this snippet does not guarantee automatic invocation - it makes the trigger condition clear to the model so it can choose appropriately.

---

## Suggested `.gitignore` setup for project-local installs

### Claude Code

```gitignore
# Claude Code local/project config
.claude/*

# Track shared project-local Claude skills intentionally
!.claude/skills/
!.claude/skills/codebase-orient/
!.claude/skills/codebase-orient/SKILL.md

# Keep local/private/generated Claude files ignored
.claude/settings.local.json
.claude/skills/codebase-orient.skill
```

### Codex

```gitignore
# Codex local/project config
.agents/*

# Track shared project-local Codex skills intentionally
!.agents/skills/
!.agents/skills/codebase-orient/
!.agents/skills/codebase-orient/SKILL.md
```

---

## Verify installation

### Claude Code

After installing, ask Claude Code:

```text
Check whether codebase-orient is available as a skill.
```

Then try:

```text
/codebase-orient
```

If direct slash invocation does not work in your environment, you can ask Claude to read the skill file explicitly:

```text
Read and follow .claude/skills/codebase-orient/SKILL.md before planning this change.
```

### Codex

After installing, invoke the skill explicitly:

```text
Use codebase-orient to orient yourself to this repo.
```

If Codex does not appear to pick up the skill, restart or reload the session - Codex may not detect new skill files without a session refresh.

---

## Claude.ai / Claude Code / Codex / API note

Each tool surface handles skills and context differently.

- Claude Code reads skills from `.claude/skills/` (project) or `~/.claude/skills/` (user).
- Codex reads skills from `.agents/skills/` (project) or `~/.agents/skills/` (user).
- Claude.ai and raw API usage do not read either path automatically.

Install into the environment where you plan to use the skill and verify in that environment. A skill installed for Claude Code does not carry over to Codex, and vice versa.

---

## Uninstall

### Claude Code: user-level

Windows PowerShell:

```powershell
Remove-Item -Recurse -Force "$HOME\.claude\skills\codebase-orient"
```

macOS/Linux:

```bash
rm -rf "$HOME/.claude/skills/codebase-orient"
```

### Claude Code: project-local

Remove from the project:

```text
.claude/skills/codebase-orient/
```

### Codex: user-level

Windows PowerShell:

```powershell
Remove-Item -Recurse -Force "$HOME\.agents\skills\codebase-orient"
```

macOS/Linux:

```bash
rm -rf "$HOME/.agents/skills/codebase-orient"
```

### Codex: project-local

Remove from the project:

```text
.agents/skills/codebase-orient/
```

### Generated orientation docs (all tools)

Optionally remove generated orientation docs:

```text
docs/ai/CODEBASE_MAP.md
docs/ai/CHANGE_SURFACES.md
docs/ai/OPEN_QUESTIONS.md
```

Do not remove these docs if your project has started relying on them.

---

## Development notes

**ASCII punctuation convention:** All tracked repo-maintenance text uses ASCII punctuation only. This includes SKILL.md files, README, CHANGELOG, scripts, and any prompt snippets or release notes.

Forbidden: em dash, en dash, curly quotes, ellipsis, non-breaking spaces, and Unicode math symbols such as <= and >=.

SKILL.md files are read by Claude/Codex as style templates. Smart punctuation in SKILL.md bleeds into generated orientation docs (`CODEBASE_MAP.md`, `CHANGE_SURFACES.md`, `OPEN_QUESTIONS.md`), which land in user repos and may render as mojibake in Windows terminals on code page 1252.

Run `scripts/check-ascii-punctuation.ps1` (or `scripts/check-ascii-punctuation.sh`) before release or broad text changes to catch regressions.

---

## License

MIT
