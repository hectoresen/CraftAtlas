# Design: Exhaustive-as-verifiable Forever material/profession coverage

## Data domain
Retain itemID as the identity, profession keys independent of the player, and an ordered set of consuming professions for each item. Extend the initial data schema from an item-level list to **relation-level evidence**:
- `itemID` numeric, `professionKey` stable, `usageKind: ingredient|component|reagent`.
- `source` URL or offline evidence reference, `recipeID` or other clear proof where available, `reviewedAt`, `clientBuild`, `rights`, `verificationStatus`.
- Optional `sourceSnapshot` identifier and provenance notes for Forever custom data.
- Separate profession registry: key, supported client builds, locale display names and whether the discipline actually consumes items.

A record is releasable only after evidence validation. Multiple recipes linking one item and one profession collapse to one displayed profession; keep relation/evidence records for auditability. ItemID collisions or changes across server builds must be detected and reported.

## Profession coverage
Discover baseline crafting and secondary professions via verified client gameplay/source. Known Vanilla-style candidates include Alchemy, Blacksmithing, Cooking, Enchanting, Engineering, First Aid, Leatherworking and Tailoring. **Do not assume that this list is complete** for Forever. Mining, Herbalism and Skinning are gathering professions: they do not automatically count as consumers of the gathered item. If Forever adds an item-consuming action to one of these, include it only with direct evidence, and use the actual profession label. For unsupported custom professions, fail validation until a reviewed registry entry exists rather than silently dropping them.

## Catalog ingestion / quality
Keep editable sources under `addon/CraftAtlas/Data/` and an offline, deterministic build pipeline under `scripts/`. Support incremental hand-reviewed entries and only explicitly approved legally redistributable datasets. Do not scrape or connect to external services during play. Generator validates record types, duplicate facts, profession keys, source rights, build/version compatibility, and evidence/status; emits compact sorted Lua tables grouped by itemID for performance.

Produce `coverage-report.json` or equivalent reproducible summary containing reference universe ID/build/date, eligible total itemIDs, verified itemIDs, eligible profession keys, verified profession keys, multi-profession count, per-profession coverage, unverified/unknown count, rights blockers and rejected entries. **Separate unsupported/unknown from verified not-used**; never infer a negative result from absence.

Do not introduce a fabricated numerical coverage percentage when the denominator is unknown. "All possible" can only mean all verified eligible entries in a documented, bounded reference snapshot. Release checks distinguish baseline valid data, snapshot completeness, and approved release exceptions. Current v0.0.1 30-item gate remains its own historical acceptance gate.

## Tooltip architecture
Re-evaluate the Forever client runtime and `TooltipDataProcessor` or verified equivalent. Centralize all item tooltip callbacks through the existing thin adapter. Extract real numeric IDs from structured item tooltip data, not strings. Handle inventory, equipped gear, personal and guild banks, merchant, auction, chat item links, crafting, mail, quest rewards and any other confirmed supported item surfaces through the **same** formatter. If an origin does not expose a safe hook, document it as unsupported; never modify protected game behavior.

Make deduplication reliable across tooltip reuse, refresh, item change, language change, different views, and callback reentrancy. Re-render immediately after selecting another language (new/rebuilt tooltip) without stale text. Avoid per-hover scans or external I/O: O(1) map lookup and a bounded number of label inserts, no polling. Unknown IDs do not add unsupported claims.

## UI, settings and locale
Keep the approved compact native-style `/craftatlas` settings layout and clear sans-serif 'CraftAtlas' title without emblem. Existing enUS/esES user settings remain account-wide and backward-compatible. All new profession names and optional tooltips/feedback must be localized, with English fallback; no raw profession keys. No new search or recipe panel in this change.

## Tests and release gates
Offline tests for all known registry keys, unknown/custom ID handling, relation merging, ordering, source duplicate detection, evidence rights and deterministic output. Tooltip adapter tests for each confirmed origin, idempotence and rapid hover, reentrant refresh, locale switching, missing client APIs and large catalogs. Profile performance/memory with an appropriately sized dataset. Real Forever-client matrix records exact build, each tooltip origin, two or more languages, multi-profession items, unknown item, saved override and custom-profession if present. Distinguish automated mocks from live observations.

**Archival sequence (blocked by current SDD policy):** a future approved governance exception must first support moving changes under `openspec/`; the validator currently forbids `openspec/**` as an implementation scope. Once supported, prepare a separate archive PR that (1) writes canonical v0.0.1 capability requirements to `openspec/specs/` using OpenSpec synchronization semantics, (2) moves the existing original change under the official `openspec/changes/archive/` location, (3) records a historical acceptance exception for its original 30-material gate (only six researched materials shipped; owner's in-game tooltips validation confirmed; broader coverage moves to this approved proposal), and (4) runs OpenSpec and SDD validation. Preserve history, do not rewrite original requirements to pretend they passed. Do not include archival in this feature implementation PR, do not perform it in this spec-only proposal PR, and do not direct-edit main.

## Rollback
Disable addon or revert catalog generation. No player character or game state is modified; SavedVariables remain backwards compatible.
