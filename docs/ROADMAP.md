# Roadmap — maintenance baseline (2026-11-18)

**Status: MAINTENANCE MODE.** Feature development is paused until further notice. Current official release: [v0.4.0](https://github.com/hectoresen/CraftAtlas/releases/tag/v0.4.0) (2026-11-17). The repository's development .toc still reads `0.2.0-dev`; this is intentional and not the shipped release version.

## Implemented functionality on main

- Source-backed localized material tooltip annotations, user-configurable native AddOn options and movable/restorable minimap launcher.
- Materiales: functional name/itemID search, profession filtering, grouped collapsible profession tree, native details, recipe usage and pagination.
- Fabricables: recipe/output search, profession filter, source-backed ingredient quantities, native detail, Shift-click client-native chat links, cross-navigation and Back.
- Opt-in **global per-character** craft tracking (persistent across recipe changes and `/reload`), native per-material and weighted total status bars, optional conditional open-bank counts; progress is recipe-scoped, not a multi-recipe planner.
- Independent bounded catalog preparation indicators, coalesced background refresh, English/Spanish localization and owner-only release packaging workflow.

These source-level capabilities have matching code and offline tests. Owner-reported real-client checks include the previously broken open-bank Hojaplata count and the global tracking toggle across recipe switches/reload (2026-11-16). Neither confirmation establishes exhaustive client compatibility or live recipe-dataset accuracy. Refer to [README](../README.md), [testing](TESTING.md) and [architecture](ARCHITECTURE.md) for limits.

## Maintenance-only priorities

1. Fix reproducible bugs and incompatibilities discovered on supported Forever builds.
2. Maintain release, CI, security and documentation correctness; preserve licensed data provenance.
3. Gather optional missing Forever evidence without retroactively marking historical `NOT RUN` checks as passed.
4. Reconcile OpenSpec lifecycle under the established SDD/owner-approval protocol; retain blocked specs until genuine acceptance or a separately approved scope adjustment.

## Deferred ideas — not committed work

Catalog refreshes from newer licensed datasets, full multi-recipe planning, learned-recipe indicators, favorites, dependency chains, auction integration and new explorer views are **not planned in maintenance mode**. Reconsider only after explicitly resuming feature development and following a new owner-approved OpenSpec proposal.

## OpenSpec closure rule

An implemented change is not automatically accepted and archived. [The evidence ledger](OPENSPEC_STATUS.md) distinguishes implementation, owner observation, automated tests, historical supersession, and archival eligibility. There are no current open PRs/issues as of the maintenance audit, but active OpenSpec folders retain incomplete historical tasks and evidence. Do not claim all specs closed.
