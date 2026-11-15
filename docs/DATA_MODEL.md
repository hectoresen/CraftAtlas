# Material-to-profession catalog

CraftAtlas identifies ingredients by **numeric itemID**, never by localized tooltip text or item names. A material may be related to one or more consuming professions, independently of the character's training. If an itemID is unknown, no relationship is fabricated.

## Implemented pipeline

- `addon/CraftAtlas/Data/materials.source.json`: editable provenance-bearing source records.
- `addon/CraftAtlas/Data/professions.source.json`: extensible profession registry, stable keys and enUS/esES names.
- `scripts/build_materials.py`: deterministic builder/importer for the compact runtime `Materials.lua` and generated `Professions.lua`.
- `addon/CraftAtlas/Data/coverage-report.json`: counts, reference scope and whether live-client source verification is complete.
- `Domain/MaterialLookup.lua`: pure, stable-ordered numeric itemID → profession list lookup.

Each relation carries `professionKey`, `usageKind`, `source`, `reviewedAt`, `clientBuild`, `rights`, `status` and recipe IDs where available. `status=verified` refers to the identified **source snapshot**, not automatically to a recipe tested on today's Forever live server.

## Current data snapshot

| Metric | Value |
| --- | ---: |
| Distinct reagent itemIDs | **593** |
| Consuming profession categories | **10** |
| Materials used by multiple professions | **237** |
| Reference client | Forever **1.60.1.69977 beta** |
| Live-client data reconciliation | **Pending** |
| Comprehensive server coverage | **Not claimed** |

The source is a pinned MIT-licensed **LibProfessionDB** beta corpus (Pimptasty), transformed from [detok/ChalkBox](https://github.com/detok/ChalkBox/tree/f8bbc3e7af7476b5685f999b79b2470cd905e014/ChalkBox/Libs/LibProfessionDB-1.0). Its attribution is retained in `addon/CraftAtlas/Data/LICENSE-LibProfessionDB.txt`. The newer 1.60.1.70938 data has not yet been reconciled. Neither the upstream addon nor any network service is needed by the runtime.

Ten categories in the bundled registry: Alchemy, Blacksmithing, Cooking, Enchanting, Engineering, First Aid, Fishing, Leatherworking, Mining and Tailoring. **Gathering alone is not counted as consumption**; mappings represent recipe or material usage from the snapshot.

## Maintain and verify

```sh
python3 scripts/build_materials.py --check
python3 scripts/coverage_report.py
python3 scripts/build_materials.py --release --check
```

The release check requires accepted live-client data evidence, not merely the minimum 30 IDs / 5 professions / 2 overlaps from the approved starter specification. Do not manually edit generated Lua files. Missing provenance, invalid keys, duplicates and generated/source drift must fail validation.

The original six-item research preview is **historical**: it was superseded by the bundled 593-item snapshot. The approved recipe-use follow-up generates an **unreleased** source-backed recipe index from `recipe-uses.source.json`, preserving recipe IDs, exact input quantities and available crafted output IDs. A full dependency graph remains out of scope.

For a licensed local source refresh (after reviewing the new data):

```sh
python3 scripts/build_materials.py --import-libprofessiondb /path/to/Forever/_core --source-url <pinned-source-url> --client-build 1.60.1.70938 --reviewed-at YYYY-MM-DD
```


## Reverse recipe-use source (implementation candidate)

- `recipe-uses.source.json`: pinned MIT source-derived records `[reagentItemID, recipeSpellID, professionKey, quantity, outputItemID, recipeKind]`. `outputItemID=0` indicates unavailable/non-item output and is never shown as an item. Includes source URL/build/license and `liveClientValidated=false`.
- `RecipeUses.lua`: generated compact runtime index, grouped by reagent itemID. Profession indices use the generated stable `professionOrder`. Kind: 1 item, 2 enchant, 3 unknown.
- **8,455** source-verified input records, **593** distinct reagent itemIDs, compiled from the MIT beta 1.60.1.69977 `reagents` blocks. The compiler verifies every record against the existing relation's recipeIDs; output-only IDs are not promoted into inputs.
- Example: `14044` Cindercloth Cloak is legitimately consumed by Leatherworking spell `19093`, 1 unit, producing item `15138`. Its being equipable is irrelevant to input eligibility.
- The pinned source is not independently verified against the latest live Forever realm. Names/tooltips come from the client and may remain unavailable; there is no claim of complete live-realm coverage.

When importing another LibProfessionDB snapshot, **regenerate and reconcile both** material relations and recipe-use records before building; mismatched source relations intentionally fail validation to prevent stale reverse lookups.

## Unique recipe catalog (implementation awaiting in-game QA)

`Data/Recipes.lua` is generated deterministically from the *same* `Data/recipe-uses.source.json` as `RecipeUses.lua`; it is not a second manually maintained source. The source's **8,455 reagent-use records** become **2,506 unique profession+spellID recipe keys**. Each record stores `{spellID, professionIndex, outputItemID|0, kindIndex, {{inputItemID, exactQuantity}...}}` and is ordered by profession registry then spell ID. The generator validates consistent output item/type and rejects duplicate input ingredients. All recipe ingredients, including ingredients other than the selected material, are preserved. Identical crafted output items from distinct recipes remain separate catalog records. Values reflect the pinned beta source and **not necessarily every recipe or crafting permission in the current live realm**. Run `python3 scripts/build_materials.py --check` to detect generated drift and provenance mismatches.
