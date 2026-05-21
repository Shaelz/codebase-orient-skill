# v1.0 Release Plan - codebase-orient-skill

Current release: v0.3.2 | Target: v1.0.0 | Updated: 2026-05-22

---

## A. Current status

### Release and tag state

| Tag | Commit | Summary |
|-----|--------|---------|
| v0.3.2 | d124cac | ASCII punctuation normalization + check scripts |
| v0.3.1 | 6827554 | Install contract cleanup, artifact policy, Codex parity docs |
| v0.3.0 | 0be3ede | Orientation surface mapping, authority-boundary cleanup |
| v0.2.0 | - | Dual-runtime skill, bootstrap, no-date-only-churn, invocation reliability |
| v0.1.x | - | Initial skill, Codex install scripts, bootstrap skill source |

Branch `main` is clean and up to date with origin.

### What the repo currently supports

- `codebase-orient` skill: user-level and project-local install for Claude Code and Codex (4 install scripts each in PS1 + sh)
- `install-codebase-orient` bootstrap skill: user-level Claude Code only (2 install scripts: PS1 + sh)
- Orientation output: `docs/ai/CODEBASE_MAP.md`, `CHANGE_SURFACES.md`, `OPEN_QUESTIONS.md`
- Dry-run / report-only mode
- Confidence labels and claim-origin labels
- No-date-only-churn rule
- Cross-file consistency rule
- Hidden-risk reporting
- Source-of-truth drift detection
- CI/deployment precision rule
- CHANGE_SURFACES mapping guidance (auth/operator UX, deployment-sensitive, docs-impact)
- Agent handoff summary block
- Instruction-layer topology mapping
- Project-local specialization (Claude Code only)
- Cheap artifact glob rule, open-question quality rule, orientation completion rule
- ASCII-only punctuation enforcement (check scripts in PS1 and sh)

### What has been tested

**Claude Code live-fire (no-wrapper `/codebase-orient`):**
- Normal mode orientation pass
- Dry-run mode
- No-date-only-churn behavior (verified current without rewriting)
- Project-local specialization path (`.claude/skills/codebase-orient/SKILL.md`)

**Codex testing:**
- Codex skeptical audit completed (drove v0.3.1 contract cleanup)
- Install path contract verified
- Lifecycle differences (no bootstrap, no project-local specialization) documented

**Install scripts:**
- PowerShell user-level install tested (install-user.ps1, install-bootstrap-user.ps1)
- Force/overwrite behavior verified
- Recursive copy verified (copies all files, preserves subdirectory structure)

### What is intentionally not supported

- Automatic guaranteed invocation (model-driven; explicit is the reliable path)
- Codex bootstrap installer
- Codex project-local specialization
- Hooks or CI integration
- Marketplace/plugin packaging
- Exact-sync reinstall (overlay semantics only; delete-first workaround documented)
- Source-code edits, refactors, or commits during orientation

---

## B. v1.0 definition

> "Safe to recommend to another serious developer without the maintainer babysitting install, invocation, or interpretation."

Concretely, v1.0 means:

1. A developer who has never used the skill can install it from a fresh clone, invoke it, and get a useful orientation pass - without reading this source repo's internals.
2. The README is complete enough that install failures can be self-diagnosed.
3. The skill description is honest about what works automatically vs what requires explicit invocation.
4. The known limitations are documented clearly enough that a user can decide whether this tool is right for their use case.
5. The canonical skill and bootstrap embedded template stay in sync - no silent drift between them.
6. The maintainer is not embarrassed by any file the user reads during normal use.

---

## C. Architecture and topology

### Intended topology

```
codebase-orient-skill (source repo)
  |
  |-- skills/codebase-orient/SKILL.md           <- canonical source, single source of truth
  |-- skills/install-codebase-orient/SKILL.md   <- bootstrap skill source, versioned here
  |
  |-- scripts/install-user.{ps1,sh}             -> ~/.claude/skills/codebase-orient/
  |-- scripts/install-project.{ps1,sh}          -> <repo>/.claude/skills/codebase-orient/
  |-- scripts/install-codex-user.{ps1,sh}       -> ~/.agents/skills/codebase-orient/
  |-- scripts/install-codex-project.{ps1,sh}    -> <repo>/.agents/skills/codebase-orient/
  |-- scripts/install-bootstrap-user.{ps1,sh}   -> ~/.claude/skills/install-codebase-orient/
```

**Installed target (user repo after running `/install-codebase-orient`):**

```
<target repo>
  |-- .claude/skills/codebase-orient/SKILL.md   <- repo-local skill (thin overlay; project-specific paths added here)
  |-- docs/ai/CODEBASE_MAP.md                   <- generated orientation cache (non-canonical)
  |-- docs/ai/CHANGE_SURFACES.md                <- generated orientation cache (non-canonical)
  |-- docs/ai/OPEN_QUESTIONS.md                 <- generated orientation cache (non-canonical)
```

### Layer authority

| Layer | Authoritative for | Tracked by git |
|-------|-----------------|----------------|
| Source code and project config | Behavior and business logic | Yes |
| `SKILL.md` (canonical, this repo) | Skill behavior and rules | Yes |
| `SKILL.md` (repo-local, installed) | Project-specific discovery paths only | Optional (recommended yes) |
| `docs/ai/` files | Orientation cache for current session/agent | Optional (usually yes, but non-canonical) |
| `CLAUDE.md` / `AGENTS.md` | Project instruction layer | Yes |

**Rules:**
- Source code and project config are always authoritative over `docs/ai/`.
- Installed `SKILL.md` copies are targets, not forks. The canonical source is `skills/codebase-orient/SKILL.md` in this repo.
- `docs/ai/` files are orientation aids. They must be verified against source before acting on them.
- Project-specific paths belong in the repo-local skill overlay. They do not belong in the canonical skill.

### What is intentionally avoided

- Large embedded state bundles in skills
- Generated `docs/ai/` files becoming canonical or ground truth
- Hidden project-specific state inside the repo-local skill overlay
- Sync machinery before it has been earned by real cross-project use
- Hooks or automation as defaults
- Drift between canonical skill and bootstrap embedded template becoming the normal state

---

## D. v1.0 release criteria

Each criterion must be verifiable before tagging v1.0.

### README clarity

- [ ] Install instructions are complete for all 5 scenarios: Claude Code user, Claude Code project, Codex user, Codex project, bootstrap user
- [ ] Overlay vs exact-sync semantics are documented and accurate
- [ ] CWD requirement for project-local installs is documented
- [ ] Codex lifecycle note is accurate (no bootstrap, no project-local specialization)
- [ ] Auto-invocation reliability is stated honestly (model-driven, not guaranteed; explicit is the reliable path)
- [ ] Known limitations section is present and accurate
- [ ] Security review note is present and accurate

### Install script safety

- [ ] All 10 install scripts refuse to overwrite without `-Force` / `--force`
- [ ] All scripts use recursive copy and preserve subdirectory structure
- [ ] All scripts use ASCII-only output (no mojibake risk)
- [ ] No script writes to a path outside its documented target
- [ ] Manual copy examples in README match script semantics exactly

### Claude Code install support

- [ ] User-level install works from fresh clone on Windows (PowerShell) and macOS/Linux (bash)
- [ ] Project-local install works from the target repo root
- [ ] Installed skill is usable via `/codebase-orient` without editing
- [ ] `/codebase-orient` produces useful output on at least 3 different repo types

### Codex install support

- [ ] User-level install works on at least one test Codex session
- [ ] Project-local install works in a target repo
- [ ] Skill can be invoked explicitly and produces useful output
- [ ] README Codex section is accurate for current Codex behavior

### Bootstrap skill clarity

- [ ] Bootstrap skill description clearly distinguishes it from the plain `codebase-orient` skill
- [ ] Bootstrap skill produces `.claude/skills/codebase-orient/SKILL.md` and `docs/ai/` files
- [ ] Bootstrap skill embedded template is consistent with the canonical skill rules (no silent drift)
- [ ] Bootstrap skill is Claude Code only - this is documented

### Project-local artifact policy

- [ ] `.agents/` is in `.gitignore` (no Codex install artifacts tracked in source repo)
- [ ] `docs/ai/` is in `.gitignore` (no generated cache tracked in source repo)
- [ ] README documents recommended `.gitignore` snippets for target repos

### Generated docs lifecycle

- [ ] No-date-only-churn rule is enforced in both canonical and bootstrap skills
- [ ] Cross-file consistency rule is present in both canonical and bootstrap skills
- [ ] Orientation report discipline labels each file as Created/Substantively updated/Verified current/Proposed only/Skipped
- [ ] `docs/ai/` files in target repos are understood as non-canonical orientation cache

### Source-of-truth drift checks

- [ ] Canonical skill and bootstrap embedded template have been compared and confirmed consistent within this release cycle
- [ ] Any divergence between them is intentional and documented

### ASCII punctuation check

- [ ] `scripts/check-ascii-punctuation.ps1` passes with exit 0 on current tracked files
- [ ] `scripts/check-ascii-punctuation.sh` passes with exit 0 on current tracked files
- [ ] Check scripts are documented in README development notes
- [ ] Check has been run and passed before tagging

### Known limitations documented

- [ ] Monorepo orientation limits documented
- [ ] Auto-invocation unreliability documented
- [ ] Overlay (not exact-sync) install semantics documented
- [ ] Codex-only limitations documented (no bootstrap, no project-local specialization)
- [ ] Orientation improves process, not correctness - documented

### Versioning and changelog hygiene

- [ ] CHANGELOG has no Unreleased entries (all work promoted or deferred)
- [ ] All tags point to correct commits
- [ ] Bootstrap skill internal version reflects its actual state (currently 0.2.2, independent of repo tag)
- [ ] Repo tag scheme (vMAJOR.MINOR.PATCH) is documented or implied clearly

### Security and trust posture

- [ ] `SKILL.md` does not tell Claude to run arbitrary shell commands
- [ ] `SKILL.md` does not tell Claude to modify source code during orientation
- [ ] `SKILL.md` does not tell Claude to commit during orientation
- [ ] Security review note in README is accurate
- [ ] No install script requests elevated privileges

---

## E. Test matrix

Run these checks before tagging v1.0. Mark each as pass/fail/skip-with-reason.

### Install tests

| Test | Tool | Platform | Notes |
|------|------|----------|-------|
| User-level install (fresh) | Claude Code | Windows PS | install-user.ps1 |
| User-level install (fresh) | Claude Code | macOS/Linux | install-user.sh |
| User-level install (-Force overwrite) | Claude Code | Windows PS | must succeed |
| User-level install (no -Force, existing) | Claude Code | Windows PS | must refuse |
| Project-local install (fresh) | Claude Code | Windows PS | from target repo root |
| Project-local install (fresh) | Claude Code | macOS/Linux | from target repo root |
| User-level install (fresh) | Codex | Windows PS | install-codex-user.ps1 |
| User-level install (fresh) | Codex | macOS/Linux | install-codex-user.sh |
| Project-local install (fresh) | Codex | Windows PS | from target repo root |
| Project-local install (fresh) | Codex | macOS/Linux | from target repo root |
| Bootstrap user-level install | Claude Code | Windows PS | install-bootstrap-user.ps1 |
| Bootstrap user-level install | Claude Code | macOS/Linux | install-bootstrap-user.sh |

### Post-install correctness

| Check | Pass condition |
|-------|---------------|
| Installed SKILL.md matches tracked source | diff is clean |
| Recursive copy preserved all files | no files dropped |
| Overlay semantics: extra file in target survives Force | extra file not deleted |
| ASCII punctuation check | exit 0 |
| `git diff --check` | no whitespace errors |

### Fresh-clone simulation

| Check | Pass condition |
|-------|---------------|
| Clone repo to a new directory | clean state |
| Run install script without any prior install | completes, no errors |
| Invoke skill in a target repo | produces useful output |
| No prior session context assumed | result is coherent without history |

---

## F. Live-fire validation matrix

At least one pass per repo type before v1.0. Record repo type, mode, and outcome.

| Repo type | Mode | Target | Key signals |
|-----------|------|--------|-------------|
| SvelteKit / frontend | Normal | Claude Code | Routes, server files, adapter, layout, auth surfaces |
| Laravel / PHP backend | Normal | Claude Code | Controllers, models, migrations, middleware, routes |
| Small / simple repo (< 20 files) | Normal | Claude Code | Does not over-read; output proportionate to size |
| Messy / legacy repo | Dry-run | Claude Code | Unknown labels appear; no false confidence |
| Docs-light repo (no README, sparse) | Normal | Claude Code | Unknown labels; no invented claims |
| Repo with existing AGENTS.md / CLAUDE.md | Normal | Codex | Instruction-layer topology mapped; drift detected if present |
| Repo with existing docs/ai | Normal | Claude Code | Refresh vs rewrite decision is correct; no-date-only-churn holds |
| Repo with deployment-sensitive workflows | Normal | Claude Code | Deployment-sensitive change surfaces flagged in CHANGE_SURFACES.md |

Minimum coverage before v1.0: at least 4 of the 8 rows with a real pass, at least 1 Codex row.

---

## G. v1.0 blockers and pre-v1 tasks

Based on current evidence. Not speculative.

### Hard blockers (must complete before v1.0 tag)

1. **Fresh-clone install validation** - has not been run as a clean simulation. Need at least one clean install from a fresh clone (or a new machine / new directory with no prior state) and a successful orientation invocation. This is the most important gap.

2. **At least one cold-user simulation** - a person or session with no knowledge of this repo's internals installs from README alone and gets a working result. A friend install, a fresh-VM test, or a highly isolated session counts. Even one successful cold pass is sufficient.

3. **Canonical skill vs bootstrap embedded template drift check** - the last confirmed full sync was at v0.3.0. Two subsequent changes (ASCII normalization at v0.3.2, plus earlier surface mapping additions) need a final diff pass to confirm the embedded template in `skills/install-codebase-orient/SKILL.md` still reflects the canonical rules in `skills/codebase-orient/SKILL.md`. Record the outcome.

### Preferred but not hard blockers

4. **One more Codex live-fire test** - specifically testing that the generic skill produces useful output when invoked explicitly in Codex, on a repo the Codex session has not seen before. Codex skeptical audit drove v0.3.1 but was primarily a contract/docs audit, not a live discovery pass.

5. **Overlay install semantics decision** - decide explicitly whether current overlay semantics (no exact-sync, delete-first workaround) are acceptable for v1.0, or whether exact-sync tooling is needed before the v1.0 tag. Current position: overlay is acceptable; document it and call it done. Record this decision.

6. **CHANGELOG promotion** - the Unreleased entry (if any) must be promoted to a version before tagging v1.0.

---

## H. Explicit non-goals before v1.0

These are not being built. If a future conversation proposes one, check here first.

- Marketplace / plugin packaging
- Hooks or automation as defaults (not earned yet)
- Full accessibility audit behavior (surfaced in CHANGE_SURFACES, not executed)
- Full deployment verification behavior (noted, not executed)
- Safe-cleanup or refactor execution during orientation
- Skeptical diff-review skill
- Guaranteed automatic invocation (model-driven; cannot guarantee)
- Codex bootstrap installer (no confirmed real user need yet)
- Exact-sync reinstall script (delete-first workaround is sufficient for v1)
- Per-project versioning of installed skill overlays
- Telemetry or usage tracking

---

## I. Known risks

### Source-of-truth drift: canonical skill vs bootstrap embedded template

`skills/install-codebase-orient/SKILL.md` contains an embedded template that is supposed to stay in sync with the rules in `skills/codebase-orient/SKILL.md`. There is no automated sync check. Manual drift checks have been done at each release. Risk: a rule change in the canonical skill is not reflected in the bootstrap embedded template, and the bootstrap generates stale project-local skills.

Mitigation: drift check is a release criterion (see D and G).

### README / install script mismatch

The README documents install paths and expected behavior. If a script is changed without updating the README, users follow wrong instructions. Risk is low given the small surface area, but it increases with each new install variant.

Mitigation: install script test matrix includes manual copy example verification.

### Over-invocation due to trigger description

The `codebase-orient` frontmatter `description` is rich with trigger phrases. This is intentional for discovery. Risk: Claude invokes orientation on tiny tasks where the user expected a direct answer, burning tokens unnecessarily.

Mitigation: "When to skip" section is explicit. User can also explicitly say "no orientation needed."

### Under-invocation (implicit invocation is model-driven)

Claude may not invoke the skill automatically even when the trigger description matches. This is a platform behavior, not a bug. Risk: users expect automatic orientation and are surprised when it does not happen.

Mitigation: README and SKILL.md both document that explicit invocation is the reliable path.

### Generated docs becoming stale

`docs/ai/` files in a target repo can lag behind the actual codebase. A session that relies on stale `docs/ai/` without refreshing may produce incorrect orientation claims.

Mitigation: staleness rule is in the skill; the orientation report discipline distinguishes verified-current from refreshed.

### Date-only churn returning

A future model might update `Last refreshed:` without substantive content changes, producing noisy git diffs. This was a real problem before v0.2.0.

Mitigation: no-date-only-churn rule is in both the canonical skill and bootstrap embedded template.

### Local overlay artifacts becoming quasi-canonical

A repo-local `.claude/skills/codebase-orient/SKILL.md` that accumulates heavy project-specific content may start to drift from the canonical skill in ways that are hard to untangle later. Users may treat the local overlay as the primary source.

Mitigation: the thin-overlay framing is explicit in the skill. Project-specific paths are meant to go at the bottom, clearly marked. The canonical rules are not meant to be overwritten.

### Scope creep before v1.0

Each live-fire pass discovers something useful but tangential. The risk is that pre-v1 tasks accumulate, the bar keeps moving, and v1.0 is never tagged.

Mitigation: this document defines a fixed bar. If a new finding does not block any criterion in section D, it goes in a future release.

---

## J. Definition of done for v1.0

Final checklist. All items must be checkable pass before tagging v1.0.

- [ ] All D-section release criteria verified (README, install scripts, Claude Code, Codex, bootstrap, artifacts, generated docs, drift, ASCII, limitations, versioning, security)
- [ ] E-section test matrix: all critical install paths checked (at minimum: Claude Code user-level on Windows + macOS, project-local on one platform, Codex user-level on one platform, bootstrap user-level on one platform)
- [ ] F-section live-fire: at least 4 repo types with real passes, at least 1 Codex row
- [ ] G-section hard blockers resolved: fresh-clone install validated, cold-user simulation completed, canonical/bootstrap drift check recorded
- [ ] G-section overlay decision recorded explicitly
- [ ] CHANGELOG has no Unreleased entries
- [ ] `scripts/check-ascii-punctuation.ps1` exits 0 on current tracked files
- [ ] `git diff --check` is clean
- [ ] `git status` is clean with no uncommitted changes
- [ ] Working tree is up to date with origin before tagging

---

## K. Next immediate step

**Run a fresh-clone install validation.** This is the highest-confidence, lowest-cost step that would close the most important hard blocker (G.1).

Suggested session prompt:

> Simulate a fresh-clone install of codebase-orient-skill and validate that the orientation skill works end-to-end.
>
> Steps:
> 1. Clone the repo to a temporary directory (or use a new directory with no prior state).
> 2. Run `scripts/install-user.ps1` (or `install-user.sh`) - do not pass -Force; this should succeed since there is no prior install.
> 3. Open a target repo that has not been oriented before.
> 4. Invoke `/codebase-orient` in Claude Code.
> 5. Verify: orientation output is coherent, `docs/ai/` files are created, confidence labels are used, no false facts appear.
> 6. Check that the installed SKILL.md matches the tracked source (`diff ~/.claude/skills/codebase-orient/SKILL.md skills/codebase-orient/SKILL.md`).
> 7. Record pass/fail for each E-section test row touched.
> 8. If any step fails, record the failure and the root cause.
>
> Hard boundaries: do not change skill behavior; do not change install scripts; do not commit changes to codebase-orient-skill during this test.
