# Architecture

CraftAtlas is a lightweight Lua addon using pragmatic ports-and-adapters concepts: **separation is mandatory; speculative abstraction is not**. Read [CODE_QUALITY.md](CODE_QUALITY.md) for Clean Code and review standards.

## Module responsibilities

| Boundary | Purpose | Must not |
| --- | --- | --- |
| `Core/` | Bootstrap, lifecycle, dependency wiring | Contain lookup/domain rules |
| `Domain/` | Pure material → professions rules | Call WoW APIs, access SavedVariables/UI |
| `Data/` | Compact offline mapping plus verifiable provenance | Infer relations from localized names |
| `Infrastructure/` | Client item/tooltip adapters, settings persistence | Decide domain relationships |
| `Features/Tooltip/` | Idempotent tooltip presentation | Own database query rules |
| `Features/Settings/` | Language preferences UI | Reach into item data directly |
| `Localization/` | Locale keys/labels | Encode game logic |

## End-to-end flow

Tooltip event → Forever-supported game adapter → numeric itemID → domain material lookup → local versioned dataset → translation by locale → tooltip presenter. Unknown IDs produce no fabricated profession lines.

Game API calls are edge effects. Domain logic must be executable and tested with vanilla Lua values. No per-frame scanning, repeated heavy allocations, or duplicate tooltip injection. Prefer small functions and minimal global namespace. Never ship a runtime network dependency.

## Compatibility and engineering constraints

The addon skeleton is currently nonfunctional. Validate exact Forever interface value, tooltips, available API and SavedVariables behavior on a current client before claiming support. Do not assume Retail or old Vanilla APIs match.

Changes to module boundaries, data schema or externally visible behavior require an OpenSpec proposal, prior maintainer approval and documented acceptance tests. Source data needs a compatible license and explicit provenance. New modules should not exist merely to anticipate future crafting graphs.

## Decision references

- [Agent workflow](AGENT_WORKFLOW.md)
- [Data model](DATA_MODEL.md)
- [Testing](TESTING.md)
- [Roadmap](ROADMAP.md)

## v0.0.1 implementation notes

`Core/Init.lua` initializes the namespace; `Core/Bootstrap.lua` wires
initialization after addon load. `Domain/MaterialLookup.lua` is a pure function
accepting a numeric itemID, table and stable profession order.
`Infrastructure/TooltipAdapter.lua` contains modern WoW tooltip-specific code,
where `TooltipDataProcessor.AddTooltipPostCall` is used provisionally;
`Features/Tooltip/Tooltip.lua` formats verified relations.
`Infrastructure/Preferences.lua`, `Localization/Locales.lua` and
`Features/Settings/Settings.lua` implement language selection independently
of lookup. The native settings panel uses the approved clean CraftAtlas
header without decorative emblem and a single General category.

The modern item-tooltip callback has a broad surface in Mainline-family WoW.
**The spec currently guarantees only inventory/bag behavior**; extending
guaranteed support to other origins needs an approved spec revision and game
tests. The adapter is not considered compatible until tested on Forever.
