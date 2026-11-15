# Agent lifecycle and context recovery

This is an executable working agreement for OpenCode and any compatible AI coding agent. `AGENTS.md` has priority for agent conduct.

## On first entry (zero repository knowledge)

1. Read `README.md` → `AGENTS.md` → `CONTRIBUTING.md` → `docs/ARCHITECTURE.md` → `docs/CODE_QUALITY.md`.
2. Read `openspec/config.yaml` and `openspec/README.md`.
3. Inspect `openspec/specs/` and `openspec/changes/` (including incomplete changes). Run `openspec list` when CLI is installed.
4. Inspect current branch, clean/dirty working tree, open GitHub PRs/issues, tests and roadmap version.
5. Identify exactly what behavior exists in code, which specs are accepted, and which is only planned.
6. Report scope and unknowns before creating a proposal.

## Guarded state machine

```text
DISCOVER → EXPLORE (optional) → PROPOSE → OWNER_APPROVAL
                                          |
                                     denied/revise
                                          |
                                          v
                                   /opsx:update
                                          |
                                  approved only
                                          v
                                      IMPLEMENT
                                          |
                                   TEST & VERIFY
                                          |
                                     SYNC SPECS
                                          |
                          RUN documentation-sync SKILL
                             AUDIT → UPDATE → VERIFY
                                          |
                                      OPEN PR
                                          |
                                  OWNER REVIEWS
                                          |
                               OWNER MERGES (only)
                                          |
                                   ARCHIVE / RELEASE
```

- **Gate 1:** The maintainer @hectoresen explicitly approves the proposal/spec scope before code changes.
- **Gate 2:** Proposed implementation passes offline checks, records manual game checks and matches accepted specs before PR.
- **Gate 3:** Before every functional PR, explicitly read and execute `skills/documentation-sync/SKILL.md`; review README and affected documentation, document test evidence and declare `Documentation-Review`/`Documentation-Evidence` in the PR body. Optional multiagent auditors must have disjoint file ownership; all agents can do the work serially. See `docs/DOCUMENTATION_PROTOCOL.md`. Structural CI cannot certify the skill ran or semantic accuracy.
- **Gate 4:** Only the owner may authorize merge, release, protection changes or privileged GitHub operations.
- Revision requests return to planning, not an automatic implementation loop.

OpenSpec `/opsx:archive` is applied when the change is accepted and the canonical specs have been synchronized. Agents may prepare the archive on a PR branch; do not archive a rejected or unreviewed behavior change as though accepted.

## Agent context-loss / handover protocol

Record the change ID, branch, approved scope, current tasks, modified files, decisions, tests with exact commands/results, game-client checks and blockers. A new agent must reconstruct state from Git and OpenSpec; never rely on chat memory alone. If active tasks and code disagree, report the discrepancy before modifying either.

## What agents must not do

Never direct-push `main`; merge; force-push shared history; create tags/releases; rotate secrets; alter GitHub permissions/rulesets; remove attribution; or import unlicensed datasets without a separate owner authorization. Never mark a manual game test completed without performing it.

## Documentation review handoff

List each reviewed document as updated or unchanged with a reason, the README feature claim checked against source, and exact tests RUN/NOT RUN. Do not place fluctuating feature summaries in AGENTS.md; that document is only an agent contract and skills index. After changing the PR, rerun the skill before asking for merge.

## Output at handoff

Provide concise: progress, PR, evidence, unmet acceptance criteria, outstanding decisions and a direct next action for @hectoresen.

## OpenSpec lifecycle and context drift

Before proposing changes, cross-check the current feature claims in `README.md` with source code and use `docs/OPENSPEC_STATUS.md` to understand historical tasks that are implemented, superseded or still missing live-client evidence. Treat `openspec/config.yaml` as stable project context only, not a second feature-status summary. Do not declare legacy changes archived or complete when acceptance requirements remain open. The lifecycle path is limited to the owner-approved change `reconcile-openspec-lifecycle-and-status` and its fixed SDD allowlist; user acceptance of UI does not prove source-data completeness or individual tooltip-origin support.
