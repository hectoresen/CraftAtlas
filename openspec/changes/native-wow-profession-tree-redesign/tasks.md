# Tasks — native WoW profession-tree redesign

## Owner approval
- [ ] A1 Owner reviews and merges this spec-only PR. No implementation code until approved.

## Pure domain and list behavior
- [ ] B1 Implement deterministic, unit-tested profession-key grouping over the **existing filtered** material index, with per-group distinct counts and stable itemID identity.
- [ ] B2 Add expand/collapse with search auto-expansion, explicit user collapse precedence, clearing-search state restoration and preservation across navigation.
- [ ] B3 Implement reusable row virtualization/scrolling for group headings and materials without duplicating actual material identities or global counts.

## Native UI
- [ ] C1 Build an adaptable native WoW shell inspired by the supplied image (dark frame, restrained gold separators, native textures/fonts; graceful Forever fallback).
- [ ] C2 Keep real search, profession filter, language selection, Materiales/Fabricables tabs, Back and close/minimap/slash workflows functional.
- [ ] C2a Replace the current search-clear textual `X` with a native WoW **broom icon**, with localized tooltip, empty-query disabled state, fallback icon and tests confirming click clears the active view's query without losing other view state.
- [ ] C2b Replace the bottom-left hardcoded `v0.1.0-dev` caption with the **installed packaged release version** read from stamped `.toc` metadata (currently `v0.1.0`); show no version for dev/unverified builds, do not query GitHub at runtime, and remove conflicting `ns.version` duplication. Test release metadata, dev metadata and unavailable client API.
- [ ] C3 Redesign material detail: real item icon/name/itemID, consuming-profession section and readable source-backed recipe **rows** with quantity, hover, navigation and pagination/scroll.
- [ ] C4 Show optional client-derived item metadata only when available; never hardcode demo item level/type/rarity or profession icons.
- [ ] C5 Redesign Fabricables detail consistently, preserving full ingredients, quantity, non-item output fallback and cross-navigation.
- [ ] C6 Ensure responsive small-window UI, clear selected/hover/collapsed states and no overlapping labels, buttons or pager.

## Verification and documentation
- [ ] D1 Add Lua domain grouping, filtering, multi-profession and collapse/restore tests.
- [ ] D2 Add native UI mocks and layout/scroll/state tests for both views, cache misses and no duplicated frames/hooks.
- [ ] D3 Run repository/SDD/OpenSpec/test gates and document all executed vs NOT RUN checks.
- [ ] D4 Verify in the real Forever client across normal/small UI scales, both languages, long lists, no-data and long recipe examples; record exact client build and screenshots or explicitly leave NOT RUN.
- [ ] D5 Invoke `skills/documentation-sync/SKILL.md` **before** implementation PR and update README, architecture, installation, testing, roadmap, changelog and relevant OpenSpec tasks.
- [ ] D6 Create separate implementation PR with merged owner spec PR number and frozen approved paths; await owner verification and merge.
