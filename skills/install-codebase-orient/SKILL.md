---
name: install-codebase-orient
version: "0.2.3"
description: "Install or refresh a project-local codebase orientation workflow in the current repo. Use when the user asks to set up codebase orientation, create a codebase map, scan the repo properly, make Claude understand this project, prepare this repo for future Claude sessions, bootstrap Claude for this repo, or orient Claude to this codebase."
---

# Skill: install-codebase-orient

> **Source:** This file is the tracked source for the Claude Code bootstrap skill. It installs to `.claude/skills/install-codebase-orient/SKILL.md` at the Claude Code user level. It generates a **Claude Code project-local** `codebase-orient` skill only - Codex installs are handled by the main repo's separate Codex install scripts, not this bootstrapper.

## Purpose

Install or refresh a project-local codebase orientation workflow inside the current repository.

This is a reusable global bootstrap skill. It does not know any one repo's architecture - it produces a repo-local orientation layer that does.

## Trigger phrases

Use this skill when the user asks things like:
- set up codebase orientation
- set up repo orientation
- install orientation workflow
- create codebase map
- scan this repo properly
- understand this codebase
- make Claude understand this project
- prepare this repo for future Claude sessions
- bootstrap Claude for this repo
- orient Claude to this project

## What this skill creates or refreshes

Inside the current repository:

| File | Purpose |
|------|---------|
| `.claude/skills/codebase-orient/SKILL.md` | Repo-local reusable orientation workflow (Claude Code) |
| `docs/ai/CODEBASE_MAP.md` | Architecture map: routes, models, services, schema |
| `docs/ai/CHANGE_SURFACES.md` | Which files to inspect before each type of change |
| `docs/ai/OPEN_QUESTIONS.md` | Real uncertainties discovered during inspection |
| `CLAUDE.md` | Minimal orientation pointer (append only if file exists) |

This skill installs to the Claude Code project-local path. For Codex support (`.agents/skills/codebase-orient/`), use the Codex install scripts from the `codebase-orient-skill` repo.

> **Generated cache, not canonical documentation:** The `docs/ai/` files are generated orientation aids - a cache of what Claude observed during inspection. Source code and project config remain authoritative. Treat `docs/ai/` as context, not ground truth.

## Hard rules

- Do not modify application/source code during setup.
- Do not refactor.
- Do not commit.
- Preserve existing project instructions (CLAUDE.md, AGENTS.md, .claude/ config).
- Use concise, durable markdown.
- Verify against source code before writing orientation claims.
- Treat docs/ai files as orientation aids, not absolute truth.
- Mark every meaningful claim: **Fact** | **Strong inference** | **Weak inference** | **Unknown**

## Idempotency rule

If the docs/ai files already exist:
- Refresh stale sections rather than rewriting from scratch.
- Preserve useful existing content.
- Ensure each file has a `Last refreshed:` line; update the date only when content changes substantively - do not stamp today's date on a file whose content has not changed. See the no-date-only-churn rule in the embedded template below.
- Only fully rewrite a doc if the architecture has significantly changed.

## Discovery order

Execute inspection in this order:

1. Project instructions and repo docs (CLAUDE.md, AGENTS.md, README.md, docs/)
2. Runtime/framework config (package.json, svelte.config.*, vite.config.*, composer.json, etc.)
3. Routes / entrypoints
4. Domain models / entities / types
5. Services / actions / workflows / jobs / importers
6. Persistence / schema / migrations
7. Admin / UI surfaces
8. Public / UI surfaces
9. Tests
10. Deployment / config
11. Known uncertainty

## Framework-aware probes

### SvelteKit / JS / TS

- `src/routes/**/+page.svelte`: UI route pages; each file is a route candidate; check subdirectories, not only the top-level `src/routes/+page.svelte`
- `src/routes/**/+page.server.ts`: server-side data loading, form actions, route-level access control
- `src/routes/**/+layout.svelte`: shared layout shells
- `src/routes/**/+layout.server.ts`: server-side load functions for layout-level auth, session, or data
- `src/routes/**/+server.ts`: API endpoints and server-only request handlers

Server-side route files (`+page.server.ts`, `+layout.server.ts`, `+server.ts`) are critical for understanding auth, data loading, form actions, API endpoints, and route-level access control. Do not skip them when mapping routes or change surfaces.

- `src/lib/`: shared lib: components, server utilities, assessment logic, i18n
- `src/app.html`: root HTML shell
- `src/hooks.server.ts`: server-side request handling
- `package.json`: deps, scripts
- `svelte.config.*`: adapter, compiler options
- `vite.config.*`: build config, plugins
- `static/`: public static assets
- `tests/`: unit and e2e test structure
- `docs/`: existing documentation

### Laravel / PHP

- `routes/`: web, api, console route files
- `app/Models/`: Eloquent models
- `app/Console/`: Artisan commands
- `app/Services/`: service layer
- `app/Filament/`: admin panel resources
- `database/migrations/`: schema history
- `resources/`: views, lang, assets
- `tests/`: Feature and Unit tests
- `docs/`: existing documentation

### Generic

- Entrypoints and routing
- Domain model / core types
- Persistence layer
- UI surfaces
- Services / workflows
- Tests
- Deployment config

## Output docs

### docs/ai/CODEBASE_MAP.md

Sections:
- Project identity
- Runtime/framework
- Entry points/routes
- Domain/data model
- Services/workflows
- Admin/UI surfaces
- Public/UI surfaces
- Persistence/schema
- Tests
- Deployment/config
- Important docs
- Known uncertainty

### docs/ai/CHANGE_SURFACES.md

For each change type, list files/dirs to inspect first:
- Route/page changes
- Styling/theme changes
- Auth/admin/operator UX changes (note any accessibility requirements or WCAG targets found in source or docs)
- Data model/schema changes
- Imports/jobs/workflows
- Copy/i18n changes
- Test changes
- Deployment-sensitive changes (flag likely smoke-check entry points: login page, health endpoint, main route)
- Docs-impact changes (note which project docs need updating alongside code changes per major subsystem)

### docs/ai/OPEN_QUESTIONS.md

Group by: Architecture | Data/persistence | UI/admin | Tests | Deployment | Documentation drift

Only list real uncertainties found during inspection. Do not invent concerns.

## Formatting generated docs

Before staging created or refreshed `docs/ai/` files, format them if the project has a discoverable formatter that covers Markdown (e.g., Prettier, markdownlint). If a formatter is missing, unavailable, not configured for Markdown, or its invocation would fail, skip formatting, note this in the orientation report, and continue. Do not treat missing formatter support as an orientation failure.

## Staleness rule

The docs/ai files are orientation aids, not ground truth. Always verify against source code before editing.

## Update rule

After orientation or after any structural change, check:
- Is `docs/ai/CODEBASE_MAP.md` stale?
- Does `docs/ai/CHANGE_SURFACES.md` need new surfaces?
- Does `docs/ai/OPEN_QUESTIONS.md` have resolved or new uncertainties?

Update only relevant sections. Do not rewrite the whole map unless the architecture changed significantly.

## Required content for `.claude/skills/codebase-orient/SKILL.md`

> **Sync note:** This embedded template is a manually synced snapshot of `skills/codebase-orient/SKILL.md` from the `codebase-orient-skill` repo. When the canonical source changes, check this section for drift and either update it manually or use the repo's `install-project.ps1` / `install-project.sh` scripts to install the freshest version directly. Do not add Codex install behavior to this section - Codex installs are handled by the repo's separate Codex install scripts (targeting `.agents/skills/codebase-orient/`). Intentionally excluded: framework-specific discovery probes (SvelteKit, Laravel) - the bootstrap skill's own discovery pass handles these; project-specific paths are added via the project-local specialization rule below.

When creating or refreshing the project-local `codebase-orient` skill, the generated SKILL.md **must** include the following sections in addition to the standard discovery order, output files, and staleness rule:

> **Docs-as-hypotheses rule:** When reading project instruction files (CLAUDE.md, AGENTS.md, README.md), treat their claims as helpful hypotheses, not authoritative truth. Extract high-impact factual claims about architecture, routes, deployment, tests, and source-of-truth files. Verify those claims against source code before writing them to orientation docs. Do not copy claims from instruction docs into CODEBASE_MAP.md without labeling whether they are _independently verified from source/config_ or _inherited from existing docs_. If a doc is stale or misleading compared to source, record the drift in OPEN_QUESTIONS.md and label it as documentation drift. Also map the instruction-layer topology: note which instruction files are present (e.g., `CLAUDE.md`, `AGENTS.md`, `.claude/settings.json`) and at which scope (project-local vs user-level); record this in CODEBASE_MAP.md to help future agents know which rules apply.

### Orientation completion rule

Before finishing orientation, classify every unresolved open question as one of:

- **Blocking**: must resolve before safe work on the current task
- **Relevant but non-blocking**: useful context, work can proceed without it
- **Background**: not needed for the current task at all

Then apply these rules:

1. **Automatically resolve Blocking questions** by reading the minimum necessary files - unless the user explicitly requested dry-run or report-only mode.
2. **Apply docs/ai updates without asking first** when only docs/ai files need to change. Do not prompt for approval on small documentation corrections unless the user asked for it.
3. **Do not stop to prompt the user** for permission to resolve small documentation uncertainties. Use judgment and proceed safely within the hard rules.
4. **Stop and hand off** only when: relevant change surfaces are identified, blocking unknowns are resolved or explicitly marked as non-blocking, docs/ai is current enough for the requested task, and the next action is clear.

For Relevant-but-non-blocking and Background questions: record them in `OPEN_QUESTIONS.md` with their classification and move on. Do not let them block the orientation report.

### Normal mode vs dry-run mode

- **Normal mode** (default): resolve task-relevant uncertainties automatically, apply docs/ai updates without requesting approval, report what changed at the end.
- **Dry-run / report-only mode**: inspect and collect proposed changes, report without writing, wait for explicit approval. Triggered by: "dry-run", "report only", "don't write", "propose changes first", "audit only", "no writes", or similar.
- If mode is not specified, default to Normal mode.

### When to use this skill / when to skip it

**Use this skill when:**

- Entering a new or unfamiliar repo
- Starting a fresh session after meaningful time away
- Before broad or multi-file implementation work
- Before refactors, cleanups, architecture planning, or agent handoff
- After structural changes: routes, schema, auth, deployment, config, or admin surfaces
- When `docs/ai/` is missing, stale, incomplete, or internally inconsistent
- When repo structure, change surfaces, deploy targets, auth behavior, or test shape are unclear
- When the agent would otherwise spend significant context rediscovering what `docs/ai/` already captures

**Skip this skill when:**

- Making a tiny, local, known edit to a single file
- Fixing a one-file bug where the relevant file and change are already clear
- Making copy-only or string-only changes
- `docs/ai/` was just refreshed and the task is narrow enough not to need a full orientation pass

### Token-aware use guidance

`docs/ai/` is an orientation cache. A fresh cache reduces repeated repo-discovery token cost across sessions and agent handoffs.

- **If `docs/ai/` is fresh and complete**: read it as context and proceed. Skip re-running orientation.
- **If `docs/ai/` may be stale or is missing**: run orientation. The upfront token cost amortizes across the work ahead.
- **If the task is tiny and the target file is known**: skip orientation. Use targeted reads instead.

Do not save tokens by skipping orientation and then guessing at structure. If broad repo discovery would otherwise be repeated or expensive, refresh the cache instead.

### Confidence labels

Primary claim labels:

- **Fact**: directly verified in code or docs
- **Strong inference**: supported by multiple files
- **Weak inference**: plausible but not confirmed
- **Unknown**: needs more inspection before editing

Distinguish how each claim was established:

- *independently verified from source/config*: claim checked against the actual source or config file, not taken from docs
- *inherited from existing docs*: claim taken from CLAUDE.md, README, or other documentation without independent verification
- *inherited then verified*: claim originated in docs and was subsequently confirmed against source
- *path existence confirmed*: file found but not read
- *partial read*: portion of the file inspected; may not capture full context
- *full source read*: complete file content inspected
- *inferred from implementation*: deduced from how code behaves, not explicitly stated
- *inferred from comments/tests/fixtures*: sourced from non-authoritative context; treat as Strong inference at best
- *behavior verified by test*: confirmed by passing test execution
- *unknown*: basis not established; do not present as Fact

In final reports and orientation docs, label each non-trivial claim with one of the above origins. Do not conflate path existence with source verification.

### Hidden-risk reporting rule

Be concise by default, but go deeper when depth changes the decision.

During orientation, actively look for hidden risks that could affect future work, reproducibility, safety, or correctness.

If any of the following appear, include a `Potential drift / hidden risk` section in the final report:

- source file vs generated file mismatch
- local copy vs packaged copy mismatch
- repo-local config vs global/user config mismatch
- runtime registry vs filesystem source mismatch
- committed source vs ignored runtime artifact mismatch
- docs claiming one thing while code suggests another
- tests passing but coverage not proving the behavior
- path existence without full source read
- behavior inferred from comments, fixtures, or tests rather than implementation
- setup that works in this session but may fail after restart, reinstall, deploy, rebuild, cache clear, or future Claude session

For each item, report: Evidence, Risk, Confidence, Recommended action, and whether action is needed now or can be deferred.

If a hidden-risk item affects reproducibility, future installs, runtime behavior, or source-of-truth clarity, classify it as Blocking or Relevant but non-blocking, not Background.

### Source-of-truth drift detection rule

When multiple copies or layers exist, explicitly map them before declaring the system current.

Check for: editable source files, generated files, packaged archives, runtime/plugin registry copies, global/user-level copies, project-local copies, committed repo files, ignored local files, and cache/session-loaded copies.

For each layer, identify: what it is used for, whether it is authoritative, whether it is tracked by git, whether it is regenerated from another source, whether it can overwrite another copy, and whether it survives restart, reinstall, clone, deploy, or future session.

If two copies differ, do not just update the currently active copy. Report the drift and either update all authoritative/durable copies, or clearly mark which copy remains stale and what consequence that has.

### CI/deployment precision rule

When reading CI or deployment workflow files, preserve operationally relevant detail. Do not round down specifics into vague summaries.

Capture and report:

- concurrency group name (which runs compete with each other)
- `cancel-in-progress` behavior - if `true`, say "newer runs cancel in-progress runs of the same group", not merely "prevents parallel deploys"
- `fail-fast` behavior
- deploy artifact paths
- release naming format including any timestamp or hash components
- retention and pruning policy for old releases or artifacts
- manual vs automatic trigger conditions
- required secrets and environment variables
- whether deployment overwrites in place, stages to a temp path, uses symlinks, or uses versioned release directories

Label CI/deployment claims with _independently verified from source/config_ when read directly from the workflow file. Do not summarize these details in ways that lose precision that an operator would need during an incident.

### Read-depth heuristic

Do not read every large CSS, config, or generated file by default.

- **Full read**: files that directly affect the requested task (entry points, routing, auth, schema, build config, the file to be edited).
- **Partial read or path-confirmation only**: secondary surfaces such as large style sheets, vendored code, generated output, or config files not relevant to the task. If you only confirm a file's path or read a portion, say so explicitly using the _path existence confirmed_ or _partial read_ labels.
- **Skip**: files that are clearly out of scope (e.g., binary assets, lock files, test snapshots) unless a specific question makes them relevant.

When in doubt, prefer confirming existence first and reading fully only if a claim requires it.

#### Path existence vs content read

Path existence alone is sufficient for low-risk inventory claims - confirming a directory structure, listing file counts, or noting that a config file is present.

Read the actual file content when the claim affects behavior, architecture, risk, commands, deployment, auth, routing, or change surfaces. Do not label a claim as _independently verified from source/config_ based on path existence alone when the file is cheap to inspect and its content would materially affect the map.

#### Small source-of-truth file read rule

If a small file appears to define vocabulary or source-of-truth tokens used throughout the project, read enough of it to verify the vocabulary rather than inheriting the vocabulary from docs.

Examples where this applies:

- CSS custom-property token files
- route or menu config files
- small schema or constants files
- command or plugin registries

Use a partial read when that is sufficient. Label the resulting claims with the appropriate claim origin (_partial read_, _full source read_). Do not label them as _independently verified from source/config_ if you did not actually read the file.

### Cheap artifact glob rule

Before leaving an open question about the existence or scope of static assets, scripts, generated outputs, documentation, tests, migrations, or config files, resolve it with a cheap path glob.

Common glob patterns to try:

- `static/**/*`
- `public/**/*`
- `scripts/**/*`
- `tests/**/*` or `test/**/*` or `spec/**/*`
- `.github/workflows/*`
- `docs/**/*`
- `migrations/**/*`
- `dist/**/*` or `build/**/*`

Do not deeply read all matched files by default. Use the glob to resolve existence and scope questions cheaply. Follow up with targeted reads only when a specific file's content is needed.

### Open question quality rule

Do not leave an open question in `OPEN_QUESTIONS.md` if it can be resolved with one cheap path glob or one small-file read.

Leave a question open only when resolving it would require:

- broad exploration that is disproportionate to the task
- external documentation that is unavailable
- commands that could have side effects
- deep reads of files that are irrelevant to the current task

If a glob or small read can close the question, close it and label the basis.

### Cross-file consistency rule

The three `docs/ai/` files must remain coherent with each other. After any update, verify:

- **Resolved questions**: if `OPEN_QUESTIONS.md` marks a question resolved, remove or update any stale "unknown" or "needs investigation" language in `CODEBASE_MAP.md` and `CHANGE_SURFACES.md` that referred to the same item.
- **New change surfaces**: if a change surface is added to `CHANGE_SURFACES.md`, check whether `CODEBASE_MAP.md` should mention the associated area or file.
- **New map uncertainty**: if a claim in `CODEBASE_MAP.md` becomes uncertain, check whether the corresponding open question exists in `OPEN_QUESTIONS.md`; add or update it if not.
- **Contradictions**: do not let one file say "unknown" or "unresolved" while another says "resolved" or "confirmed" - unless the distinction is explicitly explained.

Apply this as a final consistency pass after refreshing any of the three files.

### CHANGE_SURFACES mapping guidance

When populating `docs/ai/CHANGE_SURFACES.md`, include entries for these change types in addition to the standard surfaces (routes, styling, schema, tests, config):

- **Auth/admin/operator UX changes**: admin panels, operator dashboards, internal tooling surfaces; note any accessibility requirements or WCAG targets found in source or docs
- **Deployment-sensitive changes**: flag files whose changes should prompt a smoke check after deploy; note likely smoke-check entry points (e.g., login page, health endpoint, main route)
- **Docs-impact changes**: for each major subsystem, note which project docs need updating alongside code changes

Do not create separate `docs/ai/` files for smoke-check lists or handoff notes - record them inline in `CHANGE_SURFACES.md`.

### No-date-only-churn rule

Do not rewrite a generated `docs/ai/` file solely to update a date, timestamp, or freshness marker.

- If a file has no substantive content changes after verification, leave it unchanged.
- Report it as **verified current** in the orientation report - not as "refreshed" or "updated".
- Only update the `Last refreshed:` date when file content changes for a substantive reason.
- If the project has an existing documented convention requiring date refreshes on every orientation pass, follow that convention - but only if it is explicitly documented in `CLAUDE.md`, `AGENTS.md`, or project docs.

### Orientation report discipline

Label each `docs/ai/` file in the final report with one of:

- **Created**: file did not exist; was created this pass
- **Substantively updated**: content changed; `Last refreshed` date updated
- **Verified current / unchanged**: content inspected and confirmed accurate; file not rewritten
- **Proposed only**: dry-run mode; change proposed but not written
- **Skipped**: file not inspected this pass; state why

Do not label a file as "updated" or "refreshed" if only its date changed.

#### Agent handoff summary

When orientation is requested before an agent handoff, append a compact **Handoff summary** block to the orientation report:

- **Snapshot**: 3-5 key facts: framework, entry point, auth mechanism, deploy target, test approach
- **Blocking open questions**: anything that must resolve before safe work begins
- **Critical change surfaces**: top 3-5 surfaces most likely affected by the incoming work
- **Recommended first action**: what the receiving agent should do first

Keep it under 150 words. Do not create a separate `docs/ai/` file for it.

### Project-local specialization rule

After the first orientation pass, if the repo has important project-specific namespaces, service folders, command groups, admin surfaces, workflow directories, generated-output locations, or deployment conventions that were not in the generic probe list, update the repo-local Claude Code skill at `.claude/skills/codebase-orient/SKILL.md` with those project-specific discovery paths.

This applies only when a repo-local skill exists at `.claude/skills/codebase-orient/SKILL.md` or is being generated during this session. If no such skill exists and the user has not requested skill installation, skip this step. Codex installs (`.agents/skills/codebase-orient/`) are handled by the source repo's install scripts, not by this rule.

Before writing the local specialization:
- Verify each proposed path exists with a glob or read.
- Briefly state why each path matters (e.g., "domain workflow folder", "admin resource directory").

Do not backport concrete project-specific paths to the public skill unless they are broadly reusable across many projects.

The project-specific paths added here are the thin, customisable layer of the repo-local skill. The canonical rules in the sections above are the stable layer that applies across all repos. Keep these two layers visually separated - project-specific additions belong at the end of the file, clearly marked as project-local.

Examples of paths that qualify for local specialization:

- framework-adjacent service namespaces
- custom domain workflow folders
- admin page or resource directories
- manually-run tooling directories
- import/export pipeline directories
- deployment or release directories
- generated asset conventions

If the skill is running in dry-run/report-only mode, report the proposed local specialization but do not write it.

---

## Changelog

> **Version scheme note:** The version number in this file's frontmatter tracks the bootstrap skill's own content changes. It is independent from the repository release tag. The repository `CHANGELOG.md` records release history and relevant bootstrap-skill changes.

### 0.2.3 - 2026-05-24

- Replaced the stale concrete repository-version reference in the version-scheme note with durable repository changelog wording.
- No bootstrap behavior, embedded template rule, installer behavior, or runtime/output contract changed.

### 0.2.2 - 2026-05-21

- Clarify authority boundaries: canonical skill vs bootstrap vs repo-local specialization vs generated docs/ai cache.
- Added non-canonical cache framing note after "What this skill creates or refreshes" table.
- Fixed `Last refreshed:` contradiction in idempotency rule - now explicitly defers to no-date-only-churn rule.
- Added thin-overlay framing to project-local specialization rule in embedded template.
- Added SvelteKit subdirectory note and critical server-side route files callout to bootstrap discovery probes, matching canonical skill.
- No installer behavior changes.

### 0.2.1 - 2026-05-21

Embedded template synced with repo v0.2.1:
- Instruction-layer topology note in discovery step 1.
- CHANGE_SURFACES mapping guidance: auth/admin/operator UX, deployment-sensitive, docs-impact surface categories.
- Agent handoff summary format in orientation report discipline.

### 0.2.0 - 2026-05-21

Embedded template synced with repo v0.2.0:
- No-date-only-churn rule.
- Orientation report discipline (Created / Substantively updated / Verified current / Proposed only / Skipped labels).
- Cross-file consistency rule.
- Normal/dry-run mode (moved earlier; added "audit only" / "no writes" triggers).
- When-to-use / when-to-skip guidance.
- Token-aware orientation cache guidance.
- Read-depth heuristic: path-existence vs content-read subsection; small source-of-truth file read rule.
- Cheap artifact glob rule.
- Open question quality rule.
- Project-local specialization rule (explicit `.claude/skills/codebase-orient/SKILL.md` path; Codex delegation noted).
- Formatter fallback guidance.
- Confidence labels: full 9 claim-origin distinctions.

### 0.1.1

- User-level Claude Code install scripts added to the repo: `scripts/install-bootstrap-user.ps1` and `scripts/install-bootstrap-user.sh`.
- README updated with bootstrap install instructions and "which skill?" guidance.
- No project-local bootstrap install scripts. No Codex bootstrap install support.

### 0.1.0

- Initial tracked version. Based on the installed `~/.claude/skills/install-codebase-orient/SKILL.md` at 2026-05-21, with three additions: `version` field in frontmatter, source callout block, and this changelog section.
- Added `version` field to frontmatter.
- Added source callout block noting Claude Code-only scope and Codex delegation.
- Embedded downstream template includes all canonical rules from `skills/codebase-orient/SKILL.md` as of codebase-orient-skill v0.1.1: docs-as-hypotheses rule, orientation completion rule, normal/dry-run mode, confidence labels (all 9 origins), hidden-risk reporting rule, source-of-truth drift detection rule, CI/deployment precision rule, read-depth heuristic, cheap artifact glob rule, open question quality rule, project-local specialization rule.
