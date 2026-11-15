# Changelog

CraftAtlas uses pre-1.0 development milestones; this log distinguishes **implemented runtime features**, **imported data** and **future releases**. No tagged stable release is asserted.

## [Unreleased] — current `0.1.0-dev` (15 November 2026)

### Working in Forever (maintainer-reported)

- ItemID-based tooltip annotations listing all known consuming professions for a material, including multi-profession items.
- Spanish/English localization, automatic language resolution, saved manual selection and the `/craftatlas` settings window.
- Draggable minimap button opening the same settings panel.
- Native-style General settings UI. The search-looking control is **visual only; no search functionality exists**.

### Catalog

- Replaced the historical six-item preview with **593 distinct reagent IDs** covering **ten profession sources**; 237 materials have multiple consuming professions.
- Imported a pinned MIT-licensed LibProfessionDB beta snapshot (Forever 1.60.1.69977), retaining recipe IDs, rights metadata and attribution.
- Added a deterministic source importer and coverage report. This data is **not independently reconciled with the current Forever live server**; complete coverage is not claimed.

### Distribution tooling (not a tagged release)

- Added a manually triggered GitHub Actions release workflow restricted to repository owner `hectoresen` and branch `main`.
- Added SemVer release selection, an installable runtime-only ZIP, .toc version injection during packaging, package unit tests, and GitHub prerelease handling for 0.x.
- No release is published merely by merging this tooling; real-client and catalog accuracy limitations remain.

### Maintenance

- Removed an accidentally committed Git conflict marker from `Infrastructure/MinimapButton.lua`.
- Updated documentation to reflect the currently working addon and distinguish visual placeholders from planned search.

### Outstanding release-quality evidence

- Record the exact tested Forever build and test matrix for each tooltip origin.
- Audit imported relations against newer live-client recipe data and satisfy the separate dataset release gate.

## [0.0.1] — first playable development baseline

- Implemented a Lua addon bootstrap, domain lookup, initial tooltip hook, six-material preview, persisted language settings and a settings panel.
- Subsequently superseded by the wider `0.1.0-dev` implementation; no standalone stable release is asserted.

## [0.0.0] — foundation

- Created repository structure, project documentation, OpenSpec governance, tests scaffold and CI.
- This initial milestone was non-playable.
