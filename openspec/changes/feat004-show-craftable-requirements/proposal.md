## Why

Craftables lists ingredient quantities and offers progress tracking. The selected recipe detail does not show the trade skill needed or whether the current character has learned the recipe. The refreshed Forever catalog available in v0.4.3 already provides optional skill and teaching-item facts that the detail can use.

## What Changes

- Align both detail tabs. In Materials, show the title, item type, item level, and `ID <itemID>` in that order. Use client-provided type and level when available.
- Show the minimum profession skill as `Crafting level <level>` in enUS and `Nivel de fabricación <level>` in esES under the profession name. Use the same level text in dark gray when met, dark red when unmet, and neutral when unverified.
- Show one localized recipe-required label on the upper right for catalog entries with a teaching item, unless the game confirms an item-free path. Color it dark gray when learned, dark red when unlearned, and neutral when the learning state is unavailable.
- Replace the secondary recipe metadata with the exact format `ID <spellID>` and align the existing Track crafting checkbox with that row on the right.

## Capabilities

### New Capabilities

- `craftable-requirements`: Show source-backed profession and recipe requirements and the current character's observed progress toward them.

### Modified Capabilities

None.

## Impact

- Affects the selected Materials and Craftables detail headers and their enUS/esES labels.
- Reuses the pinned catalog shipped with v0.4.3 and guarded, read-only Forever APIs. Covers missing catalog metadata and unavailable or mismatched character data.
- Keeps Track crafting as the existing per-character ingredient tracking preference and preserves the detail's materials and navigation.
- Out of scope: catalog refreshes, tracking persistence fixes, inventory checks for recipe items, crafting automation, and an overall craftability indicator.
