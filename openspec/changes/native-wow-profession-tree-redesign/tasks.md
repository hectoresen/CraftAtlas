# Tasks — native WoW profession-tree redesign

## Owner approval
- [x] A1 Owner reviews and merges this spec-only PR. No implementation code until approved.

## Pure domain and list behavior
- [x] B1 Implement deterministic, unit-tested profession-key grouping over the **existing filtered** material index, with per-group distinct counts and stable itemID identity.
- [x] B2 Add expand/collapse with search auto-expansion, explicit user collapse precedence, clearing-search state restoration and preservation across navigation.
- [x] B3 Implement reusable row virtualization/scrolling for group headings and materials without duplicating actual material identities or global counts.

## Native UI
- [x] C1 Build an adaptable native WoW shell inspired by the supplied image (dark frame, restrained gold separators, native textures/fonts; graceful Forever fallback).
- [x] C2 Keep real search, profession filter, language selection, Materiales/Fabricables tabs, Back and close/minimap/slash workflows functional.
- [ ] C2a Approved spec calls for a **broom icon**. Current code instead uses an inline native clear `X` explicitly requested by the owner after in-game review. The behavior, localized tooltip, and tests are implemented, but the *original icon requirement* is superseded in practice and not met as written. Formal OpenSpec reconciliation is still required; do not treat this checked box as evidence of strict spec fidelity.
- [x] C2b Replace the bottom-left hardcoded `v0.1.0-dev` caption with the **installed packaged release version** read from stamped `.toc` metadata (currently `v0.1.0`); show no version for dev/unverified builds, do not query GitHub at runtime, and remove conflicting `ns.version` duplication. Test release metadata, dev metadata and unavailable client API.
- [x] C3 Redesign material detail: real item icon/name/itemID, consuming-profession section and readable source-backed recipe **rows** with quantity, hover, navigation and pagination/scroll.
- [x] C4 Show optional client-derived item metadata only when available; never hardcode demo item level/type/rarity or profession icons.
- [x] C5 Redesign Fabricables detail consistently, preserving full ingredients, quantity, non-item output fallback and cross-navigation.
- [ ] C6 Ensure responsive small-window UI, clear selected/hover/collapsed states and no overlapping labels, buttons or pager.

## Verification and documentation
- [x] D1 Add Lua domain grouping, filtering, multi-profession and collapse/restore tests.
- [ ] D2 Add native UI mocks and layout/scroll/state tests for both views, cache misses and no duplicated frames/hooks.
- [ ] D3 Run repository/SDD/OpenSpec/test gates and document all executed vs NOT RUN checks.
- [ ] D4 Verify in the real Forever client across normal/small UI scales, both languages, long lists, no-data and long recipe examples; record exact client build and screenshots or explicitly leave NOT RUN.
- [x] D5 Invoke `skills/documentation-sync/SKILL.md` **before** implementation PR and update README, architecture, installation, testing, roadmap, changelog and relevant OpenSpec tasks.
- [ ] D6 Create separate implementation PR with merged owner spec PR number and frozen approved paths; await owner verification and merge.
