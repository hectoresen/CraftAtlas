# Data model and provenance

Use numeric item IDs, stable profession keys and deterministic mapping. Suggested future example (illustrative, not shipped facts):

```lua
materials = {
  [2589] = { professions = { "TAILORING", "FIRST_AID" } },
}
```

Do not use localized item names or the tooltip phrase "Trade Goods"/"Componente de profesión" as primary identity. A material may map to zero, one or multiple professions; unknown data must remain unknown.

Recommended durable source format: normalized item/material, profession and eventually recipe/output/quantity relationships; generate compact Lua lookup tables offline. Separate canonical source metadata from generated runtime data.

Each imported data batch requires source URL/name, license, retrieval timestamp, client/patch applicability and verification method. Third-party database redistribution requires explicit compatible permission. CI should detect duplicate IDs, invalid profession keys, missing relationships and outdated generated output.

Future recipe relationships should support multiple inputs and products with quantities, without reshaping v0.1.0 public domain APIs.

## Implementation preview data pipeline

`addon/CraftAtlas/Data/materials.source.json` is the editable evidence-bearing
input. `scripts/build_materials.py` deterministically generates
`addon/CraftAtlas/Data/Materials.lua`; do not edit the generated Lua manually.
Use `--check` to detect drift and `--release --check` to enforce the minimum
30 IDs / 5 professions / 2 cross-profession items. Source entries include
`source`, `reviewed`, `clientScope` and `rights`.

The six starter associations were researched as individual facts from
Warcraft Wiki pages, not imported as a bulk proprietary data dump.
**Forever in-game verification is pending**; none of the relationships should
be described as confirmed for the live client until verified. Recording a
source URL is evidence of public reference, not automatic redistribution
permission for an entire database. If the data source rights are unclear,
do not copy the database.

## v0.1.0 auditable relations

The catalog schema version 2 in `addon/CraftAtlas/Data/materials.source.json` stores individual itemID-to-profession relationships. Each has `professionKey`, `usageKind`, `source`, `reviewedAt`, `clientBuild`, `rights`, and `status` (researched or verified). `professions.source.json` supplies a reviewed extensible registry, including language names. Build via `python3 scripts/build_materials.py`; verify drift with `--check` and review `coverage-report.json`. Without a legally permitted bounded reference universe, the coverage denominator remains unknown and no full-coverage claim is allowed.

## LibProfessionDB 1.60.1.69977 MIT snapshot

The seeded six-material prototype was replaced by **593 distinct reagent itemIDs** found across ten recipe-bearing profession files in a pinned, vendored LibProfessionDB snapshot: Alchemy, Blacksmithing, Cooking, Enchanting, Engineering, First Aid, Fishing, Leatherworking, Mining and Tailoring. **237 materials map to two or more professions.** Only reagent-consuming actions are counted; gathering is not counted just because a profession harvests something. Every imported relation includes one or more `recipeIDs` for auditability. This is the **beta client** 69977, not the current live 70938 data. Herbalism/Skinning and later specializations may be missing until the current live snapshot is imported.

Source: https://github.com/detok/ChalkBox/tree/f8bbc3e7af7476b5685f999b79b2470cd905e014/ChalkBox/Libs/LibProfessionDB-1.0/Data . Upstream LibProfessionDB authored by Pimptasty, MIT (license bundled at `addon/CraftAtlas/Data/LICENSE-LibProfessionDB.txt`). The data is transformed and grouped by ingredient itemID, without copying the upstream addon runtime. The `status=verified` flag means verified *against the identified client snapshot*, **not** confirmed craftable on the live server; `referenceUniverse.liveClientValidated=false` preserves that distinction. No full-coverage percentage is emitted because the bounded current-live universe is unknown.

For future refreshes, obtain the locally licensed LibProfessionDB core Lua files and use:

```sh
python3 scripts/build_materials.py --import-libprofessiondb /path/to/Forever/_core --source-url <pinned-source-url> --client-build 1.60.1.70938 --reviewed-at 2026-11-15
python3 scripts/build_materials.py --check
```

The importer executes **no Lua code** and never scrapes at runtime. Review generated changes and keep the upstream attribution. A live build acceptance and owner release approval are still required.
