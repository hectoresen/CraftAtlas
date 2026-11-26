## Why

A production report describes collapsible profession categories remaining visible after a profession is selected in Materiales. On main, `FilterMaterials` already returns unique itemIDs for the selected consuming profession, but the results pane groups those IDs by every associated profession. A shared reagent can therefore appear under other professions, and a collapsed section can hide a valid result.

## What Changes

- Selecting a specific profession in Materiales will show one scrollable list of matching reagents. Each itemID appears once as a top-level item row with its existing icon and name.
- The selected profession and the current query continue to constrain the same results. Choosing All professions restores the collapsible tree and its applicable expansion choices.
- The change is limited to the Materiales results pane and its view state. The item detail, Fabricables, catalog data, localization strings and saved settings are outside the behavior change.

## Capabilities

### New Capabilities

- `material-profession-filter`: Defines how Materiales presents results with a specific profession selected and when returning to the all-professions tree.

## Impact

This is a maintenance bug fix. The proposal revises the filtered presentation described in the accepted `native-wow-profession-tree-redesign` delta. The all-professions behavior from that delta remains applicable. The implementation will reuse the existing filter, bounded row pool and native interactions. It needs no new client API, dependency, data source or license. The main regression risks are stale disclosure controls on recycled rows, incorrect scroll bounds and loss of browsing state when switching modes. Rollback is a revert of the implementation PR.

The production report has no recorded Forever build. The proposal is based on source inspection. The implementation must record its own client acceptance evidence.
