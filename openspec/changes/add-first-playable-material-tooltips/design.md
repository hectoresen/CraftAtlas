# Design: CraftAtlas v0.0.1 first playable addon

## Architectural approach

Use the existing lightweight modular Lua structure; no runtime external dependency. Organize responsibilities into Core (bootstrap), Domain (pure lookup), Data (offline map), Infrastructure (WoW API adapters and SavedVariables), Features/Tooltip, Features/Settings, and Localization (enUS/esES). Keep Lua 5.1 compatibility unless a verified Forever client explicitly requires a different language level.

**Data path:** inventory/bag tooltip event → adapter extracts numeric itemID → domain service reads local map → ordered set of profession keys → localization → inject a distinct line only if matches exist. Domain code must be testable without client globals.

Do not parse translated item names or tooltip descriptions. Do not query the player's learned professions. An item used in multiple recipes of one profession appears **once** for that profession.

## Compatibility discovery and bootstrap

Before integrating with client APIs, inspect the running Forever client build and record: exact interface version, addon directory used by current installation, item ID extraction APIs supported by inventory item slots, available tooltip hook mechanisms, slash-command registration, locale retrieval and SavedVariables timing. Document observed evidence in docs/TESTING.md. If a preferred modern API (e.g. TooltipDataProcessor) is absent, choose a supported isolated adapter and include a client test. Avoid blind assumptions about C_Item, item links, or expansion APIs.

The .toc loads Lua files in dependency order and declares SavedVariables for account-level language preferences. Startup must not error when settings are absent or malformed; use a known schema version to support upgrades. No global object creation beyond the namespaced addon and required WoW registration.

## Domain model

```lua
-- Shape illustration only; item mappings must be independently verified.
materials = {
  [12345] = { "ALCHEMY", "ENCHANTING" },
}
```

The example ID above is NOT a real data claim. A profession key is a stable non-localized identifier, with translated display names outside Domain/Data. Output ordering follows an explicit stable profession list, not iteration order of Lua maps. Unknown, nil, invalid or unavailable itemID yields an empty result; UI must not append a misleading line.

For v0.0.1, domain data answers "**profession consumes this item as an ingredient/component**". It does not claim that the material is gathered by the profession, that a player can currently craft it, or which recipe uses it. Only supported, verified profession keys may appear.

## Catalog source and reproducible build

Keep an editable, auditable source manifest separate from generated runtime Lua data. Each record stores numeric itemID, profession key(s), evidence/source identifier(s), date reviewed, client scope/version, and original source licensing/redistribution terms. Only permitted source material may be imported; no silent scraped proprietary addon data. Validate duplicates, invalid keys, blank provenance, unsupported IDs and deterministic ordering. Generate/ship a compact Lua table; CI ensures regeneration does not introduce drift.

Seed **≥30** distinct verified item IDs, **≥5** consuming professions, **≥2** cross-profession materials. Provide a small test fixture of known IDs, one unknown and a multi-profession example, independent of the production corpus. The data set is intentionally non-exhaustive; its limitations must be stated in release notes.

## Tooltip adapter and UI behavior

Register a hook appropriate to the tested Forever build, scoped to standard inventory and bag tooltips. Do not overwrite protected frame behavior, spam chat or create repeated lines on refresh. Deduplicate using tooltip identity, current itemID and addon line state; reset when tooltip content changes. Only append when a verified local match exists, using a localized heading such as "Used by professions" / "Usado por profesiones". Group ordered profession labels, avoid duplicate labels, respect normal tooltip layout, and do not modify item properties.

## Language and settings

Use WoW locale where supported: esES → Spanish; enUS → English; any other code → English fallback. Account-wide override stores `auto`, `enUS`, or `esES` in SavedVariables. Invalid setting reverts to `auto`. `/craftatlas` opens a minimal accessible panel showing current choice and a selector, with localized UI copy. Changing language takes effect for subsequent tooltips without game restart; setting survives `/reload` and reopening the client. Do not require chat-only interaction.


## Approved provisional interactive UI reference

The reviewed interactive reference is stored at [prototype/settings.html](prototype/settings.html). This is the **second, user-approved visual iteration**: a clean sans-serif 'CraftAtlas' header with no decorative star or badge, restrained native-inspired colors, only the functional General section, and a simple language dropdown. Preserve the **visual hierarchy, whitespace, low-density layout and absence of the removed emblem** when implementing the real WoW UI. HTML/CSS/JavaScript is a review artifact, **not** addon runtime code and SHALL NOT ship inside the WoW AddOns folder. Native font objects, frames and textures available in the tested Forever/Classic client take precedence over exact web CSS values.

## Visual language: Forever-first, Classic-compatible settings

The settings UI SHALL visually belong to the installed WoW Forever client. **Reuse the client's native frames, textures, controls, font objects and interaction conventions first**. When Forever has no distinct supported styling, fall back to native WoW Classic styling. Do not import modern web fonts, external art packs or an invented graphic identity.

- **Typography:** prefer client-supplied readable UI font objects at normal game UI scale; one clear panel title, small section headings, regular-size body text. Do not hardcode third-party font files or use ornate display typography for controls.
- **Color:** neutral dark/in-game parchment surfaces as supplied by the client, restrained warm gold for headings or selected state, native muted text for help, accessible contrast. Avoid gradients, neon accents, oversized borders and unnecessary ornament.
- **Density:** compact movable window with generous but efficient internal padding, short labels, no decorative cards, no permanently visible future-feature placeholders.
- **Structure:** a reusable navigation region with a single visible **General** category in v0.0.1 and a content region for the language selector. The navigation model SHALL support adding Search, Recipes and other sections later without redesigning the window; those sections must not be shown as operational before implementation.
- **Open/close:** `/craftatlas` opens (or focuses) the settings window; a recognizable native close button closes it. Reopening preserves the selected category. Integrate into the client's native addon settings menu only if the verified Forever API supports it, without making that entry point a release dependency.
- **Language row:** label `Language / Idioma`, simple `Auto / English / Español` selector and one concise help sentence about following the game locale. Apply immediately and persist; no Save button.
- **Accessibility:** native hover/focus behavior, visible selected state, clear mouse hit targets, readable text at default UI scale and graceful UI scaling. Do not rely on color alone for the selected option.
- **Implementation boundary:** build a lightweight reusable settings shell and a General section; do not build search/recipe functionality or add speculative UI screens.

The exact Blizzard/Forever font objects and frame templates SHALL be verified in the actual client, not guessed from other WoW versions. Screenshot acceptance evidence must be captured at ordinary UI scale.

## Testing and release validation

Offline Lua tests exercise nil/unknown/known/multi-profession IDs, deterministic ordering, multiple recipe links, invalid settings, locale fallback and idempotent repeated callbacks with adapters mocked. Data validation scripts test source rights/provenance, target coverage, duplicate detection and reproducibility. Include static lint if compatible toolchain available.

Manual Forever matrix: startup, inventory/bags, known unknown and multi-profession, ES/EN, manual override, reload, repeated hover, errors, performance under rapid inspection. Record exact Forever build and screenshot/issue evidence. Packaging includes only the playable addon directory and required data; smoke-test its installed form.

## Decisions intentionally deferred

Bank/merchant/auction/global-tooltip integration; recipe graph schema and UI; full/custom coverage; future import automation; caching beyond proven bottlenecks. Such features require their own approved OpenSpec changes and target milestones.

## Rollback

Disable/remove the addon directory to restore stock game behavior; SavedVariables remain inert. No character data or online state is modified.
