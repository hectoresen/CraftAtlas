# Design — unified release-readiness checks

## Root cause
The validator derives allowed source relation keys as (itemID, professionKey, spellID), but tracks observed keys as (itemID, spellID, professionKey). The set difference therefore reports all 8,455 relations as missing even though every relation is present.

## Implementation
Correct only the observed key order in scripts/build_materials.py. Keep schema, duplicate and missing-relation protection. Add a focused regression test removing one use row and verifying exactly one missing relation is detected.

Centralize the release checks in scripts/validate_release_checks.sh, using `set -euo pipefail` and four existing commands: repository foundation validation, material tests, generated-catalog --check, package tests. Update both .github/workflows/ci.yml and .github/workflows/publish-release.yml to call the same script under Python 3.11.

## Safeguards
Never remove or relax tests. Preserve existing owner-only gates. Do not change source data, generated Lua, or packaging. GitHub repository ruleset for required CI check is an owner-managed repository setting, not accessible to the integration.

## Verification
PR and push CI pass; traceability passes after owner-approved specification. Manually publish release after implementation merge.
