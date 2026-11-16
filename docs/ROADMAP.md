# Roadmap — capabilities and evidence gates

## Current source: `0.2.0-dev`

**Implemented on main (merged PR #36):** source-backed tooltip profession annotations, Spanish/English localization and language preferences, draggable minimap launcher, **Materiales** name/itemID search and profession filters, collapsible profession-grouped Materiales list and paginated native crafting-use rows, **Fabricables** output/recipe search and ingredient/quantity detail, native item/spell hover, cross-view navigation, Back, reusable native widgets and owner-only manual release tooling.

**Maintainer validation:** PR #23 and PR #25 *previous* UI changes reported tested and accepted in Forever. The owner has tested and provided in-game screenshots of the evolving grouped-tree redesign, but has not recorded comprehensive acceptance of the final changes across all locales, scales and interactions. The exact build and a complete per-tooltip-origin test matrix have not been collected; the beta import has not been reconciled with every current live-realm recipe.

## Prior milestones (implemented, not future promises)

- Repository foundation and first playable item-tooltip implementation (`0.0.0` / `0.0.1` development milestones).
- Expanded 593-item catalog, 10 consuming professions and 237 multi-profession materials.
- Source-backed 8,455 material-use relations and 2,506 unique recipe keys.
- Native Materiales/Fabricables exploration, recyclable visible result rows, grouped material tree and vertical use pagination, searchable recipes, full ingredient detail, reusable widgets and cross-navigation.
- Manual release workflow with runtime-only packaging, SemVer and shared validation.

These are **features of the current development branch** and do not imply separate tagged releases.

**Approved performance change being implemented (not yet on main):** independent genuine active-view preparation progress, coalesced redraws, cache-generation invalidation and optional `/craftatlas perf` counters, tracked by OpenSpec `optimize-catalog-loading-and-progress`. No measured FPS improvement is claimed; final real-client validation is pending.

## Future work (not implemented)

- Reconcile imported recipe/material data with a newer licensed Forever build, record live mapping exceptions and improve coverage.
- Record exact game build, per-origin item tooltips, locale and UI-scale regression matrix, and release-quality compatibility evidence.
- Optional inventory material quantities, user-known recipe checks and craftability indicators.
- Optional favorites, crafting lists/dependency chains, auction integration and additional reusable explorer views.
- Security/maintainer branch protection and approved workflow/process improvements where applicable.

Future behavior changes follow an owner-approved OpenSpec proposal and separate implementation PR. Avoid claiming complete live data coverage or promising game-client support unsupported by recorded tests. See [OpenSpec](../openspec/README.md), [testing](TESTING.md) and [data model](DATA_MODEL.md).

## OpenSpec evidence and synchronization

Canonical specs are being reconciled for accepted material lookup, localization, minimap access and the stable profession registry under owner-approved lifecycle policy. Historical changes with incomplete source coverage, initial 30-item acceptance, or unrecorded client build/per-origin checks remain open rather than being falsely archived. Read [OpenSpec status](OPENSPEC_STATUS.md) for change-by-change evidence. Future agents must not duplicate a version-specific feature summary in `openspec/config.yaml`; current behavior remains in [README](../README.md).

## Contributor governance and CI quality

The two active owner-configured `main` rulesets (2026-11-16) require independent contributor approval and non-bypassable `repository-validation` / `traceability` checks, with a PR-only administrator exemption for the review rule. The implementation of approved OpenSpec change `harden-contributor-pr-governance` adds explicit Lua 5.1 syntax/regression jobs, owner CODEOWNERS review requests, stronger documentation evidence tests and cross-agent review instructions. **This feature remains implementation-branch-only until merged**. The owner must add the two new Lua check names after successful main integration. See `docs/GITHUB_SETTINGS.md`. The actual contributor-vs-owner merge-eligibility matrix remains untested.

**CI cost control:** pure OpenSpec PRs perform spec/SDD validation, pure Markdown PRs perform lightweight policy/format checks, while code and mixed PRs run the full Lua 5.1, catalog, Python and release gates. Stable required checks remain present; failures in change classification remain blocking.
