# Atomic implementation archival

## Purpose

Defines the owner-approved transactional acceptance and archival contract for CraftAtlas OpenSpec implementation pull requests.

## Requirements

### Requirement: Prepare archive in the implementation PR

A new implementation SHALL prepare a canonical spec synchronization and full same-change dated archive in its implementation PR when all approved mandatory acceptance criteria have adequate evidence. The archive SHALL become part of the canonical repository state only if the owner merges the PR.

#### Scenario: Complete implementation accepted
- **WHEN** a PR implements the owner-approved change, the mandatory tests/scenarios have genuine evidence, and canonical specs are synchronized
- **THEN** the PR contains the dated archive, removal of only its own active change, an updated evidence ledger and updated functional documentation
- **AND** after owner merge there SHALL be no later routine archive-only PR for that change.

#### Scenario: Implementation PR closed
- **WHEN** a prepared-archive implementation PR is rejected or closed without merge
- **THEN** `main` retains the originally active change and its original owner-approved artifacts
- **AND** no acceptance or archived status is recorded on `main`.

### Requirement: Enforce immutable archival provenance

The SDD validator SHALL permit a complete archive of **only** the approved implementation's own change and synchronized capabilities while rejecting altered approved artifacts, unrelated change archives, deleted history or broadened implementation scope.

#### Scenario: Attempted archive manipulation
- **WHEN** a PR changes approved proposal/design/delta requirements or scope in the archive, omits archived files, removes unrelated active changes or edits unrelated canonical capabilities
- **THEN** SDD validation fails even if the PR metadata claims archiving is complete.

#### Scenario: Incomplete archive
- **WHEN** an implementation PR removes the active change without a lossless, complete dated archive
- **THEN** SDD validation fails.

### Requirement: Evidence gates remain honest

An agent SHALL not claim all requirements fulfilled or archive a change with unmet mandatory acceptance tests. An implementation without archive SHALL state exact outstanding requirements and tests as blocked, without skipping the owner acceptance or mandatory SDD checks.

#### Scenario: Missing Forever acceptance
- **WHEN** an approved acceptance scenario requires a real-client test but it is `NOT RUN`
- **THEN** the active change remains open, the relevant task unchecked and the PR records its evidence blocker
- **AND** no CI result or agent attestation falsely substitutes for the real-client evidence.

#### Scenario: No archive but implementation PR
- **WHEN** an implementation legitimately cannot archive because a mandatory scenario is incomplete
- **THEN** it declares `OpenSpec-Archive: blocked` with specific evidence
- **AND** maintainer review determines whether to withhold merge or require a separately approved scope change.

### Requirement: Preserve strict spec-first lifecycle and cost-aware checks

A proposal SHALL remain a spec-only PR requiring owner merge before any implementation. The SDD validator SHALL preserve exact approval PR provenance, non-bypassable check names, read-only CI and the existing restricted historical lifecycle mode.

#### Scenario: Agent tries to skip approval with an archive
- **WHEN** a PR contains an archive but lacks a previously owner-merged proposal
- **THEN** it fails SDD even when all files are structurally present.

#### Scenario: Spec-only PR
- **WHEN** a PR changes only a proposal folder under `openspec/changes/<id>`
- **THEN** SDD/OpenSpec checks validate it and Lua/runtime suites are not required.
