# Design — licensed catalog refresh

## Input provenance

Use LibProfessionDB **Forever** branch/source at a pinned official release (currently v1.10.1, live build 1.60.1.70938) as the primary candidate, recording each file/hash and MIT attribution. Cross-check later build information (e.g. ReagentSkillTips v1.7.0, Forever 1.60.1.71037) separately. Do not merge unrelated-game-version datasets or silently replace trusted recipe output/source facts with a secondary projection that lacks them. The 2,517 source-recipe count includes classifications different from CraftAtlas's old reagent-driven catalog and cannot be equated without normalizing identity and empty-reagent support.

## Model

- Recipe key: `professionKey:spellID`; reagent identity: numeric `itemID` with integer `quantity > 0`. Preserve output itemID and action kind independently from reagent set.
- Extend the local source model to include **recipes with zero reagents** without manufacturing artificial ingredient relations. The `Recipes.lua` generation must no longer derive its entire recipe universe exclusively from `recipe-uses.source.json`; `RecipeUses.lua` and `Materials.lua` remain projections of genuinely nonempty reagent relationships.
- Add optional, source-attributed fields for camp classification, required skill/difficulty, teaching items, trainers/vendors/quests and vendor cost/faction only if supported by verifiable licensed source evidence. Avoid treating lack of metadata as `false` or `0`; distinguish unavailable from confirmed empty.
- Include two new registry identities `HERBALISM` and `SKINNING` when source-backed recipes are present, with enUS/esES labels and appropriate role/category semantics. Existing 10 identities must remain stable.
- Retain non-item, no-output, and client-cache-missing recipe identities in a safe fallback representation. Names are advisory, not primary identity.

## Reconciliation algorithm

1. Preserve existing source snapshot baseline and generate a canonical normalized tuple stream by (professionKey, spellID, itemID) plus recipe-level output/kind/source metadata.
2. Parse pinned upstream dataset deterministically with no runtime network dependency. Enforce license/source/build annotations, duplicate handling, integer range/quantity validation and output consistency.
3. Produce machine-readable **add, remove, modify, ambiguous** rows at recipe, reagent, profession and metadata levels. Require separate proof (source record + build + rationale) for disappearing recipes, missing reagents and output/kind reversals.
4. Check set equality between positive ingredient tuples in recipe source and both material-relation JSON and generated Lua views. A recipe with zero reagents must appear in `Recipes.lua` but *not* falsely appear as a consumed material.
5. Produce stable JSON coverage/report counts, including total source recipes vs those with reagents; mark all unverified Forever-client entries as unverified, not silently 'verified live'.
6. Use baseline source as rollback reference. Rebuild `Data/Materials.lua`, `Data/RecipeUses.lua`, `Data/Recipes.lua`, `Data/Professions.lua` and `Data/coverage-report.json` only from reviewed sources.
7. Test current Domain/RecipeCatalog.lua search/ingredient methods, recipe detail and Materiales filters for zero-reagent recipes, camping registry and preexisting tracking; use native fallbacks for missing item/spell data.

## Evidence boundary

The previously observed five quantities and one recipe are **candidate changes**, not accepted solely on ReagentSkillTips. The 27 emptied entries and disappeared spell 1251750 are mandatory manual-review exceptions. If the primary upstream build and newer secondary build disagree, record both and select an explicit verified outcome; preserve prior values when evidence is inconclusive. The source refresh must not claim comprehensive live realm coverage.

## Compatibility and operational risk

A full source-model refresh affects generator, validation, catalog identity, user-facing profession filters and recipe detail; maintain account/character SavedVariables behavior and Lua 5.1 syntax. Potential risks: client-cache unknown names for new spells, incompatible output semantics for scrolls/enchantments, empty-reagent actions, duplicate recipe IDs across professions, metadata size/startup overhead. Keep core recipe metadata bounded and lazy where practical. Rollback by reverting the implementation PR and regenerate from the prior immutable baseline.
