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

## Testing and release validation

Offline Lua tests exercise nil/unknown/known/multi-profession IDs, deterministic ordering, multiple recipe links, invalid settings, locale fallback and idempotent repeated callbacks with adapters mocked. Data validation scripts test source rights/provenance, target coverage, duplicate detection and reproducibility. Include static lint if compatible toolchain available.

Manual Forever matrix: startup, inventory/bags, known unknown and multi-profession, ES/EN, manual override, reload, repeated hover, errors, performance under rapid inspection. Record exact Forever build and screenshot/issue evidence. Packaging includes only the playable addon directory and required data; smoke-test its installed form.

## Decisions intentionally deferred

Bank/merchant/auction/global-tooltip integration; recipe graph schema and UI; full/custom coverage; future import automation; caching beyond proven bottlenecks. Such features require their own approved OpenSpec changes and target milestones.

## Rollback

Disable/remove the addon directory to restore stock game behavior; SavedVariables remain inert. No character data or online state is modified.
