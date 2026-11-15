# Roadmap — capabilities and evidence gates

## Current source: `0.1.0-dev`

**Implemented on main:** source-backed tooltip profession annotations, Spanish/English localization and language preferences, draggable minimap launcher, **Materiales** name/itemID search and profession filters, six-card paginated material use detail, **Fabricables** output/recipe search and ingredient/quantity detail, native item/spell hover, cross-view navigation, Back, reusable native widgets and owner-only manual release tooling.

**Maintainer validation:** PR #23 and PR #25 UI changes reported tested and accepted in Forever. The exact build and a complete per-tooltip-origin test matrix have not been collected; the beta import has not been reconciled with every current live-realm recipe.

## Prior milestones (implemented, not future promises)

- Repository foundation and first playable item-tooltip implementation (`0.0.0` / `0.0.1` development milestones).
- Expanded 593-item catalog, 10 consuming professions and 237 multi-profession materials.
- Source-backed 8,455 material-use relations and 2,506 unique recipe keys.
- Native Materiales/Fabricables exploration, seven normal-height result rows, six-card use pagination, searchable recipes, full ingredient detail, reusable widgets and cross-navigation.
- Manual release workflow with runtime-only packaging, SemVer and shared validation.

These are **features of the current development branch** and do not imply separate tagged releases.

## Future work (not implemented)

- Reconcile imported recipe/material data with a newer licensed Forever build, record live mapping exceptions and improve coverage.
- Record exact game build, per-origin item tooltips, locale and UI-scale regression matrix, and release-quality compatibility evidence.
- Optional inventory material quantities, user-known recipe checks and craftability indicators.
- Optional favorites, crafting lists/dependency chains, auction integration and additional reusable explorer views.
- Security/maintainer branch protection and approved workflow/process improvements where applicable.

Future behavior changes follow an owner-approved OpenSpec proposal and separate implementation PR. Avoid claiming complete live data coverage or promising game-client support unsupported by recorded tests. See [OpenSpec](../openspec/README.md), [testing](TESTING.md) and [data model](DATA_MODEL.md).

## OpenSpec evidence and synchronization

Canonical specs are being reconciled for accepted material lookup, localization, minimap access and the stable profession registry under owner-approved lifecycle policy. Historical changes with incomplete source coverage, initial 30-item acceptance, or unrecorded client build/per-origin checks remain open rather than being falsely archived. Read [OpenSpec status](OPENSPEC_STATUS.md) for change-by-change evidence. Future agents must not duplicate a version-specific feature summary in `openspec/config.yaml`; current behavior remains in [README](../README.md).
