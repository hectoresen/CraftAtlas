# Proposal: Recipe Explorer and reusable native UI

## Why
The maintainer accepted the six-card paginated material explorer implemented in PR #23 and wants a second top-level view, **Recetas / Recipes**, with the same native WoW visual language and the same searching, profession filtering, list/detail layout, pagination and tooltip behavior. Future views must reuse actual Lua UI controls rather than copy-paste Settings.lua or RecipePanel.lua.

## Scope
1. **Preserve existing Materials:** The current explorer becomes a selectable "Materiales / Materials" view with its current material search, profession filters, consuming-recipes grid, native item/spell tooltips, language persistence, minimap/slash navigation and working X.
2. **Add Recipes:** A "Recetas / Recipes" sibling view with a name search, profession filter, compact selectable recipe rows and an adjacent detail of recipe output, consuming profession, *all known required reagent materials* and exact source-backed quantities. Each ingredient and result uses native icons and mouseover tooltip; native item quality/stats come only from the client. For enchantment/non-item and unknown outputs, show explicit differentiated fallback.
3. **Reuse controls and state contracts:** Extract a common CraftAtlas shell and native, configurable shared components for search, profession selection, recycled results list, detail layout, pagination, item/recipe cards and hover presentation. No duplicate UI implementation or dependencies on external frameworks.
4. **Navigation:** Switch between Materials and Recipes without losing each view's own search/filter/selection/page state. Selecting a material from a recipe opens its Materials detail; selecting a consuming recipe from Materials opens that recipe's Recipes detail. Provide a predictable return path and avoid recursive navigation loops.
5. **Data:** Generate an independent *runtime index of unique recipes* (recipe spellID + professionKey), preserving every source-backed ingredient itemID and exact quantity. Build deterministically from the existing licensed, pinned `recipe-uses.source.json` (8,455 reagent→recipe uses / 593 itemIDs); do not duplicate or hand-edit a parallel database. Support optional output itemID and recipe kind. No assumption about current character's profession training.
6. **Quality:** Complete enUS/esES and auto mode, pure Lua domain tests, WoW API adapters/mocks, deterministic generator/data validation, documentation and real Forever client QA gates.

## Invariants
- A material is a recipe **input**, not simply an item a profession can craft. Existing source-backed classification remains untouched.
- A recipe identity is `professionKey + spellID`, not the produced itemID; multiple recipes may produce one output, and one recipe can consume multiple reagents.
- Search for recipes matches **spell/recipe name and crafted output item name** when supplied by WoW; numeric spellID remains a fallback. Searching a profession name is supported, alongside the profession selector; do not claim full search results until client cache names are loaded.
- Recipe detail lists **all verified inputs**, not the material selected in the previous view only. Input count is not inferred; missing data is marked incomplete, not fabricated.
- The current source is a pinned **Forever 1.60.1.69977 beta** MIT snapshot, not a guaranteed live realm catalog. Recipe known/craftable status, quality and player inventory are **not** inferred from this index. Do not list unrelated recipes merely because they produce items within the same profession.
- Avoid network calls, mandatory dependencies, protected UI hooks and fake quality coloring. The WoW client owns names, icons and native tooltips.

## Explicitly excluded
Character learned/unlearned filtering, stock in bags, shopping lists, crafting buttons, skill difficulty ranking, economic/profit calculations, auction integration, full dependency trees, favorites, source refresh to a different build and changing SDD governance or workflows.

## Implementation strategy
Perform the implementation after owner review/merge of this spec PR in a **single code PR** with internal checkpoints: (A) proven component extraction without behavior drift, (B) generated unique recipe index and domain filtering, (C) Recipes view with cross-navigation, (D) tests, docs and client QA. The spec itself remains spec-only under existing SDD two-PR contract. A separate UX proposal is required for material behavioral changes outside this scope.

## Risks, evidence, rollback
Shared UI refactor risks breaking the now-approved Materials screen (including paging, X, locales, tooltips). Name caches may resolve asynchronously; recipe spell IDs may not correspond to available client spell info or its tooltip. Long localized ingredient names and many inputs can overflow frames. Mitigate with per-view independent state, a temporary default Materials view, fixed native frame shells, scalable/recycled rows, guarded API adapters, clear missing-data states and regression scenarios for the current UI. Owner to test in actual Forever on different UI scales. Rollback must restore previous Materials-only layout without altering the source catalog.

## Approval
This PR proposes only OpenSpec artifacts; no Lua implementation. @hectoresen alone reviews/merges. After the spec PR is merged, implementation proceeds in its own PR referring to the actual approval PR number. PR #14's one-time combined exception cannot be reused.
