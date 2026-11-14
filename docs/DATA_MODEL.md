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
