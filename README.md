# codebase-orient

`codebase-orient` is a reusable skill for **Claude Code** and **Codex** that gives the agent a repeatable way to inspect an unfamiliar repository before broad work.

Instead of asking the model to vaguely "understand the project", this skill tells it what to read first, what uncertainty to label, what hidden risks to surface, and what orientation artifacts to create or refresh. It is for developers who want better repo context before refactors, multi-file changes, handoffs, or work in an unfamiliar area.

> [!NOTE]
> Installing a skill copies skill files into your tool's skill directory only. Running `codebase-orient` instructs the agent not to edit application code, refactor, or commit. In normal mode it creates or reconciles the fixed four-artifact `docs/ai/` package, including `ORIENTATION_STATE.json`. In dry-run mode it reports proposed changes without writing them. Orientation never generates or mutates a project-local runtime `SKILL.md`.

## Quickstart

Most users want the reusable `codebase-orient` skill at the **user level** for the tool they already use.

Before running the install scripts, clone or download this repository locally and run the commands below from the repository root so `scripts/` is present.

### Have your coding agent install it

If you already work in Codex or Claude Code, a practical onboarding path is to give that coding agent this repository and ask it to install the reusable skill for the tool you are currently using.

Exact-install integrity rule for agent-delegated setup:

- The agent must first obtain an exact local copy of the requested repo revision by cloning/checking out the requested tag or by downloading and extracting that tagged archive.
- It must then run the checked-in installer script for the selected tool and install scope.
- It must not manually recreate, paste, summarize, paraphrase, or rewrite `SKILL.md` from web-fetched, rendered, transformed, or partial content.
- If it cannot obtain an exact local copy or cannot run the documented installer, it must stop and ask rather than approximate the installation.

Use this prompt:

```text
Install the reusable codebase-orient skill for the coding tool we are using now. Follow this repository's README. Obtain an exact local copy of the requested repo revision first by cloning/checking out the requested tag or by downloading and extracting that tagged archive, then run the checked-in installer script. Do not manually recreate or rewrite SKILL.md from fetched or rendered content. Use the recommended user-level install path by default unless I request project-local scope; if I ask to install it "in this project," use the supported project-local route. If an installation already exists, do not overwrite or delete it automatically; explain the choices and ask me whether to do an overlay refresh, a clean reinstall, or a project-local install instead. If you cannot obtain an exact local copy or cannot run the documented installer, stop and ask. After installation, report how to invoke the installed skill explicitly. Do not run orientation in any target repository until I choose the target or ask you to do that next.
```

The manual commands below remain the inspectable install contract that the agent should follow.

| If you use | Recommended install | What it changes |
|---|---|---|
| Claude Code | User-level `codebase-orient` | Copies the skill to `~/.claude/skills/codebase-orient/` |
| Codex | User-level `codebase-orient` | Copies the skill to `~/.agents/skills/codebase-orient/` |
| Claude Code, and you want a dedicated first-pass bootstrap entry point | User-level `install-codebase-orient` bootstrap skill | Installs a separate bootstrap skill at `~/.claude/skills/install-codebase-orient/` |

### Install the reusable skill

If you want a **project-local** install instead, or the **Claude Code bootstrap** route, skip to [Alternate install paths](#alternate-install-paths) before running the default commands below.

If the install target already exists, stop and choose intentionally:

- Overlay refresh: rerun with `-Force` in PowerShell or `--force` in bash.
- Clean reinstall: rerun with `-Clean` in PowerShell or `--clean` in bash.
- Project-local install: use this when you intentionally want repo-scoped installation or testing.
- Agents acting on your behalf should ask before overwriting an existing installation.

**Claude Code**

```powershell
.\scripts\install-user.ps1
```

<details>
<summary>macOS/Linux</summary>

```bash
bash ./scripts/install-user.sh
```

</details>

**Codex**

```powershell
.\scripts\install-codex-user.ps1
```

<details>
<summary>macOS/Linux</summary>

```bash
bash ./scripts/install-codex-user.sh
```

</details>

### First use

Keep these three steps separate:

- Installing the skill copies files into the tool's skill location.
- Invoking the installed skill is the next step.
- Running orientation in a target repo happens only after you explicitly invoke it there.

Reading an installed `SKILL.md` directly can confirm what was copied, but that is not the same as confirming the tool discovered or invoked the installed skill.

After installing, Codex should detect a newly installed or updated skill automatically. If `codebase-orient` does not appear, restart Codex.

Then invoke the skill explicitly:

**Claude Code**

```text
/codebase-orient
```

**Codex**

```text
In Codex CLI or the IDE extension, run `/skills` or type `$` to mention/select `codebase-orient`, then ask it to orient the repo. In the Codex app, the skill is also available, but this README does not assume the same picker interaction there unless Codex documentation says so.
```

### What to expect after the first run

- The agent reads high-signal files first, then maps routes, entry points, services, schema, tests, deployment/config, and instruction files.
- The target repo may gain or reconcile `docs/ai/ORIENTATION_STATE.json`, `docs/ai/CODEBASE_MAP.md`, `docs/ai/CHANGE_SURFACES.md`, and `docs/ai/OPEN_QUESTIONS.md`.
- Those `docs/ai/` files are orientation aids, not the source of truth. Source code and project config stay authoritative.
- The skill should not edit source code, refactor, or commit during orientation.

## Which install path applies to you?

| Path | Use it when | Target |
|---|---|---|
| User-level `codebase-orient` | You want one reusable skill available across projects in the same tool | `~/.claude/skills/codebase-orient/` or `~/.agents/skills/codebase-orient/` |
| Project-local `codebase-orient` | You want the skill available only inside one repo | `.claude/skills/codebase-orient/` or `.agents/skills/codebase-orient/` |
| User-level `install-codebase-orient` bootstrap skill | You use Claude Code and want a dedicated first-pass entry point for the fixed orientation package | `~/.claude/skills/install-codebase-orient/` |

## Alternate install paths

<details>
<summary>Project-local install for Claude Code or Codex</summary>

Run these from the **target repo root**. The scripts install relative to the current working directory and do not verify that it is a repository root.

For delegated installation from a GitHub URL or tag, first acquire the exact skill source separately, then run the checked-in project-local installer from the target repo root. Do not manually write `.claude/skills/codebase-orient/SKILL.md` or `.agents/skills/codebase-orient/SKILL.md`.

**Claude Code project-local**

```powershell
& "PATH\TO\codebase-orient-skill\scripts\install-project.ps1"
```

```bash
bash /path/to/codebase-orient-skill/scripts/install-project.sh
```

This copies the skill into `.claude/skills/codebase-orient/` in the current repo.

**Codex project-local**

```powershell
& "PATH\TO\codebase-orient-skill\scripts\install-codex-project.ps1"
```

```bash
bash /path/to/codebase-orient-skill/scripts/install-codex-project.sh
```

This copies the skill into `.agents/skills/codebase-orient/` in the current repo.

</details>

<details>
<summary>Claude Code bootstrap install: <code>install-codebase-orient</code></summary>

This is a different skill from `codebase-orient`. Install it only if you want a
dedicated Claude Code first-pass entry point. It creates orientation state, not
a project-local runtime skill.

```powershell
.\scripts\install-bootstrap-user.ps1
```

```bash
bash ./scripts/install-bootstrap-user.sh
```

First use:

```text
/install-codebase-orient
```

Expected result in the target repo is the fixed four-artifact `docs/ai/`
package. The bootstrap no longer creates or changes
`.claude/skills/codebase-orient/SKILL.md`.

Codex does not have a bootstrap installer in this repo.

</details>

## What the skill actually does

The canonical skill source is [`skills/codebase-orient/SKILL.md`](skills/codebase-orient/SKILL.md). Its job is to make repository orientation more deliberate and less guessy.

It tells the agent to:

- read project instructions and docs first;
- verify important claims against source instead of inheriting them blindly from README or instruction files;
- map important change surfaces such as routes, services, auth, schema, UI, tests, and deployment;
- create or refresh `docs/ai/` orientation artifacts;
- label claims as Fact, Strong inference, Weak inference, or Unknown;
- report hidden risks such as stale docs, source-of-truth drift, generated-vs-source mismatches, and lifecycle traps.

It is meant for broad or unfamiliar work. It is explicitly meant to be skipped for tiny, known, single-file edits.
The reusable canonical skill currently includes an explicit tuned framework-probe section for SvelteKit. Other frameworks currently use the generic discovery order unless later live-fire or eval evidence justifies a dedicated tuned probe section. The separate Claude Code bootstrap skill has its own bootstrap-specific discovery helpers and should not be treated as identical framework coverage.

## Local behavioral evals

This repo now includes a small local/manual Codex eval scaffold for behavioral checks on `codebase-orient`.

- Prompt corpus: `evals/codebase-orient-behavioral-cases.json`
- Runner: `scripts/run-behavioral-evals.ps1`
- Default artifact location: `../codebase-orient-behavioral-eval-artifacts/`

The PowerShell entrypoint is a thin wrapper over a dependency-free Node core, so maintainer use requires `node` to be available on `PATH`.

Run the validated one-case vertical slice:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-behavioral-evals.ps1 --case-id explicit-dry-run-unfamiliar
```

The runner executes one selected case per invocation. It preserves single-pass
execution and supports the authored `behavior-no-date-only-churn` and
`behavior-stale-docs-source-drift` two-pass cases. Use `--model <model>` when
the local Codex default is unavailable to the current account. No
representative multi-case subset command is implemented.

The runner keeps disposable fixtures and raw traces outside the repository by
default. It copies the canonical skill into disposable user-level and
project-local locations and records content hashes. Runtime skill precedence
remains observable evidence: if Codex selects another installed copy, the trace
must be treated as an isolation failure rather than a behavior result.

Observable limits are intentional and documented:

- `codex exec --json` provides deterministic filesystem and command-event evidence.
- The proven dry-run case ran under a `read-only` sandbox, so its no-write result deterministically proves no files were written during that constrained run only. It does not by itself prove voluntary no-write compliance under a writable sandbox.
- The local traces from this scaffold did not expose a dedicated skill-selected event type.
- Invocation and skip behavior are therefore reported as proxy evidence, not direct proof, based on the JSONL agent-message stream plus outcome traces.

## Running it again later

Use the same invocation whenever `docs/ai/` is missing, stale, or likely cheaper than rediscovering the repo from scratch.

**Claude Code**

```text
/codebase-orient
```

**Codex**

```text
In Codex CLI or the IDE extension, run `/skills` or type `$` to mention/select `codebase-orient`, then ask it to orient this repo before planning this change.
```

You can also ask for dry-run behavior:

```text
Run codebase-orient in dry-run mode. Report proposed docs/ai changes before writing anything.
```

## Outputs and authority boundaries

`codebase-orient` works with four distinct layers that should not be confused:

- `skills/codebase-orient/SKILL.md` in this repo is the canonical reusable skill source.
- `skills/install-codebase-orient/SKILL.md` is the separate Claude Code bootstrap skill source.
- A repo-local installed skill such as `.claude/skills/codebase-orient/SKILL.md` or `.agents/skills/codebase-orient/SKILL.md` is the local runtime copy.
- `docs/ai/*` files are Orient-owned, provenance-backed orientation state, not permanent source of truth.

That distinction matters because the generated `docs/ai/` files can go stale, while source code and project config remain authoritative.

## Important notes

### Explicit invocation is the reliable path

The skill may be auto-invoked when the model recognizes an orientation request, but repository evidence is clear that auto-invocation is model-driven and not guaranteed. If you want the orientation pass, invoke it explicitly. Current Codex documentation says skills are available in the Codex CLI, IDE extension, and Codex app; Codex detects newly installed or updated skills automatically; if a skill does not appear, restart Codex; and in CLI/IDE the explicit invocation path is `/skills` or `$`.

### Reinstall behavior

All install scripts validate their source package before mutation and refuse an
existing target unless an explicit reinstall mode is selected.

That overwrite is an **overlay install**:

- current source files are copied over the existing target;
- files that existed in an older install but were removed from the source package are **not** pruned automatically.

For a staged clean reinstall, use `-Clean` in PowerShell or `--clean` in bash.
Conflicting overlay and clean flags are rejected.

### Codex lifecycle limits

This repo supports Codex user-level and project-local installs of the reusable `codebase-orient` skill.

Codex does not include the Claude-only `install-codebase-orient` bootstrap
entry point. Codex uses the reusable `codebase-orient` skill directly.

### Project-local runtime mutation retired

Orientation does not generate, specialize, migrate, or preserve
`.claude/skills/codebase-orient/SKILL.md`. Existing specialized copies are
legacy local state. Useful project-specific paths belong in the supported
`docs/ai/` package; no replacement overlay system is provided.

### Project-local `.gitignore` snippets

If you install a project-local skill and want to track only the shared skill file, these are the patterns printed or documented by the repo.

**Claude Code**

```gitignore
.claude/*
!.claude/skills/
!.claude/skills/codebase-orient/
!.claude/skills/codebase-orient/SKILL.md
```

**Codex**

```gitignore
.agents/*
!.agents/skills/
!.agents/skills/codebase-orient/
!.agents/skills/codebase-orient/SKILL.md
```

## Limitations and trust

- **Explicit invocation is the reliable path.** Auto-invocation is model-driven and not guaranteed in either Claude Code or Codex. If you need the orientation pass, invoke it explicitly.
- **Orientation improves process, not correctness.** The skill instructs the agent to label uncertainty and verify claims against source, but verify any claim that matters before acting on it.
- **Large monorepos may need scoped orientation.** Running against an entire monorepo can produce shallow results. Scope the invocation to the relevant package or area when needed.
- **Skills are agent instructions.** Review `SKILL.md` before installing third-party skills. This skill is designed to be conservative: no source edits, no refactors, no commits during orientation.

## Reference and contributor notes

- [`skills/codebase-orient/SKILL.md`](skills/codebase-orient/SKILL.md): canonical reusable skill behavior
- [`skills/install-codebase-orient/SKILL.md`](skills/install-codebase-orient/SKILL.md): Claude Code bootstrap skill behavior and versioned embedded template
- [`CHANGELOG.md`](CHANGELOG.md): release history
- [`docs/releases/v1.0-validation-record.md`](docs/releases/v1.0-validation-record.md): frozen historical validation record for `v1.0.0`
- [`scripts/`](scripts/): install and validation helpers

Tracked repo-maintenance text in this repo follows an ASCII punctuation convention. The check scripts are:

```powershell
.\scripts\check-ascii-punctuation.ps1
```

```bash
./scripts/check-ascii-punctuation.sh
```

Shared canonical/bootstrap rule blocks can also be validated directly with:

```powershell
.\scripts\check-shared-rule-drift.ps1
```

<details>
<summary>Uninstall reference</summary>

Remove the installed skill directory that matches how you installed it:

```text
Claude Code user-level: ~/.claude/skills/codebase-orient/
Claude Code project-local: .claude/skills/codebase-orient/
Codex user-level: ~/.agents/skills/codebase-orient/
Codex project-local: .agents/skills/codebase-orient/
Claude Code bootstrap user-level: ~/.claude/skills/install-codebase-orient/
```

</details>

## License

MIT. See [`LICENSE`](LICENSE).
