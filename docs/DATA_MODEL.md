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
