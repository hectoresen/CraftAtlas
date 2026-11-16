# Roadmap — capabilities and evidence gates

## Current source: `0.2.0-dev` (main, 2026-11-16)

**Implemented on main (PRs #36, #38 and #40 merged):** source-backed tooltip profession annotations, Spanish/English localization and language preferences, draggable minimap launcher, **Materiales** name/itemID search and profession filters, collapsible profession-grouped Materiales list and paginated native crafting-use rows, **Fabricables** output/recipe search and ingredient/quantity detail, native item/spell hover, cross-view navigation, Back, reusable native widgets and owner-only manual release tooling.

**Maintainer validation:** PR #23 and PR #25 *previous* UI changes reported tested and accepted in Forever. The owner has tested and provided in-game screenshots of the evolving grouped-tree redesign, but has not recorded comprehensive acceptance of the final changes across all locales, scales and interactions. The exact build and a complete per-tooltip-origin test matrix have not been collected; the beta import has not been reconciled with every current live-realm recipe.

## Prior milestones (implemented, not future promises)

- Repository foundation and first playable item-tooltip implementation (`0.0.0` / `0.0.1` development milestones).
- Expanded 593-item catalog, 10 consuming professions and 237 multi-profession materials.
- Source-backed 8,455 material-use relations and 2,506 unique recipe keys.
- Native Materiales/Fabricables exploration, recyclable visible result rows, grouped material tree and vertical use pagination, searchable recipes, full ingredient detail, reusable widgets and cross-navigation.
- Manual release workflow with runtime-only packaging, SemVer and shared validation.

These are **implemented in `main`** and do not imply that every source change has a separate tagged release or passed complete in-game acceptance.

**First-use preparation optimization merged in PR #38:** independent active-view preparation progress, coalesced redraws, cache-generation invalidation and optional `/craftatlas perf` counters are implemented in `main`. The progress bar is a bounded real-work indicator, not a frame-rate benchmark or proof of resolved item names. Final layout verification and measured FPS comparison in the actual Forever client remain **NOT RUN**.

## Approved but not yet merged into main

- OpenSpec `fix001-native-chat-links-and-recipe-icon` (#52 merged) is being implemented separately: native Shift-click chat links on clickable item/recipe entities and removal of a duplicate Fabricables detail icon overlay. Client confirmation is pending; do not describe it as shipped until its implementation PR merges.

## Current implementation candidate (pending owner review)

- Owner-approved `feat001-track-craftable-materials` spec #54: opt-in current-character ingredient tracking in Fabricables, with bags-only reliable baseline and bank freshness gating. Code exists on the implementation branch, **not yet merged or client-accepted**. It is not the previously discussed multi-recipe planner.

## Future work (not implemented)

- Reconcile imported recipe/material data with a newer licensed Forever build, record live mapping exceptions and improve coverage.
- Record exact game build, per-origin item tooltips, locale and UI-scale regression matrix, and release-quality compatibility evidence.
- Optional inventory material quantities, user-known recipe checks and craftability indicators.
- Optional favorites, crafting lists/dependency chains, auction integration and additional reusable explorer views.
- Evidence-backed closure of outstanding UI/client acceptance matrices, including the latest progress-bar layout and material-tooltip restyling. Governance rulesets, Lua CI checks, atomic OpenSpec archival and agent branch naming are already merged; improve them only through newly approved changes.

Future behavior changes follow an owner-approved OpenSpec proposal and separate implementation PR. Avoid claiming complete live data coverage or promising game-client support unsupported by recorded tests. See [OpenSpec](../openspec/README.md), [testing](TESTING.md) and [data model](DATA_MODEL.md).

## OpenSpec evidence and synchronization

Canonical specs include the accepted material lookup, localization, minimap access and profession registry contracts, plus capabilities synchronized by subsequent approved and archived governance changes. The status ledger distinguishes historical gaps from already-merged source. Historical changes with incomplete source coverage, initial 30-item acceptance, or unrecorded client build/per-origin checks remain open rather than being falsely archived. Read [OpenSpec status](OPENSPEC_STATUS.md) for change-by-change evidence. Future agents must not duplicate a version-specific feature summary in `openspec/config.yaml`; current behavior remains in [README](../README.md).

## Contributor governance and CI quality

The two active owner-configured `main` rulesets (2026-11-16) require independent contributor approval and non-bypassable `repository-validation` / `traceability` checks, with a PR-only administrator exemption for the review rule. Owner-merged PR #42 added Lua 5.1 syntax/regression jobs, CODEOWNERS review requests and evidence-based contributor documentation checks. Both `lua-compatibility` and `lua-regressions` are now required by the active CI ruleset, alongside `repository-validation` and `traceability`. See `docs/GITHUB_SETTINGS.md`. The actual contributor-vs-owner merge-eligibility matrix remains untested.

**CI cost control:** pure OpenSpec PRs perform spec/SDD validation, pure Markdown PRs perform lightweight policy/format checks, while code and mixed PRs run the full Lua 5.1, catalog, Python and release gates. Stable required checks remain present; failures in change classification remain blocking.

## OpenSpec archival process modernization

Merged proposal #45 and implementation #47 established a transactional archive workflow for future implementation PRs. It makes canonical spec synchronization and dated same-change archiving part of the code PR when mandatory evidence exists. Missing client tests remain explicit blockers; historical partially accepted OpenSpec changes must not be mass-archived. There is no third routine archival PR and no owner-approval bypass.

## Agent naming governance

Approved proposals #48/#49 and merged implementation #50 enforce deterministic typed OpenSpec IDs and Git branches, with #49 correcting change IDs to lowercase for official CLI compatibility. Existing in-flight/historical proposals remain unchanged. Agent PR creation now includes a mandatory four-context Actions check-run discovery gate; missing checks receive one safe metadata retry, never forged PASS. This is governance/agent development and does not change CraftAtlas's in-game functionality.

### Contributor governance correction (approved spec #58)

The implementation of `chore001-require-owner-review-not-merge` changes SDD to require real @hectoresen review on contributor-authored merged specifications rather than requiring the owner to perform every merge. Contributor PR approval will also be enforced by GitHub's code-owner review ruleset **after manual administrator configuration and verification**. Until that setting is confirmed, do not claim the mandatory-review policy is enforced on all PRs. No runtime or release authorization changes.
