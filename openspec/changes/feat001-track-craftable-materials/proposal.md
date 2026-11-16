# Track craftable material availability

## Why

CraftAtlas already explains which ingredients a craftable requires, but does not answer the player's immediate follow-up: how many of those ingredients are in the current character's bags, how many are missing, and whether bank contents can help. The native profession window only addresses the character's own profession workflow; CraftAtlas can inspect recipes regardless of learned profession.

## Scope

- Add a small, opt-in **Track crafting / Seguir fabricación** checkbox to a selected Fabricables recipe detail. Tracking is off by default, scoped to the **current character** and durable across reloads. Selecting another recipe changes the displayed tracker but retains each recipe's chosen tracking state.
- When tracking is enabled, display a compact secondary **Material progress / Progreso de materiales** subsection beneath **Required materials / Materiales necesarios**. Show each required ingredient's needed quantity, currently held quantity, missing quantity and individual progress. Show one aggregate progress bar for the selected recipe.
- Read **current-character bag** counts through a guarded Forever client adapter. Offer an independent **Include bank / Incluir banco** checkbox only if bank counts are supported with trustworthy semantics. Distinguish bag and bank amounts rather than silently merging them; report unknown/stale bank data explicitly and never treat unsupported or stale bank data as confirmed inventory.
- Refresh shown quantities in response to inventory/bank lifecycle events while the tracker is visible, without per-frame loops or repeated full-catalog scans. Keep the UI responsive at compact scales, and do not disrupt existing recipe details, paging, native Shift-click links or navigation.
- Scope progress to **one craft of the selected recipe**, using the catalog's existing ingredient itemIDs and quantities. 100% means all known required ingredient quantities are covered by trustworthy observed stock; it never claims the character learned the recipe, has the right profession, or can craft it.

## Exclusions

No automatic crafting, multi-recipe planning, global shopping lists, alt inventories, account bank, auction data, ingredient substitution, recursive ingredients, mail/guild bank, or assumed stock from another session. Do not add a second profession window or an always-on inventory scan.

## Dependencies and compatibility

Catalog ingredients already exist in `Domain/RecipeCatalog.lua`; the detail and collapsible material section exist in `Features/Settings/RecipesView.lua`. Add the smallest pure coverage calculator and guarded API adapter under the existing architectural boundaries. Use established SavedVariables patterns and enUS/esES text. Warcraft Wiki documents `C_Item.GetItemCount(itemInfo, includeBank, ...)` for the Forever client API, but whether the **bank-only portion** remains reliable when the bank is closed requires actual in-game verification; treat that as an acceptance gate, not a source-backed guarantee.

No source dataset change, network dependency or migration of old recipe IDs. Failure or absent optional APIs must fall back to bag-only or unavailable state, never invented inventory.

## Verification and lifecycle

Test arithmetic, character isolation, toggles, missing API, stale bank semantics, event refreshes and compact layout with isolated Lua 5.1 tests. Manual Forever tests must record exact client build, locale, empty/partial/complete inventory cases, bank open/closed, UI scale, browsing/paging and reload persistence. Unexecuted evidence is NOT RUN, not passed.

The earlier `fix001-native-chat-links-and-recipe-icon` remains a separate active OpenSpec change with historical acceptance evidence to regularize. The current SDD lifecycle protects a single change per implementation PR. **Do not quietly archive `fix001` in the implementation PR for this feature or alter governance validation as an unrelated shortcut**; regularize it through an explicitly authorized process separately.

No code changes are included in this proposal PR.
