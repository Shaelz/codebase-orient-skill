# Changelog

## 1.0.0-rc.4 - 2026-05-23

Pre-public sanitation candidate for external cold-user validation. No skill behavior or installer changes.

**Documentation sanitation:**

- Remove maintainer-local filesystem paths from tracked public-intended docs.
- Generalize private validation target names and local snapshot identifiers to public-safe repo-type descriptions while preserving the validation outcomes that matter for release confidence.
- Keep the public distribution model unchanged: documented manual installation only; no marketplace or plugin packaging work added.

**Release status:**

- `v1.0.0-rc.3` remains the last pre-public contract-correction candidate, but it is blocked for publication because the tracked docs and reachable tags/history still carried private validation identifiers and local path disclosures.
- `v1.0.0-rc.4` is the new publication-safe candidate for independent cold-user validation.
- External cold-user validation remains pending and must now run against `v1.0.0-rc.4`.

---

## 1.0.0-rc.3 - 2026-05-23

Pre-validation contract correction before external cold-user testing. No skill behavior or installer changes.

**README corrections:**

- Narrow the early safety NOTE: distinguish normal-mode writes (`docs/ai/*` creation or refresh) from dry-run mode (proposes changes without writing); disclose that Claude Code project-local installs may also update `.claude/skills/codebase-orient/SKILL.md` with verified project-specific discovery paths.
- Add `### Claude Code project-local specialization` under `## Important notes`: concisely states what specialization writes, that canonical rules are not overwritten, that dry-run mode suppresses the write, and that Codex project-local installs do not use this behavior.
- Restore a compact `## Limitations and trust` section: explicit invocation is the reliable path; orientation improves process not correctness; large monorepos may need scoped orientation; skills are agent instructions and `SKILL.md` should be reviewed before installing.

**Release status:**

- `v1.0.0-rc.1` and `v1.0.0-rc.2` remain intact as immutable historical candidates.
- `v1.0.0-rc.2` should no longer be used for external cold-user validation; the mutation-scope and trust-posture wording corrected here was not present in that candidate.
- External cold-user validation is pending and must now run against `v1.0.0-rc.3`.

---

## 1.0.0-rc.2 - 2026-05-23

Promote the post-`rc.1` user-facing corrections into the active release candidate for external cold-user validation.

**User-facing corrections:**

- Rewrite `README.md` around a faster newcomer journey: what the skill is, which install path applies, the exact command to run, the first prompt to give the agent, and the expected repo changes.
- Clarify local acquisition and shell-script invocation: README now supports clone or download flows and uses `bash ./scripts/...` or `bash /path/to/...` for macOS/Linux examples where archive downloads may not preserve executable bits.
- Fix project-local `.gitignore` guidance emitted by the Claude Code and Codex project-local installer scripts: all four scripts now print `.claude/*` or `.agents/*` with the required negations so the shared `SKILL.md` file can actually be re-included and tracked.
- Behaviorally verify the corrected `.gitignore` guidance with `git add -n` / ignore-state checks before promoting this candidate.

**Release status:**

- `v1.0.0-rc.1` remains intact as the prior historical candidate and does not contain these README / installer-guidance fixes.
- Final `v1.0.0` remains blocked on the external cold-user validation gate and should be tested against `v1.0.0-rc.2`, not `v1.0.0-rc.1`.

---

## 1.0.0-rc.1 - 2026-05-22

Freeze the cold-user validation baseline. All implementation and accumulated validation evidence are complete. Final `v1.0.0` tag is gated by one remaining external acceptance result: an independent cold-user install simulation (G.2).

**Validation and evidence (docs only):**

- Add `docs/V1_RELEASE_PLAN.md`: v1.0 definition, release criteria, test matrix, live-fire validation matrix, blockers, non-goals, known risks, definition of done, and next immediate step.
- Record completed v0.3.2 install matrix validation: Windows PowerShell (5 scripts, 5 cases each) and Git Bash (18 checks, 18/18 PASS) from disposable tagged clone.
- Complete canonical/bootstrap embedded-template drift check: no material unintentional drift found; no edits to either SKILL.md required.
- Backfill live-fire validation evidence from prior Claude Code passes: one external SvelteKit/frontend repo (normal mode) and one external Laravel/backend/deployment-sensitive repo (normal mode). F-matrix Rows 1, 2, 7, 8 satisfied.
- Record external Codex live-fire pass in the external Laravel/backend/deployment-sensitive repo (project-local skill, cross-agent cache lifecycle, no date-only churn, no application code modified). Close G.4. F-matrix Row 6 PASS.
- Record a second cross-agent cache-lifecycle validation in an external SvelteKit/static-portfolio/deployment-workflow repo: Claude Code refreshed orientation cache; Codex found substantive README drift and pushed only documentation/orientation corrections. Corroborating second external cross-agent lifecycle evidence.
- Record blind no-Git dry-run validation in an unseen legacy PHP CMS snapshot (Codex user-level skill, no prior docs/ai). Codex surfaced a real maintenance-doc versus config contradiction and recommended dry-run only. F-matrix Row 4 PASS. F-matrix rows satisfied: 6/8.
- Polish README onboarding clarity before independent cold-user validation: surface the default install choice and make update guidance explicit without changing behavior.

No Skill or installer behavior changes.

---

## 0.3.2 - 2026-05-22

Normalize and enforce ASCII punctuation in tracked repo-maintenance text.

**Smart punctuation removal:**

- Replace ~210 lines of em dashes across CHANGELOG.md, README.md, and both SKILL.md files.
- Replacement rules: closing markdown span (`**label**`, `_label_`, `` `code` ``) followed by em dash converted to colon-space; all other em dashes converted to space-hyphen-space.
- En dashes in numeric ranges (`3-5`) replaced with hyphen-minus.
- `<=150` replaced with `under 150` in CHANGELOG.

**Enforcement:**

- Add `scripts/check-ascii-punctuation.ps1` and `scripts/check-ascii-punctuation.sh` - scan tracked text files for forbidden smart punctuation; exit 1 if found.
- Update README development notes: strict ASCII-only convention now covers all tracked repo-maintenance text, not just terminal output strings. SKILL.md files are read as style templates by Claude/Codex; smart punctuation bleeds into generated orientation docs.

No skill or installer behavior changes.

---

## 0.3.1 - 2026-05-22

v1 contract cleanup based on skeptical second-opinion audit.

**Artifact policy - `.gitignore`:**

- Add `.agents/` to `.gitignore`: Codex project-local install artifacts in this source repo are local runtime artifacts and should not be tracked.
- Add `docs/ai/` to `.gitignore`: generated self-orientation cache is non-canonical in this source repo and should not be tracked.

**Install refresh semantics - `README.md`:**

- Document that `-Force` / `--force` is an overlay install: source files are copied over the target, but files removed from the source package since the last install are not pruned from the installed target.
- Add delete-first workaround note for clean exact-sync reinstalls.

**Project-local CWD contract - `README.md`:**

- Add explicit note that project-local install scripts use the current working directory as the install root and do not verify it is a repository root.

**Codex lifecycle parity - `README.md`:**

- Add callout after Codex project-local install section: bootstrap skill and post-orientation project-local specialization are Claude Code only features; Codex project-local installs get the generic skill and require explicit invocation.

**Manual copy example alignment - `README.md`:**

- Change bash manual copy examples from `cp -R .../\*` to `cp -r .../. ` to match script semantics (includes hidden files; currently harmless since the package has none, but examples now match exactly).

---

## 0.3.0 - 2026-05-21

Consolidates post-v0.2.0 work into a tagged release. The orientation behavior additions recorded in the v0.2.1 development entry (instruction-layer topology, CHANGE_SURFACES mapping guidance, agent handoff summary) are included under this tag - v0.2.1 was a named development checkpoint that was never separately tagged.

**Installer output hardening - `scripts/*.sh`, `README.md` (9bc01df):**

- Replace non-ASCII characters (em dashes, curly quotes) in installer script terminal output with ASCII equivalents.
- Reduces mojibake rendering in PowerShell 5.1 / Windows terminals on code page 1252.
- Added ASCII-only output encoding convention to README development notes.
- No install behavior changes.

**Authority-boundary clarification - `skills/codebase-orient/SKILL.md` (a707995):**

- Add thin-overlay framing to project-local specialization rule: project-specific paths are the thin customisable layer; canonical rules are the stable layer across all repos; keep them visually separated.
- Closes source/mirror inconsistency introduced in c75c675.

**Authority-boundary clarification - `skills/install-codebase-orient/SKILL.md` (c75c675):**

- Fix `Last refreshed:` contradiction in idempotency rule: now defers to the no-date-only-churn rule.
- Add generated-cache framing note after creates table: `docs/ai/` files are orientation aids; source code and project config remain authoritative.
- Add thin-overlay framing to project-local specialization rule in embedded template.
- Add SvelteKit subdirectory note and critical server-side route files callout to bootstrap discovery probes, matching canonical skill.
- Add internal changelog entries for v0.2.0 and v0.2.1 syncs (previously unrecorded).
- Bump `install-codebase-orient` frontmatter version to `0.2.2`.

---

## 0.2.1 - 2026-05-21

Weaves orientation-core deep-research findings into the skill without adding new default docs files, hooks, or automation.

**Findings woven in (canonical skill + bootstrap embedded template):**

- **Instruction-layer topology**: discovery step 1 now notes which instruction files are present (`CLAUDE.md`, `AGENTS.md`, `.claude/settings.json`) and at which scope (project-local vs user-level); recorded in `CODEBASE_MAP.md` for agent handoff clarity.
- **CHANGE_SURFACES mapping guidance**: new section explicitly calls out three additional surface categories: auth/admin/operator UX changes (with a11y/WCAG note), deployment-sensitive changes (with smoke-check entry-point note), and docs-impact changes (which docs need updating per subsystem). Hard rule added: no separate smoke-check or handoff files in `docs/ai/`.
- **Agent handoff summary**: orientation report discipline now includes an optional compact handoff block (snapshot, blocking questions, critical surfaces, recommended first action; under 150 words, no new file).

**Bootstrap sync:** `skills/install-codebase-orient/SKILL.md` updated - CHANGE_SURFACES template section and embedded downstream template both reflect the three new findings.

**Rejected:** hooks, CI automation, release checklist, full a11y audit, separate `AGENT_HANDOFFS.md` / `DEPLOYMENT_SMOKE_CHECKS.md` by default, safe-cleanup behavior, sceptical review behavior - none are orientation-core.

---

## 0.2.0 - 2026-05-21

Dual-runtime orientation skill with bootstrap support. Adds Codex install, recursive skill copy, user-level bootstrap install scripts, live-fire-driven refresh behavior, cross-file consistency rules, no-date-only-churn rule, and trigger-oriented / token-aware invocation guidance.

---

No-date-only-churn fix from second no-wrapper live-fire test:

- **No-date-only-churn rule**: do not rewrite a `docs/ai/` file solely to bump the `Last refreshed` date. A verified-current doc is left unchanged. `Last refreshed` is updated only when content changes for a substantive reason.
- **Orientation report discipline**: final report must label each `docs/ai/` file as: Created / Substantively updated / Verified current (unchanged) / Proposed only / Skipped. Reporting a date-only rewrite as "updated" is not allowed.
- **Bootstrap embedded template synced**: both rules added to `skills/install-codebase-orient/SKILL.md`.
- No installer behavior changes.

Invocation reliability and token-aware use improvements:

- **Trigger-oriented skill description**: `codebase-orient` frontmatter `description` rewritten to be richer in trigger signals: new/unfamiliar repo, new session, before multi-file work, before refactor/planning/handoff, stale `docs/ai/`, unclear structure. Includes explicit trigger phrases (`scan`, `orient`, `survey`, `familiarize`, `before I start`, etc.) and explicit skip signal (tiny single-file known edits).
- **When-to-use / when-to-skip guidance**: "When to use this skill" section split into explicit use cases and explicit skip cases. Replaces the previous flat bullet list of task types.
- **Token-aware orientation cache guidance**: new "Token-aware use guidance" section explaining `docs/ai/` as an orientation cache: use when cost amortizes over broad work or sessions; skip for tiny known tasks; do not save tokens by guessing instead.
- **Optional AGENTS.md / CLAUDE.md snippet**: README now includes recommended project-instruction snippet for both Codex (`AGENTS.md`) and Claude Code (`CLAUDE.md`). Marked optional; does not guarantee invocation; triggers when useful, suppresses when not needed.
- **Bootstrap embedded template synced**: when-to-use/skip and token-aware guidance added to `skills/install-codebase-orient/SKILL.md` embedded downstream template. Also added "audit only" / "no writes" to dry-run triggers.
- No installer behavior changes.

Live-fire findings from no-wrapper `/codebase-orient` test applied.

- **Normal/dry-run mode surfaced earlier**: moved to immediately after Hard rules, before discovery and output rules, so it is visible without scrolling through the full skill. Added "audit only" and "no writes" as recognized dry-run triggers.
- **Cross-file consistency rule**: new rule requiring `CODEBASE_MAP.md`, `CHANGE_SURFACES.md`, and `OPEN_QUESTIONS.md` to remain coherent with each other. Covers resolved questions, new surfaces, new uncertainty, and direct contradictions. Applied to both canonical skill and bootstrap embedded template.
- **SvelteKit route probing expanded**: server-side route files (`+page.server.ts`, `+layout.server.ts`, `+server.ts`) now listed explicitly alongside `+page.svelte` and `+layout.svelte` in the canonical skill and bootstrap discovery section. Note added that server-side files are critical for auth, data loading, form actions, and API endpoints.
- **Formatter fallback guidance**: formatter guidance now explicitly handles the case where a formatter is missing, unavailable, or not configured for Markdown. Skip with a note; do not treat missing formatter support as an orientation failure.
- **Read-depth clarification**: new "Path existence vs content read" subsection clarifies when path existence alone is sufficient (low-risk inventory claims) versus when actual file content must be read (claims affecting behavior, architecture, risk, auth, routing, or change surfaces). Applied to both canonical skill and bootstrap embedded template.
- **Project-local specialization path made explicit**: target path `.claude/skills/codebase-orient/SKILL.md` now stated explicitly. Added note that this applies only when a repo-local Claude Code skill exists or is being generated, and that Codex installs are handled separately. Applied to both canonical skill and bootstrap embedded template.
- **Bootstrap embedded template synced**: all six findings reflected in `skills/install-codebase-orient/SKILL.md`.

## 0.1.3

- Added `scripts/install-bootstrap-user.ps1` and `scripts/install-bootstrap-user.sh`: user-level Claude Code install scripts for the `install-codebase-orient` bootstrap skill.
- Updated README with bootstrap skill install instructions (user-level, Claude Code only).
- No project-local bootstrap install scripts added; no Codex bootstrap install support added.

## 0.1.2

- Added `skills/install-codebase-orient/SKILL.md`: tracked source for the Claude Code bootstrap skill. Bootstrap skill source is now versioned here but is not yet part of the automated install flow.
- Updated README with "Skills in this repo" section listing both skill sources and their tool targets.

## 0.1.1

- Added Codex install support: `scripts/install-codex-user.ps1`, `install-codex-project.ps1`, `install-codex-user.sh`, `install-codex-project.sh`.
- Single shared skill source `skills/codebase-orient/SKILL.md` unchanged - install scripts copy it to the appropriate target path for each tool.
- All install scripts now copy skill contents recursively, preserving optional subdirectories (future `scripts/`, `references/`, `assets/` etc).
- README now positions the project as an Agent Skill for both Claude Code and Codex.
- README now documents install paths: Claude Code uses `.claude/skills/`, Codex uses `.agents/skills/`.
- README now explains invocation reliability: auto-invocation is model-driven and not guaranteed; explicit invocation is preferred.
- README now documents `AGENTS.md` as the Codex persistent instruction layer equivalent to `CLAUDE.md`.
- README now includes `.gitignore` guidance for Codex project-local installs.
- README now includes Codex uninstall instructions.

## 0.1.0

- Initial private release.
- Added `codebase-orient` Claude Code skill.
