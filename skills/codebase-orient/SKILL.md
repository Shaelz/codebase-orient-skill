---
name: codebase-orient
description: 'Orient Claude to the current codebase before non-trivial work. Use before audits, refactors, new features, route/page changes, schema changes, auth changes, i18n changes, test changes, deployment changes, or whenever the user says scan, understand, map, review, or orient the codebase.'
---

# Skill: codebase-orient

## Purpose

Orient Claude to the current state of this repo before non-trivial work. Produces or refreshes `docs/ai/CODEBASE_MAP.md`, `docs/ai/CHANGE_SURFACES.md`, and `docs/ai/OPEN_QUESTIONS.md`.

> **Customization note:** The `docs/ai/` output location is a convention. Adapt it to your project's documentation structure.

## When to use this skill

Use before:

- audits and security reviews
- refactors or architectural changes
- adding new features
- editing unfamiliar areas
- architecture planning
- route/page changes
- data model or schema changes
- auth or session changes
- i18n/copy changes
- test architecture changes
- deployment or config changes
- any time the user says "scan", "understand", "map", "review", or "orient"

## Hard rules during orientation

- Do not modify application or source code.
- Do not refactor.
- Do not commit.
- Verify claims against source code before writing them.
- Mark every meaningful claim with a confidence label.

## Confidence labels

- **Fact** — directly verified in code or docs
- **Strong inference** — supported by multiple files
- **Weak inference** — plausible but not confirmed
- **Unknown** — needs more inspection before editing

Distinguish how a claim was established:

- _path existence confirmed_ — file found but not read
- _full source read_ — complete file content inspected
- _inferred from implementation_ — deduced from how code behaves, not explicitly stated
- _inferred from comments/tests/fixtures_ — sourced from non-authoritative context; treat as Strong inference at best
- _behavior verified by test_ — confirmed by passing test execution
- _unknown_ — basis not established; do not present as Fact

## Discovery order

> **Customization note:** The discovery order below is intentionally broad and works across most project shapes without editing. You can tune the file paths and order for a specific project, but this is optional — not required before first use.

Execute in this order:

1. Project instruction files such as `CLAUDE.md`, `AGENTS.md`, and `README.md`, if present — product purpose, agent rules, project conventions.
   - Extract high-impact factual claims about architecture, routes, deployment, tests, and source-of-truth files.
   - Verify those claims against source code before relying on them. Focus on claims that would affect future edits; do not audit every sentence.
   - If an instruction doc is stale or misleading compared to what the source shows, record the drift in `OPEN_QUESTIONS.md` under the hidden-risk reporting rule.
2. Project manifest (e.g., `package.json`, `pyproject.toml`, `Cargo.toml`) — deps, scripts, build/test commands
3. Build and config files (e.g., framework config, bundler config) — adapter, build config
4. `scripts/` directory, if present — may contain manually-run tooling not represented in package scripts or CI
5. Entry points and routing layer — all pages, controllers, or API routes
6. Core business logic — domain types, models, scoring, report logic
7. Server-side services — auth, db/schema, email, external integrations
8. UI/presentation layer — components, views, templates
9. Internationalisation or copy files — locale files
10. Request lifecycle / middleware — hooks, interceptors, middleware
11. Database layer — migrations, schema snapshots
12. Tests — test structure and coverage shape
13. Documentation — existing docs, verification matrices
14. Known uncertainty

## Framework-specific probes

Apply these probes in addition to the generic discovery order when the relevant framework is detected.

### SvelteKit

- Glob `src/routes/**/+page.svelte` to enumerate all routes. Each `+page.svelte` file is a route candidate; check subdirectories, not only the top-level `src/routes/+page.svelte`.
- The standard app shell template is `src/app.html`.
- Check `src/routes/**/+layout.svelte`, `+server.ts`, and `+page.server.ts` files for shared layout and server-side logic.
- Adapter choice in `svelte.config.js` determines deployment target — confirm before making deployment-related claims.

## Read-depth heuristic

Do not read every large CSS, config, or generated file by default.

- **Full read** — files that directly affect the requested task (entry points, routing, auth, schema, build config, the file to be edited).
- **Partial read or path-confirmation only** — secondary surfaces such as large style sheets, vendored code, generated output, or config files not relevant to the task. If you only confirm a file's path or read a portion, say so explicitly in the report using the _path existence confirmed_ or partial-read labels defined under Confidence labels.
- **Skip** — files that are clearly out of scope (e.g., binary assets, lock files, test snapshots) unless a specific question makes them relevant.

When in doubt, prefer confirming existence first and reading fully only if a claim requires it.

## Output files

After orientation, create or refresh:

- `docs/ai/CODEBASE_MAP.md`
- `docs/ai/CHANGE_SURFACES.md`
- `docs/ai/OPEN_QUESTIONS.md`

Add `Last refreshed: <date>` at the top of each.

Before staging, format all created/refreshed files according to your project's linting requirements (e.g., Prettier, markdownlint).

## Staleness and update rule

The docs/ai files are orientation aids, not ground truth. Always verify against source code before editing.

After any structural change, check whether the three docs/ai files need updates. Update only the relevant sections. Do not rewrite the whole map unless the architecture changed significantly.

## Orientation completion rule

Before finishing orientation, classify every unresolved open question as one of:

- **Blocking** — must resolve before safe work on the current task (e.g., unknown auth behavior before touching auth, unknown API shape before touching that route)
- **Relevant but non-blocking** — useful context for the task but work can proceed without it
- **Background** — not needed for the current task at all

Then apply these rules:

1. **Automatically resolve Blocking questions** by reading the minimum necessary files — unless the user explicitly requested dry-run or report-only mode.
2. **Apply docs/ai updates without asking first** when only docs/ai files need to change. Do not prompt for approval on small documentation corrections unless the user asked for it.
3. **Do not stop to prompt the user** for permission to resolve small documentation uncertainties. Use judgment and proceed safely within the hard rules.
4. **Stop and hand off** only when:
   - relevant change surfaces are identified
   - blocking unknowns are resolved or explicitly marked as non-blocking
   - docs/ai is current enough for the requested task
   - the next action is clear

For Relevant-but-non-blocking and Background questions: record them in `OPEN_QUESTIONS.md` with their classification and move on. Do not let them block the orientation report.

## Normal mode vs dry-run mode

**Normal mode** (default — use when the user does not specify):

- Resolve small task-relevant uncertainties automatically by reading source files
- Apply docs/ai updates without requesting approval
- Report what changed at the end

**Dry-run / report-only mode** (use when the user says "dry-run", "report only", "don't write", "propose changes first", or similar):

- Inspect and collect proposed changes
- Report proposed edits to docs/ai without writing them
- Wait for explicit approval before writing

If mode is not specified, default to Normal mode.

## Hidden-risk reporting rule

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

For each item, report:

- Evidence
- Risk
- Confidence
- Recommended action
- Whether action is needed now or can be deferred

If a hidden-risk item affects reproducibility, future installs, runtime behavior, or source-of-truth clarity, classify it as Blocking or Relevant but non-blocking, not Background.

## Source-of-truth drift detection rule

When multiple copies or layers exist, explicitly map them before declaring the system current.

Check for:

- editable source files
- generated files
- packaged archives
- runtime/plugin registry copies
- global/user-level copies
- project-local copies
- committed repo files
- ignored local files
- cache/session-loaded copies

For each layer, identify:

- what it is used for
- whether it is authoritative
- whether it is tracked by git
- whether it is regenerated from another source
- whether it can overwrite another copy
- whether it survives restart, reinstall, clone, deploy, or future session

If two copies differ, do not just update the currently active copy. Report the drift and either:

- update all authoritative/durable copies, or
- clearly mark which copy remains stale and what consequence that has.
