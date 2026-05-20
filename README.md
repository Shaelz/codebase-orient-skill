# Codebase Orient Skill

A Claude Code skill for turning “scan this repo” into a repeatable codebase orientation workflow.

Instead of asking Claude to vaguely “understand the project,” this skill guides Claude to build and maintain a small orientation layer:

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

1. Read high-signal files first.
2. Identify the framework, entrypoints, routes, models, services, UI surfaces, tests, and deployment/config files.
3. Create or refresh repo-local orientation docs.
4. Mark uncertainty explicitly.
5. Identify which files matter for different kinds of changes.
6. Detect hidden risks such as stale docs, multiple active copies, generated/runtime mismatches, and source-of-truth drift.

It is useful before:

- audits
- refactors
- new features
- unfamiliar-area edits
- architecture planning
- risky edits
- route/page changes
- admin UI changes
- data model/schema changes
- import/workflow/job changes
- test architecture changes
- deployment/config changes

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

This matters because “file exists” is not the same as “behavior verified.”

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

## Normal mode vs dry-run mode

### Normal mode

Default behavior.

Claude may:

- read the minimum necessary files
- resolve blocking uncertainty
- update `docs/ai` orientation files
- proceed until the repo is mapped enough for the requested task

### Dry-run / report-only mode

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

## Invocation reliability

Claude may automatically use this skill when your request clearly matches the skill description, such as when you ask it to orient, scan, understand, review, audit, or plan changes in a codebase.

However, automatic invocation is model-driven and not guaranteed.

For reliable use, invoke it directly:

```text
/codebase-orient
```

or explicitly say:

```text
Use codebase-orient first, then help me plan this change.
```

Recommended habit:

Use the skill directly at the start of a new repo, before large refactors, before unfamiliar-area work, and before tasks where source-of-truth drift or architecture uncertainty would matter.

---

## Installation

This repository is intended for Claude Code.

There are two common install styles:

1. personal install, available across your Claude Code projects
2. project-local install, committed or used inside one repo

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

## Example usage

### First orientation pass

```text
/codebase-orient
```

or:

```text
Use codebase-orient to orient yourself to this repo before suggesting changes.
```

### Before a refactor

```text
Use codebase-orient first, then plan a safe refactor of the routing and layout structure. Do not edit yet.
```

### Before a design/admin UI pass

```text
Use codebase-orient first, then identify the relevant UI, styling, and component change surfaces.
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

## Versioning

Current version: `0.1.0`

Initial public version:

- codebase orientation workflow
- architecture map generation
- change-surface map generation
- open-question tracking
- confidence labels
- hidden-risk reporting
- source-of-truth drift detection
- normal mode and dry-run mode

---

## License

MIT
