# Proposal: Expand CraftAtlas to all verified professions and usable materials

## Why
The v0.0.1 implementation proves the initial itemID -> consuming profession tooltip concept in the real WoW Forever client. A six-item preview and eight hard-coded profession keys do not solve the user's actual long-term need: hover **any material** and see **all professions that use it**, wherever the item's tooltip is shown. The goal is broad, continuously auditable coverage without asserting undocumented completeness.

## What changes
- Expand the offline catalog from the small seed to **every verified craft-relevant itemID and consuming profession supported by the Forever client**, covering classic and Forever-specific additions.
- Build a versioned and extensible profession registry from **observed in-game crafting disciplines**, not a fixed Vanilla list. Preserve stable nonlocalized keys and localized user labels. Include secondary disciplines when they consume reagents. Gathering-only professions must not be shown as consumers merely because they collect an item.
- Record evidence **per item-to-profession relation**, and distinguish confirmed, incomplete and unverified entries without guessing.
- Expand hover annotations to **all supported item tooltip origins**: inventory, equipment, bank, guild bank, merchant, auction, chat item links, crafting UI, mail, quest rewards, and other client-provided item tooltip surfaces where safely possible.
- Add tooling for incremental source curation, generation, quality checks, coverage reports and reproducible packaging; keep runtime fully offline.
- Continue respecting user-selected language, persistence, minimal native Forever/Classic styling and the clean CraftAtlas settings panel.
- Document what is actually supported, known limitations and procedures to maintain compatibility when Forever adds professions, recipes, or items.

## Scope and versioning
**Target milestone:** the next catalog-expansion release after v0.0.1; propose **v0.1.0**, pending owner approval and roadmap update at implementation. This is not a promise that every unknown/custom item can be classified.

**In scope:** all recognized **consuming** professions including secondary/custom ones; all verified materials including items with no class restriction, intermediate crafted reagents, profession reagents/consumables, classic/custom itemIDs; multiple consuming professions per ID; item tooltip surfaces using safe available Forever APIs; offline data quality and coverage diagnostics.

**Out of scope:** displaying a profession solely because it *gathers* or *produces* an item, player's learned profession filtering, recipe trees and quantities, crafting availability, AH valuation, search UI, online sync/scraping in the client, and claims of complete coverage without a defined audited universe.

## Acceptance / meaningful completeness
A claim of "all" MUST specify a **bounded reference universe** (Forever build, item/recipe dataset snapshot, source rights, expected item and profession counts), then compute and publish coverage. The acceptance gate is **100% of eligible records in the approved reference universe with traceable evidence**, not 100% of all possible server-side IDs. Unknown/unverified items must never be annotated as if confirmed. If a suitable complete reference cannot be obtained lawfully, publish a measured partial snapshot and explicitly withhold any "full coverage" claim; owner approval is required to release under reduced coverage.

Existing v0.0.1 quality gates must remain enforced independently until that milestone is accepted: in particular 30 distinct verified itemIDs, five consuming professions and two multi-profession items.

## Risks
- Forever-specific profession names and recipes change; their API and catalog availability must be verified in the real client.
- Broad tooltip interception might duplicate lines, interact with protected frames or produce overhead. Use a single safe isolated hook with bounded work, and test each origin.
- Third-party addon datasets may be copyrighted or unredistributable. Record rights and provenance for each relationship; never copy an unlicensed dataset to attain coverage.
- Absence of an item in sources does not imply non-use.
- Localization availability for custom profession names may vary; use explicit reviewed strings and safe fallback, without parsing localized item names.

## Delivery and approval
This PR contains specification artifacts only. The owner reviews and merges it before any implementation PR. The prior change `add-first-playable-material-tooltips` must be synchronized to canonical `openspec/specs/` and archived **after** its implementation PR #4 is merged and its acceptance criteria are explicitly resolved (including the starter catalog gate), in a separate archival/sync workflow. Do not silently treat functional smoke-test success as proof of full spec completion, and do not merge or archive implementation unilaterally.
