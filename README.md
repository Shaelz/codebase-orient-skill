# Codebase Orient Skill

A Claude Code skill for turning "scan this repo" into a repeatable codebase orientation workflow.

Instead of asking Claude to vaguely "understand the project," this skill guides Claude to build and maintain a small orientation layer:

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

---

## What it creates in a repo

When used in a project, the skill may create or update:

```text
CLAUDE.md
docs/ai/CODEBASE_MAP.md
docs/ai/CHANGE_SURFACES.md
docs/ai/OPEN_QUESTIONS.md
.claude/skills/codebase-orient/SKILL.md
```

The skill works out of the box without editing. `SKILL.md` ships with a broad, generic discovery order that covers most project shapes. You can tune that order for your specific project later, but customization is optional — not required before first use.

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
- Framework: Next.js 14 (App Router) — Fact, full-source-read
- Language: TypeScript — Fact, full-source-read
- Package manager: pnpm — Fact, path-confirmed (pnpm-lock.yaml)

## Entry points
- Web app: app/layout.tsx — Fact, path-confirmed
- API routes: app/api/** — Strong inference, inferred from implementation
- Background jobs: jobs/ directory — Weak inference, no scheduler config found

## Authentication
- Auth provider: unclear — Unknown, needs inspection
- Session storage: likely cookie-based — Weak inference, inferred from middleware

## Known uncertainty
- Whether jobs/ is actively used or legacy — Unknown
- Whether app/api/admin routes are gated by middleware — Unknown
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

1. **Reads project instructions and docs first** — CLAUDE.md, README, any existing docs/ai files.
2. **Checks framework, config, and entrypoints** — package.json, tsconfig, Dockerfile, CI files, root config.
3. **Maps routes, models, services, UI surfaces, tests, and deployment** — in enough depth to understand the shape, not every implementation detail.
4. **Creates or refreshes the docs/ai files** — CODEBASE_MAP.md, CHANGE_SURFACES.md, OPEN_QUESTIONS.md.
5. **Resolves blocking unknowns when safe** — reads additional files to resolve high-impact uncertainties before stopping.
6. **Reports hidden risks and remaining uncertainty** — source-of-truth drift, confidence gaps, anything that would affect a safe edit.

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

- **Monorepos** — orientation may need to be scoped to a sub-package. Running against the entire monorepo at once can produce shallow results.
- **Repos with no docs** — expect more Unknown labels. The skill cannot infer what is not there.
- **Generated output mixed with source** — this can confuse source-of-truth detection. Flag generated directories explicitly in CLAUDE.md if possible.
- **Auto-invocation is not guaranteed** — Claude may invoke this skill automatically when it recognizes an orientation request, but direct invocation is the reliable path.
- **Orientation improves process, not correctness** — Claude should still verify claims against the actual source before editing.

---

## Invocation

For reliable use, invoke the skill directly:

```text
/codebase-orient
```

Or explicitly say:

```text
Use codebase-orient first, then help me plan this change.
```

Claude may invoke this skill automatically when your request matches the skill description (orient, scan, understand, audit, plan changes). This is not guaranteed — use direct invocation when it matters.

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

## Installation

This repository is intended for Claude Code.

There are two common install styles:

1. personal install, available across your Claude Code projects
2. project-local install, committed or used inside one repo

The `scripts/` directory contains install helpers for both styles. They refuse to overwrite an existing install unless you pass `-Force` (PowerShell) or `--force` (bash), so they are safe to run on a machine where the skill may already be present. The manual commands below are shown for transparency — either approach works.

---

## Option A: personal install

Use this if you want the skill available across projects.

### Windows PowerShell

From this repo:

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude\skills\codebase-orient" | Out-Null
Copy-Item -Recurse -Force ".\skills\codebase-orient\*" "$HOME\.claude\skills\codebase-orient\"
```

Then restart Claude Code if needed and try:

```text
/codebase-orient
```

### macOS/Linux

From this repo:

```bash
mkdir -p "$HOME/.claude/skills/codebase-orient"
cp -R ./skills/codebase-orient/* "$HOME/.claude/skills/codebase-orient/"
```

Then restart Claude Code if needed and try:

```text
/codebase-orient
```

---

## Option B: project-local install

Use this if you want the skill available only inside a specific repo.

From the target repo, copy the skill into:

```text
.claude/skills/codebase-orient/SKILL.md
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Force ".\.claude\skills\codebase-orient" | Out-Null
Copy-Item -Recurse -Force "PATH\TO\codebase-orient-skill\skills\codebase-orient\*" ".\.claude\skills\codebase-orient\"
```

### macOS/Linux

From the target repo, run:

```bash
/path/to/codebase-orient-skill/scripts/install-project.sh
```

Or manually:

```bash
mkdir -p ./.claude/skills/codebase-orient
cp -R /path/to/codebase-orient-skill/skills/codebase-orient/* ./.claude/skills/codebase-orient/
```

Then in Claude Code:

```text
/codebase-orient
```

---

## Suggested `.gitignore` setup for project-local installs

If you want to commit the readable skill source but keep local Claude settings private, use a selective ignore pattern:

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

This tracks:

```text
.claude/skills/codebase-orient/SKILL.md
```

but keeps local/private/generated files ignored.

---

## Verify installation

After installing, ask Claude Code:

```text
Check whether codebase-orient is available as a skill.
```

Then try:

```text
/codebase-orient
```

If direct slash invocation does not work in your environment, you can still ask Claude to read the skill file explicitly:

```text
Read and follow .claude/skills/codebase-orient/SKILL.md before planning this change.
```

---

## Claude.ai / Claude Code / API note

Claude surfaces may handle skills differently.

This repo is primarily for Claude Code usage.

A skill installed in Claude Code does not necessarily sync automatically to Claude.ai or API usage. Treat each environment separately and verify installation in the place where you plan to use it.

---

## Uninstall

### Personal install

Remove:

```text
~/.claude/skills/codebase-orient/
```

Windows PowerShell:

```powershell
Remove-Item -Recurse -Force "$HOME\.claude\skills\codebase-orient"
```

macOS/Linux:

```bash
rm -rf "$HOME/.claude/skills/codebase-orient"
```

### Project-local install

Remove from the project:

```text
.claude/skills/codebase-orient/
```

Optionally remove generated orientation docs:

```text
docs/ai/CODEBASE_MAP.md
docs/ai/CHANGE_SURFACES.md
docs/ai/OPEN_QUESTIONS.md
```

Do not remove these docs if your project has started relying on them.

---

## License

MIT
