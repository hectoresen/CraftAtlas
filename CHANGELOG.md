# Changelog

This file summarizes implemented source changes. Historical PRs are not active feature proposals; source data coverage and test evidence remain separate questions.

## [Unreleased] — `0.2.0-dev`

### Material and craftable exploration
- Added **Materiales**: functional material name/itemID search, profession filter, native detail view, and profession uses.
- Added **Se utiliza para fabricar** with paginated vertical source-backed native rows (replacing six-card tiles), native item/spell hover, result icons, exact required quantities and clickable navigation.
- Added **Fabricables** (formerly labeled Recetas): searchable/filterable index of 2,506 unique profession+spellID recipes, full source-backed ingredient quantities and crafted/non-item outputs, with a native item icon border and collapsible ingredient section displaying the true count.
- Added cross-navigation between materials and craftables, bounded **Volver / Back** history, independent view state, and reusable native search/filter/result/pager widgets.
- Added source-backed grouped profession tree with distinct matching counts, expand/collapse, search-time auto-expansion and restoration, shared bounded rows, native inline search-clear X (shown only for nonempty text) with localized tooltip, dedicated gold profession-group disclosure dividers, compact icon/name material entries with highlighted selection, collapsible icon-labeled profession-use and crafting-use sections, optional client item metadata, four-per-page profession icons in normal detail panes (compact two-per-page fallback), vertically centered title, discreet installed-version footer and prepared 0.2.0-dev source manifest, restored classic red WoW buttons, Blizzard-native language/profession dropdowns with guarded fallback and native expand/collapse artwork, improved hierarchy and responsive viewport scaling. The locally stamped release SemVer is shown only for official installed packages; development versions remain hidden. Preserved separate top-right X close and both explorer tabs.

### Catalog, compatibility and localization
- Replaced the historical six-item preview with **593** distinct source-backed reagents, **10** consuming professions, **237** multi-profession items and **8,455** reagent-use relationships.
- Compiled both reverse material→recipe uses and recipe→all-ingredients indices from one pinned MIT LibProfessionDB Forever 1.60.1.69977 beta source; preserved attribution, deterministic generation and inconsistency checks.
- Added guarded Forever `C_Item` name/icon loading, item/spell tooltips and enUS/esES translations. No guarantee of complete current-live-realm data coverage.

### Distribution and quality
- Added manual, owner-only GitHub Releases, installable runtime-only ZIPs, SemVer increments and prerelease handling, with shared PR/release validation checks.
- Added OpenSpec/SDD approval gating, Python generator/package tests and Lua domain/UI regressions. Automated checks alone do not certify client behavior.

### Evidence and remaining limitations
- Maintainer reported earlier addon UI tested and accepted in Forever, including PR #23 and #25. The owner has manually checked successive Materiales and Fabricables redesigns in Forever and supplied screenshots, but has not recorded full acceptance of the final four-profession layout, centered title and release-version footer or the exact client build. The exact game-build number, comprehensive tooltip-origin matrix and individual live-realm recipe verification are not recorded.
- No crafting automation, inventory availability, player-known recipe validation, dependency graph or external syncing is implemented.

## Historical milestones

- **0.0.1** — first playable itemID-based profession tooltip, language settings and minimap/settings controls; expanded by subsequent work.
- **0.0.0** — repository bootstrap, Lua scaffold, CI and OpenSpec governance; not a playable release.

A tagged GitHub Release is not implied by these development headings. See [roadmap](docs/ROADMAP.md) for future work.
