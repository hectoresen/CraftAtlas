## Unreleased — licensed reagent import (DRAFT)

- Imported 593 unique ingredient itemIDs and mappings across 10 profession recipes from MIT-licensed LibProfessionDB beta 1.60.1.69977 (237 multi-profession materials).
- Preserved recipe spell IDs and per-relation provenance with upstream license attribution.
- Added an offline source importer, expanded tests and stricter release QA gate.
- **Not full live coverage**: newest Forever 1.60.1.70938 snapshot and real-game validation remain pending.

## Unreleased — v0.1.0 development candidate

- Extensible localized profession registry and relation-level catalog evidence.
- Reproducible coverage report without unjustified completeness claims.
- Centralized modern item tooltip adapter with localization-aware refresh and nil/zero enum support.
- Offline data/Lua tests; expansion and client compatibility still require verification.

## Unreleased — v0.0.1 implementation candidate

- Added an offline Lua material-profession lookup and a small evidence-linked
  starter catalog (six researched IDs; 30 required before release).
- Added modern item-tooltip adapter pending live Forever API testing.
- Added native-style settings panel and `/craftatlas` with Spanish/English
  selection and SavedVariables persistence.
- Added deterministic data generator, data tests and mocked Lua behavior tests.
- **Not a release:** no complete dataset or real-client acceptance yet.

# Changelog

This project uses [Semantic Versioning](https://semver.org/) after the first release. Pre-1.0 milestones are planned feature boundaries, not guarantees.

## [Unreleased]

### Added
- Project initialization: contributor and agent contracts, OpenSpec workflow, documentation, CI and addon folder layout.

## [0.0.0] — Foundation

This milestone is a **nonfunctional scaffold**; no working in-game functionality is released.
