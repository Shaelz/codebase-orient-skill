# Changelog

## Unreleased

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
