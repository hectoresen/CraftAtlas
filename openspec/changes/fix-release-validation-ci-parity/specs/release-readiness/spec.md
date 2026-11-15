# Release-readiness specification

## ADDED Requirements

### Requirement: consistent recipe-use relationship validation
The system SHALL compare recipe-use records and source catalog relations using one canonical tuple ordering. It SHALL detect missing relationships without reporting existing relationships as missing.

#### Scenario: catalog has all relationships
- **WHEN** source relations and recipe uses match
- **THEN** recipe-use validation succeeds without missing-relation errors

#### Scenario: one relation is absent
- **WHEN** exactly one source relation has no matching recipe use
- **THEN** validation reports exactly one missing relationship

### Requirement: release parity with pull request CI
The system SHALL execute the same repository, material-data, catalog drift and package-test gates before merge and before publishing a manual release.

#### Scenario: a release test fails on a pull request
- **WHEN** a pull request includes changes that make any release-readiness check fail
- **THEN** its CI check fails before the change is merged

#### Scenario: owner dispatches a release
- **WHEN** the owner triggers a release from main
- **THEN** the release uses the same checks as PR CI before publishing
