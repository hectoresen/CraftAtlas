# Proposal: Native material explorer and usable search

## Why
CraftAtlas 0.1.0-dev displays material-consuming professions in tooltips, but its 560x340 settings shell has an intentionally non-editable search placeholder, one General navigation entry and a Coming soon message. Players cannot browse the existing 593-item offline catalog or inspect an item directly. The maintainer approved a V3 interactive layout concept with more room for search, submenus, results and details; this proposal describes the intended in-game behavior, not the web prototype as production code.

## What changes
- Evolve the existing /craftatlas and minimap settings shell into a compact material explorer, using client-native frames, textures, controls and fonts; retain the **single** centered CraftAtlas header title, header search on the left and Auto/esES/enUS selector on the right.
- Increase frame dimensions moderately from 560x340, fit within the viewport, and allocate approximately 38% of content width to the scrollable results pane and 62% to material details. Leave room for readable controls and empty states.
- Replace the decorative search control with a real, immediately updating search by known material name and numeric itemID, with deterministic handling when client-localized names are unavailable.
- Add a compact consuming-profession filter, matching-count indicator, clear-search icon control and compact item rows with available client item icons; preserve search/filter selection while inspecting results.
- Show one selected material's icon, name or safe itemID fallback, itemID and all known consuming professions from the existing offline catalog. Explain unavailable recipe/quantity information rather than presenting fabricated recipes.
- Offer a safe opt-in direct entry to the material detail from supported item tooltip interactions; do not alter ordinary tooltip behavior or use unsupported/protected frame hooks.
- Preserve the existing language preference, slash command, draggable minimap button, and tooltip annotations; extend localization for all new strings.

## In scope
- Native WoW/Forever material explorer frame and layout, limited settings/preferences access without duplicating the header language selector.
- Offline search index and client-provided name/icon resolution using stable itemIDs (including cache-miss/loading/unknown behavior); profession filtering and results/detail state.
- Supported tooltip-to-detail interaction with an explicit safe fallback when a direct interaction is unavailable.
- Mocked domain/UI-adapter tests, manual Forever-client matrix, documentation and localized copy.

## Out of scope
- Recipe lookup, recipe quantities, production chains, shopping lists, favorites, auction prices, external data services, live-server catalog completeness or broad new material mappings.
- Broad changes to the SDD validator, governance lifecycle, historical OpenSpec status or openspec/specs/. A **one-time, owner-authorized exception for this PR #14** is included to allow spec + runtime code in the same PR while keeping all other PRs' two-phase rules unchanged.
- Invented or redistributed third-party fonts/textures when built-in client resources suffice.

## Compatibility and data caveats
The catalog contains 593 distinct itemIDs and known profession relations sourced from a bounded MIT-licensed Forever beta snapshot. It does not provide a verified complete server material universe or a guaranteed full localized material-name index. The implementation must not claim all names resolve or all materials are covered. UI APIs, tooltip clickability, item icons and safe item-name retrieval must be checked on the actual Forever client; no unrelated gameplay behavior may be hooked.

## Risks, mitigations and rollback
- UI template differences: reuse available native frame templates where verified, fail safely and keep slash/minimap access.
- Client item cache: show a numeric-ID fallback and never report absence as a confirmed negative when a search cannot resolve names. Avoid expensive bulk synchronous queries or per-frame scanning.
- Tooltip interactions: only expose a deliberate entry action through supported APIs; if the client cannot safely support it, retain ordinary tooltip annotation and log the unmet acceptance gate, without insecure frame modification.
- Layout: check clipping at representative UI scales/resolutions and long localized strings.
- Rollback: restore previous settings-only shell and placeholder UI while retaining existing tooltip, saved preferences and minimap behavior.

## Approval gate
@hectoresen explicitly authorized spec and functionality together in existing PR #14 on 2026-11-15. This is a **single-PR combined proposal plus implementation** exception, narrowly restricted to PR #14 and change ID `improve-material-explorer-ui` by the SDD validator. The user also approved the V3 UX layout. Runtime behavior still requires code review, automated checks and real Forever client smoke tests before any release. Only @hectoresen merges or releases.
