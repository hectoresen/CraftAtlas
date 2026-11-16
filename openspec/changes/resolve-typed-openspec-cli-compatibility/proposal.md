# Proposal: OpenSpec-compatible typed IDs and dependable PR check discovery

## Context / blocking incompatibility

The owner-merged naming specification PR #48 proposed uppercase OpenSpec change names such as `FEAT001-improve-materials-menu`. The current official upstream OpenSpec CLI documentation states that change names MUST use lowercase kebab-case and uppercase is invalid (https://github.com/Fission-AI/OpenSpec/blob/main/docs/cli.md). Directly implementing the approved uppercase directory grammar would break the required OpenSpec CLI propose/validate/archive workflow. This is a narrow correction to the approved governance intent, not a relaxation of SDD or abandonment of typed identities.

The agent-created PR #48 initially had no Actions check runs. Editing its PR body triggered read-only `pull_request: edited` for the SDD workflow and the CI workflow; both later passed. The current agent protocol does not explicitly check whether required checks were *created*, not merely whether they passed when present.

## Outcome

- Adopt a **lowercase typed OpenSpec identity** of the form `feat001-improve-materials-menu`, with `feat|fix|chore|upd|del`, 3+ decimal digits and lowercase kebab slug, case-compatible with the official OpenSpec CLI.
- Retain the user's uppercase branch classification and link exactly and deterministically:
  - spec `feat001-improve-materials-menu`
  - proposal branch `SPEC/FEAT001-improve-materials-menu`
  - implementation branch `FEAT/001-improve-materials-menu`
  - PR `OpenSpec-Change: feat001-improve-materials-menu`
  - archive `openspec/changes/archive/YYYY-MM-DD-feat001-improve-materials-menu/`
- A parser SHALL derive and compare names exactly. No alias, case-insensitive comparison or free-form naming is allowed for new proposals.
- All already-approved and in-flight legacy specs and branches (including #48's original legacy spec ID) SHALL remain valid; owner-approval provenance, frozen scopes and atomic archive policy remain intact.
- After an agent creates or updates a PR, it SHALL check that **all required contexts have materialized** on the PR's current head SHA. If absent, perform **one** safe GitHub PR metadata update that actually retriggers configured workflows and re-check; a missing check after that is an explicit blocker, not “PASS” and not a reason to remove required checks. If the connector cannot update metadata or the event cannot trigger, report the limitation to the owner without claiming success.
- Preserve spec-only cost controls: Lua jobs intentionally skipped are considered materialized `skipped` statuses, not missing checks.
- This governance correction is the source for naming and agent PR-check protocol. The earlier #48 approval remains evidence for the architectural intent, but the incompatible uppercase **change-directory** grammar is explicitly superseded by this proposal.

## Exclusions

No addon Lua behavior, no direct push to main, no workflow token escalation, no GitHub ruleset edits, no PR merge, no disabling SDD/Lua check requirements, no mass renaming of legacy specs.

## Delivery and tests

Owner reviews/merges this spec-only proposal first. Then implement the compatible ID and branch SDD validation, allocation and grandfathering, tests, agent documentation-sync preflight, and post-create check verification in a separate implementation PR referencing this approval. Do not implement the incompatible uppercase naming grammar from #48. Keep its change ledger status truthful and resolve the superseded original requirement during the implementation archive/acceptance process.
