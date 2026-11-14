# Code quality rules — Lua / CraftAtlas

These requirements apply to all production Lua and relevant test/helper code. Favor **readability, testability and predictable performance** over frameworks and cleverness.

## Clean Code / SOLID proportionately

- **Single responsibility:** each module has one clear purpose, functions perform one coherent operation.
- **Open/closed:** extend via data entries or stable interfaces rather than adding item-specific UI conditionals.
- **Liskov/interface segregation:** when adapters/interfaces are needed, keep contracts honest, small and usable; do not build inheritance frameworks unnecessarily in Lua.
- **Dependency inversion:** domain depends on plain Lua values/functions rather than WoW globals or UI; game APIs remain in adapters.
- **DRY:** avoid duplicated behavior/keys, but do not abstract coincidental similarities prematurely.
- **KISS / YAGNI:** implement the approved OpenSpec scope only. Future search, recipes and dependency graphs are not reasons to ship unnecessary runtime complexity in v0.1.0.

## Lua conventions

- Use descriptive English identifiers and consistent `local` declarations. Minimize globals; expose one intentional addon namespace if required.
- Use Lua 5.1-compatible syntax and APIs supported by the validated Forever client.
- Use stable `itemID` (number) and symbolic profession constants. No localized names as database keys.
- Keep presentation strings in locale modules; default enUS with esES override and locale fallback.
- Prefer explicit parameter/return contracts, simple guard clauses and short functions. Avoid hidden mutations and cyclic dependencies.
- Do not silently swallow errors; handle unknown/unavailable item data as an expected case without fabricated fallback.
- WoW tooltip hooks must be idempotent and performant. Avoid polling, expensive lookups per frame and duplicate lines.
- No network calls, tracking, logging of sensitive character data or required external addon.

## Data discipline

- Keep source data versioned, reproducible and attributable. Preserve license, source date and client applicability metadata.
- Validate each imported dataset: duplicate IDs, unknown profession keys, inconsistent references and unexpected counts.
- Prefer generated compact lookup tables to manually duplicating mappings in several modules.
- Avoid changing accepted mapping semantics without an OpenSpec change and tests.

## Tests and reviews

- Pure domain logic gets offline deterministic tests for normal, unknown, multi-profession and malformed-data paths.
- Adapter/UI behavior gets mocked tests where practical and **real Forever client** manual smoke tests when game-facing.
- Add regression tests for each repaired defect.
- Treat lint/test warnings as work to investigate; never weaken checks just to make CI green.
- PRs should be small, titled conventionally and include rationale, change ID, evidence, risks, data rights and a rollback explanation.
- Update both locales, docs and specs whenever new behavior needs them.

## Anti-patterns to reject

God objects; huge functions; deeply nested conditionals that can be simplified; unnecessary metatables/inheritance; hard-coded translations; copying data from unlicensed addons; fake passing test claims; speculative frameworks; global mutation without lifecycle ownership; hidden errors; UI components that know recipe/database implementation details.

## Review checklist

Is the scope approved? Are boundaries intact? Could it be simpler? Are names and error cases clear? Are tests and real-client evidence honest? Is every dataset legal and traceable? Is documentation synchronized? Would a new maintainer understand the behavior without chat context?
