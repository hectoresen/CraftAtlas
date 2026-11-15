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


## Unreleased — material explorer (PR #14; game QA pending)

- Added functional local material search, profession filters, result list and detail pane to native CraftAtlas settings frame.
- Added localized name/icon cache handling with numeric itemID fallbacks, and `/craftatlas <itemID>` entry.
- Added search regression tests and a one-time, owner-authorized combined spec/implementation SDD exception specific to PR #14.
- Tooltip-to-detail click remains gated pending safe Forever-client API verification; no recipe database was added.

- Follow-up fix for PR #14 after in-game screenshot: corrected names and native icons via Forever `C_Item` APIs and asynchronous data requests; suppressed placeholder-only browse rows, added loading states and visually separated rows. Added adapter regression test. Game retest pending.


## Unreleased — reagent-only reverse recipe-use explorer (implementation candidate)

- Compiled 8,455 MIT-source-backed recipe input relations across the 593 reagent catalog, preserving spell IDs, profession, exact quantities and available crafted outputs.
- Constrained browse/search to catalog entries with verified input uses; kept crafted item 14044 because Leatherworking genuinely consumes it for recipe 19093.
- Added a native grouped/scrollable recipe section in the material details; native item and spell/recipe tooltip support with compatibility fallbacks, no fabricated rarity.
- Added Python provenance/consistency tests, pure Lua recipe lookup tests and game-tooltip mocks. Forever-client QA pending; no stable release claim.

## Unreleased — native paginated recipe cards and close fix

- Replaced duplicated vertical recipe/output rows with **six** compact native-WoW-style icon cards per page; show output icon/name when available, with recipe fallback and profession/required quantity.
- Added localized Previous/Next controls, page index/total and disabled boundary states. Preserve page during item-info refresh; reset on selecting another material.
- Rebound native top-right window X to explicitly hide CraftAtlas, raise the button above decorative frames, and clean up search/menu/tooltip state.
- Added offline domain, native-frame and close-button regressions; **in-game QA remains pending**.

## Unreleased — Recipe Explorer and shared native UI

- Added Materials/Recipes subnavigation, recipe name/product search, profession filters and full recipe input/output detail with original WoW item hover.
- Compiled **2,506** unique recipes and all their source-backed ingredients from the same 8,455-use MIT beta snapshot, with conflict/duplicate detection and deterministic checks.
- Reused a single native search box, profession selector, recycled result rows and pager across views, preserving Materials behavior, native X and six-card consuming-recipe grid.
- Added bidirectional Material ↔ Recipe navigation and bounded Back history, plus enUS/esES strings and regression tests. Real Forever-client QA is still pending.

### PR #25 layout correction after user screenshot

- Renamed user-visible Recipes view to **Fabricables / Craftables** and its material usage section to **Se utiliza para fabricar / Used to craft**, leaving source identities and enchantment behavior unchanged.
- Fixed profession-label/section-title overlap, aligned Back within the top navigation and hid it when there is no history.
- Increased normal-height result rows from five to **seven** with a shared geometry helper, and added a Lua layout regression for row capacity and material-detail spacing.
