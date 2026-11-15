# Proposal: Reagent-only catalog and reverse recipe usage

## Why
The owner tested the material explorer merged in PR #14 and found finished/equippable craft outputs such as "Capa de paño cenizo" among browse/search results. CraftAtlas is currently intended to help users discover **items consumed by profession recipes**, not catalog every profession-produced object as a searchable material. The selected-material detail currently shows only professions and itemID; players need to see **which verified recipes consume the material, which profession uses it, and what each recipe makes**, including native item/recipe tooltips.

## Scope
- Audit existing 593-item snapshot against source recipe reagent and output evidence. Remove or suppress false positives introduced by erroneous source inference, without blanket-excluding equippable items: a crafted/equippable object may legitimately be a reagent for another craft. Avoid silently treating a missing recipe proof as a confirmed non-reagent.
- Introduce a licensed, generated, versioned local recipe-use index keyed by reagent itemID with recipe spellID, consuming profession, material quantity where available, optional crafted output itemID and provenance/verification status. Reuse recipeIDs already held in materials.source.json but independently verify linkage and output fields; no runtime online dependency.
- Keep the left explorer exclusive to validated reagent itemIDs for browse, text search, profession filtering and counts. Do not list craft outputs solely because a profession can create them.
- Expand the selected material detail: readable **Recipes using this material** section grouped by consuming profession; compact recipe/output rows, native icon/quality presentation, reagent quantity if verified, hover item tooltip and compatible recipe/spell tooltip where available.
- Add useful but bounded UX: show number of verified recipe uses; order recipes deterministically, with name-based search results and visible empty/loading/unsupported states; preserve list selection/filter/search. Distinguish output item from recipe name and clearly indicate when a recipe does not create an item (enchantments, conversions, etc.).
- Keep local enUS/esES strings and game-native frames. Do not ship third-party visual skins or fabricate item quality/links.
- Add data validation/generation, offline tests, documented reproducible provenance, and a real Forever smoke-test checklist.

## Important semantics
- **An item's category or equip slot does not determine reagent eligibility.** Eligibility requires a validated relation in which it appears as an input to a profession recipe. A manufactured object may also be consumed by another recipe and must remain discoverable in that case.
- **A relation with only a profession label is insufficient evidence.** Every published reagent relation needs an attributable source recipe ID and preferably an input quantity; absence of reliable input evidence is documented as unverified and excluded from the verified-only default browse view until resolved.
- Existing MIT LibProfessionDB beta snapshot (Forever 1.60.1.69977) and its recipeIDs are source evidence, **not** proof of today's live Forever recipe catalog. The new source must be pinned, licensed, and labelled appropriately.
- Prefer native C_Item and compatible C_TradeSkillUI APIs when available. Some recipe APIs can be scoped to the character's open profession or known recipes: the offline index must not falsely hide known source-backed recipe relations because the character has not learned a profession. Verify APIs in the real Forever build.

## Out of scope
- Dedicated catalog of all craftable outputs, all gear, equipment browsing or standalone item search.
- Crafting automation, skill training, auction prices, bag scans, shopping lists, crafting trees, favorites, character recipe unlock filtering, ingredient substitutes or profitability.
- Fabricating missing crafted output IDs, reagent quantities, recipe names or rarity.
- SDD validator/governance modifications; prior one-PR exception was restricted to PR #14 and does not carry over.

## Proposed release conditions
A recipe row SHALL be shown only when the item-to-recipe input relationship has validated provenance. If the source recipe has no reliably known output, show the recipe/spell as an explicitly unresolved output instead of inventing an item. If no complete index is available, expose the limited-data state rather than claiming completeness.

## Risks and rollback
False positives or missing recipe outputs from beta snapshots, incomplete Forge/Forever API availability, non-item crafting actions, cache loading, long result lists, UI scale and license incompatibility. Mitigate with cross-checks, deterministic converter tests, fallback states and documented real-client smoke tests. Rollback restores the prior material explorer and static profession detail; do not modify existing working tooltip annotations.

## Approval
This PR is a **specification proposal only**. No Lua production implementation before the owner merges/approves it and implementation in a separate scoped PR. Only @hectoresen may merge or release.
