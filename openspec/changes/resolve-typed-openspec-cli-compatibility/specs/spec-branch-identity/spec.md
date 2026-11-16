# Typed OpenSpec identity and PR check discovery

## MODIFIED Requirements

### Requirement: Typed and stable OpenSpec change identifiers

For each newly proposed change, the official OpenSpec identity SHALL use lowercase `(feat|fix|chore|upd|del)NNN-slug` so the upstream CLI supports propose, validate, sync and archive. The typed number is globally unique within its category across approved and currently open proposals; canonical zero-padding is at least three digits. Owner-approved change identity SHALL never be silently renamed.

#### Scenario: Official OpenSpec CLI change names
- **WHEN** the agent creates the first feature proposal under the policy
- **THEN** the spec ID is `feat001-improve-materials-menu`, not `FEAT001-improve-materials-menu`
- **AND** the official OpenSpec CLI accepts the lowercase kebab-case name.

#### Scenario: Existing uppercase sample from original policy
- **WHEN** an agent sees the prior approved example `FEAT001-improve-materials-menu`
- **THEN** it applies the compatible lowercase OpenSpec ID and retains the uppercase type only in the Git branch naming convention
- **AND** legacy approved real changes are not retroactively renamed.

### Requirement: Branch names determined by approved spec identity

The proposal and implementation PR head branches SHALL derive deterministically from the lowercase typed OpenSpec change ID using uppercase type tokens. Proposal branch grammar SHALL be `SPEC/TYPESEQ-slug`; implementation branch SHALL be `TYPE/SEQ-slug`.

#### Scenario: Exact proposal and implementation mapping
- **WHEN** `OpenSpec-Change` equals `feat001-improve-materials-menu`
- **THEN** the proposal branch equals `SPEC/FEAT001-improve-materials-menu`
- **AND** the implementation branch equals `FEAT/001-improve-materials-menu`.

#### Scenario: Unmatched metadata or branch
- **WHEN** head branch, change folder or PR body disagree
- **THEN** SDD rejects the PR without disabling any required check.

## ADDED Requirements

### Requirement: Verify required Actions contexts after agent-created PR

An agent SHALL check that the four mandatory GitHub contexts are reported for the current PR head commit after creating or updating a PR, recover once by a supported safe PR metadata edit if they are missing, and report a blocker if they remain absent or fail.

#### Scenario: No check runs after initial PR creation
- **WHEN** the agent creates a PR and GitHub has not reported the four required check contexts
- **THEN** the agent triggers a single safe metadata edit through the available GitHub integration
- **AND** rechecks the current head without pretending missing checks succeeded.

#### Scenario: Spec-only PR skips Lua
- **WHEN** the diff changes only the approved OpenSpec proposal
- **THEN** `lua-compatibility` and `lua-regressions` may report `skipped` without running Lua
- **AND** the two Lua check-run records SHALL exist rather than remain indefinitely `Expected`.

#### Scenario: Missing check persists
- **WHEN** the metadata update cannot trigger an expected check or a required context reports failure
- **THEN** the agent blocks the ready-for-merge handoff with the exact missing/failed context and does not relax branch protection.
