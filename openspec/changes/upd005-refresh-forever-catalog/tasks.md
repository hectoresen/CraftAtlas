# Tasks — full Forever catalog refresh

- [x] 1.1 Confirm latest primary Forever LibProfessionDB version/build and source license; record exact pinned artifact, SHA and attribution, and examine any newer independently verifiable authoritative sources.
- [ ] 1.2 Acquire source offline; create reproducible importer plus machine-readable previous/current/delta report by profession+spellID and ingredient itemID; capture baseline counts.
- [ ] 1.3 Review all missing/deleted recipes, output changes, zero-reagent records and source conflicts; explicitly classify the 27 empty secondary records and spell 1251750 using independent evidence. Do not equate omission with removal.
- [x] 2.1 Update data model, registry and schema for 12 supported profession categories, including Herbalism/Skinning camping recipes and optional source-backed recipe metadata.
- [x] 2.2 Keep zero-reagent recipes in unique recipe catalog, but out of material-use projections; ensure output IDs/kinds, counts and recipe names are never invented.
- [x] 2.3 Reconcile every source material relation against recipe source; regenerate deterministic Lua/coverage and retain pinned provenance and license.
- [x] 2.4 Verify all five changed bag quantities, Enchant Boots - Speed and four Leatherworking reagent changes against primary records; record decision/evidence for each.
- [ ] 3.1 Add parser, diff, data-integrity, new/camp recipe, zero-reagent, output consistency, 12-category registry and duplicate-ID tests; preserve previous UI/tracking compatibility tests.
- [ ] 3.2 Execute build --check, full release readiness, Lua 5.1 compatibility/regressions and OpenSpec strict/SDD gates; record exact outputs.
- [ ] 3.3 Test core browse, filters, ingredient detail, tooltip references, tracking progress and camp recipes on actual supported Forever client; record client build, locale, success/failure and NOT RUN scenarios.
- [ ] 4.1 Execute documentation-sync skill before implementation PR; update README, DATA_MODEL, TESTING, CHANGELOG, coverage evidence and OpenSpec status without claims of full live validation.
- [ ] 4.2 Create separate implementation PR only after owner-approved and merged spec proposal; include exact spec approval PR, scope, QA and archival disposition. Do not merge or release unilaterally.

## Implementation data ledger — 2026-11-26 (owner review required)

**Pinned source:** `ImCheesecake/Altisan` commit `c942539402802f2ec837cac1788f8c24fea374ed`, vendored MIT LibProfessionDB **ProfessionDB-v1.10.1 Forever 1.60.1.70938** core, originally authored by Pimptasty. Baseline: **Forever 1.60.1.69977**. This branch is not a published release and full live Forever validation is **NOT RUN**.

**Before → after, accepted source records:**
- Professions **10 → 12** (+ HERBALISM/Herboristería and SKINNING/Desuello).
- Recipe identities **2,506 → 2,518** (12 added; one absent-source legacy record retained).
- Reagent relationships **8,455 → 8,471** (+16 net); distinct material itemIDs **593 → 592**, removal of item `4321` from all four consuming Leatherworking recipes in this data set; **no new distinct material itemIDs**, but six camp recipes reuse existing reagents.
- Multi-profession reagent IDs **237 → 240**; **five zero-reagent recipe identities** included in Fabricables source, omitted from material reverse indexes.
- Source-backed optional metadata: **2,335 required-skill**, **2,517 difficulty quartets**, **1,889 teaching-item** references, **316 Forever merchant recipes and native vendor offers/prices/faction**; **1,170 borrowed Classic acquisition-source records are explicitly marked unconfirmed for Forever**.

### A. Every new recipe key (12)

- `COOKING:3413` — output none/unknown, ingredients: none (zero-input source action)
- `ENCHANTING:1328948` — output none/unknown, ingredients: 11175 ×2, 11176 ×8, 11178 ×2, 12361 ×1
- `ENGINEERING:4073` — output none/unknown, ingredients: none (zero-input source action)
- `ENGINEERING:19804` — output none/unknown, ingredients: none (zero-input source action)
- `FIRST_AID:7924` — output none/unknown, ingredients: none (zero-input source action)
- `FISHING:7732` — output none/unknown, ingredients: none (zero-input source action)
- `HERBALISM:1229705` — output 279962, ingredients: 765 ×1, 2447 ×1
- `HERBALISM:1262980` — output 279964, ingredients: 4470 ×2, 8831 ×1, 8836 ×1
- `HERBALISM:1263070` — output 279947, ingredients: 8925 ×1, 13465 ×4, 14047 ×2
- `SKINNING:1229517` — output 279979, ingredients: 2318 ×3, 4470 ×2
- `SKINNING:1262982` — output 279938, ingredients: 3575 ×1, 4234 ×4, 4470 ×2
- `SKINNING:1262985` — output 279969, ingredients: 2319 ×3, 2321 ×1, 5784 ×2

### B. Every confirmed ingredient change (9)

- `LEATHERWORKING:1301431`: `4321` 1 → removed
- `LEATHERWORKING:1301437`: `4321` 1 → removed
- `LEATHERWORKING:1301455`: `4321` 1 → removed
- `LEATHERWORKING:1301461`: `4321` 1 → removed
- `TAILORING:3758`: `2997` 4 → 5
- `TAILORING:6688`: `2997` 4 → 5
- `TAILORING:6693`: `4305` 4 → 5
- `TAILORING:6695`: `4305` 5 → 6
- `TAILORING:12079`: `4339` 4 → 5

These nine updates comprise five Tailoring quantity corrections and four Leatherworking removals of reagent `4321`. No preexisting recipe output or kind was changed automatically for these entries.

### C. Explicitly retained ambiguous changes (28)

**27 source-empty recipes:** The newer core source has no ingredients or outputs, but the older pinned beta source has them. Their original positive ingredients and known outputs remain in the canonical dataset with `evidenceStatus: retained-legacy-pending-forever-verification`; none is silently cleared:

`BLACKSMITHING:1252988`, `BLACKSMITHING:1252989`, `BLACKSMITHING:1252990`, `BLACKSMITHING:1253001`, `BLACKSMITHING:1253002`, `BLACKSMITHING:1253003`, `ENGINEERING:1253004`, `ENGINEERING:1253005`, `ENGINEERING:1253006`, `LEATHERWORKING:1252982`, `LEATHERWORKING:1252983`, `LEATHERWORKING:1252984`, `LEATHERWORKING:1252985`, `LEATHERWORKING:1252986`, `LEATHERWORKING:1252987`, `LEATHERWORKING:1252995`, `LEATHERWORKING:1252996`, `LEATHERWORKING:1252997`, `LEATHERWORKING:1252998`, `LEATHERWORKING:1252999`, `LEATHERWORKING:1253000`, `TAILORING:1252979`, `TAILORING:1252980`, `TAILORING:1252981`, `TAILORING:1252991`, `TAILORING:1252992`, `TAILORING:1252993`

**One source-missing Alchemy recipe:** `ALCHEMY:1251750` is missing from the newer source. Its beta record is retained under `evidenceStatus: retained-legacy-missing-from-new-source`.

All 28 require actual client or other authoritative evidence before dropping or changing retained facts. These are **not** accepted removals.

### D. Source fields and runtime changes

- Added `Data/recipes.source.json` as canonical recipe catalog independent of reagent-use projections.
- `materials.source.json`, `recipe-uses.source.json`, generated `Materials.lua`, `RecipeUses.lua`, `Recipes.lua`, `Professions.lua` and `coverage-report.json` were rebuilt for the same accepted facts.
- Reagent-free source actions are represented in `Recipes.lua` without fabricating a consumed material. Existing profession indices and SavedVariables keys stay stable, with two professions appended.
- Extended local recipe metadata with skill/difficulty, teaching items, camping, owned Forever merchant IDs and offers (including currency/amount and supported faction), plus separately flagged borrowed acquisition IDs. No new recipe-following UI, learned-status claims or runtime network dependency.
- Authoritative per-record machine-readable diff: `addon/CraftAtlas/Data/reconciliation-report.json`; source/provenance: `addon/CraftAtlas/Data/recipes.source.json` and `docs/DATA_MODEL.md`.

### E. Validation and open acceptance

**Source comparison:** 12 source per-profession headers cross-checked with parsed record counts, 2,517 total before preservation, branch catalog 2,518. JSON projections use exactly 8,471 positive-input facts.

**Offline and CI evidence:** `tests/test_catalog_refresh.py`, `tests/test_material_data.py`, generated-data drift checks and repository Actions to be reviewed on the implementation PR. Do not mark checks PASS until they actually complete.

**Forever acceptance:** NOT RUN — verify all six camp entries, new enchant, zero-input actions, locale/filter, changed quantities, retained 28 anomalies, output types, tracking and bank behavior with exact client-build record. **Archival blocked** until acceptance is recorded and owner merges the implementation.

### F. Documentation-sync review

`README.md`, `docs/DATA_MODEL.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, `docs/TESTING.md` and `CHANGELOG.md` were reconciled against source and updated. `docs/OPENSPEC_STATUS.md` was reviewed but left unchanged because blocked implementations may not modify that protected lifecycle ledger. `docs/INSTALLATION.md` and `docs/DEVELOPMENT.md` remain unchanged because install/dev commands do not change and their paths are not in approved implementation scope. `AGENTS.md`, `openspec/README.md`, `docs/SDD_COMPLIANCE.md` and proposal/design/delta spec are unchanged governance/immutable approval artifacts.

### UI finding during owner acceptance — Herbalism icon (2026-11-26)

- **OWNER-REPORTED FAIL (screenshot):** Materiales detail for itemID `8925` (Crystal Vial) lists Herbalism, but its profession artwork rendered as the question-mark fallback. Cause: the newly registered `HERBALISM` and `SKINNING` keys were missing from `GetExplorerProfessionIcon` in `Features/Settings/Shared/ExplorerWidgets.lua`.
- **FIX IN IMPLEMENTATION BRANCH:** map HERBALISM to the client icon path `Interface\\Icons\\Trade_Herbalism` and SKINNING to `Interface\\Icons\\INV_Misc_Pelt_Wolf_01`. Added offline regression assertions in `tests/test_shared_widgets.lua` for both. The data identities and ingredient facts remain unchanged.
- **RETEST NOT RUN:** owner to verify both icons in the actual Forever client after installing this PR build; do not convert the screenshot failure into PASS without a new observation.

### Tracking toggle regression — owner report (2026-11-26)

- **OWNER-REPORTED FAIL:** `Seguir fabricación` on Fabricables no longer stays checked or enables progress in the actual game. The bank toggle uses the same problematic callback conversion. **Root cause in current callback:** `GetChecked() == true` rejects a numeric `1` return from the native classic WoW `UICheckButtonTemplate`; rerender then restores the unchecked state. This was not detected because the prior Lua mock returned booleans.
- **FIX IN IMPLEMENTATION BRANCH:** normalize native `GetChecked()` values (boolean `true` or numeric `1`) for both the global tracking and bank checkboxes in `RecipesView.lua`, and make the `tests/test_craftable_tracking.lua` UI mock use the native 1/nil convention. Test enabling/disabling both preferences and retaining tracking across recipe navigation.
- **RETEST NOT RUN:** owner to verify both toggle behaviors, recipe navigation, `/reload`, bag/bank counts and progress in the supported actual Forever client. Do not mark live acceptance PASS until observed.

### Tracking toggle retest failed after numeric normalization — investigation (2026-11-26)

- **OWNER-REPORTED FAIL AGAIN:** The prior conversion of numeric `GetChecked() == 1` did not restore either checkbox state or visible material tracking on the actual Forever client; the first proposed root cause was therefore insufficient, and must not be called a verified fix.
- **Additional suspected failure path:** `SetCraftTrackingEnabled` silently returns `false` when `UnitName("player")` or `GetRealmName()` is unavailable at the click; the subsequent `render()` redraws an unchecked box. Added `UnitFullName("player")` fallback without changing the existing `realm:name` SavedVariables format; UI now prints an explicit failure diagnostic if persistence is rejected, both for tracking and bank.
- **EVIDENCE:** offline tests cover identity fallback and numeric checkbox state. **Real-client root cause and fix: NOT YET VERIFIED.** On the next owner test, check for the new `CraftAtlas: tracking not saved; character/realm identity unavailable` chat message, and inspect SavedVariables if the visual behavior still fails. Do not mark the checkbox issue resolved merely because CI passes.
