# Documentation PR readiness gate

## ADDED Requirements

### Requirement: Enforce a pre-PR documentation audit structurally
Functional PRs SHALL include a truthful documentation review attestation in PR metadata and sufficiently updated functional documentation or a reviewable reason for no change. A read-only CI check SHALL reject missing or inconsistent attestations without bypassing existing SDD checks.

#### Scenario: Functional PR updates README
- **WHEN** addon functionality changes and README plus relevant docs are updated
- **THEN** a `Documentation-Review: updated` declaration and changed-file evidence pass structural validation

#### Scenario: Functional PR forgets documentation
- **WHEN** user behavior changes but no documentation review or README impact rationale is supplied
- **THEN** documentation gate fails even if Lua/Python checks pass

#### Scenario: Nonfunctional maintenance
- **WHEN** the PR only changes permitted docs or a spec proposal
- **THEN** validation uses appropriate lighter checks and does not insist on fictional new functionality

#### Scenario: Attested but inaccurate claim
- **WHEN** a PR contains a structurally complete attestation but misleading semantic claims
- **THEN** CI reports its structural limits
- **AND** human owner review remains required rather than falsely certifying truth

### Requirement: Keep owner-protected governance
Changes to AGENTS.md and CI enforcement SHALL require the original owner-merged spec approval and a narrow, verified allowlist for this exact governance change.

#### Scenario: This approved implementation
- **WHEN** the implementation references the real merged governance spec PR and touches only approved paths
- **THEN** SDD may accept its AGENTS.md and explicitly named CI workflow updates

#### Scenario: Other implementation tries to edit governance
- **WHEN** any unrelated change attempts to modify AGENTS.md without its own approved governance allowance
- **THEN** SDD rejects it despite any documentation attestation
