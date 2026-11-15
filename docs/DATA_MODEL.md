# Offline profession and craftable catalog — current source

CraftAtlas treats **numeric itemID** as the identity for materials and **professionKey + spellID** as the identity for a crafting recipe. Display names and icons come from the game client and are not used as identifiers. The same output item can be produced by distinct recipes; a crafted or equippable item can also be an input to another recipe.

## Source datasets and current scope

| Metric | Imported source-backed value |
| --- | ---: |
| Distinct recipe-input material itemIDs | **593** |
| Registered consuming profession categories | **10** |
| Materials consumed by multiple professions | **237** |
| Verified-in-source reagent → recipe use records | **8,455** |
| Distinct profession+spellID recipe keys | **2,506** |

The values describe a **pinned, MIT-licensed LibProfessionDB Forever 1.60.1.69977 beta snapshot**, transformed from [detok/ChalkBox](https://github.com/detok/ChalkBox/tree/f8bbc3e7af7476b5685f999b79b2470cd905e014/ChalkBox/Libs/LibProfessionDB-1.0), copyright attribution retained in `addon/CraftAtlas/Data/LICENSE-LibProfessionDB.txt`. **This does not prove every recipe still exists in the live Forever realm** or that all possible materials/recipes are included. `liveClientValidated: false` in the source is about complete imported-data reconciliation, not the maintainer's successful UI smoke tests.

Ten consuming source categories are Alchemy, Blacksmithing, Cooking, Enchanting, Engineering, First Aid, Fishing, Leatherworking, Mining and Tailoring. The index describes **recipe consumption**, not gathering nodes or the character's learned professions.

## One source, multiple generated runtime views

| Source / artifact | Meaning |
| --- | --- |
| `Data/materials.source.json` | Attributed material relations, consuming profession, source and source recipe IDs |
| `Data/professions.source.json` | Stable profession keys and localized enUS/esES labels |
| `Data/recipe-uses.source.json` | Pinned source record `[reagentItemID, recipeSpellID, professionKey, quantity, outputItemID, kind]` |
| `Data/Materials.lua` | Fast material itemID → profession indices/names |
| `Data/Professions.lua` | Localized stable profession registry and order |
| `Data/RecipeUses.lua` | Material itemID → recipe uses with exact required quantity |
| `Data/Recipes.lua` | Unique profession+spellID → **all known** reagent itemIDs and quantities, optional output, kind |
| `Data/coverage-report.json` | Scope/coverage evidence and the distinction between source and live validation |

`Recipes.lua` is **generated from the same reagent-use source**, not maintained as a separate database. A compact record stores `{spellID, professionIndex, outputItemID|0, kindIndex, {{reagentItemID, quantity}, ...}}`; `0` represents no known item output, including non-item enchantment effects. The builder verifies ingredient relations and rejects inconsistent output kinds/IDs and duplicated input facts.

Example: item **14044** (Cindercloth Cloak) is consumed by Leatherworking spell **19093**, quantity **1**, to produce item **15138** (Onyxia Scale Cloak). It must remain in the material index despite being equippable. An item that appears only as a crafted output does **not** qualify as a material.

## Runtime behavior and constraints

`Domain/MaterialSearch.lua` filters source-backed inputs by itemID/client name and profession. `Domain/RecipeUsage.lua` identifies actual consuming recipes and provides deterministic page slicing. `Domain/RecipeCatalog.lua` supplies unique recipe identity, name/output/profession search and ingredient lists. UI modules use `Infrastructure/ItemInfo.lua`, `RecipeInfo.lua` and `RecipeNameCache.lua` for guarded native client names/icons/tooltips.

If a spell or item name is missing from the client's cache, text search is incomplete; numeric-ID search and factual fallback remain available. Rarity, stats, learned recipes, craftability and stock counts are **not inferred** from the pinned source.

## Validation and refresh

```sh
bash scripts/validate_release_checks.sh
python3 scripts/build_materials.py --check
python3 scripts/coverage_report.py
```

Do not hand-edit generated Lua. For an approved licensed source refresh, update the attributed source data, **reconcile both material and reagent-use relations**, regenerate and verify the resulting catalog, and record the client build/review date. For example the importer accepts:

```sh
python3 scripts/build_materials.py --import-libprofessiondb /path/to/core --source-url <pinned-source-url> --client-build <build> --reviewed-at YYYY-MM-DD
```

The importer alone does not automatically reconcile the separate recipe-use facts; mismatched relationships should fail validation. The stronger `--release --check` gate can require additional approved live data evidence. See [testing](TESTING.md) and [architecture](ARCHITECTURE.md).
