## Context

`Data/Recipes.lua` and `Domain/RecipeCatalog.lua` already expose optional `requiredSkill` and `teachingItemID` by profession key and spell ID. The pinned Forever catalog has 2,335 positive skill values and 1,889 teaching-item IDs across 2,518 entries. The Alchemy entry with spell ID 2329 has a required skill of 15 and no teaching-item metadata. Missing acquisition metadata cannot establish that a teaching item is unnecessary.

`Features/Settings/RecipesView.lua` owns the selected detail header and the existing native checkbox. The current code obtains display names and icons through client adapters and tracks observed ingredient quantities separately.

## Goals / Non-Goals

**Goals:** Display the two requirements with independent visual states and move the checkbox within the header. Preserve readable labels and interactions in both supported locales and at supported UI scales.

**Non-goals:** Expand the catalog, infer unsupported acquisition facts, change SavedVariables, repair the existing tracker or evaluate all conditions for crafting.

## Decisions

1. **Use the selected recipe's catalog identity and facts.** Reuse `requiredSkill` and `teachingItemID` where present. A teaching-item ID proves an associated teaching item in the pinned source. It does not establish that the item is the only learning path. Use an observed matching trainer offer as evidence of an item-free path. Use the recipe-required label for catalog entries with a teaching item unless such an alternative is verified. Omit the label if the catalog lacks a teaching-item ID. Borrowed Classic acquisition records alone do not establish a Forever path.
2. **Read character data in Infrastructure.** Verify the selected recipe's skill line and rank with the Forever client, using the numeric skill-line ID where available. Candidate reads include `C_TradeSkillUI.GetProfessionInfoByRecipeID` and `C_TradeSkillUI.GetRecipeInfo` by recipe spell ID. Accept the skill rank and learned flag only when they describe the current character and the selected recipe or profession. Check closed and open profession windows, and unavailable, initializing, linked, or mismatched profession data. Treat no trustworthy result as unknown. Use confirmed profession absence as unmet when a positive skill requirement is known. Do not open game panels to collect data.
3. **Render two independent requirements and align the tracking row.** Compare the verified character rank to the catalog threshold. Show the localized crafting level and numeric minimum in every state when the minimum is known. Give the level its own full-width row below the profession. Convey the comparison through color alone. For a displayed recipe requirement, use one localized label and let the verified learned flag determine its color. Both fields use dark gray for met, dark red for unmet, and neutral for unknown. Use the same icon, title, subtitle, level, lower identifier and first divider positions and native fonts in both tabs. Materials uses the client item type for the subtitle and the client item level below it. Clear a row when its metadata is missing. Put the recipe-required label on the right of the Craftables subtitle row. The lower left shows only `ID <spellID>`. Anchor the right-hand checkbox to the vertical center of that ID line. Keep the fields hidden with no selection. Verify that the title, ingredients, tooltip and chat-link targets, and checkbox hit regions stay usable.
4. **Refresh only the selected detail.** Read on initial detail display and recipe selection. Refresh on supported client notifications for known recipe or skill changes and when corresponding profession data becomes ready. Confirm event behavior in Forever and avoid scans of the full catalog or per-frame polling. Keep current character observations in session memory if a cache is needed, and invalidate on profession or character context changes.
5. **Make a local test build.** Package the implementation checkout as a privately installable ZIP using the repository runtime manifest. Record the actual build, locale, scale and observed results separately from automated tests.

## Risks / Trade-offs

- Forever's documented profession APIs may depend on the currently loaded profession data. If a closed-window read cannot be trusted, show the static facts and a neutral status until a trustworthy observation is available.
- The catalog does not supply full acquisition coverage. When a teaching item is unavailable in the catalog, the recipe requirement is omitted.
- Dark text on the existing panel needs a visual check. Use short localized labels and test the dark shades against the panel at standard and compact widths.
- The v0.4.3 evidence ledger records a tracking persistence retest failure before an unverified follow-up fix. Verify the checkbox after moving it and record any reproduced baseline failure separately.
