# Implementation tasks — reagent-only recipe usage

## Proposal gate
- [ ] Owner reviews and merges spec-only PR; later code PR references approved merged spec.
- [ ] Recheck current main, current client, schema and source rights before implementation.

## Source audit and modeling
- [ ] Resolve the complained-about "Capa de paño cenizo" to numeric itemID and its exact source recipe relations; document whether it really is a reagent.
- [ ] Audit imports for output-vs-reagent false positives; define verifiable inclusion policy without blanket filtering equippable items.
- [ ] Inspect pinned licensed source for exact reagent counts, crafted output IDs and recipe categories; document missing fields and version provenance.
- [ ] Add deterministic source model and offline RecipeUses.lua compiler preserving recipe IDs, professions, quantities and optional output IDs, with compatibility checks.
- [ ] Ensure generated material search index is derived from valid input relations rather than craft output-only associations; no fabricated items.

## Domain and runtime
- [ ] Add pure Lua material→verified recipe uses lookup with deterministic sort/dedup.
- [ ] Build guarded client recipe data adapter (optional) and native tooltip presenters for outputs and recipes; record Forever-specific API gate.
- [ ] Update explorer search and filters to show eligible inputs only, preserving names/icons/loading and valid selection.
- [ ] Expand right-side detail with compact grouped recipe rows, verified per-recipe quantities, output info, count, and factual missing-data states.
- [ ] Add locale strings for both enUS/esES with fallback.

## Verification and handoff
- [ ] Offline parser/generator tests and regression: crafted cloak, output-only vs real secondary reagent, bad quantities, multiple professions and duplicates.
- [ ] Lua pure-domain and UI adapter tests for recipe listing, mouseover tooltip show/hide, icon/name cache miss, and other safe fallbacks.
- [ ] Run repository validator, generated data --check, Python/Lua tests and strict OpenSpec; document exact run results.
- [ ] Update README, DATA_MODEL, ARCHITECTURE, ROADMAP, TESTING and CHANGELOG when code is implemented.
- [ ] Execute documented manual Forever-client matrix; record exact build/screenshot and pass/fail, leaving unrun paths explicit.
- [ ] Open separate implementation PR with the required OpenSpec approval metadata, no direct push to main and no automatic merge.
