# Specification and branch identity

## ADDED Requirements

### Requirement: Typed and stable OpenSpec change identifiers

Every new functional or governance OpenSpec change SHALL use a unique typed ID `TYPESEQ-slug` with `TYPE` from `FEAT|FIX|CHORE|UPD|DEL`, a type-local increasing minimum-three-digit sequence, and a lowercase kebab-case slug. Once owner-approved, its ID SHALL remain immutable through implementation and archiving.

#### Scenario: New feature
- **WHEN** an agent proposes the first new feature under the naming policy
- **THEN** the change directory and PR metadata identify it as `FEAT001-improve-materials-menu` (assuming no earlier FEAT sequence has been reserved).

#### Scenario: Number collision
- **WHEN** a new proposal's typed number is already reserved by an existing approved or concurrently open proposal of the same type
- **THEN** validation rejects it and provides a conflict message; the agent MUST allocate an unused later sequence before owner approval.

#### Scenario: Unsupported format
- **WHEN** an agent proposes `feat001-foo`, `FEAT0-foo`, `FEAT001_Foo`, `XYZ001-foo` or a malformed slug
- **THEN** SDD rejects the proposal before it can be merged.

### Requirement: Branch names determined by approved spec identity

For a new typed change, the proposal PR branch SHALL be `SPEC/TYPESEQ-slug`, and the subsequent implementation PR branch SHALL be `TYPE/SEQ-slug`. The SDD validator SHALL compare actual PR head branch metadata to the spec directory and `OpenSpec-Change` metadata, not merely trust the PR title or body.

#### Scenario: Matching proposal branch
- **WHEN** a proposal introduces `FEAT001-improve-materials-menu` from branch `SPEC/FEAT001-improve-materials-menu`
- **THEN** SDD accepts its naming relationship, subject to all existing proposal checks.

#### Scenario: Matching implementation branch
- **WHEN** an owner-approved `FEAT001-improve-materials-menu` is implemented from branch `FEAT/001-improve-materials-menu`
- **THEN** SDD accepts the relationship, subject to approval provenance, scope and archive evidence.

#### Scenario: Arbitrary branch rejected
- **WHEN** an agent invents branch `feature/materials-update` or misaligns the type/sequence/slug with the approved change
- **THEN** SDD fails with an actionable naming error, even when the code and tests pass.

### Requirement: Backward compatible rollout

The new naming gate SHALL apply to **new** changes after rollout and SHALL NOT retroactively invalidate owner-approved legacy specs, existing open PRs or dated archives, nor modify legacy canonical capability names.

#### Scenario: Existing proposal
- **WHEN** an already-open, valid legacy proposal is revalidated after the naming policy deployment
- **THEN** it still passes the previously applicable OpenSpec provenance checks without forced rename.

#### Scenario: Existing implementation and archive
- **WHEN** an implementation references a legacy change approved before rollout, or prepares that change's existing archive
- **THEN** legacy identity remains valid and old approval/archive integrity requirements continue to apply.

### Requirement: Agent preflight and enforcement

Before opening or updating a new proposal or implementation PR, the agent SHALL verify type, next available number, actual branch format, metadata and accepted change ID against the repo state. CI SHALL independently enforce the identity and preserve the owner-merged proposal/implementation two-PR approval process.

#### Scenario: Pre-PR revalidation
- **WHEN** an agent runs the mandatory documentation-sync skill before PR submission
- **THEN** the audit includes typed ID uniqueness and branch-to-spec consistency, and declares any missing/ambiguous identity as a blocker rather than inventing a name.
