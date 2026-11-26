# Offline profession and craftable catalog — current source

CraftAtlas treats **numeric itemID** as the identity for materials and **professionKey + spellID** as the identity for a crafting recipe. Display names and icons come from the game client and are not used as identifiers. The same output item can be produced by distinct recipes; a crafted or equippable item can also be an input to another recipe.

## Source datasets and current scope

| Metric | Proposed pinned catalog |
| --- | ---: |
| Distinct reagent itemIDs | **592** |
| Registered consuming profession categories | **12** |
| Materials consumed by multiple professions | **240** |
| Reagent → recipe use records | **8,471** |
| Distinct profession+spellID recipe keys | **2,518** |
| Recipe entries with no reagent facts | **5** |
| Confirmed Forever vendor-source recipe records | **316** |
| Legacy discrepancies deliberately retained | **28** |

The refreshed primary dataset is a pinned MIT-licensed **LibProfessionDB ProfessionDB-v1.10.1 Forever 1.60.1.70938** copy in [ImCheesecake/Altisan at `c9425394`](https://github.com/ImCheesecake/Altisan/tree/c942539402802f2ec837cac1788f8c24fea374ed/Libs/LibProfessionDB/Data/Forever/_core), attribution to Pimptasty preserved. The older base is Forever 1.60.1.69977. **No exhaustive live Forever validation has yet been performed.** Other LibProfessionDB acquisition source types borrowed from Classic emulator data are explicitly flagged as *not confirmed for Forever*. The 316 vendor records are from Forever's own captured merchant sources.

The 12 source-backed consuming professions are Alchemy, Blacksmithing, Cooking, Enchanting, Engineering, First Aid, Fishing, Leatherworking, Mining, Tailoring, **Herbalism** and **Skinning**. The last two include source-backed camping recipes (3 each); these are *consuming* activities in this catalog, not a claim that gathering itself crafts items.

### Canonical source and projections

The **canonical source of truth** is `Data/recipes.source.json` with `professionKey:spellID` records, output item/kind, `ingredients` pairs, skill requirements and difficulty where known, teaching item, camping flag, native Forever vendor IDs/prices/faction where supported, and clearly labeled borrowed acquisition identifiers. It also contains genuine zero-reagent recipe identities.

`Data/recipe-uses.source.json` holds positive-ingredient relations only. `Data/materials.source.json` groups those relations by reagent itemID and consuming profession. `Materials.lua`, `RecipeUses.lua`, `Recipes.lua` and `Professions.lua` are deterministic outputs of `scripts/build_materials.py`; never edit those by hand. `Recipes.lua` stores compact metadata alongside the stable five core fields, allowing future recipe planning without a new runtime service. The source JSON contains more provenance than the intentionally compact runtime metadata.

`Data/reconciliation-report.json` records **every added recipe, confirmed ingredient modification and unresolved source discrepancy** against the old snapshot. Specifically, 27 spells with empty new-source reagent/output records retain their 69977 ingredients/outputs and 1251750 is retained despite being absent from the newer source. A source change is not the same as a live realm deletion.

## Local opt-in tracking state (not catalog data)

The tracking **display preference** is a single boolean per character in `CraftAtlasDB.craftTrackingEnabled[realm:character]`, independent of recipe keys. Existing per-recipe `craftTracking` records remain untouched for compatibility but never auto-enable global mode. The selected recipe still uses its own `professionKey:spellID` identity for ingredient requirements. Only explicit booleans are stored; the current bag/bank item counts are read from guarded in-game APIs and are **never persisted or treated as part of source-backed catalog coverage**. Include-bank preference is per character; a closed bank is unknown and excluded from confirmed availability. Progress is calculated against current requirements for one craft, not learned recipes, planned batches or stock on other characters. This implementation is still pending client acceptance.

## One source, multiple generated runtime views

| Artifact | Responsibility |
| --- | --- |
| `Data/recipes.source.json` | All canonical profession+spellID identities, reagents, output/kind and source-backed optional metadata, including zero-input actions |
| `Data/recipe-uses.source.json` | Strictly positive reagent relationships and quantities |
| `Data/materials.source.json` | Material itemID → consuming profession/recipe relations with provenance |
| `Data/professions.source.json` | 12 stable keys and localized labels |
| `Data/reconciliation-report.json` | Full source-to-source add/change/ambiguous record |
| `Data/Recipes.lua` | All recipes with ingredients and compact optional metadata (required skill, teaching item, camp flag, difficulty quartet, Forever vendors) |
| `Data/RecipeUses.lua` | Input itemID → consuming recipes and required quantity |
| `Data/Materials.lua` | Input itemID → profession indices/names |
| `Data/Professions.lua` | Registry/localization |
| `Data/coverage-report.json` | Source counts and explicit live-client verification limits |

The recipe identity is `professionKey:spellID`; a physical output itemID is not itself a reagent unless another recipe uses it. An enchantment without a crafted item has output ID 0, and a recipe with no ingredients still has a catalog identity but creates no material relation. No fictitious ingredient is introduced for a camp action. All positive quantities must agree between canonical source, material reverse index, recipe-use projection and generated Lua.

## Runtime behavior and constraints

`Domain/MaterialSearch.lua` filters source-backed inputs by itemID/client name and profession. `Domain/ProfessionTree.lua` then groups those unique filtered IDs in registry order; per-group counts are distinct within each profession while the global result count stays deduplicated. Expanded/collapsed visibility never changes itemID identity or the underlying licensed catalog. `Domain/RecipeUsage.lua` identifies actual consuming recipes and provides deterministic page slicing. `Domain/RecipeCatalog.lua` supplies unique recipe identity, name/output/profession search and ingredient lists. UI modules use `Infrastructure/ItemInfo.lua`, `RecipeInfo.lua` and `RecipeNameCache.lua` for guarded native client names/icons/tooltips.

If a spell or item name is missing from the client's cache, text search is incomplete; numeric-ID search and factual fallback remain available. Rarity, stats, learned recipes, craftability and stock counts are **not inferred** from the pinned source.

## Validation and refresh

```sh
bash scripts/validate_release_checks.sh
python3 scripts/build_materials.py --check
python3 scripts/coverage_report.py
```

Do not hand-edit generated Lua. For an approved licensed source refresh, update the pinned canonical recipes, **reconcile both material and reagent-use relations**, regenerate and verify the resulting catalog, and record the client build/review date. For example the importer accepts:

```sh
python3 scripts/build_materials.py --import-libprofessiondb /path/to/core --source-url <pinned-source-url> --client-build <build> --reviewed-at YYYY-MM-DD
```

The legacy reagent-only importer does not automatically reconcile the canonical recipe catalog: do not use it as a full-refresh command. Canonical and projection mismatches must fail validation. The stronger `--release --check` gate can require additional approved live data evidence. See [testing](TESTING.md) and [architecture](ARCHITECTURE.md).
