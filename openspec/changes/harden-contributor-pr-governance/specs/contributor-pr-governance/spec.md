# Contributor pull-request governance

## ADDED Requirements

### Requirement: Require independent review of contributor changes
Changes into the default branch SHALL require a pull request and at least one approval by a different authorized reviewer, unless an explicitly configured owner/admin bypass is used. The ruleset SHALL be verified to match `main`; a ruleset whose enforcement or branch targeting is unverified SHALL not be claimed as active protection.

#### Scenario: Contributor opens PR
- **WHEN** a non-owner contributor opens a PR into `main` and no authorized independent approving review exists
- **THEN** the PR cannot be merged into `main`, regardless of CI result
- **AND** the author cannot count their own review as approval.

#### Scenario: Contributor adds changes after approval
- **WHEN** the contributor pushes changes after an approval
- **THEN** the stale approval SHALL no longer authorize the altered content without new review, according to the enabled GitHub ruleset.

### Requirement: Preserve owner merge ability without bypassing checks
The owner SHALL be able to merge their own PR using a supported review-rule bypass rather than self-approval, while a separate non-bypassable technical ruleset SHALL require successful checks for owner and contributor alike.

#### Scenario: Owner opens PR
- **WHEN** `hectoresen` authors a PR with successful required checks
- **THEN** the review-rule bypass can permit merging without a second GitHub approval
- **AND** the technical checks remain enforced
- **AND** the project SHALL NOT describe this as self-approval or a GitHub API review from the author.

#### Scenario: Owner change fails required check
- **WHEN** any required check fails on an owner-authored PR
- **THEN** the owner is blocked from merging by the non-bypassable technical ruleset.

### Requirement: No contributor self-merge by untrusted privilege
The repository SHALL document that write permissions can allow merging already approved PRs, independently of the author's identity, and SHALL not grant merge-capable permissions to external contributors solely to let them submit changes.

#### Scenario: Untrusted contributor submits change
- **WHEN** a contributor without write/maintain permissions submits a fork PR
- **THEN** they cannot merge to `main` themselves
- **AND** the owner controls the final merge or release.

### Requirement: Repository administration evidence
The PR SHALL include a precise, manually executable GitHub Settings checklist and verification of actual protection rules, plus disclosure of any admin-API limitations. Automation SHALL not report repository protection as configured until the owner has applied and verified it.

#### Scenario: Implementation PR merged but Settings untouched
- **WHEN** a workflow/documentation PR is merged without the owner changing the ruleset
- **THEN** documentation states that required reviews and checks are still not enforced
- **AND** provides the manual Settings steps.
