## Purpose and scope

Describe the change and its target version. Separate specification proposal and implementation PRs.

## OpenSpec — mandatory metadata

Replace this section's sample with exactly the corresponding lines, **not in a code fence**:

For a specification PR:
- OpenSpec-Change: YOUR-CHANGE-ID
- OpenSpec-Phase: proposal

For an implementation PR:
- OpenSpec-Change: YOUR-CHANGE-ID
- OpenSpec-Phase: implementation
- OpenSpec-Approval-PR: NUMBER-OF-MERGED-SPEC-PR

For an eligible exception:
- OpenSpec-Exemption: docs-only

Keep only the applicable declaration in your PR body. Consult docs/SDD_COMPLIANCE.md.

## Approval and verification

Link the merged, owner-approved spec PR (implementation only).
Explain what was approved and how the code matches its scenarios.

- [ ] Official OpenSpec validation passes
- [ ] SDD traceability policy tests and gate pass
- [ ] Relevant code tests and lint pass
- [ ] In-game Forever checks reported as passed/failed/not run
- [ ] Locales, data rights, docs and changelog updated when needed

## Risks, rollback and evidence

Document limitations, reproduction and screenshots as relevant.
