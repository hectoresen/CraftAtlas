# Proposal — Standardize OpenSpec IDs and agent branch naming

## Problem

CraftAtlas agents currently choose arbitrary OpenSpec change IDs and Git branch names. There is no enforced, discoverable link between a feature specification, the spec-only PR branch, its later implementation branch and the dated archived change. This makes triage, automation, ownership, and provenance unnecessarily difficult. Existing active PRs #43, #44 and #46 still use legacy IDs/branches; no unsafe retroactive rename is permitted.

## Goal

For **new** changes after rollout, introduce a predictable typed identifier (`FEAT001`, `FIX002`, `CHORE003`, `UPD004`, `DEL005`) shared by spec, implementation branch, PR metadata, and archive, with a deterministic mapping and automatic validation.

### Proposed examples

| Purpose | Name |
| --- | --- |
| OpenSpec directory and change ID | `FEAT001-improve-materials-menu` |
| Proposal PR branch | `SPEC/FEAT001-improve-materials-menu` |
| Implementation PR branch | `FEAT/001-improve-materials-menu` |
| OpenSpec PR metadata | `OpenSpec-Change: FEAT001-improve-materials-menu` |
| Archived change directory | `openspec/changes/archive/YYYY-MM-DD-FEAT001-improve-materials-menu/` |

The **proposal branch** intentionally differs from the implementation branch: the former carries only the new spec before owner approval, whereas the latter carries code after owner merge. Reusing an identical branch for both PRs would make provenance and lifecycle unsafe.

## Scope

- Define explicit type registry `FEAT`, `FIX`, `CHORE`, `UPD`, `DEL`, their semantics, example mappings, numeric allocation and no-reuse policy.
- Enforce canonical, case-sensitive `TYPEddd-kebab-slug` change IDs and corresponding `TYPE/ddd-kebab-slug` implementation branches for new changes, with `SPEC/TYPEddd-kebab-slug` proposal branch.
- Require agents to allocate the **next unused** 3+ digit number per type from all active/archived specs plus open/merged PR references, and check again before PR; never silently substitute a different suffix or reuse an ID.
- Validate new and archived OpenSpec paths, branch names, PR metadata, owner-approval provenance, and current approved scope via SDD CI; forbid ambiguous alternate naming or unchecked aliases.
- Preserve the accepted two-PR flow, mandatory documentation-sync audit, same-PR atomic archives, read-only security checks, and cost-aware spec-only CI.
- Specify migration compatibility for all existing legacy change IDs and already-open PRs, without renaming old artifacts, branches, or archives or breaking old approved implementation PRs.

## Non-goals

No rename/migration of historical specifications, no changes to WoW addon behavior, no new GitHub rulesets/required check names, no automatic merging, and no additional routine third archival PR.

## Risk and rollback

- Current SDD identifier regex only accepts lowercase IDs; enforcing uppercase prematurely would break specs. Introduce versioned/grandfathered validation **after** this owner-merged policy spec and add positive/negative regression tests before enforcing.
- Future concurrent proposal authors could claim the same numeric ID: recompute the next available ID from default branch plus open PRs; enforce uniqueness at PR validation. A rejected proposal does not permanently reserve its number unless it was merged or otherwise allocated in a committed accepted change; no silent reuse of accepted IDs.
- Existing manual `docs/SDD_COMPLIANCE.md` and `openspec/README.md` contracts describe legacy lowercase names. The implementation must update approved guidance without weakening the protected `openspec/` scope boundary. This first governance proposal itself uses the **legacy naming convention** as the explicit bootstrap case.
- If new gating causes failures, correct the validator or documents in an owner-approved PR. Do not disable `traceability` or GitHub rulesets.

## Delivery

1. Owner reviews and merges **this spec-only PR**; it contains only this new change folder.
2. Separate implementation PR updates SDD validator/tests, agent skill and documentation within the approved scope.
3. All *new* specs after the implementation merge use typed IDs and branch naming. Existing active/archived specs stay valid.
