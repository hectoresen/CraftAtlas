# Proposal: Native WoW profession-tree explorer redesign

## Why

The current CraftAtlas implementation has a functional Materiales/Fabricables explorer, searchable flat results, a profession dropdown, six-card material uses and cross-view navigation. The maintainer supplied a new **visual target** (a WoW-inspired dark stone/metal frame, profession-grouped collapsible list, large item header, clear section bars and horizontal recipe entries) and asks to redesign CraftAtlas to resemble it.

The reference image is a **conceptual visual reference**, not a screenshot of currently running CraftAtlas. Some text in it ("Recetas", type "Hierba", item level, example recipe names), decorative textures, profession counts, and colors are illustrative and must not be treated as verified runtime data. The currently approved UX terminology remains **Fabricables** and **Se utiliza para fabricar**. This change must not silently remove the already functional craftable explorer, exact quantities, search, profession filter, back navigation or native tooltips.

## Proposed outcome

Create a cohesive **native WoW Forever** visual shell with the look and information hierarchy of the reference, while preserving existing capabilities and license/data boundaries.

### In scope

- A restrained dark Blizzard/Classic-style frame with native supported fonts, accents, buttons, scrollbars, icon borders and section dividers. Keep it responsive at the game's supported UI scales; use client-bundled textures where available and a clean native fallback where not.
- Persistent header with **CraftAtlas** title, real search field/clear action, language choice, explicit **Materiales / Fabricables** tabs and Back/history. Preserve minimap and slash-command entry.
- Replace the flat left-hand Materiales list with a **profession-grouped, collapsible tree** whose group headers show source-backed matching material counts. Users can expand/collapse groups, select an item and use the global profession filter.
- A material used by multiple professions may appear under more than one expanded profession; selection remains keyed by **numeric itemID** and the detail is identical in every group. Group counts refer to per-group distinct materials, never the global deduplicated total. Search/filter apply **before** grouping; expand matching groups deterministically, while respecting explicit user collapses.
- Right-hand **material detail** based on the reference: native icon and client-provided item name, itemID, a profession-uses section, a separate **Se utiliza para fabricar** section with **vertical, clickable recipe rows** (not the reference's hardcoded demo names/counts), and optional item metadata ONLY when provided by supported WoW APIs. Use paging/scrolling for large recipe lists; retain exact per-material quantities, output fallback, hover and navigation.
- Right-hand **Fabricables detail** in the same design language: actual output/non-item action, profession, spellID, all known ingredient IDs/quantities, clickable ingredient navigation and native tooltip fallback. Preserve search by known spell/output names and ID, profession filtering and cross-navigation.
- Preserve saved language preferences, unknown/cached item fallbacks, native close/reopen behavior, bounded Back history and state restoration for each view. Keep localization enUS/esES and non-duplicated UI components.
- Extract pure, deterministic grouping/tree-visibility logic to `Domain/`, reusable native tree/section/recipe-row widgets to `Features/Settings/Shared/`, and add measured layout geometry regression tests.
- Perform the mandatory `documentation-sync` audit before the **implementation** PR: README current features, architecture, installation, testing, roadmap, changelog and OpenSpec tasks updated where affected.

### Explicitly out of scope

- Importing new item/recipe data, claiming full current-live realm coverage, character recipes or craftability, inventory counts, auction prices, auto-crafting and new dependencies.
- Bundling screenshots, proprietary game artwork or external fonts as runtime assets. The supplied visual reference guides layout only; use game-provided UI resources, not redistributed extracted textures.
- Changing `openspec/config.yaml`, `AGENTS.md`, protected governance/CI workflows, release policy, or data-generator semantics.
- Shipping hardcoded profession counts, item level, item type or quality colors when the game API does not provide those facts.
- Removing the Fabricables tab because the concept image shows only the Materiales detail.

## UX and compatibility risks

1. **Groups with many entries** can cause expensive frame creation or poor scrolling. Build a flattened visible-node projection, reuse rows, preserve scroll offset and avoid full-list rebuilds on every render.
2. **One reagent in multiple groups** means multiple list occurrences, but never duplicated domain identities or fabricated global counts. Group headers use only actual filtered material→profession relations.
3. **Screen size/UI scale** varies on Forever: design height-aware scrolling, fixed safe header/footers, minimum size fallback and no overlapped headings/pagers.
4. **Client API differences**: item info, native templates or tooltip APIs may be missing; use supported fallbacks and record exact live-client test results. The reference's richly rendered icons/metadata are not a guarantee.
5. **Search and collapsed state** interact: document an unambiguous rule, test search clearing/restoration and ensure relevant matches are discoverable.
6. **Performance / ownership**: asynchronous item names and group counts must not block UI; no extra runtime network calls.

## Delivery

Two-PR OpenSpec flow: this **spec-only PR** is reviewed/merged by @hectoresen. Only then open an implementation PR within the frozen `sdd-scope.json`, with tests, docs, screenshots from the actual Forever client and explicit `NOT RUN` evidence if unavailable. Owner exclusively merges and publishes.
