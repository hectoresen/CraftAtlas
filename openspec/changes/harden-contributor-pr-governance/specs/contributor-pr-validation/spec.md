# Automated contributor PR validation and agent documentation sync

## ADDED Requirements

### Requirement: Validate all pull-request code using deterministic checks
Every code pull request targeting `main` SHALL execute a reliable Lua 5.1 compatibility check, relevant Lua domain/UI regressions, Python/catalog/release-readiness validation, documentation gate and SDD/OpenSpec traceability. Failures SHALL block merges once the corresponding status checks are required in GitHub Rulesets.

#### Scenario: Invalid addon Lua code
- **WHEN** a PR introduces Lua syntax incompatible with 5.1 or breaks an existing deterministic Lua test
- **THEN** the relevant CI job fails
- **AND** no baseline failure is silently bypassed or misreported as passing.

#### Scenario: Release-readiness drift
- **WHEN** changes introduce inconsistent generated data, missing licensed provenance, a malformed addon package or a regression in existing Python checks
- **THEN** the shared release-readiness validation fails on the PR, matching publication policy.

#### Scenario: Untrusted contributor PR
- **WHEN** CI runs for a fork PR
- **THEN** jobs use minimally scoped read-only permissions and no privileged `pull_request_target` execution of untrusted code
- **AND** contributors cannot obtain release tokens or trigger owner-only publication.

### Requirement: Enforce documentation synchronization for functional PRs
Agents and contributors SHALL explicitly invoke `skills/documentation-sync/SKILL.md` after implementation/testing and before opening or updating a functional PR; they SHALL reconcile README, relevant docs and changelog with the actual implementation and attest to evidence in the PR description. CI SHALL validate submitted evidence and changed paths without claiming it can observe private agent activity.

#### Scenario: Functionality changes but docs are stale
- **WHEN** a PR changes user-visible behavior without corresponding README/technical documentation/changelog updates or a specific justified unchanged-docs rationale
- **THEN** the documentation validation fails with an actionable error.

#### Scenario: Pure infrastructure change without visible behavior
- **WHEN** a functional PR legitimately leaves README unchanged
- **THEN** it may pass only with a detailed `Documentation-Review: not-applicable` attestation citing affected code and the docs reviewed
- **AND** empty boilerplate does not satisfy the gate.

#### Scenario: Spec-only proposal
- **WHEN** a PR contains only a new OpenSpec change proposal
- **THEN** it is governed by the proposal-specific SDD rules and is not forced to claim implemented runtime or current README changes.

### Requirement: Preserve owner-controlled releases and approval lifecycle
Changes to governance, workflows or validation SHALL follow owner-approved OpenSpec scope, and the existing owner-only release workflow and protected settings SHALL not be weakened for convenience.

#### Scenario: Workflow or agent protocol change
- **WHEN** a PR edits GitHub workflows, governance scripts, AGENTS or the documentation skill
- **THEN** SDD checks verify the paths are allowed by the separately owner-approved scope and the change documents any privileges required
- **AND** its merge does not automatically change repository rulesets or publish an addon release.
