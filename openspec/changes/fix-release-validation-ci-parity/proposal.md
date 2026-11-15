# Prevent release-only validation failures

## Why
The manual CraftAtlas release rejected 8,455 valid recipe relations because the relation validator used inconsistent tuple ordering. The normal PR CI lacked release-readiness tests, so the defect was only discovered during publication.

## Scope
- Correct the recipe-use validator to compare the same canonical (itemID, professionKey, recipeSpellID) keys.
- Add a regression test that detects an actual missing relation.
- Extract the existing release-readiness commands to a shared script.
- Execute the same script for pull requests, main pushes and release validation.
- Preserve maintainer-only release authorization, existing gates, and release package behavior.

## Out of scope
No new catalog facts, gameplay behavior, release publication, automatic merges, weakening of checks, or changing GitHub branch-protection settings. Owner must configure branch protection/ruleset separately to require CI.

## Rollback
Revert implementation PR; retain existing release authorization and data integrity gates.
