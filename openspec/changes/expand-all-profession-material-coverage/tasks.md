# Implementation tasks — expand all verifiable material-profession coverage

> Planning only. No implementation before the owner merges the proposal PR and authorizes work.

## 0. Synchronize and archive the accepted first-playable change
- [ ] 0.1 Confirm PR #4 was owner-merged, record the user's in-game confirmation that /craftatlas and profession annotations work.
- [ ] 0.2 Explicitly record the **v0.0.1 exception**: six starter materials instead of the original 30, with the catalog expansion transferred to this new approved change. Do not claim the old 30-item acceptance criterion passed.
- [ ] 0.3 Synchronize the accepted v0.0.1 capability deltas to canonical openspec/specs/ using official OpenSpec sync semantics.
- [ ] 0.4 Archive openspec/changes/add-first-playable-material-tooltips/ to the supported OpenSpec archive location, preserving proposal, design, tasks, specs, rights and audit history.
- [ ] 0.5 Obtain a separately approved governance pathway for archiving: current SDD scope policy rejects `openspec/**`. Then run official OpenSpec validation and SDD checks on a separate archive PR; never bypass checks or commit directly to main.

## 1. Reconcile v0.0.1 and client baseline
- [ ] 1.1 Confirm the old implementation PR #4 is merged or identify explicit outstanding gates; do not mark old spec complete solely from settings working.
- [ ] 1.2 Record active Forever build and available profession registry/crafting evidence APIs and tooltip sources.
- [ ] 1.3 Establish the legally usable **bounded reference universe** and provenance snapshot; owner reviews coverage denominator and claims.

## 2. Extend data model and registry
- [ ] 2.1 Add reviewed profession registry with stable keys, names enUS/esES, secondary/custom entries, consuming-vs-gathering distinction.
- [ ] 2.2 Migrate starter catalog to per-relation provenance (itemID, profession, evidence, client build, rights, status); preserve existing working behaviors.
- [ ] 2.3 Extend deterministic generator, integrity/rights validation, version handling and reproducible coverage report.
- [ ] 2.4 Build auditable import/review workflows for legally permitted sources; no network usage at runtime.

## 3. Expand verified catalog
- [ ] 3.1 Enumerate candidate recipe/material mappings for each profession in the reference universe.
- [ ] 3.2 Verify evidence and legality for every published itemID→consuming profession relation, including multi-profession and custom Forever materials.
- [ ] 3.3 Generate and review coverage report; address all eligible itemIDs or explicitly document blockers and request owner's reduced-coverage approval.
- [ ] 3.4 Run release and regression checks; retain separate v0.0.1 outstanding gates until closed.

## 4. Global tooltip support
- [ ] 4.1 Implement centralized supported item-tooltip adapter for all tested client origins.
- [ ] 4.2 Test bags, equipment, bank/guild bank, merchants, AH, chat item links, crafting, mail and quest-reward previews.
- [ ] 4.3 Validate refresh/change/lang toggles, no duplicates, protected frames and callback performance, and record unsupported surfaces.

## 5. Localization, documentation and review
- [ ] 5.1 Add translated names for all verified profession keys with English fallback.
- [ ] 5.2 Preserve approved settings look-and-feel and persisted preferences.
- [ ] 5.3 Add data/adapter tests and large-data benchmarks; execute offline and in Forever, capturing exact client version/screenshots.
- [ ] 5.4 Update README, roadmap, data model, testing, installation, changelog and coverage report with precise claims.
- [ ] 5.5 Submit separate implementation PR with approved spec PR reference; do not merge without owner review.
