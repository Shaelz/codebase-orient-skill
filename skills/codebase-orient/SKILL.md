---
name: codebase-orient
description: 'Use to orient Claude before broad or unfamiliar repo work. Good triggers: new or unfamiliar repo, new session, before multi-file changes, refactors, planning, or agent handoff, after route/schema/auth/deploy/config changes, when docs/ai/ is missing or stale, when repo structure or change surfaces are unclear, when the agent would otherwise spend significant context rediscovering the codebase. Skip for tiny single-file known fixes. Produces a provenance-backed four-artifact docs/ai package. Trigger phrases: scan, orient, understand, map, review, audit, survey, familiarize, plan changes, where is X, how does this work, before I start.'
---

# Skill: codebase-orient

## Purpose

Orient Claude to the current state of this repo before non-trivial work. It
creates or reconciles a fixed, provenance-backed four-artifact package in
`docs/ai/`. Source code and project configuration remain authoritative.

<!-- shared-rule:start:when-to-use-this-skill -->
## When to use this skill

### Use this skill when

- Entering a new or unfamiliar repo
- Starting a fresh session after meaningful time away from the repo
- Before broad or multi-file implementation work
- Before refactors, cleanups, architecture planning, or agent handoff
- After structural changes: routes, schema, auth, deployment, config, or admin surfaces
- When `docs/ai/` is missing, stale, incomplete, or internally inconsistent
- When repo structure, change surfaces, deploy targets, auth behavior, admin routes, commands, or test shape are unclear
- When the agent would otherwise spend significant context rediscovering what is already in or near `docs/ai/`
- Any time the user says "scan", "orient", "understand", "map", "review", "audit", "survey", "familiarize", or "before I start"

### Skip this skill when

- Making a tiny, local, known edit to a single file
- Fixing a one-file bug where the relevant file and the change are already clear
- Making copy-only or string-only changes
- The task is scoped tightly to files already verified in the current context
- `docs/ai/` was just refreshed and the task is narrow enough not to need a full orientation pass
<!-- shared-rule:end:when-to-use-this-skill -->

<!-- shared-rule:start:token-aware-use-guidance -->
## Token-aware use guidance

`docs/ai/` is an orientation cache. A fresh cache reduces repeated repo-discovery token cost across sessions and agent handoffs.

- **If `docs/ai/` is fresh and complete**: read it as context and proceed. Skip re-running orientation.
- **If `docs/ai/` may be stale or is missing**: run the skill to refresh the cache. The upfront token cost amortizes across the work ahead.
- **If the task is tiny and the target file is already known**: skip orientation. Use targeted reads instead.
- **If the agent would spend many tokens rediscovering what `docs/ai/` already captures**: refresh it.

Do not save tokens by skipping orientation and then guessing at structure. If broad repo discovery would otherwise be repeated or expensive, refresh the cache instead.
<!-- shared-rule:end:token-aware-use-guidance -->

## Hard rules during orientation

- Do not modify application or source code.
- Do not refactor.
- Do not commit.
- Verify claims against source code before writing them.
- Mark every meaningful claim with a confidence label.

<!-- shared-rule:start:normal-mode-vs-dry-run-mode -->
## Normal mode vs dry-run mode

**Normal mode** (default - use when the user does not specify):

- Resolve small task-relevant uncertainties automatically by reading source files
- Create a full package on first use in a clean repository
- Reuse an exact-current clean package without rewriting it
- Treat an unspecific request to refresh or reconcile as a full reconciliation
- Report what changed at the end

**Dry-run / report-only mode** (use when the user says "dry-run", "report only", "don't write", "propose changes first", "audit only", "no writes", or similar):

- Inspect and collect proposed changes
- Report proposed edits to `docs/ai/` without writing them
- Wait for explicit approval before writing

If mode is not specified, default to Normal mode.
<!-- shared-rule:end:normal-mode-vs-dry-run-mode -->

## Lifecycle and write safety

- **Explicit refresh:** Refresh or reconcile only when the user explicitly asks
  after an exact-current package is found.
- **Scoped refresh:** Follow an explicit user scope and its direct dependencies.
  Record scoped coverage without advancing or claiming a package-wide full
  snapshot. Do not create a partial supported package before a full package
  exists.
- **Legacy adoption:** Markdown artifacts without `ORIENTATION_STATE.json` are
  legacy material. Inspect them, but obtain explicit approval before writing a
  manifest or changing them. Reconcile from source after approval.
- **Dirty tree:** Before writing state that represents uncommitted work, ask
  whether to write a dirty snapshot or report only. Record the tree condition;
  keep it marked dirty until a clean refresh replaces it.
- **No usable Git history:** Perform a full reconciliation and record that
  revision comparison is unavailable.
- **Manual edits:** Orient owns the package. Do not promise merge or preservation
  behavior for manually edited Orient state.

<!-- shared-rule:start:confidence-labels -->
## Confidence labels

- **Fact**: directly verified in code or docs
- **Strong inference**: supported by multiple files
- **Weak inference**: plausible but not confirmed
- **Unknown**: needs more inspection before editing

Distinguish how a claim was established:

- _independently verified from source/config_: claim checked against the actual source or config file, not taken from docs
- _inherited from existing docs_: claim taken from CLAUDE.md, README, or other documentation without independent verification
- _inherited then verified_: claim originated in docs and was subsequently confirmed against source
- _path existence confirmed_: file found but not read
- _partial read_: portion of the file inspected; may not capture full context
- _full source read_: complete file content inspected
- _inferred from implementation_: deduced from how code behaves, not explicitly stated
- _inferred from comments/tests/fixtures_: sourced from non-authoritative context; treat as Strong inference at best
- _behavior verified by test_: confirmed by passing test execution
- _unknown_: basis not established; do not present as Fact

In final reports and orientation docs, label each non-trivial claim with one of the above origins so readers can judge which claims need re-verification before acting on them.
<!-- shared-rule:end:confidence-labels -->

## Discovery order

> **Customization note:** The discovery order below is intentionally broad and works across most project shapes without editing. You can tune the file paths and order for a specific project, but this is optional - not required before first use.

Execute in this order:

1. Project instruction files such as `CLAUDE.md`, `AGENTS.md`, and `README.md`, if present - product purpose, agent rules, project conventions.
   <!-- shared-rule:start:docs-as-hypotheses-rule -->
   **Docs-as-hypotheses rule**
   - Treat these documents as helpful hypotheses, not authoritative truth.
   - Extract high-impact factual claims about architecture, routes, deployment, tests, and source-of-truth files.
   - Verify those claims against source code before relying on them. Focus on claims that would affect future edits; do not audit every sentence.
   - Do not copy claims from these docs into `CODEBASE_MAP.md` without labeling whether they are _independently verified from source/config_ or _inherited from existing docs_.
   - If an instruction doc is stale or misleading compared to what the source shows, record the drift in `OPEN_QUESTIONS.md` under the hidden-risk reporting rule and label it as documentation drift.
   - Map the instruction-layer topology: note which instruction files are present (e.g., `CLAUDE.md`, `AGENTS.md`, `.claude/settings.json`) and at which scope (project-local vs user-level). Record this in `CODEBASE_MAP.md`; it helps future agents know which rules apply.
   <!-- shared-rule:end:docs-as-hypotheses-rule -->
2. Project manifest (e.g., `package.json`, `pyproject.toml`, `Cargo.toml`) - deps, scripts, build/test commands
3. Build and config files (e.g., framework config, bundler config) - adapter, build config
4. `scripts/` directory, if present - may contain manually-run tooling not represented in package scripts or CI
5. Entry points and routing layer - all pages, controllers, or API routes
6. Core business logic - domain types, models, scoring, report logic
7. Server-side services - auth, db/schema, email, external integrations
8. UI/presentation layer - components, views, templates
9. Internationalisation or copy files - locale files
10. Request lifecycle / middleware - hooks, interceptors, middleware
11. Database layer - migrations, schema snapshots
12. Tests - test structure and coverage shape
13. Documentation - existing docs, verification matrices. If a release plan, milestone tracking doc, or version changelog is found, add a `## Release status` section to `CODEBASE_MAP.md` summarizing the current version, active milestone, and what is blocking the next release. Omit this section if no release lifecycle artifact is present.
14. Known uncertainty

## Framework-specific probes

Apply these probes in addition to the generic discovery order when the relevant framework is detected.

The reusable skill currently includes one explicit tuned probe set for SvelteKit. Other frameworks currently use the generic discovery order unless later live-fire or eval evidence justifies a dedicated tuned probe section.

### SvelteKit

Glob the following file patterns when a SvelteKit project is detected:

- `src/routes/**/+page.svelte`: UI route pages; each file is a route candidate; check subdirectories, not only the top-level `src/routes/+page.svelte`
- `src/routes/**/+page.server.ts`: server-side data loading, form actions, and route-level access control
- `src/routes/**/+layout.svelte`: shared layout shells
- `src/routes/**/+layout.server.ts`: server-side load functions for layout-level auth, session, or data
- `src/routes/**/+server.ts`: API endpoints and server-only request handlers

Server-side route files (`+page.server.ts`, `+layout.server.ts`, `+server.ts`) are critical for understanding auth, data loading, form actions, API endpoints, and route-level access control. Do not skip them when mapping routes or change surfaces.

- The standard app shell template is `src/app.html`.
- Adapter choice in `svelte.config.js` determines deployment target - confirm before making deployment-related claims.

<!-- shared-rule:start:ci-deployment-precision-rule -->
## CI/deployment precision rule

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
<!-- shared-rule:end:ci-deployment-precision-rule -->

<!-- shared-rule:start:read-depth-heuristic -->
## Read-depth heuristic

Do not read every large CSS, config, or generated file by default.

- **Full read**: files that directly affect the requested task (entry points, routing, auth, schema, build config, the file to be edited).
- **Partial read or path-confirmation only**: secondary surfaces such as large style sheets, vendored code, generated output, or config files not relevant to the task. If you only confirm a file's path or read a portion, say so explicitly in the report using the _path existence confirmed_ or partial-read labels defined under Confidence labels.
- **Skip**: files that are clearly out of scope (e.g., binary assets, lock files, test snapshots) unless a specific question makes them relevant.

When in doubt, prefer confirming existence first and reading fully only if a claim requires it.

### Path existence vs content read

Path existence alone is sufficient for low-risk inventory claims - confirming a directory structure, listing file counts, or noting that a config file is present.

Read the actual file content when the claim affects behavior, architecture, risk, commands, deployment, auth, routing, or change surfaces. Do not label a claim as _independently verified from source/config_ based on path existence alone when the file is cheap to inspect and its content would materially affect the map.

### Small source-of-truth file read rule

If a small file appears to define vocabulary or source-of-truth tokens used throughout the project, read enough of it to verify the vocabulary rather than inheriting the vocabulary from docs.

Examples where this applies:

- CSS custom-property token files
- route or menu config files
- small schema or constants files
- command or plugin registries

Use a partial read when that is sufficient. Label the resulting claims with the appropriate claim origin (_partial read_, _full source read_). Do not label them as _independently verified from source/config_ if you did not actually read the file.
<!-- shared-rule:end:read-depth-heuristic -->

<!-- shared-rule:start:cheap-artifact-glob-rule -->
## Cheap artifact glob rule

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
<!-- shared-rule:end:cheap-artifact-glob-rule -->

<!-- shared-rule:start:open-question-quality-rule -->
## Open question quality rule

Do not leave an open question in `OPEN_QUESTIONS.md` if it can be resolved with one cheap path glob or one small-file read.

Leave a question open only when resolving it would require:

- broad exploration that is disproportionate to the task
- external documentation that is unavailable
- commands that could have side effects
- deep reads of files that are irrelevant to the current task

If a glob or small read can close the question, close it and label the basis.
<!-- shared-rule:end:open-question-quality-rule -->

## Supported orientation package

A full supported package always contains:

- `docs/ai/ORIENTATION_STATE.json`
- `docs/ai/CODEBASE_MAP.md`
- `docs/ai/CHANGE_SURFACES.md`
- `docs/ai/OPEN_QUESTIONS.md`

`ORIENTATION_STATE.json` is the single freshness and provenance record. It
records the format, producer and Orient version, package-wide source revision
and ref where available, tree condition, expected artifact inventory,
reconciliation mode, and compact scoped coverage where applicable. Keep it a
compact current-state record, not telemetry or an append-only diary.

The Markdown artifacts do not carry `Last refreshed:` lines. `OPEN_QUESTIONS.md`
always exists; when no material questions remain, state that explicitly.

In target repos, these files should be committed to version control. They are authored narrative that improves across sessions, not regenerable cache - do not add them to `.gitignore` in target repos.

Before staging, format all created/updated files if the project has a discoverable formatter that covers Markdown (e.g., Prettier, markdownlint). If a formatter is missing, unavailable, not configured for Markdown, or its invocation would fail, skip formatting, note this clearly in the orientation report, and continue. Do not treat missing formatter support as an orientation failure.

<!-- shared-rule:start:change-surfaces-mapping-guidance -->
## CHANGE_SURFACES mapping guidance

When populating `docs/ai/CHANGE_SURFACES.md`, include entries for these change types in addition to the standard surfaces (routes, styling, schema, tests, config):

- **Auth/admin/operator UX changes**: admin panels, operator dashboards, internal tooling surfaces; note any accessibility requirements or WCAG targets found in source or docs
- **Deployment-sensitive changes**: flag files whose changes should prompt a smoke check after deploy; note likely smoke-check entry points (e.g., login page, health endpoint, main route)
- **Docs-impact changes**: for each major subsystem, note which project docs need updating alongside code changes (e.g., "changes to the auth flow should also update `docs/auth.md`"). For check or validation scripts found in `scripts/`, note what file types or patterns they enforce as a constraint on docs-impact changes (e.g., ASCII-only enforcement that applies to all tracked Markdown).

Do not create separate `docs/ai/` files for smoke-check lists or handoff notes - record them inline in `CHANGE_SURFACES.md`.
<!-- shared-rule:end:change-surfaces-mapping-guidance -->

<!-- shared-rule:start:no-date-only-churn-rule -->
## No-date-only-churn rule

Do not rewrite the package solely to change a date, timestamp, or freshness
marker. Freshness belongs in `ORIENTATION_STATE.json`, and a normal exact-current
reuse leaves every artifact unchanged.
<!-- shared-rule:end:no-date-only-churn-rule -->

## Staleness and update rule

The docs/ai files are orientation aids, not ground truth. Always verify against source code before editing.

When re-running orientation on a repo that already has docs/ai/ files, read them to understand what was previously recorded - but treat their structural claims as hypotheses requiring source verification, the same way the docs-as-hypotheses rule applies to CLAUDE.md and README.md. Do not accept prior orientation claims as discovery input for the new analysis pass; verify them against source before carrying them forward.

After any structural change, check whether the package needs reconciliation.
Update only relevant content unless a full reconciliation is requested or
required by unsafe provenance comparison.

<!-- shared-rule:start:cross-file-consistency-rule -->
## Cross-file consistency rule

The four `docs/ai/` artifacts must remain coherent with each other. After any update, verify:

- **Resolved questions**: if `OPEN_QUESTIONS.md` marks a question resolved, remove or update any stale "unknown" or "needs investigation" language in `CODEBASE_MAP.md` and `CHANGE_SURFACES.md` that referred to the same item.
- **New change surfaces**: if a change surface is added to `CHANGE_SURFACES.md`, check whether `CODEBASE_MAP.md` should mention the associated area or file.
- **New map uncertainty**: if a claim in `CODEBASE_MAP.md` becomes uncertain, check whether the corresponding open question exists in `OPEN_QUESTIONS.md`; add or update it if not.
- **Contradictions**: do not let one file say "unknown" or "unresolved" while another says "resolved" or "confirmed" - unless the distinction is explicitly explained.

Apply this as a final consistency pass after reconciling any package artifact.
<!-- shared-rule:end:cross-file-consistency-rule -->

<!-- shared-rule:start:orientation-completion-rule -->
## Orientation completion rule

Before finishing orientation, classify every unresolved open question as one of:

- **Blocking**: must resolve before safe work on the current task (e.g., unknown auth behavior before touching auth, unknown API shape before touching that route)
- **Relevant but non-blocking**: useful context for the task but work can proceed without it
- **Background**: not needed for the current task at all

Also classify each open question by who can act on it:

- **Agent-closable**: resolvable by running a command, reading a file, or making a local change
- **Human-required**: requires external access, permissions, approvals, or out-of-band action

This second axis lets a new agent immediately identify which items it can work on autonomously without waiting for human input.

Then apply these rules:

1. **Automatically resolve Blocking questions** by reading the minimum necessary files - unless the user explicitly requested dry-run or report-only mode.
2. **Apply docs/ai updates without asking first** when only docs/ai files need to change. Do not prompt for approval on small documentation corrections unless the user asked for it.
3. **Do not stop to prompt the user** for permission to resolve small documentation uncertainties. Use judgment and proceed safely within the hard rules.
4. **Stop and hand off** only when:
   - relevant change surfaces are identified
   - blocking unknowns are resolved or explicitly marked as non-blocking
   - docs/ai is current enough for the requested task
   - the next action is clear

For Relevant-but-non-blocking and Background questions: record them in `OPEN_QUESTIONS.md` with their classification and move on. Do not let them block the orientation report.
<!-- shared-rule:end:orientation-completion-rule -->

<!-- shared-rule:start:orientation-report-discipline -->
## Orientation report discipline

The final orientation report must distinguish between docs that changed and docs that did not. Label each `docs/ai/` file with one of:

- **Created**: file did not exist; was created this pass
- **Substantively updated**: content and manifest provenance changed
- **Verified current / unchanged**: content inspected and confirmed accurate; file not rewritten
- **Proposed only**: dry-run mode; change proposed but not written
- **Skipped**: file not inspected this pass; state why

Do not label a file as "updated" or "refreshed" if only its date changed. A file with no substantive changes must be reported as **verified current / unchanged**.

### Agent handoff summary

When orientation is requested before an agent handoff, append a compact **Handoff summary** block to the orientation report:

- **Snapshot**: 3-5 key facts: framework, entry point, auth mechanism, deploy target, test approach
- **Blocking open questions**: anything that must resolve before safe work begins
- **Critical change surfaces**: top 3-5 surfaces most likely affected by the incoming work
- **Recommended first action**: what the receiving agent should do first

Keep it under 150 words. Do not create a separate `docs/ai/` file for it.
<!-- shared-rule:end:orientation-report-discipline -->

<!-- shared-rule:start:project-local-specialization-rule -->
## Project-local runtime mutation boundary

Do not create, update, specialize, migrate, or preserve
`.claude/skills/codebase-orient/SKILL.md` during orientation. A repo-local
installed skill is runtime material, not Orient state. Existing specialized
copies are legacy local state with no automatic migration or overlay contract.

Report useful project-specific paths in the supported `docs/ai/` package. Do
not invent a replacement overlay system.
<!-- shared-rule:end:project-local-specialization-rule -->

<!-- shared-rule:start:hidden-risk-reporting-rule -->
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
- release validation records or gate scripts present in the repo (if found, note in CHANGE_SURFACES that any file change after a validated candidate requires a re-check before tagging)

For each item, report:

- Evidence
- Risk
- Confidence
- Recommended action
- Whether action is needed now or can be deferred

If a hidden-risk item affects reproducibility, future installs, runtime behavior, or source-of-truth clarity, classify it as Blocking or Relevant but non-blocking, not Background.
<!-- shared-rule:end:hidden-risk-reporting-rule -->

<!-- shared-rule:start:source-of-truth-drift-detection-rule -->
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
<!-- shared-rule:end:source-of-truth-drift-detection-rule -->
