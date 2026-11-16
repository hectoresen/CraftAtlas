# Require owner review without owner-only merge

## Problem
The SDD approval validator currently rejects a specification PR merged by a contributor, even if @hectoresen approved it, because it checks `merged_by` rather than review provenance. This forces duplicate proposals (e.g. #44 and #57). The active GitHub review ruleset requires one independent approval but does not enforce CODEOWNER review; CODEOWNERS merely requests it.

## Proposed solution
Allow contributors to author and merge PRs after successful required checks and explicit owner approval. Validate the owner's actual APPROVED review on an already merged specification PR, without tying approval to its merger. Configure the GitHub main review ruleset to require code-owner review of changes, preserving CI without bypass. Owner-authored PRs cannot be self-reviewed and continue to require the existing admin PR-only bypass; never bypass CI.

## Scope
Update SDD validator and regression tests; align AGENTS, contributor and governance guidance, Code Owners / GitHub ruleset instructions. Do not alter addon runtime, release authorization or required checks.

## Acceptance
Contributor-authored, owner-approved specs merged by someone else are valid. Contributor-merged specs without the owner's approval are rejected. Old #44 is recognized based on actual review records, without creating a duplicate proposal if it has an owner approval; if not, handle its historical status explicitly rather than claiming it was approved. GitHub ruleset must enforce mandatory owner code-owner review, and tests/documentation distinguish configuration from observed behavior.
