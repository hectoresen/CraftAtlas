# Restyle material tooltips

## Why

CraftAtlas currently appends a muted heading and a comma-separated list of consuming professions to known material tooltips. Use the default expanded presentation from Profession Reagents so players can scan individual professions and recognize them by their native icons.

## In scope

- Add a blank separator, a native gold heading (`Used in:` in enUS and `Utilizado en:` in esES), and one white row per consuming profession with a 14 × 14 native profession icon when available.
- Match the reference's alphabetical presentation in the effective CraftAtlas language while keeping the existing itemID lookup and verified profession memberships.
- Preserve native item lines, the existing guarded item-tooltip integration, and idempotent rendering when the client refreshes or reuses a tooltip.
- Add targeted offline regression tests and verify visual parity on a recorded Forever build before claiming in-game acceptance.

## Out of scope

- Profession Reagents' compact mode, visibility and icon toggles, commands, settings, and diagnostics.
- Catalog or source-data changes, additional locales, new tooltip origins or compatibility hooks, and changes to explorer panels or spell tooltips.

## Compatibility, provenance and rollback

The reference is Profession Reagents 1.0.0 from `sebasgrios/profession-util` at commit `66555a5c5c1d4ad3d3c2f8d5d0982beb2b23a4b8`. Its code is MIT-licensed. Implement the layout in CraftAtlas with client-provided textures and CraftAtlas data. The reference's icon identifiers are presentation metadata from Forever's `SkillLine.SpellIconFileID` at build `1.60.1.70938`. The design lists the identifiers for the ten shared professions. Reference source inspection establishes the intended appearance. Actual client behavior and texture rendering require manual verification.

The main risk is that the extra rows expose stale or duplicate content in reused tooltips or affect tall tooltips in compact viewports. Exercise native tooltip reuse, missing icons and long lists before approval of the implementation. Target the next release that includes the accepted implementation. Reverting the implementation PR restores the current layout without data or settings migration.
