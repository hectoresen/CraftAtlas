## ADDED Requirements

### Requirement: Verify reference snapshot and license before completeness claims
The release process SHALL record the exact Forever client build, approved source snapshot ID/date, item eligibility definition, legal rights and eligible per-profession coverage denominator.

#### Scenario: Build changes
- **WHEN** Forever introduces new recipes or a custom profession after the tested snapshot
- **THEN** existing coverage claims remain explicitly scoped to the older build until refreshed and revalidated

### Requirement: Enforce verifiable catalog quality and accurate release status
Release checks SHALL reject unverified published relations, source/provenance drift and inaccurate "all items" claims. If full verification is blocked, a partial release requires explicit owner approval and public coverage limitations.

#### Scenario: Incomplete universe
- **WHEN** the coverage report has unresolved eligible relations
- **THEN** an unqualified full-coverage release fails and documents all blockers

### Requirement: Exercise real Forever hover surfaces and language persistence
Before claiming compatibility, tests SHALL run on a real supported Forever build across each claimed tooltip origin, known/unknown/multi-profession/custom materials where present, enUS/esES and persisted settings. Offline mocks SHALL not be reported as live verification.

#### Scenario: Mock-only passing tests
- **WHEN** automated Lua adapter tests succeed but in-game validation has not run for auction or mail tooltips
- **THEN** those origins remain unverified and SHALL NOT be announced as supported

#### Scenario: Settings unchanged
- **WHEN** the user opens /craftatlas after updating the addon
- **THEN** the approved minimal settings layout remains usable and the saved language preference persists
