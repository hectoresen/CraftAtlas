# Tasks — full Forever catalog refresh

- [ ] 1.1 Confirm latest primary Forever LibProfessionDB version/build and source license; record exact pinned artifact, SHA and attribution, and examine any newer independently verifiable authoritative sources.
- [ ] 1.2 Acquire source offline; create reproducible importer plus machine-readable previous/current/delta report by profession+spellID and ingredient itemID; capture baseline counts.
- [ ] 1.3 Review all missing/deleted recipes, output changes, zero-reagent records and source conflicts; explicitly classify the 27 empty secondary records and spell 1251750 using independent evidence. Do not equate omission with removal.
- [ ] 2.1 Update data model, registry and schema for 12 supported profession categories, including Herbalism/Skinning camping recipes and optional source-backed recipe metadata.
- [ ] 2.2 Keep zero-reagent recipes in unique recipe catalog, but out of material-use projections; ensure output IDs/kinds, counts and recipe names are never invented.
- [ ] 2.3 Reconcile every source material relation against recipe source; regenerate deterministic Lua/coverage and retain pinned provenance and license.
- [ ] 2.4 Verify all five changed bag quantities, Enchant Boots - Speed and four Leatherworking reagent changes against primary records; record decision/evidence for each.
- [ ] 3.1 Add parser, diff, data-integrity, new/camp recipe, zero-reagent, output consistency, 12-category registry and duplicate-ID tests; preserve previous UI/tracking compatibility tests.
- [ ] 3.2 Execute build --check, full release readiness, Lua 5.1 compatibility/regressions and OpenSpec strict/SDD gates; record exact outputs.
- [ ] 3.3 Test core browse, filters, ingredient detail, tooltip references, tracking progress and camp recipes on actual supported Forever client; record client build, locale, success/failure and NOT RUN scenarios.
- [ ] 4.1 Execute documentation-sync skill before implementation PR; update README, DATA_MODEL, TESTING, CHANGELOG, coverage evidence and OpenSpec status without claims of full live validation.
- [ ] 4.2 Create separate implementation PR only after owner-approved and merged spec proposal; include exact spec approval PR, scope, QA and archival disposition. Do not merge or release unilaterally.
