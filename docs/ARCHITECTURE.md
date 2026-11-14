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
