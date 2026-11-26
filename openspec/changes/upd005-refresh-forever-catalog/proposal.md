# Refresh the licensed WoW Forever crafting catalog for future recipe tracking

## Why

CraftAtlas currently packages a pinned Forever beta LibProfessionDB snapshot (1.60.1.69977), with 593 distinct reagent itemIDs, 8,455 ingredient-use relationships, 2,506 profession+spellID recipe keys and 10 consuming profession categories. Its catalog needs current live-client facts before future Fabricables recipe-following work can safely use quantities and recipe metadata.

LibProfessionDB ProfessionDB-v1.10.1 (2026-11-16) documents 2,517 recipes across 12 professions on its Forever dataset (including Herbalism and Skinning camp recipes), with sources, vendors and trainer evidence. ReagentSkillTips v1.7.0 (2026-11-23) reports recipe and reagent changes from Forever build 1.60.1.71037. These are candidate sources, not blanket proof that every claimed entry is live usable or that the secondary dataset carries all original facts.

## Changes

- Rebuild an attributed **offline** source-backed catalog from the newest independently verified licensed Forever dataset available when implementation starts; pin exact library release, source version/hash, game build, license, download path and review date.
- Reconcile **all** material-to-recipe relations using stable `professionKey:spellID` identity. Include correct ingredient IDs/quantities, recipe output IDs and kind, new/renamed recipes, genuine removals, new materials and profession coverage.
- Register Forever Herbalism and Skinning camp recipes and preserve existing camp recipes across the other professions, including reagent-free recipes or non-item actions. Support 12 supported categories where source data warrants them; do not treat gathering professions as interchangeable with ordinary manufacturing.
- Preserve optional structured recipe metadata when licensed and proven: skill requirements and difficulty, learning/teaching source, vendor NPC/faction/cost, taught-by-item, and camping classification. Record unknowns explicitly. Metadata need only be readable in the local catalog/API, **not displayed in a new UI** in this change.
- Produce deterministic before/after diff evidence and QA exceptions for removals, empty ingredients, unknown outputs, conflicting source/build snapshots, and any source gap.
- Keep existing Materiales and Fabricables behavior, tracking, global toggle, navigation, localization, and saved preferences compatible with the refreshed data. Do not silently classify zero-ingredient activities as craftable physical items.

## Known discrepancy candidates (not automatic import decisions)

- Five Tailoring cloth/bag quantity changes (spells 3758, 6688, 6693, 6695, 12079).
- Spell 1328948 (Enchant Boots - Speed) absent from pinned source; reagent candidates 11175 ×2, 11176 ×8, 11178 ×2, 12361 ×1.
- Four Leatherworking recipes (1301431, 1301437, 1301455, 1301461) with different ingredient 4321 presence.
- A group of 27 historical spells (1252979–1253006 subset) with nonempty CraftAtlas requirements but empty entries in the compared ReagentSkillTips dataset; **never delete these facts solely due to the empty secondary source**.
- A possible Alchemy removal (1251750); independently verify lifecycle rather than deleting by absence.
- Some source recipe actions have zero reagents. Classify them without inventing required materials or outputs.

## In scope

Source/provenance ingestion, canonical catalog data, deterministic Lua compilation, offline runtime data contract (only necessary consumer compatibility), registry/locales, generator validation, tests and accurate documentation. Prepare schema/data for future recipe tracking **without implementing the tracking feature itself**.

## Out of scope

New recipe-following UI, batch craft planning, automated crafting, auction queries, live network sync, learned-recipe scanning, assumptions that missing secondary data mean removals, or fabricated source metadata. No runtime external dependency on LibProfessionDB or ReagentSkillTips.

## Acceptance and rollout

Must pass deterministic source/report tests, recipe cross-index integrity, Lua 5.1 and release-readiness gates, strict OpenSpec/SDD and documented Forever smoke tests or explicitly leave acceptance/archival blocked. Preserve prior source as an auditable baseline and make rollback possible by reverting the implementation PR. Existing user tracking settings and IDs must not migrate or be lost. Owner review of source rights and material diff is mandatory before merging the **separate** implementation PR. Maintenance-mode exception: this is a catalog accuracy update, not approval of the forthcoming tracking feature.
