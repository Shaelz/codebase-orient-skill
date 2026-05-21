# Changelog

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
