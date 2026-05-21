# Changelog

## 0.3.0 — 2026-05-21

Consolidates post-v0.2.0 work into a tagged release. The orientation behavior additions recorded in the v0.2.1 development entry (instruction-layer topology, CHANGE_SURFACES mapping guidance, agent handoff summary) are included under this tag — v0.2.1 was a named development checkpoint that was never separately tagged.

**Installer output hardening — `scripts/*.sh`, `README.md` (9bc01df):**

- Replace non-ASCII characters (em dashes, curly quotes) in installer script terminal output with ASCII equivalents.
- Reduces mojibake rendering in PowerShell 5.1 / Windows terminals on code page 1252.
- Added ASCII-only output encoding convention to README development notes.
- No install behavior changes.

**Authority-boundary clarification — `skills/codebase-orient/SKILL.md` (a707995):**

- Add thin-overlay framing to project-local specialization rule: project-specific paths are the thin customisable layer; canonical rules are the stable layer across all repos; keep them visually separated.
- Closes source/mirror inconsistency introduced in c75c675.

**Authority-boundary clarification — `skills/install-codebase-orient/SKILL.md` (c75c675):**

- Fix `Last refreshed:` contradiction in idempotency rule: now defers to the no-date-only-churn rule.
- Add generated-cache framing note after creates table: `docs/ai/` files are orientation aids; source code and project config remain authoritative.
- Add thin-overlay framing to project-local specialization rule in embedded template.
- Add SvelteKit subdirectory note and critical server-side route files callout to bootstrap discovery probes, matching canonical skill.
- Add internal changelog entries for v0.2.0 and v0.2.1 syncs (previously unrecorded).
- Bump `install-codebase-orient` frontmatter version to `0.2.2`.

---

## 0.2.1 — 2026-05-21

Weaves orientation-core deep-research findings into the skill without adding new default docs files, hooks, or automation.

**Findings woven in (canonical skill + bootstrap embedded template):**

- **Instruction-layer topology** — discovery step 1 now notes which instruction files are present (`CLAUDE.md`, `AGENTS.md`, `.claude/settings.json`) and at which scope (project-local vs user-level); recorded in `CODEBASE_MAP.md` for agent handoff clarity.
- **CHANGE_SURFACES mapping guidance** — new section explicitly calls out three additional surface categories: auth/admin/operator UX changes (with a11y/WCAG note), deployment-sensitive changes (with smoke-check entry-point note), and docs-impact changes (which docs need updating per subsystem). Hard rule added: no separate smoke-check or handoff files in `docs/ai/`.
- **Agent handoff summary** — orientation report discipline now includes an optional compact handoff block (snapshot, blocking questions, critical surfaces, recommended first action; ≤150 words, no new file).

**Bootstrap sync:** `skills/install-codebase-orient/SKILL.md` updated — CHANGE_SURFACES template section and embedded downstream template both reflect the three new findings.

**Rejected:** hooks, CI automation, release checklist, full a11y audit, separate `AGENT_HANDOFFS.md` / `DEPLOYMENT_SMOKE_CHECKS.md` by default, safe-cleanup behavior, sceptical review behavior — none are orientation-core.

---

## 0.2.0 — 2026-05-21

Dual-runtime orientation skill with bootstrap support. Adds Codex install, recursive skill copy, user-level bootstrap install scripts, live-fire-driven refresh behavior, cross-file consistency rules, no-date-only-churn rule, and trigger-oriented / token-aware invocation guidance.

---

No-date-only-churn fix from second no-wrapper live-fire test:

- **No-date-only-churn rule** — do not rewrite a `docs/ai/` file solely to bump the `Last refreshed` date. A verified-current doc is left unchanged. `Last refreshed` is updated only when content changes for a substantive reason.
- **Orientation report discipline** — final report must label each `docs/ai/` file as: Created / Substantively updated / Verified current (unchanged) / Proposed only / Skipped. Reporting a date-only rewrite as "updated" is not allowed.
- **Bootstrap embedded template synced** — both rules added to `skills/install-codebase-orient/SKILL.md`.
- No installer behavior changes.

Invocation reliability and token-aware use improvements:

- **Trigger-oriented skill description** — `codebase-orient` frontmatter `description` rewritten to be richer in trigger signals: new/unfamiliar repo, new session, before multi-file work, before refactor/planning/handoff, stale `docs/ai/`, unclear structure. Includes explicit trigger phrases (`scan`, `orient`, `survey`, `familiarize`, `before I start`, etc.) and explicit skip signal (tiny single-file known edits).
- **When-to-use / when-to-skip guidance** — "When to use this skill" section split into explicit use cases and explicit skip cases. Replaces the previous flat bullet list of task types.
- **Token-aware orientation cache guidance** — new "Token-aware use guidance" section explaining `docs/ai/` as an orientation cache: use when cost amortizes over broad work or sessions; skip for tiny known tasks; do not save tokens by guessing instead.
- **Optional AGENTS.md / CLAUDE.md snippet** — README now includes recommended project-instruction snippet for both Codex (`AGENTS.md`) and Claude Code (`CLAUDE.md`). Marked optional; does not guarantee invocation; triggers when useful, suppresses when not needed.
- **Bootstrap embedded template synced** — when-to-use/skip and token-aware guidance added to `skills/install-codebase-orient/SKILL.md` embedded downstream template. Also added "audit only" / "no writes" to dry-run triggers.
- No installer behavior changes.

Live-fire findings from no-wrapper `/codebase-orient` test applied.

- **Normal/dry-run mode surfaced earlier** — moved to immediately after Hard rules, before discovery and output rules, so it is visible without scrolling through the full skill. Added "audit only" and "no writes" as recognized dry-run triggers.
- **Cross-file consistency rule** — new rule requiring `CODEBASE_MAP.md`, `CHANGE_SURFACES.md`, and `OPEN_QUESTIONS.md` to remain coherent with each other. Covers resolved questions, new surfaces, new uncertainty, and direct contradictions. Applied to both canonical skill and bootstrap embedded template.
- **SvelteKit route probing expanded** — server-side route files (`+page.server.ts`, `+layout.server.ts`, `+server.ts`) now listed explicitly alongside `+page.svelte` and `+layout.svelte` in the canonical skill and bootstrap discovery section. Note added that server-side files are critical for auth, data loading, form actions, and API endpoints.
- **Formatter fallback guidance** — formatter guidance now explicitly handles the case where a formatter is missing, unavailable, or not configured for Markdown. Skip with a note; do not treat missing formatter support as an orientation failure.
- **Read-depth clarification** — new "Path existence vs content read" subsection clarifies when path existence alone is sufficient (low-risk inventory claims) versus when actual file content must be read (claims affecting behavior, architecture, risk, auth, routing, or change surfaces). Applied to both canonical skill and bootstrap embedded template.
- **Project-local specialization path made explicit** — target path `.claude/skills/codebase-orient/SKILL.md` now stated explicitly. Added note that this applies only when a repo-local Claude Code skill exists or is being generated, and that Codex installs are handled separately. Applied to both canonical skill and bootstrap embedded template.
- **Bootstrap embedded template synced** — all six findings reflected in `skills/install-codebase-orient/SKILL.md`.

## 0.1.3

- Added `scripts/install-bootstrap-user.ps1` and `scripts/install-bootstrap-user.sh` — user-level Claude Code install scripts for the `install-codebase-orient` bootstrap skill.
- Updated README with bootstrap skill install instructions (user-level, Claude Code only).
- No project-local bootstrap install scripts added; no Codex bootstrap install support added.

## 0.1.2

- Added `skills/install-codebase-orient/SKILL.md` — tracked source for the Claude Code bootstrap skill. Bootstrap skill source is now versioned here but is not yet part of the automated install flow.
- Updated README with "Skills in this repo" section listing both skill sources and their tool targets.

## 0.1.1

- Added Codex install support: `scripts/install-codex-user.ps1`, `install-codex-project.ps1`, `install-codex-user.sh`, `install-codex-project.sh`.
- Single shared skill source `skills/codebase-orient/SKILL.md` unchanged — install scripts copy it to the appropriate target path for each tool.
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
