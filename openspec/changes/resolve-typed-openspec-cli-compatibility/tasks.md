# Implementation tasks — OpenSpec CLI-compatible typed naming

## Approval
- [x] Owner review and merge this spec-only correction PR; do not implement incompatible uppercase OpenSpec names in advance.
- [x] Reference merged correction PR in the implementation PR, acknowledging supersession of the uppercase OpenSpec directory grammar approved in #48.

## Implementation
- [x] Implement case-sensitive lowercased typed OpenSpec identity parsing and stable uppercase branch mapping in `scripts/validate_sdd.py`.
- [x] Enforce type-local sequence allocation and concurrency checks using trusted GitHub information.
- [x] Preserve owner-merged approval, scope checks, historical lifecycle and atomic same-PR archive validation.
- [x] Grandfather pre-rollout legacy specs and existing PRs using a stable baseline.
- [x] Add positive/negative tests for typed proposals/implementations, collisions, aliases, legacy paths and typed archive provenance.
- [x] Update agents' documented branch/ID preflight and mandatory documentation-sync skill.
- [x] Add an explicit post-PR creation check-run materialization audit and one-shot safe recovery to the agent protocol.
- [x] Add tests/docs explaining `skipped` versus missing contexts and how to report failures without bypassing GitHub rulesets.

## Verification and handoff
- [ ] Run SDD/Python and official OpenSpec validation; code/mixed PR also runs Lua regression/compatibility and repository readiness.
- [ ] Document actual PASS/FAIL/NOT RUN evidence; avoid claiming a completed check that has not reported.
- [ ] Prepare atomic archive of this change where acceptance evidence is complete, and preserve separate historical status of spec #48.
- [ ] Open implementation PR only after owner merge, without unilateral merge/release.

## Evidence before implementation PR CI

- Owner-merged correction proposal #49 was verified in main. The original #48 upper-case OpenSpec-directory grammar is superseded by #49, without rewriting approved history.
- Validator now recognizes lowercase CLI-safe typed IDs and strict branch mappings, grandfathering previous approved IDs and the already-open #43/#44/#46 proposals. It checks approved and concurrent numeric reservations and preserves existing approval/archive gates.
- Python regression fixtures cover branch mapping, invalid IDs/case/zero-padding, collisions, legacy baseline and missing-vs-skipped PR checks. GitHub Actions validation: NOT RUN on this implementation commit yet.
- Reviewed README, ARCHITECTURE, DATA_MODEL and INSTALLATION: unchanged because no Lua/player-facing behavior changes. Updated agent, workflow, SDD, testing, roadmap, contributor and skill guidance.
- WoW Forever client tests: NOT RUN, not applicable to governance-only behavior. Actual GitHub Actions confirmation still required.
