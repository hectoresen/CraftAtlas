# Implementation tasks — OpenSpec CLI-compatible typed naming

## Approval
- [ ] Owner review and merge this spec-only correction PR; do not implement incompatible uppercase OpenSpec names in advance.
- [ ] Reference merged correction PR in the implementation PR, acknowledging supersession of the uppercase OpenSpec directory grammar approved in #48.

## Implementation
- [ ] Implement case-sensitive lowercased typed OpenSpec identity parsing and stable uppercase branch mapping in `scripts/validate_sdd.py`.
- [ ] Enforce type-local sequence allocation and concurrency checks using trusted GitHub information.
- [ ] Preserve owner-merged approval, scope checks, historical lifecycle and atomic same-PR archive validation.
- [ ] Grandfather pre-rollout legacy specs and existing PRs using a stable baseline.
- [ ] Add positive/negative tests for typed proposals/implementations, collisions, aliases, legacy paths and typed archive provenance.
- [ ] Update agents' documented branch/ID preflight and mandatory documentation-sync skill.
- [ ] Add an explicit post-PR creation check-run materialization audit and one-shot safe recovery to the agent protocol.
- [ ] Add tests/docs explaining `skipped` versus missing contexts and how to report failures without bypassing GitHub rulesets.

## Verification and handoff
- [ ] Run SDD/Python and official OpenSpec validation; code/mixed PR also runs Lua regression/compatibility and repository readiness.
- [ ] Document actual PASS/FAIL/NOT RUN evidence; avoid claiming a completed check that has not reported.
- [ ] Prepare atomic archive of this change where acceptance evidence is complete, and preserve separate historical status of spec #48.
- [ ] Open implementation PR only after owner merge, without unilateral merge/release.
