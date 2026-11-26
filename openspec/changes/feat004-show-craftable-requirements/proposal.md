## Why

Craftables lists ingredient quantities and offers progress tracking. The selected recipe detail does not show the trade skill needed or whether the current character has learned the recipe. The refreshed Forever catalog available in v0.4.3 already provides optional skill and teaching-item facts that the detail can use.

## What Changes

- Add the minimum profession skill below the profession name in the selected Craftables detail.
- Add recipe acquisition and learned status to the upper right of that detail. Distinguish a known teaching item, a confirmed alternative source, and an unknown acquisition method.
- Show the skill and learned-status fields independently in dark gray when met and dark red when unmet. Show a neutral state when the relevant data is missing.
- Move the existing Track crafting checkbox below the recipe status on the right.

## Capabilities

### New Capabilities

- `craftable-requirements`: Show source-backed profession and recipe requirements and the current character's observed progress toward them.

### Modified Capabilities

None.

## Impact

- Affects the selected Craftables detail and its enUS/esES labels.
- Reuses the pinned catalog shipped with v0.4.3 and guarded, read-only Forever APIs. Covers missing catalog metadata and unavailable or mismatched character data.
- Keeps Track crafting as the existing per-character ingredient tracking preference and preserves the detail's materials and navigation.
- Out of scope: catalog refreshes, tracking persistence fixes, inventory checks for recipe items, crafting automation, and an overall craftability indicator.
