# Design — Deterministic OpenSpec identifiers and branches

## Naming contract

Grammar for new change IDs:
- `TYPE` is exactly one of `FEAT|FIX|CHORE|UPD|DEL`, case-sensitive uppercase.
- `SEQ` is a per-type monotonically allocated decimal ordinal, padded to **at least three digits** (`001` through `999`, then `1000`, without truncation). No zero and no leading extra padding for the minimum width.
- `SLUG` is a stable lowercase English kebab-case description: `[a-z0-9]+(?:-[a-z0-9]+)*`, no duplicate separators or trailing hyphens.
- Final OpenSpec ID: `TYPESEQ-SLUG` (for example, `FEAT001-improve-materials-menu`).
- No type can be changed during implementation; `FIX003` and `FEAT003` are different identities and numbering sequences.

Type semantics:
- `FEAT`: new end-user capability.
- `FIX`: defect correction restoring accepted behavior.
- `CHORE`: internal maintenance, tooling, CI and agent workflow changes.
- `UPD`: deliberate change/extension of existing accepted behavior or UX.
- `DEL`: intentional removal/deprecation of a behavior, module or supported contract.

Branch grammar:
- Proposal branch (before owner merge): `SPEC/TYPESEQ-SLUG`.
- Implementation branch (after owner merge): `TYPE/SEQ-SLUG`.
- PR title should retain the same typed ID; the authoritative identity remains spec path + branch + machine-readable PR body.

`FEAT001-improve-materials-menu` → `SPEC/FEAT001-improve-materials-menu` → `FEAT/001-improve-materials-menu`.

The proposal and implementation branches MUST be distinct. Agents MUST NOT invent `feature/`, `feat/`, `implementation/`, date-prefixed, issue-number-derived or random branches for new approved specs. Short-lived ancillary non-spec maintenance PRs may use a separate documented exception only when already permitted by SDD, not as a bypass for functional changes.

## Allocation

1. Read `main`, `openspec/changes/` active and archived folders, accepted proposal PRs and open PRs/branches relevant to the chosen type. Only new-style IDs participate in numeric allocation; legacy IDs remain valid but do not consume ordinals.
2. Choose `max(existing TYPE sequence) + 1`, starting at `001` for a type with no accepted or open proposed numbers. If a parallel PR has reserved the same typed number, choose the next one before submitting a proposal; avoid force-push renaming an already approved ID.
3. Record the typed ID verbatim in proposal artifacts, PR body, branch names, tasks and archive path. Exactly one approved change ID per standard functional PR.
4. SDD checks both grammar and branch identity using **actual GitHub event metadata** (`pull_request.head.ref`, base and changed paths). Do not trust a user-supplied PR description as proof of branch identity.
5. On conflicts, fail closed and tell the agent to choose a new ID or coordinate; never silently rewrite owner-approved proposal/specs/scope or renumber a merged change.

## Compatibility and rollout

The proposal of this *naming-governance change* uses legacy `standardize-spec-and-branch-identifiers` and `spec/standardize-spec-and-branch-identifiers`, because the present owner-merged validator does not accept uppercase metadata. The implementation PR follows the existing legacy scheme as well, so enforcement is introduced without a bootstrap deadlock.

After this policy implementation is merged:
- **Grandfather** IDs that already exist in the default branch at the rollout boundary, and already-open proposals/implementation branches that were created before the boundary. Approval lookup, owner chronology, frozen scope, `prepared|blocked` archive and historical lifecycle logic must continue to work for them.
- **New** proposal PRs must have a canonical typed ID and a `SPEC/` branch, with no fallback to legacy or alternate case.
- **New** implementation PRs for a new-style spec must use `TYPE/SEQ-SLUG` and refer to the exact merged proposal PR. No independent identity assignment.
- Archives carry the exact typed ID from their spec directory. Do not retroactively rename old archives or canonical capability names (`openspec/specs/<capability>/spec.md` is a capability namespace, not a change ID).

The grandfathering boundary MUST derive from an explicit stable repository point, not an untrusted author claim. Tests must cover pre-rollout proposed/open work and post-rollout new work even if it later updates its base.

## Validator and security

Extend `scripts/validate_sdd.py` with pure parsing and branch-matching helpers. Extend `tests/test_validate_sdd.py` for exact names, mismatch, collision, uppercase/lowercase, zero/padding, slug, reserved legacy and typed ID, approved implementation, subsequent archive, malicious mismatched metadata, and concurrent proposals. Do not drop the existing owner-merged approval, approved scope or archive equality checks.

The GitHub SDD workflow already reads PR events and scopes changes; it may use read-only GitHub API to check reservations/duplicate IDs. No privileged `pull_request_target` workflow or broad `.github/**` access. CI checks are stable and independent of Lua suite for spec-only changes.

## Agent protocol and artifacts

Update `AGENTS.md`, `CONTRIBUTING.md`, `docs/AGENT_WORKFLOW.md`, `docs/SDD_COMPLIANCE.md`, `docs/DEVELOPMENT.md`, and `skills/documentation-sync/SKILL.md` with an explicit pre-branch identification step (discover/reconcile IDs, choose type and slug, allocate next ordinal, verify branch-to-spec match), plus pre-PR revalidation after code and documentation. Add a reference cheat-sheet and error messages. `openspec/README.md` is intentionally **not** part of this approved implementation scope because the existing scope validator prohibits adding `openspec/` paths as arbitrary allowed paths.

Regression tests must ensure the new policy doesn't accidentally trigger full Lua suites on pure-spec proposals, or disallow approved existing branches.
