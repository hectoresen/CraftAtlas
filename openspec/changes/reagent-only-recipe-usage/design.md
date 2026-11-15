# Design: reverse material-to-recipe browsing

## Existing state
PR #14 is merged into main. The catalog `materials.source.json` contains 593 reagent itemIDs with one or more profession relations, each including `recipeIDs` in most imported records; `Materials.lua` is a compiled, flattened itemID → profession-keys map and **does not contain recipe IDs or output IDs**. `scripts/build_materials.py` imports reagent IDs using the MIT LibProfessionDB Forever beta `reagents` blocks, but discards ingredient quantities in `extract_reagent_facts` and does not generate a reverse recipe index or crafted outputs. `Settings.lua` currently renders an explicit recipe-unavailable message.

## Domain model and source integrity
- Define `RecipeUse` fields: `reagentItemID` (numeric), `recipeSpellID` (numeric), `professionKey` (stable key), `quantity` (positive integer if proven), `outputItemID` (numeric or null), `recipeKind` (item/enchant/other/unknown), `source` (pinned reference), `clientBuild`, `rights`, `verification`.
- Source JSON holds original attribution; a deterministic generator produces compact Lua `reagentItemID -> RecipeUse[]` and a documented source/evidence report. Deduplicate same recipe/profession/reagent, preserve cross-profession usage, and never infer input status from `craftedItemId` or the item's equippability.
- Record confirmed recipe reagent entries through source-parsed `reagents` including exact input count. Resolve `craftedItemId` or output from licensed source when available, otherwise retain `nil`. Do not copy an unlicensed source or assume the newer source fixes completeness.
- Audit example `Capa de paño cenizo` by its actual numeric itemID and source recipe relation, not by Spanish display name alone. If it is genuinely consumed by a later craft, retain it; if its inclusion is only because it is a craft output or corrupted mapping, exclude it and create a regression fixture.
- Keep an explicit classification for `verified reagent`, `unverified/pending`, and `output-only` where evidence exists. The public browse/search defaults to verified reagents only; a missing record is unknown, not conclusively output-only.

## Runtime components
- `Domain/RecipeUsage.lua`: deterministic pure lookup by numeric itemID, grouping, ordering and dedup.
- `Data/RecipeUses.lua`: generated compact offline local recipe index; no runtime HTTP, mandatory third-party library or huge JSON load.
- `Infrastructure/RecipeInfo.lua`: optional client adapter for C_TradeSkillUI recipe info/schematic/output API when available and safe; fall back to source-based row details. Source-backed rows must not require profession learned/open.
- `Infrastructure/ItemInfo.lua`: reuse current async names/icons; native `GameTooltip:SetHyperlink` or supported item-link APIs for real item rarity/statistics, with explicit guarded fallback for missing info.
- `Features/Settings/Settings.lua`: preserve main window and filters, add a scrollable secondary recipe list to right pane with profession section headings, recipe name/icon, output name/icon/quality only if verified, quantity, count and loading/unavailable state. Use existing native WoW UI controls/frames, not a redesigned skin.
- `Localization`: enUS/esES and auto-mode fallback.

## Tooltip contract
- Output item hover: use the game's normal item tooltip API and actual item hyperlink/itemID, so Blizzard owns rarity, stats and localized text. Never emulate item quality with arbitrary CSS or infer rarity from icon tint.
- Recipe hover: show native spell/recipe tooltip **only where a supported Forever API permits it**; otherwise use a localized factual text tooltip with known recipe/profession fields and mark the native tooltip as unsupported until verified. No protected-frame hooking or fabricated gameplay stats.
- OnLeave resets tooltip ownership, on list scroll or selection change removes stale tooltip; avoid duplicate hooks.

## Suggested practical UX extensions in the same scope
1. Per-material number of verified recipe uses grouped by profession and a compact output icon/name row. 
2. Quantity consumed by each recipe when known; omit or label unknown quantities, never default to `1`.
3. Deterministic alphabetical/grouped ordering and simple scrollbar for long lists; no extra full-window tabs.
4. Distinct `craft output` vs `non-item action` vs `unresolved output` states.
5. Show only confirmed relations in default browse to avoid false confidence; preserve global coverage disclaimer in docs.

## Client validation
Use source-owned (or licensed pinned upstream) data for offline availability independent of the current character; do not rely on UI opened profession, spellbook known recipes or character skill. Verify `C_TradeSkillUI.GetRecipeInfo`, `GetRecipeOutputItemData`, item tooltip APIs and possible spell tooltip APIs **in actual Forever**; document unsupported paths and alternative. Cache asynchronous item info and prevent stale hover. Test recipe outputs including no item produced.

## QA
- Static/provenance tests: recipe count, valid IDs/quantities, no output-only inclusions, no orphan reagent IDs, stable generated output, license, source pin and build applicability.
- Pure Lua tests: material with 0/1/many usages, duplicate recipe, two professions, unknown output, crafted object also used as reagent, false-positive crafted item, stable order.
- UI/mock tests: native item tooltip, recipe tooltip fallback, item cache missing, enUS/esES, selection/scroll, no long frame stalls.
- In-game: screenshot-identified cloak, blackmouth oil and a known multi-use material; item-link/stat/rarity hover, recipe without output item, quantity correctness, name loading, scroll and scale. Real build and pass/fail/not-run must be captured.
