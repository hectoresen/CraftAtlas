# Reviewed workflow governance

## ADDED Requirements

### Requirement: Explicitly authorized workflow paths
The SDD policy SHALL allow an implementation PR to change a GitHub Actions YAML workflow only when its exact path under .github/workflows/ is included in a frozen allowed_paths manifest of a previously merged, owner-approved OpenSpec proposal.

#### Scenario: Authorized workflow
- **WHEN** the referenced owner-merged proposal explicitly permits .github/workflows/publish-release.yml
- **THEN** the implementation may edit that file, subject to all existing traceability checks.

#### Scenario: Unapproved workflow
- **WHEN** a workflow change is absent from the referenced manifest
- **THEN** CI rejects the implementation.

### Requirement: Unsafe scopes remain blocked
The policy SHALL reject broad .github wildcard scopes, traversal paths, unrelated hidden files and unauthorized governance changes without weakening existing approval validation.

#### Scenario: Broad GitHub scope
- **WHEN** a manifest permits .github/workflows/** or .github/**
- **THEN** CI rejects the manifest.

#### Scenario: Non-workflow GitHub file
- **WHEN** an implementation changes .github/CODEOWNERS without appropriate authorization
- **THEN** CI rejects the implementation.

### Requirement: Existing approval gates preserved
The policy SHALL continue to require an already merged owner-approved specification PR, correct change ID, correct base, approved paths and chronological ordering.

#### Scenario: No approved specification
- **WHEN** a developer changes a workflow before the related proposal is merged
- **THEN** the SDD validation rejects the implementation.
