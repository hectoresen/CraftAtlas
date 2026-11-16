# Changelog

### Typed agent branch discipline and PR check discovery (merged PR #50)

- Define CLI-safe lowercase OpenSpec IDs with type-local three-digit sequences and deterministic `SPEC/TYPEddd-slug` / `TYPE/ddd-slug` branches.
- Preserve historical approved OpenSpec changes while blocking new arbitrary branch names, malformed typed IDs and sequence collisions.
- Require agents to verify all mandatory PR check runs appear after creating a PR and perform a single safe metadata retry if absent.


This file summarizes implemented source changes. Historical PRs are not active feature proposals; source data coverage and test evidence remain separate questions.

## [Unreleased source changes] — `0.2.0-dev`

- Fix SDD validation for approved legacy proposals #43, #44 and #46 that merged after the naming policy rollout, and parse PR declarations with Windows line endings.

### Minimap button interaction

- Keep the minimap button on the circular edge throughout a drag and restore the release angle on reload.
- Open the explorer on the first ordinary left-click after a drag and show separate localized open and move instructions on hover.

### Native chat linking and craftable detail icon (implementation awaiting owner merge)

- Added Shift + left-click support for client-native item/spell links in clickable Materiales/Fabricables rows, uses, ingredients and detail icon/title surfaces; normal navigation remains unchanged.
- Added guarded native chat insertion that never manufactures link markup or sends chat messages.
- Removed the duplicate native quickslot overlay from the Fabricables detail icon; final visual/Forever compatibility tests remain NOT RUN.


### OpenSpec governance (merged PR #47)

- Prepare complete canonical spec synchronization and lossless dated archive in the same implementation PR, eliminating routine follow-up archive PRs.
- Keep incomplete acceptance or `NOT RUN` client checks explicit: archive remains blocked and active artifacts preserved.
- Add SDD regression coverage for archival provenance, canonical requirement retention, and malicious/partial archive rejection.



### Contributor governance and validation (merged PR #42)
- Added separate Lua 5.1 parsing and isolated Lua regression jobs to pull-request CI, with hard failures instead of silent gaps.
- Added CODEOWNERS review requests and updated agent/contributor documentation to require verifiable documentation-sync evidence before functional PRs.
- Hardened OpenSpec governance exceptions for the owner-approved CI/security change and documented the active independent review and CI branch rulesets.
- Replaced a previously malformed Markdown-as-Lua test fixture with a deterministic Lua 5.1 foundation smoke test; no addon gameplay behavior changes.


### First-use catalog preparation (merged PR #38; current development source, release/client evidence separate)
- Added independent, native-header percent indicators for bounded local Materiales/Fabricables metadata preparation. Percent measures attempted work, not completed client name resolution or remote synchronization. Existing unresolved-name warnings remain.
- Coalesced background name-cache redraw requests and cached filtered searches with query, profession, effective-locale and data-generation invalidation, preserving immediate user searches and navigation.
- Added guarded timer fallback, in-memory operational counters accessible only through `/craftatlas perf`, and fake-timer/progress regressions. No gameplay FPS improvement is claimed without in-client comparison.

### Material and craftable exploration
- Added **Materiales**: functional material name/itemID search, profession filter, native detail view, and profession uses.
- Added **Se utiliza para fabricar** with paginated vertical source-backed native rows (replacing six-card tiles), native item/spell hover, result icons, exact required quantities and clickable navigation.
- Added **Fabricables** (formerly labeled Recetas): searchable/filterable index of 2,506 unique profession+spellID recipes, full source-backed ingredient quantities and crafted/non-item outputs, with a native item icon border and collapsible ingredient section displaying the true count.
- Added cross-navigation between materials and craftables, bounded **Volver / Back** history, independent view state, and reusable native search/filter/result/pager widgets.
- Added source-backed grouped profession tree with distinct matching counts, expand/collapse, search-time auto-expansion and restoration, shared bounded rows, native inline search-clear X (shown only for nonempty text) with localized tooltip, dedicated gold profession-group disclosure dividers, compact icon/name material entries with highlighted selection, collapsible icon-labeled profession-use and crafting-use sections, optional client item metadata, four-per-page profession icons in normal detail panes (compact two-per-page fallback), vertically centered title, discreet installed-version footer and prepared 0.2.0-dev source manifest, restored classic red WoW buttons, Blizzard-native language/profession dropdowns with guarded fallback and native expand/collapse artwork, improved hierarchy and responsive viewport scaling. The locally stamped release SemVer is shown only for official installed packages; development versions remain hidden. Preserved separate top-right X close and both explorer tabs.

### Catalog, compatibility and localization
- Restyled material tooltips to show a gold localized heading and one alphabetical, icon-labeled row per consuming profession, with a text fallback when native art is unavailable.
- Replaced the historical six-item preview with **593** distinct source-backed reagents, **10** consuming professions, **237** multi-profession items and **8,455** reagent-use relationships.
- Compiled both reverse material→recipe uses and recipe→all-ingredients indices from one pinned MIT LibProfessionDB Forever 1.60.1.69977 beta source; preserved attribution, deterministic generation and inconsistency checks.
- Added guarded Forever `C_Item` name/icon loading, item/spell tooltips and enUS/esES translations. No guarantee of complete current-live-realm data coverage.

### Distribution and quality
- Added manual, owner-only GitHub Releases, installable runtime-only ZIPs, SemVer increments and prerelease handling, with shared PR/release validation checks.
- Added OpenSpec/SDD approval gating, Python generator/package tests and Lua domain/UI regressions. Automated checks alone do not certify client behavior.

### Evidence and remaining limitations
- Maintainer reported earlier addon UI tested and accepted in Forever, including PR #23 and #25. The owner has manually checked successive Materiales and Fabricables redesigns in Forever and supplied screenshots, but has not recorded full acceptance of the final four-profession layout, centered title, release-version footer, latest progress-bar appearance or the exact client build. The exact game-build number, comprehensive tooltip-origin matrix and individual live-realm recipe verification are not recorded.
- No crafting automation, inventory availability, player-known recipe validation, dependency graph or external syncing is implemented.

## Historical milestones

- **0.0.1** — first playable itemID-based profession tooltip, language settings and minimap/settings controls; expanded by subsequent work.
- **0.0.0** — repository bootstrap, Lua scaffold, CI and OpenSpec governance; not a playable release.

A tagged GitHub Release is not implied by these development headings. See [roadmap](docs/ROADMAP.md) for future work.

### Unreleased — contributor governance

- Updated the OpenSpec traceability policy to honor owner APPROVED reviews of contributor-merged specification PRs, removing the owner-only merger dependency (approved spec #58).
- Added tests for review validity and corrected contributor/agent guidance. GitHub code-owner review enforcement still requires administrator verification; release publishing remains owner-only.
