# Design: OpenSpec-compatible identity and reliable PR check handoff

## Compatibility decision

Official upstream OpenSpec CLI change names reject uppercase letters. Therefore the **filesystem/CLI/PR metadata identity is lowercase**, while **Git branches encode the visually prominent uppercase TYPE**.

| Type | Change ID | Proposal branch | Implementation branch |
| --- | --- | --- | --- |
| New feature | `feat001-improve-materials-menu` | `SPEC/FEAT001-improve-materials-menu` | `FEAT/001-improve-materials-menu` |
| Bugfix | `fix002-repair-tooltip` | `SPEC/FIX002-repair-tooltip` | `FIX/002-repair-tooltip` |
| CI/tooling | `chore001-agent-pr-checks` | `SPEC/CHORE001-agent-pr-checks` | `CHORE/001-agent-pr-checks` |

New identity grammar: `^(feat|fix|chore|upd|del)(?:00[1-9]|0[1-9][0-9]|[1-9][0-9]{2,})-[a-z0-9]+(?:-[a-z0-9]+)*$` with stricter canonical zero-padding: any number under 1000 must use three digits; numbers over 999 are unpadded. The parser SHALL not accept `feat000`, `feat01`, `feat0001`, uppercase spec names or malformed separator/case. Agent numbering is per type, `max+1`, considering active+archived specs and concurrent PRs, with deterministic collision failures.

The proposal stage uses actual event `pull_request.head.ref` and PR body `OpenSpec-Change` plus one matching new spec folder; the implementation stage uses approved spec change metadata and `TYPE/SEQ-SLUG`. The existing owner-merged approval PR check, code path scope, correct phase, and atomic archival transaction are independent.

### Rollout / legacy

Existing changes under the known fixed policy rollout commit in `main` and PRs created before the policy rollout boundary (including #43, #44, #46 and #48) are grandfathered. This exception derives from trusted GitHub timestamps or frozen Git refs, never untrusted descriptions or arbitrary `legacy=true` flags. A branch based on an existing legacy spec keeps its original identity through owner approval, implementation and archive, even if its implementation PR is opened after rollout. A post-rollout new proposal SHALL use the new format.

Do not broaden paths in `sdd-scope.json` to `openspec/**`. Do not modify protected `openspec/README.md` in an implementation PR. Existing shared canonical capability folders under `openspec/specs/` keep their own lowercase names.

### Missing Actions on agent-created PRs

GitHub Actions may suppress workflow chaining when writes use a repository `GITHUB_TOKEN`, or may not surface check runs immediately. A missing check is not a green check. Agents SHALL:

1. Create PR with complete metadata (spec phase/approval/archive/docs) and record returned head SHA.
2. Query PR check-runs for that SHA (not previous commits), classify `queued`, `in_progress`, `completed:success`, `completed:skipped`, `completed:failure` and completely missing contexts. Require `repository-validation`, `traceability`, `lua-compatibility` and `lua-regressions` to have *appeared*; `classify-pr` is a useful diagnostic but not a branch-required context.
3. If required contexts are **absent** (not merely queued), perform one idempotent PR metadata update through a supported GitHub-authenticated integration, such as adding a short check-dispatch note to the PR body; preserve all machine-readable declarations and review evidence. GitHub's `pull_request: edited` is configured for SDD, and the standard CI `pull_request` trigger uses default activity types including `edited` behavior depending on GitHub; if a job does not trigger, do not claim it has.
4. Query the current head SHA again. If any context is missing or failed, explicitly block the PR handoff and report the exact context, run link/error and possible manual steps. Never disable a ruleset, synthesize success statuses, loop retries, create empty commits to bypass reviews or use privileged tokens.
5. A status `skipped` for Lua on a specs-only PR is expected and acceptable if the check run actually exists. PR approval remains a separate gate.

No custom privileged workflow or new required GitHub contexts is needed to teach agents this handoff. Keep the existing read-only workflow permissions.

### Security tests

- Parse and map type, padded sequence and lowercase slug.
- Reject malformed, mismatched, ambiguous or conflicting type+number combinations.
- Verify owner-approved legacy IDs and already-open proposal PRs remain valid using a trusted rollout baseline.
- Verify archive of typed and legacy changes via base-byte equality and only-this-change restrictions.
- Assert that no agent check-state verification can mistake **missing** for **skipped**.
- Retain stable rule contexts and cost-aware spec-only mode.

## Implementation scope

Source validator: `scripts/validate_sdd.py`, tests: `tests/test_validate_sdd.py`, agent protocol: `AGENTS.md`, `CONTRIBUTING.md`, `docs/AGENT_WORKFLOW.md`, `docs/SDD_COMPLIANCE.md`, `docs/DEVELOPMENT.md`, `docs/DOCUMENTATION_PROTOCOL.md`, `docs/TESTING.md`, `skills/documentation-sync/SKILL.md`; update `CHANGELOG.md`, `docs/ROADMAP.md`, `docs/OPENSPEC_STATUS.md` only if warranted. Source scripts for PR check queries are not proposed; the existing agent integrations can query GitHub without adding privileged workflows.
