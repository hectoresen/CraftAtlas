# Make craftable tracking a global per-character display preference

## Motivation

The owner reported that enabling Track crafting for one Fabricables result resets the checkbox when another result is selected. The approved feat001 implementation deliberately persists a **per-recipe** toggle, but actual desired UX is an explorer-wide opt-in tracking mode: once enabled, progress should update as the selected recipe changes without repeated toggles.

This is a **behavior change that contradicts the immutable, owner-approved feat001 per-recipe SHALL scenarios**, so it requires its own approved OpenSpec change before implementation. Do not silently modify the existing feat001 scope or archive either change as if this behavior were already approved.

## Proposed behavior

- One Track crafting / Seguir fabricación toggle is shared by all Fabricables recipes **for the current character**, initially disabled.
- Enabling it immediately shows the selected recipe's Material progress. Selecting another recipe preserves the checked toggle and updates progress for that recipe. Disabling it hides Material progress regardless of which recipe is selected, while leaving original Ingredients intact.
- Persist the toggle across closing/reopening the addon and UI reload for the same character. A different character maintains an independent toggle.
- Keep Include bank as a separate per-character display option; bank freshness rules, adapter, inventory updates, individual bars, aggregate unit-weighted progress, native UI and click/navigation behavior stay as approved in feat001.
- Migrate safely from the unmerged implementation branch's `CraftAtlasDB.craftTracking[character][recipeKey]` experiment: do not automatically enable global tracking just because a previously tracked recipe exists. New global choice defaults off until explicitly toggled; avoid misidentifying characters. The old per-recipe keys may be ignored without destructive migration.
- Preserve enUS/esES labels and the native Blizzard visual requirements. No batch planner, character-wide stock sharing, or catalog changes.

## Scope and handoff

This proposal must be owner-merged first. Apply it in its **own separate implementation PR** after the underlying feat001 material-tracking implementation has merged; a spec-only proposal does not authorize modifying the feature implementation PR #55 to contradict feat001. If #55 remains blocked, keep it blocked and coordinate the implementation order. Repository-wide one-change-per-implementation-PR safeguards must remain intact.

## Validation

Lua 5.1: single character toggles across multiple recipe keys, reload, character isolation, opt-out, absent player identity, Include bank independence and native UI update. Forever: switch between two Fabricables with tracking enabled/disabled, bank mode, reload and at least two characters if available. Record exact build or mark unrun cases NOT RUN. Documentation-sync and same-change archive rules apply. No code changes in this proposal PR.
