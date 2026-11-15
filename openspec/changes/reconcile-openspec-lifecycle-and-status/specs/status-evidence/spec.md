## ADDED Requirements

### Requirement: Distinguish working runtime from unverified catalog scope
All release/agent status records SHALL differentiate implementation present in source, maintainer-reported in-game function, executed automated checks, exact client-build verification and per-relation live-server data accuracy.

#### Scenario: Working addon with beta catalog
- **WHEN** the maintainer reports that tooltips, settings and minimap work on Forever while catalog evidence comes from an older beta dataset
- **THEN** documentation reports the runtime as working and catalog completeness/current-client reconciliation as pending

#### Scenario: Search affordance in settings
- **WHEN** describing the current settings window
- **THEN** the search-looking control is documented as visual only, without a functional search capability

### Requirement: Task closure requires evidence or explicit deferral
Task checkboxes and change status SHALL be updated only with direct implementation/QA evidence or an explicit approved exception. Merged PRs alone SHALL NOT imply that all acceptance scenarios and release gates passed.

#### Scenario: Original thirty-material gate
- **WHEN** the first-playable implementation initially shipped fewer than 30 independently verified live-client relations
- **THEN** its original acceptance gate remains historically unmet and an explicitly owner-approved follow-up or reduced scope is documented before closure

#### Scenario: Untested individual tooltip origin
- **WHEN** a modern shared hook exists but bank, auction, mail or chat hover has not been individually recorded as tested
- **THEN** no such individual origin is automatically marked accepted

### Requirement: Onboarding and canonical specs reflect the current state
AGENTS.md, OpenSpec context and the status ledger SHALL describe the implemented v0.1.0-dev runtime and distinguish current features from future plans.

#### Scenario: A new coding agent enters
- **WHEN** the agent reads root onboarding and canonical specs
- **THEN** it can identify the current implementation, original approved requirements, tracked outstanding validation, and the valid next SDD action without mistaking it for a non-playable scaffold
