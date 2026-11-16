# Contributor governance

## ADDED Requirements

### Requirement: Owner approval must be independent of merge actor
Contributor-authored specification pull requests SHALL be accepted as SDD approval evidence only when a GitHub review from @hectoresen has state APPROVED and is still valid at merge time. The merge actor SHALL NOT need to be @hectoresen.

#### Scenario: Contributor merges owner-approved specification
- **WHEN** a contributor merges into main a spec PR previously approved by @hectoresen and all quality gates pass
- **THEN** a later in-scope implementation may refer to the merged spec PR as its approval provenance

#### Scenario: Contributor merges without owner approval
- **WHEN** the merged spec PR has no valid owner review
- **THEN** the implementation is rejected regardless of the merger's permissions

### Requirement: GitHub shall require code-owner review
Every contributor-authored PR targeting main SHALL require @hectoresen's approval through GitHub's code-owner review ruleset, in addition to mandatory status checks. Contributors with merge permission MAY merge after checks and owner approval. Root CODEOWNERS SHALL cover all changed paths.

#### Scenario: Other contributor approves
- **WHEN** a contributor PR receives an approval from someone other than @hectoresen
- **THEN** that review alone cannot authorize merging to main

### Requirement: Owner-authored PRs remain possible
Owner-authored PRs SHALL retain the PR-only administrator review bypass because self-approval is impossible. Status checks SHALL remain mandatory without bypass.

#### Scenario: Owner authors a PR
- **WHEN** @hectoresen authors a pull request and all mandatory status checks pass
- **THEN** the owner may use the existing PR-only administrator review bypass to merge without self-approval, but cannot bypass failing checks

### Requirement: Historical proposals remain traceable
Previously merged specification PRs SHALL be checked against real review provenance rather than requiring duplicate specification content merely due to who merged.

#### Scenario: Historical contributor-merged spec had owner approval
- **WHEN** a previously merged specification PR has a valid pre-merge APPROVED review by @hectoresen but was merged by a contributor
- **THEN** the implementation can cite the original specification PR and does not require an identical replacement proposal
