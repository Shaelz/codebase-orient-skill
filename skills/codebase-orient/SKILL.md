---
name: codebase-orient
description: 'Use to orient Claude before broad or unfamiliar repo work. Good triggers: new or unfamiliar repo, new session, before multi-file changes, refactors, planning, or agent handoff, after route/schema/auth/deploy/config changes, when docs/ai/ is missing or stale, when repo structure or change surfaces are unclear, when the agent would otherwise spend significant context rediscovering the codebase. Skip for tiny single-file known fixes. Produces docs/ai/CODEBASE_MAP.md, CHANGE_SURFACES.md, OPEN_QUESTIONS.md. Trigger phrases: scan, orient, understand, map, review, audit, survey, familiarize, plan changes, where is X, how does this work, before I start.'
---

# Skill: codebase-orient

## Purpose

Orient Claude to the current state of this repo before non-trivial work. Produces or refreshes `docs/ai/CODEBASE_MAP.md`, `docs/ai/CHANGE_SURFACES.md`, and `docs/ai/OPEN_QUESTIONS.md`.

> **Customization note:** The `docs/ai/` output location is a convention. Adapt it to your project's documentation structure.

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
- Apply `docs/ai/` updates without requesting approval
- Report what changed at the end

**Dry-run / report-only mode** (use when the user says "dry-run", "report only", "don't write", "propose changes first", "audit only", "no writes", or similar):

- Inspect and collect proposed changes
- Report proposed edits to `docs/ai/` without writing them
- Wait for explicit approval before writing

If mode is not specified, default to Normal mode.
<!-- shared-rule:end:normal-mode-vs-dry-run-mode -->

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
13. Documentation - existing docs, verification matrices
14. Known uncertainty

## Framework-specific probes

Apply these probes in addition to the generic discovery order when the relevant framework is detected.

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

## Output files

After orientation, create or refresh:

- `docs/ai/CODEBASE_MAP.md`
- `docs/ai/CHANGE_SURFACES.md`
- `docs/ai/OPEN_QUESTIONS.md`

Add or update `Last refreshed: <date>` at the top of each file **only when its content changes for a substantive reason**. Do not update the date solely because orientation ran again. A file that is verified current and unchanged should be left as-is.

Before staging, format all created/updated files if the project has a discoverable formatter that covers Markdown (e.g., Prettier, markdownlint). If a formatter is missing, unavailable, not configured for Markdown, or its invocation would fail, skip formatting, note this clearly in the orientation report, and continue. Do not treat missing formatter support as an orientation failure.

<!-- shared-rule:start:change-surfaces-mapping-guidance -->
## CHANGE_SURFACES mapping guidance

When populating `docs/ai/CHANGE_SURFACES.md`, include entries for these change types in addition to the standard surfaces (routes, styling, schema, tests, config):

- **Auth/admin/operator UX changes**: admin panels, operator dashboards, internal tooling surfaces; note any accessibility requirements or WCAG targets found in source or docs
- **Deployment-sensitive changes**: flag files whose changes should prompt a smoke check after deploy; note likely smoke-check entry points (e.g., login page, health endpoint, main route)
- **Docs-impact changes**: for each major subsystem, note which project docs need updating alongside code changes (e.g., "changes to the auth flow should also update `docs/auth.md`")

Do not create separate `docs/ai/` files for smoke-check lists or handoff notes - record them inline in `CHANGE_SURFACES.md`.
<!-- shared-rule:end:change-surfaces-mapping-guidance -->

<!-- shared-rule:start:no-date-only-churn-rule -->
## No-date-only-churn rule

Do not rewrite a generated `docs/ai/` file solely to update a date, timestamp, or freshness marker.

- If a file has no substantive content changes after verification, leave it unchanged.
- Report it as **verified current** in the orientation report - not as "refreshed" or "updated".
- Only update the `Last refreshed:` date when file content changes for a substantive reason.
- If the project has an existing documented convention requiring date refreshes on every orientation pass, follow that convention - but only if it is explicitly documented in `CLAUDE.md`, `AGENTS.md`, or project docs.
<!-- shared-rule:end:no-date-only-churn-rule -->

## Staleness and update rule

The docs/ai files are orientation aids, not ground truth. Always verify against source code before editing.

After any structural change, check whether the three docs/ai files need updates. Update only the relevant sections. Do not rewrite the whole map unless the architecture changed significantly.

<!-- shared-rule:start:cross-file-consistency-rule -->
## Cross-file consistency rule

The three `docs/ai/` files must remain coherent with each other. After any update, verify:

- **Resolved questions**: if `OPEN_QUESTIONS.md` marks a question resolved, remove or update any stale "unknown" or "needs investigation" language in `CODEBASE_MAP.md` and `CHANGE_SURFACES.md` that referred to the same item.
- **New change surfaces**: if a change surface is added to `CHANGE_SURFACES.md`, check whether `CODEBASE_MAP.md` should mention the associated area or file.
- **New map uncertainty**: if a claim in `CODEBASE_MAP.md` becomes uncertain, check whether the corresponding open question exists in `OPEN_QUESTIONS.md`; add or update it if not.
- **Contradictions**: do not let one file say "unknown" or "unresolved" while another says "resolved" or "confirmed" - unless the distinction is explicitly explained.

Apply this as a final consistency pass after refreshing any of the three files.
<!-- shared-rule:end:cross-file-consistency-rule -->

<!-- shared-rule:start:orientation-completion-rule -->
## Orientation completion rule

Before finishing orientation, classify every unresolved open question as one of:

- **Blocking**: must resolve before safe work on the current task (e.g., unknown auth behavior before touching auth, unknown API shape before touching that route)
- **Relevant but non-blocking**: useful context for the task but work can proceed without it
- **Background**: not needed for the current task at all

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
- **Substantively updated**: content changed; `Last refreshed` date updated
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
## Project-local specialization rule

After the first orientation pass, if the repo has important project-specific namespaces, service folders, command groups, admin surfaces, workflow directories, generated-output locations, or deployment conventions that were not in the generic probe list, update the repo-local Claude Code skill at `.claude/skills/codebase-orient/SKILL.md` with those project-specific discovery paths.

This applies only when a repo-local skill exists at `.claude/skills/codebase-orient/SKILL.md` or is being generated during this session. If no such skill exists and the user has not requested skill installation, skip this step. Codex installs (`.agents/skills/codebase-orient/`) are handled by the source repo's install scripts, not by this rule.

Before writing the local specialization:
- Verify each proposed path exists with a glob or read.
- Briefly state why each path matters (e.g., "domain workflow folder", "admin resource directory").

Do not backport concrete project-specific paths to the public skill unless they are broadly reusable across many projects.

The project-specific paths added here are the thin, customisable layer of the repo-local skill. The canonical rules above are the stable layer that applies across all repos. Keep them visually separated - project-specific additions belong at the end of the file, clearly marked as project-local.

Examples of paths that qualify for local specialization:
- framework-adjacent service namespaces
- custom domain workflow folders
- admin page or resource directories
- manually-run tooling directories
- import/export pipeline directories
- deployment or release directories
- generated asset conventions

If the skill is running in dry-run/report-only mode, report the proposed local specialization but do not write it.
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
