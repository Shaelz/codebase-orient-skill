# Contributing

Thanks for helping improve `codebase-orient-skill`.

Useful contributions here include:
- install and onboarding documentation fixes
- Claude Code or Codex compatibility findings
- reproducible workflow bugs
- tightly scoped improvements to the orientation workflow or distribution surface

## Security

Do not report security vulnerabilities in public Issues.

Please follow [SECURITY.md](/Shaelz/codebase-orient-skill/blob/main/SECURITY.md) and use GitHub private vulnerability reporting when possible.

## Useful bug reports

Please include:
- tool used: Claude Code or Codex
- operating system and shell
- installation route used
- repo tag or version tested
- exact reproduction steps
- expected result
- actual result
- sanitized logs or output

## Pull requests

Please keep pull requests small and focused.

- Preserve documented behavior unless you are intentionally changing it.
- Update docs when the public contract changes.
- Run the relevant validation for the surface you changed.

## Verification expectations

- Run `git diff --check`.
- Run the ASCII punctuation checks when tracked Markdown or script text changes.
- Run installer smoke tests when installer behavior changes.
- Do not claim Claude Code and Codex have identical lifecycle behavior.
