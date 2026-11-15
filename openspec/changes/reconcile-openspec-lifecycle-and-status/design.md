# Design: gated OpenSpec lifecycle reconciliation

## Authority and truth hierarchy
Accepted requirements and merged owner-approved PRs are historical facts. Current source code determines present implementation; maintainer-reported game operation is client smoke-test evidence. A `checked` task needs direct support in code/PR evidence or an explicit owner statement. A separate evidence matrix labels `implemented`, `maintainer-validated`, `automated-validated`, `pending-live-data-QA` and `not-run`.

Never promote the beta LibProfessionDB relations to verified live-server coverage on the basis of the addon booting. Search in settings is only a visual affordance.

## Current validator constraints
`scripts/validate_sdd.py` currently:
- accepts `OpenSpec-Phase: proposal|implementation` only;
- excludes `openspec/**` from implementation scope and blocks unrelated change directories;
- rejects `AGENTS.md` in implementations even if explicitly approved;
- allows no governance exemption suitable for reconciliation.

Avoid bypassing checks. Stage B can safely modify `scripts/validate_sdd.py`, `tests/test_validate_sdd.py`, `docs/SDD_COMPLIANCE.md` under this change's pre-approved path scope and the existing implementation validator; it **must not** modify AGENTS.md or `openspec/**` outside its own allowed tasks file.

## Target lifecycle gate (Stage B)
Introduce a separately named owner-approved lifecycle PR mode, not a general docs exception. Require:
- `OpenSpec-Change: reconcile-openspec-lifecycle-and-status`;
- `OpenSpec-Phase: lifecycle`;
- `OpenSpec-Approval-PR: <this proposal PR number>`;
- explicit fixed allowlist for Stage C: `AGENTS.md`, `openspec/config.yaml`, `openspec/README.md`, `docs/AGENT_WORKFLOW.md`, selected documentation/status files, `openspec/specs/<approved-capability>/spec.md`, tasks/metadata for the three named historical changes and `openspec/changes/archive/<dated-change-id>/**`.

The validator must reject modifications to historic proposal/design/delta specs or scope manifests; require archive content equality to original files (or explain OpenSpec metadata changes permitted by official archive tool); ensure old directories are only deleted when their complete archival copies exist; reject unrelated directory moves and any request to archive an unresolved change without a reviewed acceptance/deferral record. Validate that canonical capability specs correspond to accepted delta requirements and no future unimplemented requirements are advertised as shipped.

The lifecycle validator must check that the approval PR was merged by owner **before** creating the lifecycle PR and verify fixed target change IDs/paths. The user retains final merge authority.

## Stage C reconciliation
1. Update AGENTS.md and openspec/config.yaml to describe implemented v0.1.0-dev accurately; refresh development/governance guidance without removing spec-first requirements.
2. Prepare `docs/OPENSPEC_STATUS.md` evidence ledger: IDs, spec PRs, merged implementation PRs, user smoke-test acknowledgement, code paths, unmet acceptance criteria and client-build gaps.
3. Check only supported tasks; use explicit notes for exceptions. Original 0.0.1 starter catalog's 30 verified itemIDs requirement was **not verified at the time**; user acceptance of a playable build is not evidence that the initial dataset gate was met.
4. Use official OpenSpec sync semantics for accepted/implemented features. Do not incorporate a false 'complete Forever coverage' requirement into canonical shipped capabilities. For incomplete expansion obligations, leave a tracked active delta or request owner-approved reduced scope before archive.
5. Archive only changes accepted under the gated ledger. Record the archival path and preserve complete source docs and approval linkage. `openspec/changes/archive` is an archive, not a deletion of history.
6. Run OpenSpec CLI validation, SDD policy unit tests, repository checks and material generator checks, reporting which cannot run locally. No owner approval is inferred.

## Consistency and tests
Stage B unit tests must cover valid lifecycle, missing/other-owner approval, modifications of immutable historic specs, non-allowlisted paths, partial archive/copy mismatches, unsupported feature claims and regression of existing proposal/implementation modes. Stage C must demonstrate archive/source consistency, canonical spec consistency, no conflict markers and no unverified 'done' checkboxes.

## Version semantics
`0.1.0-dev` is a functional development version, **not** a tagged release. Search is visual only; known 593 itemIDs/10 profession sources/237 shared IDs describe a bounded MIT-licensed beta snapshot, not 100% live realm coverage.
