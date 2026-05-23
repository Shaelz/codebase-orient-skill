# v1.0 Release Plan - codebase-orient-skill

Current release candidate: v1.0.0-rc.6 (active candidate for independent human-through-agent validation rerun) | Final target: v1.0.0 | Updated: 2026-05-23
Last validation: 2026-05-23 (`rc.6` is the active candidate for rerunning independent human-through-agent validation; `rc.5` is the prior public agent-delegated onboarding candidate and failed the external validation gate on exact-install integrity; `rc.4` remains the prior published sanitized candidate; the governance hardening pass is complete)

---

## A. Current status

### Release and tag state

| Tag | Summary |
|-----|---------|
| v1.0.0-rc.6 | Active candidate for independent human-through-agent validation rerun. Adds an exact-source installation integrity rule for agent-delegated onboarding and records the failed `rc.5` external gate safely. |
| v1.0.0-rc.5 | Prior public agent-delegated onboarding candidate. Failed the external validation gate on exact-install integrity before any installed skill file was written. |
| v1.0.0-rc.4 | Published sanitized candidate. Records the pre-public sanitation decision and the corrected manual-install contract that preceded the delegated-install onboarding correction. |
| v1.0.0-rc.3 | Historical pre-public contract-correction candidate. In retained sanitized history, this tag no longer carries the removed disclosures, but it is not the candidate to use for external cold-user validation. |
| v1.0.0-rc.2 | Historical pre-public candidate: README onboarding rewrite + fixed project-local installer `.gitignore` guidance. |
| v1.0.0-rc.1 | Historical pre-public cold-user candidate; README polished; 6/8 live-fire rows satisfied. |
| v0.3.2 | ASCII punctuation normalization + check scripts. |
| v0.3.1 | Install contract cleanup, artifact policy, Codex parity docs. |
| v0.3.0 | Orientation surface mapping and authority-boundary cleanup. |
| v0.2.0 | Dual-runtime skill, bootstrap, no-date-only-churn, invocation reliability. |
| v0.1.x | Initial skill, Codex install scripts, bootstrap skill source. |

`v1.0.0-rc.1` and `v1.0.0-rc.2` remain historical pre-public candidates. `rc.2` introduced the README onboarding rewrite and project-local installer `.gitignore` correction but carried incomplete README mutation-scope and trust-posture wording. `rc.3` corrected those statements but was then blocked by the pre-public exposure audit because tracked docs and reachable pre-public history still contained private validation identifiers and maintainer-local paths. `rc.4` is the prior published sanitized candidate, and a supplementary Codex delegated-install exploration against public `rc.4` showed that agent-facing onboarding needed one more focused correction before the independent gate could be rerun. `rc.5` then became the first public agent-delegated onboarding candidate, but the independent external validation attempt failed on exact-install integrity. `rc.6` is the active candidate for rerunning that external validation. Do not use `rc.1`, `rc.2`, or `rc.3` for external validation, do not treat the `rc.4` exploratory agent run as the independent gate pass, and do not treat the interrupted `rc.5` run as passing evidence.

### Publication and governance state

- Public repository publication and the pre-v1 sanitation pass are complete; `v1.0.0-rc.6` is the active candidate for independent human-through-agent validation rerun.
- Repository governance hardening is complete: protected main history, protected version tags, secret scanning alerts, push protection, private vulnerability reporting, and immutable future releases are already enabled.
- A concise public `SECURITY.md` is now part of the candidate docs so the in-repo security-reporting path matches the GitHub repository configuration.

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

**Install scripts - Windows PowerShell (v0.3.2, 2026-05-22):**
- All 5 install scripts tested: user/project-local for Claude Code and Codex, plus bootstrap user-level
- Installed SKILL.md matched tracked source by SHA-256 for all 5 cases
- Non-force refusal (exit 1 + message) verified for all 5 cases
- Force overwrite verified for all 5 cases
- Overlay semantics verified: injected extra file survived --force for all 5 cases
- Terminal output: no mojibake; ASCII-only rendered correctly
- README cold-reader pass: no release blocker found for Windows consumers
- ASCII punctuation check (PS1 script): exit 0, all tracked files clean
- Disposable clone remained clean after all tests

**Install scripts - Git Bash / MSYS2 (v0.3.2, 2026-05-22):**
- All 5 install scripts tested: same matrix as PowerShell above
- 18/18 checks PASS: hash match, non-force refusal, --force overlay, extra-file survival
- ASCII punctuation check (sh script): exit 0, all tracked files clean
- Disposable clone remained clean after all tests
- Note: recursive copy is implementation-inspected (cp -rf); no nested fixture file was added to prove the recursive path by test - this remains an open gap

**Fresh-clone simulation:**
- A disposable tagged clone was used for both PS and bash runs
- Clone was at the tagged `v0.3.2` baseline before and after
- All temp install targets used fake HOME or temp dirs; real user-level skills were not touched

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
- [ ] `SECURITY.md` is present and points reporters to GitHub private vulnerability reporting with email fallback
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

## E1. Completed install validation runs

Records of actual validation passes. Each row is a real test, not a plan item.

### v0.3.2 - 2026-05-22 - Windows PowerShell

- **Clone:** disposable tagged clone
- **Commit basis:** tagged `v0.3.2` baseline
- **Environment:** Windows, PowerShell 5.1
- **Targets:** all temp dirs under `%TEMP%`; real user skills not touched

| Case | Script | Result | Evidence |
|------|--------|--------|---------|
| Claude Code user-level | install-user.ps1 | PASS | SHA-256 match, refusal, --force overlay, extra-file survived |
| Claude Code project-local | install-project.ps1 | PASS | SHA-256 match, refusal, --force overlay, extra-file survived |
| Codex user-level | install-codex-user.ps1 | PASS | SHA-256 match, refusal, --force overlay, extra-file survived |
| Codex project-local | install-codex-project.ps1 | PASS | SHA-256 match, refusal, --force overlay, extra-file survived |
| Bootstrap user-level | install-bootstrap-user.ps1 | PASS | SHA-256 match, refusal, --force overlay, extra-file survived |
| ASCII punctuation check | check-ascii-punctuation.ps1 | PASS | exit 0, all tracked files clean |
| Terminal output | all scripts | PASS | no mojibake; ASCII rendered correctly |
| README cold-reader | README.md | PASS | no release blocker found for Windows consumers |
| Disposable clone state | git status | PASS | clean before and after all tests |

### v0.3.2 - 2026-05-22 - Git Bash (MSYS2 bash 5.2, Windows)

- **Clone:** disposable tagged clone
- **Commit basis:** tagged `v0.3.2` baseline
- **Environment:** Git Bash / MSYS2 bash 5.2.37, Windows
- **Targets:** mktemp -d (fake HOME, project-local temp dirs); real user skills not touched

| Case | Script | Result | Evidence |
|------|--------|--------|---------|
| Claude Code user-level | install-user.sh | PASS | SHA-256 match (A1), refusal (A2), overlay (A3), force re-hash (A4) |
| Claude Code project-local | install-project.sh | PASS | SHA-256 match (B1), refusal (B2), overlay (B3) |
| Codex user-level | install-codex-user.sh | PASS | SHA-256 match (C1), refusal (C2), overlay (C3) |
| Codex project-local | install-codex-project.sh | PASS | SHA-256 match (D1), refusal (D2), overlay (D3) |
| Bootstrap user-level | install-bootstrap-user.sh | PASS | SHA-256 match (E1), refusal (E2), overlay (E3) |
| ASCII punctuation check | check-ascii-punctuation.sh | PASS | exit 0, all tracked files clean (F1) |
| Disposable clone state | git status | PASS | clean before and after all tests (G1) |
| Total | 18 checks | 18/18 PASS | 0 failures |

**Open gap from bash run:** recursive copy is implementation-inspected only (`cp -rf`). No nested fixture file was added to prove the recursive path by test. This remains pending.

### v0.3.2 - 2026-05-22 - Canonical/bootstrap drift check

- **Files compared:** `skills/codebase-orient/SKILL.md` vs embedded template in `skills/install-codebase-orient/SKILL.md`
- **Last confirmed sync before this check:** v0.3.0 (two releases prior)
- **Result:** No material unintentional drift. All major behavioral rules represented accurately. See G.3 for full detail.
- **Action taken:** None. No edits to either SKILL.md.

### Not yet covered

- macOS/Linux native bash (MSYS2 on Windows confirmed; native macOS/Linux not tested)
- Runtime orientation behavior (outside this install-matrix pass)
- Codex live-fire discovery pass (install validated; invocation not tested this pass)
- Independent cold-user install (README cold-reader pass done by maintainer; independent user not yet tested)

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

## F1. Completed live-fire passes

Records of actual live-fire orientation passes against real repos with real findings.

### Claude Code - External SvelteKit frontend repo A

- **Repo type:** SvelteKit / frontend / product-flow repo
- **Agent/runtime:** Claude Code
- **Invocation:** `/codebase-orient` without a wrapper prompt
- **docs/ai existed:** Yes - recently refreshed before this pass
- **Mode:** Normal

**Findings:**

- Skill recognized recently refreshed `docs/ai/` and performed lightweight verification rather than a full rewrite. No-date-only-churn behavior confirmed in practice.
- Found a real cross-file consistency issue: `CODEBASE_MAP.md` still listed uncertainty items already resolved in `OPEN_QUESTIONS.md`.
- Updated project-local `.claude/skills/codebase-orient/SKILL.md` with substantive specialization improvements after the orientation pass.
- A later rerun validated the no-date-only-churn fix: date-only changes to `CHANGE_SURFACES.md` and `OPEN_QUESTIONS.md` were reverted; only substantive changes were committed in that repo.

**Matrix rows covered:** Row 1 (SvelteKit/frontend/Claude Code), Row 7 (existing docs/ai - refresh vs rewrite correct, no-date-only-churn holds)

**Evidence confidence:** High. Real repo, real cross-file consistency issue found, substantive changes committed.

---

### Claude Code - External Laravel backend repo A

- **Repo type:** Laravel / backend / admin / deployment-sensitive repo
- **Agent/runtime:** Claude Code
- **Invocation:** `/codebase-orient`
- **docs/ai existed:** Yes - validated rather than rewritten broadly
- **Mode:** Normal

**Findings:**

- Stale claim corrected: migration count 35 -> 32 (verified against source)
- Stale claim corrected: feature test count 40+ -> 38 (verified against source)
- Stale deploy-risk claim corrected: `storage:link` was listed as absent but had been added to `deploy.yml`; corresponding stale reference in `CHANGE_SURFACES.md` also corrected
- `OPEN_QUESTIONS.md` verified current / unchanged; no-date-only-churn held
- All corrections were committed in the target repo

**Matrix rows covered:** Row 2 (Laravel/PHP backend/Claude Code), Row 8 (deployment-sensitive workflows - deployment surfaces flagged correctly)

**Evidence confidence:** High. Real stale claims found against real source code, corrections committed.

---

### Codex - codebase-orient-skill (self-orientation, supporting evidence only)

- **Repo type:** Skill-source repo (self-referential)
- **Agent/runtime:** Codex
- **Invocation:** Explicit natural-language invocation
- **docs/ai existed:** No - created during this pass
- **Mode:** Normal

**Observations:**

- Project-local `.agents/skills/codebase-orient/SKILL.md` install confirmed by hash match before the session.
- Codex created the expected `docs/ai/` cache files and displayed skill behavior consistent with the skill definition.
- Driven by real content inspection of this source repo (scripts, SKILL.md files, changelogs).

**Limitations:**

- Self-referential repo: the skill was orienting to a repo that describes itself.
- Discovery confound: the skill body appeared later in the session thread, which may have supplemented project-local install pickup.
- Not equivalent to orienting to an unfamiliar external codebase.

**Classification:** Supporting / limited evidence. This does NOT count as a clean external-repo Codex pass. It establishes that Codex project-local skill installation works and that Codex exhibits skill behavior. It does not satisfy any F matrix row.

**Matrix rows covered:** None counted. Supporting evidence for Codex install-to-behavior chain only.

---

### Codex - External Laravel backend repo A (deployment-sensitive, external repo)

- **Repo type:** Laravel / backend / admin / deployment-sensitive repo (same repo, different agent)
- **Agent/runtime:** Codex
- **Invocation:** Explicit natural-language invocation
- **Skill path:** Project-local `.agents/skills/codebase-orient/SKILL.md`
- **docs/ai existed:** Yes - Claude Code orientation cache from a prior Claude Code correction pass
- **Mode:** Normal

**Observed evidence:**

- Codex session registry exposed `codebase-orient` at the project-local path.
- The installed skill file was opened and followed explicitly.
- Target repo confirmed as the external Laravel backend repo (not the skill-source repo).
- Codex verified the existing `docs/ai/` cache against source/config/canonical docs:
  - `deploy.yml` includes `php artisan storage:link` after `migrate --force` - confirmed correct
  - Migration count 32 - confirmed correct
  - Feature test count 38 - confirmed correct
  - Public routes match `routes/web.php` - confirmed
  - Filament/admin/operator surfaces match current source/docs - confirmed
  - Instruction-layer topology claims are grounded - confirmed
  - CI/deploy summary matches `.github/workflows/deploy.yml` - confirmed
  - `OPEN_QUESTIONS.md` remains a correct uncertainty log - confirmed
- Codex found no substantive correction needed. No changes made to `docs/ai/`.
- No date-only churn. No application code modified.
- Final target working tree contained only the untracked `.agents/` install artifact.

**Cross-agent validation significance:** This pass demonstrates the intended cross-agent lifecycle: Claude Code oriented and corrected, Codex independently verified. The Codex session confirmed the Claude-maintained cache was accurate and held the no-date-only-churn rule (no rewrite triggered despite a full verification pass).

**Evidence note:** Codex skill pickup relied on project-local install; a distinct UI skill-attachment click event was not independently observable from the terminal/session report. Behavioral evidence (skill followed, real verification performed against real source) is sufficient to classify this as a PASS. The acceptance bar is behavioral, not UI-event-level.

**Matrix rows covered:** Row 6 (AGENTS.md/CLAUDE.md/Codex - instruction-layer topology mapped, Codex explicit invocation confirmed)

**Evidence confidence:** High, with the noted UI-attachment observability caveat.

---

### Claude Code -> Codex - External SvelteKit portfolio repo B

- **Repo type:** SvelteKit / static portfolio / deployment workflow repo
- **Agent/runtime sequence:** Claude Code (orientation and cache creation/refresh) then Codex (verification and substantive update)
- **docs/ai existed at Codex pass:** Yes - created and refreshed by Claude Code in prior passes
- **Mode:** Normal (both passes)

**Claude Code phase:**

- Initial Claude Code dry-run found real instruction drift in `README.md` and proposed the orientation layer.
- Claude Code created and refreshed the orientation cache in two prior committed passes.

**Codex phase:**

- Codex ran using the project-local installed skill in the external portfolio repo.
- Codex consumed the pre-existing Claude-created `docs/ai/` cache and verified it against source/config.
- Codex found new substantive documentation drift not corrected in the Claude Code passes:
  - `README.md` still described the site as single-page despite three prerendered routes.
  - `README.md` described deploy as a symlink swap while the actual workflow uses release-directory upload plus rsync publish into `PUBLIC_PATH`.
- Codex substantively refreshed the orientation cache: instruction-layer mapping, docs-impact guidance, deploy smoke-check guidance, and corrected README-drift status.
- No application/source/config/deploy-behavior files changed.
- No date-only churn. No spurious rewrites.

**Durable target-repo commit:** Documentation-only evidence commit pushed to the target repo (`CLAUDE.md`, `README.md`, and `docs/ai/*` only)

**Final state:** Temporary `.agents/` Codex install artifact removed after evidence commit was pushed. Working tree clean and aligned with origin.

**Cross-version wording:** Omitted. Insufficient timeline evidence to determine which version of the skill each agent used; lifecycle wording only.

**Classification:** PASS - corroborating second external cross-agent orientation-cache lifecycle validation. This strengthens the lifecycle evidence base across a second repo family (SvelteKit portfolio vs Laravel backend). The external Laravel backend repo A already closed the required Codex live-fire blocker (G.4); this pass does not close a new required matrix row.

**Matrix rows covered:** None additional. Row 1 (SvelteKit/Claude Code) and Row 6 (Codex) are already satisfied by prior passes. Recorded as supplementary run evidence only.

**Evidence confidence:** High. Substantive drift found by Codex against real source, corrected, and pushed to the target repo.

---

### Codex (user-level skill) - Legacy PHP CMS snapshot (no Git, dry-run)

- **Repo type:** Unseen legacy PHP flat-file CMS snapshot (`GetSimple CE 3.3.22`); mixed runtime/live-like artifacts; no `.git`; no `docs/ai/`
- **Agent/runtime:** Codex using the user-level installed skill
- **docs/ai existed:** No; none created (dry-run mode, no target files modified)
- **Mode:** Dry-run only

**Blind discovery (no advance description of target contents given):**

- Codex classified the folder as a legacy PHP flat-file CMS snapshot, likely a mixed live/deployed working snapshot rather than the canonical source repo.
- Runtime/framework identified: GetSimple CE 3.3.22.
- Meaningful surfaces discovered from source:
  - Root `index.php` bootstrap/render flow
  - `data/pages/*.xml` content source
  - Admin page-save/sitemap workflow
  - Active theme `theme/Seascape2-main`
  - File-backed visitor counter
  - Custom admin/operator pages
  - Enabled plugin policy and plugin layer
  - Competition results/team roster JSON workflows
  - `.htaccess`, writable content/auth, backups/uploads/plugin internals flagged as security/deploy-sensitive surfaces

**Substantive finding:**

- `LOCAL_MAINTENANCE.md` states that checked-in `PRETTYURLS` is off.
- `data/other/website.xml` has `<PRETTYURLS>1</PRETTYURLS>`.
- Runtime code honors the XML value; sitemap output uses pretty URLs.
- Real maintenance-doc vs config contradiction found and documented.

**Safety-boundary behavior:**

- Codex correctly recommended keeping this target dry-run only: live-like data, runtime artifacts, uploads, logs, backups, no Git history, possible snapshot/deployed-mirror status.
- Codex recommended locating the canonical maintained source repo before creating `docs/ai/*`.
- A possible canonical maintained source location was suggested by the snapshot context, but it was not confirmed during this dry-run. Finding that source remains optional project follow-up, not a `codebase-orient-skill` v1 requirement.

**Final files modified:** None.

**Classification:** PASS - blind dry-run generalization in an unseen no-Git legacy snapshot. Satisfies Row 4 (messy/legacy / dry-run). Note: original matrix plan listed Claude Code as the target agent; Codex was used. Behavioral requirements (unknown labels surfaced, no false confidence, no spurious writes, correct safety-boundary recommendation) were met regardless of which agent executed the run.

**Evidence confidence:** High for blind dry-run generalization and safety-boundary behavior. The "unseen" precondition was structurally enforced: no advance description, no Git, no docs/ai, no project-local skill install.

---

### Live-fire coverage summary

| Matrix row | Status | Evidence source |
|------------|--------|-----------------|
| Row 1: SvelteKit/frontend / Claude Code | PASS | External SvelteKit frontend repo A |
| Row 2: Laravel/PHP backend / Claude Code | PASS | External Laravel backend repo A |
| Row 3: Small/simple repo / Claude Code | NOT YET | - |
| Row 4: Messy/legacy / dry-run / Claude Code | PASS (Codex dry-run) | Legacy PHP CMS snapshot (no Git) |
| Row 5: Docs-light repo / Claude Code | NOT YET | - |
| Row 6: AGENTS.md/CLAUDE.md / Codex | PASS | External Laravel backend repo A (Codex, 2026-05-22) |
| Row 7: Existing docs/ai / Claude Code | PASS | External SvelteKit frontend repo A |
| Row 8: Deployment-sensitive / Claude Code | PASS | External Laravel backend repo A |

**Matrix rows satisfied: 6 / 8.** Minimum count requirement (4) met. Codex row requirement met.
**External live-fire runs recorded: 5.** Claude Code in one external SvelteKit/frontend repo; Claude Code in one external Laravel/backend/deployment-sensitive repo; Codex in that same external Laravel repo; Claude Code -> Codex sequence in one external SvelteKit/static-portfolio/deployment-workflow repo; Codex dry-run in one no-Git legacy PHP CMS snapshot.

**Minimum remaining before v1.0:** Cold-user simulation (G.2 hard blocker). All live-fire matrix requirements satisfied.

### Supplementary onboarding evidence - public `rc.4` Codex delegated-install exploration

- Classification: supplementary evidence only. This was not an independent external-user pass and does not close G.2.
- What it showed:
  - A coding agent acting on behalf of a user selected the recommended Codex user-level installation route from the README.
  - Existing-install refusal and later overlay refresh behavior worked as documented.
  - The agent then blurred together installation, installed-skill discovery/invocation, and immediately running the workflow until explicit invocation was surfaced more clearly.
  - After explicit invocation was surfaced, the resulting orientation behavior was useful and matched expectations.
- Product implication: the public onboarding contract needed to treat agent-delegated installation as a first-class path, make overwrite decisions explicit for the agent, and separate installation from invocation more clearly before rerunning the external validation gate.

### External validation evidence - public `rc.5` human-through-agent attempt

- Classification: FAIL / BLOCKER. This was a genuine independent external validation attempt and it did not satisfy G.2.
- What happened:
  - A new Claude Code session received only a minimal natural-language install request plus the public tagged `rc.5` URL.
  - The agent reasonably chose the supported project-local Claude Code route because the request was to install the skill "in this project."
  - The failure was installation integrity, not route selection: the agent then began an invalid approximate manual-install path that would have reconstructed installed `SKILL.md` content from fetched non-authoritative material rather than from an exact local tagged source plus the checked-in installer.
  - The attempt was interrupted before any installed skill file was written. Only empty install directories were created in the target project, and no tracked target-project change was observed.
- Product implication: agent-delegated installation must require exact tagged source acquisition plus the checked-in installer, and must stop and ask rather than approximate installed instruction files from transformed or partial content.

---

## G. v1.0 blockers and pre-v1 tasks

Based on current evidence. Not speculative.

### Hard blockers (must complete before v1.0 tag)

1. ~~**Fresh-clone install validation**~~ - RESOLVED 2026-05-22. Full install matrix tested from disposable tagged clone on Windows PowerShell 5.1 and Windows Git Bash/MSYS2. All 5 install scripts PASS on both tested Windows environments. Native macOS/Linux bash was not part of this validation pass; it remains an open item in the D-section install criterion and E matrix but does not reopen this blocker (the original G.1 requirement was at least one clean install from a fresh clone, not full cross-platform coverage). See E1.

2. **At least one independent human-through-agent validation pass** - an external person receives only the public repo or tag link plus a minimal instruction to have their coding agent install the skill by following the README. The earlier maintainer README cold-reader pass and the supplementary `rc.4` Codex delegated-install exploration do not satisfy this gate. The public `rc.5` attempt was a genuine external run, but it failed on exact-install integrity and therefore did not satisfy the gate. A rerun is still pending and must target published `v1.0.0-rc.6`.

   **Validation handoff (send only this setup context):**
   - Send the tester only the GitHub repo or release link for `codebase-orient-skill`.
   - Tell them to have their coding agent install the appropriate skill for the tool they are already using by following the README.
   - Do not explain the repo architecture, which skill to choose, or which install path should win before they attempt the install.

   **Ask the tester to record:**
   - tool used by the human and by the coding agent
   - OS and shell used
   - which install route the agent chose
   - whether installation succeeded
   - whether the agent knew which skill to install
   - whether the agent surfaced any existing-install overwrite decision before changing an existing install
   - whether explicit invocation guidance was clear after install
   - where they hesitated or needed help
   - whether any unexpected files, writes, or errors appeared

   **PASS:**
   - The agent correctly selects the reusable `codebase-orient` skill for normal use.
   - The agent chooses the appropriate supported install route for the tool in use.
   - The agent does not overwrite an existing install without surfacing the decision first.
   - Installation succeeds from the README contract without maintainer coaching and without reconstructing installed skill content from fetched, rendered, summarized, or partial source material.
   - Explicit invocation guidance is clear after install.
   - If orientation is actually run, the agent accurately reports the expected writes.

   **FAIL / feedback-worthy hesitation:**
   - The agent chooses the bootstrap skill unintentionally.
   - The agent cannot distinguish Claude Code vs Codex install paths.
   - The agent overwrites an existing install without first surfacing the decision.
   - The agent attempts to reconstruct or approximate installed `SKILL.md` content instead of using an exact tagged source plus the checked-in installer.
   - Install, discovery/invocation, and workflow execution are blurred together in a way that confuses the user.
   - The tester is blocked by README ambiguity or needs maintainer coaching.

   **Status rule:**
   - G.2 remains pending until an actual external tester response is received and reviewed.
   - A maintainer-run or exploratory agent simulation can be supplementary evidence, but it does not replace the independent external-user-through-agent test.

3. ~~**Canonical skill vs bootstrap embedded template drift check**~~ - RESOLVED 2026-05-22. Full section-by-section comparison completed. No material unintentional drift found. Details:

   **Accurate in embedded template:** docs/ai non-canonical cache framing, docs-as-hypotheses and source authority rules, instruction-layer topology note, no-date-only-churn rule, orientation report discipline (full label set), agent handoff summary, all 9 confidence claim-origin labels, hidden-risk reporting, source-of-truth drift detection, CI/deployment precision rule, read-depth heuristic (including path-existence and small-file-read subsections), cheap artifact glob rule, open question quality rule, cross-file consistency rule, CHANGE_SURFACES mapping guidance (all three categories), project-local specialization rule with thin-overlay framing.

   **Minor non-material wording differences (no action taken):** two reinforcing sentences in orientation report discipline absent from embedded template; one skip-condition bullet and one token-aware bullet absent; docs-impact inline example phrase absent. None affect behavioral outcomes.

   **Intentionally excluded from embedded template:** SvelteKit/Laravel framework-specific discovery probes (bootstrap handles its own discovery pass; noted in the embedded template sync note at line 182); trigger phrases in when-to-use (handled by frontmatter `description`); bootstrap-specific sections (purpose, trigger phrases, creates table, hard rules, idempotency) are bootstrap-only by design.

   No edits to either SKILL.md were made. Embedded template is fit for v1.0.

### Preferred but not hard blockers

4. ~~**One clean Codex live-fire pass on an external repo**~~ - RESOLVED 2026-05-22. External Codex live-fire pass completed in the external Laravel/backend/deployment-sensitive repo. Codex project-local skill (`.agents/skills/codebase-orient/SKILL.md`) was exposed and followed; existing Claude-maintained `docs/ai/` files were verified against source with no substantive corrections needed; no-date-only-churn held; no application code modified. Cross-agent cache lifecycle (Claude Code orients and corrects, Codex verifies) demonstrated. See F1 for full evidence record.

5. ~~**Overlay install semantics decision**~~ - RESOLVED 2026-05-22. Overlay semantics are confirmed acceptable for v1.0. The extra-file survival test in the install matrix proves the behavior matches the documented contract (overlay, not exact-sync). Delete-first workaround is documented in README. No exact-sync tooling will be added before v1.0. Decision recorded.

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

### Agent-delegated install integrity failure

An agent that reads public repo content through a transformed channel may try to reconstruct an installed skill file manually instead of acquiring the exact tagged source and running the checked-in installer. That would compromise instruction-file integrity even if the chosen install scope is otherwise reasonable.

Mitigation: README now states the exact-source integrity rule explicitly, and G.2 requires a rerun against published `rc.6` to prove an external agent follows it.

### Historical rc drift during validation

`v1.0.0-rc.1` was tagged before the README onboarding rewrite and the project-local installer `.gitignore` correction. `v1.0.0-rc.2` carried those corrections but had incomplete README mutation-scope and trust-posture wording discovered by a pre-validation contract audit. `v1.0.0-rc.3` corrected those statements in the pre-public lineage, but the original private/pre-rewrite `rc.3` candidate then failed the exposure audit because tracked docs and reachable history still disclosed private validation identifiers and local paths. The retained sanitized `v1.0.0-rc.3` tag is now historical only. `v1.0.0-rc.4` is the prior sanitized candidate, `v1.0.0-rc.5` is historical evidence of the failed exact-install integrity gate, and `v1.0.0-rc.6` is the active validation candidate. Risk: a tester uses an older tag and encounters guidance or release-decision context that has already been superseded.

Mitigation: keep prior RC tags only if they are sanitized and clearly presented as historical pre-public candidates, and direct independent external validation to published `v1.0.0-rc.6`. Do not use `rc.1`, `rc.2`, or `rc.3` for that validation, do not treat the `rc.4` delegated-install exploration as the gate-closing pass, and do not treat the interrupted `rc.5` run as passing evidence.

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
- [ ] G-section hard blockers resolved: fresh-clone install validated, independent human-through-agent validation completed, canonical/bootstrap drift check recorded
- [ ] G-section overlay decision recorded explicitly
- [ ] CHANGELOG has no Unreleased entries
- [ ] `scripts/check-ascii-punctuation.ps1` exits 0 on current tracked files
- [ ] `git diff --check` is clean
- [ ] `git status` is clean with no uncommitted changes
- [ ] Working tree is up to date with origin before tagging

---

## K. Next immediate step

`v1.0.0-rc.6` is the active validation candidate. The live-fire matrix requirements remain fully satisfied. G.2 (independent human-through-agent validation) is still the remaining hard blocker before `v1.0.0` can be tagged. G.2 is not the sole pre-tag step: D-section and J-section checklist items must also be re-verified against the published `rc.6` candidate as final pre-tag checks.

**K.1 - Independent human-through-agent validation (closes G.2 hard blocker)**

A person with no prior knowledge of this repo's internals receives only the public repo or tag link plus a minimal instruction to have their coding agent install the skill by following the README at published `v1.0.0-rc.6`. Even one successful independent pass is sufficient. Do not use `rc.1`, `rc.2`, or `rc.3` for this test, do not count the earlier `rc.4` exploratory agent run as this gate, and do not count the interrupted `rc.5` failure as passing evidence.

Suggested approach: send a colleague only the GitHub repo link and tag. Ask them to have their coding agent install the skill for the tool they are already using by following the README, without any additional guidance. Record the G.2 acceptance criteria from the blocker section above.

After G.2 is resolved, verify the D/J final checklist against the current working tree, then promote CHANGELOG and tag `v1.0.0` (G.6).
