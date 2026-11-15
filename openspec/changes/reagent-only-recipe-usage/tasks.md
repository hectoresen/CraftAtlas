# Implementation tasks — reagent-only recipe usage

## Proposal gate
- [x] Owner merged spec PR #20; this implementation branch references that approval.
- [x] Rechecked main, pinned MIT source schema and license; real Forever client remains unavailable for hands-on QA.

## Source audit and modeling
- [x] Resolve the complained-about "Capa de paño cenizo" to numeric itemID and its exact source recipe relations; document whether it really is a reagent.
- [x] Audit imports for output-vs-reagent false positives; define verifiable inclusion policy without blanket filtering equippable items.
- [x] Inspect pinned licensed source for exact reagent counts, crafted output IDs and recipe categories; document missing fields and version provenance.
- [x] Add deterministic source model and offline RecipeUses.lua compiler preserving recipe IDs, professions, quantities and optional output IDs, with compatibility checks.
- [x] Ensure generated material search index is derived from valid input relations rather than craft output-only associations; no fabricated items.

## Domain and runtime
- [x] Add pure Lua material→verified recipe uses lookup with deterministic sort/dedup.
- [x] Built guarded spell info and native tooltip adapters with factual fallback; client compatibility remains a manual validation gate.
- [x] Update explorer search and filters to show eligible inputs only, preserving names/icons/loading and valid selection.
- [x] Expand right-side detail with compact grouped recipe rows, verified per-recipe quantities, output info, count, and factual missing-data states.
- [x] Add locale strings for both enUS/esES with fallback.

## Verification and handoff
- [x] Offline parser/generator tests and regression: crafted cloak, output-only vs real secondary reagent, bad quantities, multiple professions and duplicates.
- [x] Added pure Lua recipe lookup, native tooltip adapter mocks and existing name/icon adapter regression tests; execution results still pending.
- [ ] Run repository validator, generated data --check, Python/Lua tests and strict OpenSpec; document exact run results.
- [x] Update README, DATA_MODEL, ARCHITECTURE, ROADMAP, TESTING and CHANGELOG when code is implemented.
- [ ] Execute documented manual Forever-client matrix; record exact build/screenshot and pass/fail, leaving unrun paths explicit.
- [x] Open separate implementation PR with the required OpenSpec approval metadata, no direct push to main and no automatic merge.
