# Roadmap and release gates

## Current state — v0.1.0-dev (15 November 2026)

**Implemented and reported working in-game by the maintainer:** numeric itemID → consuming professions on supported item tooltips, multiple profession matches, enUS/esES localization, account-wide language preference, `/craftatlas` settings, draggable minimap button and an offline 593-item index. **A functional material explorer was implemented in PR #14.** The new recipe-use detail is being implemented in a separate approved follow-up; live-client QA is pending.

The exact client build and per-origin tooltip test results have not been captured in this repository. Imported relations are traceable to a beta database, not all independently verified against the current live realm; do not advertise comprehensive material coverage.

## Milestones

| Version | State / scope |
| --- | --- |
| 0.0.0 | Completed: repository foundation, CI, OpenSpec, agent protocol and Lua scaffold |
| 0.0.1 | First playable baseline: implemented and tested in-game by maintainer; no standalone stable release tagged |
| 0.1.0-dev | Current source: broader offline catalog (593 itemIDs / 10 professions), tooltip annotations, settings, minimap button; runtime reported working, data coverage not fully live-verified |
| 0.2.0 (planned) | Improve live-client data coverage, auditing, diagnostics, optimizations and user experience |
| 0.3.0 (candidate) | Functional offline material search and profession filters (merged in PR #14) |
| 0.4.0 (implementation candidate) | View source-backed consuming recipes, input quantities and crafted outputs; actual Forever QA pending |
| 0.5.0 (planned) | Reverse crafting/dependency exploration |
| 1.0.0 (planned) | Stable release after acceptance, precise compatibility declaration and audited coverage |

Scope and dates are not commitments. Future behavior changes require reviewed OpenSpec deltas. Releases require owner approval, the applicable tests, updated documentation and release notes. The existing approved [v0.0.1 change](../openspec/changes/add-first-playable-material-tooltips/specs/) guarantees inventory/bag tooltips; other item origins must be separately evidenced before making support guarantees.

### UI refinement after PR #21

The approved follow-up implements six-card recipe pagination (three columns, two rows at typical resolutions), native hover information, and a working close button. It does not implement the separate searchable recipe catalog/tab; that remains a possible future change. Real Forever-client visual/close QA is pending.

## Recipe Explorer milestone (implementation candidate)

Shared native Materials/Recipes navigation, reusable UI controls, unique recipe-by-profession/spellID index, searchable recipe results, ingredient/output details, cross-navigation and native tooltips are implemented in a PR candidate. The existing Materials viewer remains the default. **Not yet verified in the Forever client.** Further wishlist features (owned reagent counts, recipe craftability, favorites, auction data and crafting trees) remain future work and are not included.
