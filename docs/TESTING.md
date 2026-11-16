# Testing strategy and evidence

Automated tests, maintainer-reported game checks and source-data verification are three **distinct** categories. Do not mark one as proof of the others.

## Evidence snapshot for current `main` (reconciled 2026-11-16)

| Area | Present on `main` | In-game evidence | Still missing |
| --- | --- | --- | --- |
| Materiales/Fabricables original explorer (#23/#25) | **Merged**; later replaced/enhanced by #36 | Owner reported previous UI functioning and accepted | Exact build and full origins/locale/scale matrix |
| Grouped tree, vertical crafting-use rows, inline clear and detail layout (#36) | **Merged** | Screenshots show material details after crash fix, and native Fabricables buttons/selectors | Final four-profession/compact pane, inline clear, collapsible ingredient and full navigation regression: **NOT RUN** as a complete matrix |
| Preparation progress (#38) | **Merged** | Owner screenshot showed **intermediate** 66% progress and partial results | **Final** width-capped bar layout and repeatable before/after FPS measurements: **NOT RUN** |
| Material tooltip styling (#40) | **Merged** | Named offline Lua regression fixtures exist | Visual comparison on actual Forever, multiple origins, enUS/esES: **NOT RUN** |
| Lua 5.1 CI and OpenSpec gates (#42/#47/#50) | **Merged** | Automated checks and archival policy are repository-governance evidence, not gameplay evidence | Two-user ruleset approval behavior and actual game-client compatibility across all surfaces remain unverified |

**Interpretation:** `NOT RUN` in an older PR implementation environment means that particular command or client scenario was not executed **there**, not that the feature never merged or that subsequent GitHub CI never ran. A screenshot confirms only the specific state it depicts. Source merged ≠ final visual acceptance ≠ full live-catalog verification. Keep those categories separate; do not reopen source implementation tasks simply because client evidence is incomplete.

## Addon configuration

Spec [#46](https://github.com/hectoresen/CraftAtlas/pull/46) was approved by the owner and merged before implementation. Offline, `tests/test_addon_configuration.lua` covers fresh and legacy records, individual invalid values and explicit false, native and fallback language selectors, compact viewport anchors, preserved search/filter/selection and Back history, dependent checkbox state, reload, slash recovery and reopening from the restored minimap button. `tests/test_material_tooltips.lua` covers both layouts with and without icons, visibility on rebuild, localized ordering, an unknown item, missing artwork and repeat callbacks with and without native clear events.

**Offline PASS:** 53 Lua files parsed and all 24 Lua fixtures passed using Lua 5.1 via Lupa. The shared release gate (`bash scripts/validate_release_checks.sh`), all 142 Python tests and `openspec validate --all --strict --no-interactive` (31 items) passed.

**Forever for this implementation: NOT RUN.** Record the exact client build, addon locales and UI scales. The following client acceptance remains open:

| Scenario | Forever result |
| --- | --- |
| Open from Materials and Craftables, then return with query, filter, selection and Back history preserved. Check controls and preparation progress at normal and compact scales. | **NOT RUN** |
| Change language from General and from the browsing header. Verify immediate translation, synchronized selection and persistence after `/reload`. | **NOT RUN** |
| Toggle the four checkboxes, reload, and verify persistence and disabled layout controls. Restore the hidden minimap button using `/craftatlas` and verify its saved angle and ordinary left-click. | **NOT RUN** |
| On each tested tooltip surface, use Copper Ore (`2770`), Linen Cloth (`2589`) and unknown item `25`. Compare default, disabled, icon-free and single-line combinations in enUS and esES. Verify rebuilt tooltips, native wrapping, no duplicates and unchanged native content. | **NOT RUN** |

The change remains active pending this client evidence.

## Minimap button interaction

Spec [#43](https://github.com/hectoresen/CraftAtlas/pull/43) covers edge tracking, release and reload, click behavior and localized hover text. `tests/test_minimap_button.lua` passed under Lua 5.1 via Lupa, including two minimap scales, a centered pointer and unavailable geometry, releases outside the map, drag releases with and without a click callback, first-click opening, preference restoration, and tooltip text, locale fallback and dismissal. All 22 isolated Lua fixtures passed and all 48 addon and test Lua files parsed. `bash scripts/validate_release_checks.sh`, `python3 -m unittest discover -s tests` (139 tests), and `openspec validate --all --strict --no-interactive` (30 items) passed.

On 2026-11-16, Codex exercised the installed copy of implementation commit `5c31b6f` in the contributor's live Forever session. All 39 tracked addon files matched the checkout. `GetBuildInfo()` reported `1.60.1.70938` (interface `16001`). The client locale was esES. The two measured minimap effective scales were 0.768 (automatic UI scale) and 1.020 (manual UI scale set to 0.85). In-game diagnostics read the native frame coordinates and mouse events during the drags.

| Acceptance case | Forever result |
| --- | --- |
| Ordinary left-click opens the same explorer as `/craftatlas`. | **PASS** at both scales. |
| The button center stays on the circular edge while moving. | **PASS** on the sampled drag paths at both scales. Four samples per scale, including release, stayed within 0.001 minimap units of the radius. A continuous full sweep was **NOT RUN**. |
| The pointer reaches the exact minimap center and the button keeps its last valid angle. | **NOT RUN** at the exact center in the client. The Lua fixture covers exact-center coordinates. |
| Release outside the map, move away, then left-click the icon. | **PASS** at both scales. The anchor matched the release angle, the explorer stayed closed, and the first ordinary left-click opened it. |
| Run `/reload` after a drag. | **PASS** at both scales. The icon returned to the saved angles of approximately −156.04° and 156.20°. |
| Hover for the title and two localized instructions, then move away. | **PASS** in Automatic with the esES client at scale 0.768 and in explicit enUS at scale 1.020. The tooltip closed on pointer exit. |
| Automatic falls back to English on a client locale other than esES. | **NOT RUN** in the client. The Lua fixture covers this fallback. |

## Native chat links / Fabricables detail icon — implementation branch evidence

Spec PR #52 was owner-merged. The implementation introduces `tests/test_chat_links.lua` for native item-vs-spell link selection, unsafe/missing API no-op behavior, chat editor handling and current-row identity contracts. **Standalone Lua command: NOT RUN in the connector-only authoring environment**; GitHub `lua-compatibility`/`lua-regressions` will provide CI evidence only when executed and observed. **Forever: NOT RUN** for Shift + left-click across Materiales/Fabricables uses, rows, ingredients, detail titles/icons, chat open/closed, two locales and UI scales; the exact client build has not been recorded. The removal of the extra `UI-Quickslot2` slot texture is source-confirmed, not yet visually verified in Forever. No release/live compatibility claim is made.

## Craftable material tracking — implementation evidence (spec #54)

The feature implementation branch introduces `Domain/CraftableTracking.lua`, `Infrastructure/InventoryCounts.lua`, per-character preferences and a native Fabricables tracking UI. `tests/test_craftable_tracking.lua` covers pure weighted progress, duplicate ingredients, unknown API data, bank open/closed and per-character persistence. Locale regression coverage is extended. **Standalone Lua and release/strict OpenSpec commands: NOT RUN in the GitHub connector authoring environment; evaluate actual CI results before merging.**

**Forever-client acceptance: PARTIAL / NOT ACCEPTED.** The maintainer supplied a live-client screenshot on 2026-11-16: initial tracker showed Spanish text under an English addon choice, invisible-looking 0% progress tracks and a summary visually disconnected from the required ingredients. The implementation branch now refreshes tracker labels on locale changes, restores **Ingredients** exactly to item/name/required `xN`, and renders a separate **Material progress** list with native Blizzard `StatusBar` instances, per-material observed/required and missing values at every percentage, optional bank contribution, and overall weighted completion. The isolated Lua fixture tests an empty confirmed bank as numeric zero, and contrasts bag-only vs included-bank progress. After another maintainer screenshot, the native StatusBar uses Blizzard's built-in UI-StatusBar fill and tooltip backdrop/border, with a lighter empty track. Compact geometry was tightened to fit three ingredient/tracker rows at a 440px logical detail pane; an offline fixture asserts the third row and four native bars are all visible. The visual result is still NOT RUN in the actual game. These corrections are **NOT RUN in Forever** until a new test is supplied. The screenshot does not verify bank semantics, inventory refresh, or acceptance. Remaining scenarios: Record exact build and outcomes for live bag changes, bag empty/partial/full, bank open/closed, bank count freshness, multiple recipes, reload and character isolation, missing input recipes, esES/enUS labels, compact scale, existing pagination and Shift-click. **Bank counted as confirmed only while open; this is a conservative implementation choice, not proven API behavior on the real build.** Treat the spec archive as blocked until mandatory evidence is obtained.


**Visual regression after compact layout retest (2026-11-16):** Maintainer screenshot shows that 19px tracker rows made material names, missing labels, and bars overlap. The follow-up source fix uses 23px rows with explicit separate baselines, a 10px native bar fully inside each row, and safe spacing after the bank checkbox. Lua regression now checks vertical bounds, not only the number of rows. The corrected appearance in Forever is **NOT RUN** and requires another screenshot/acceptance before merging.

**Further layout revision (2026-11-16):** The maintainer screenshot still showed compressed labels in the 23px two-baseline tracker rows. The feature now renders each tracker as a single line containing material name and available/required/missing, followed by a full-width native status bar, with 25px row spacing. The layout assertions cover title/summary anchoring and bar bounds, including three ingredients at compact UI height. **Forever retest: NOT RUN** for this revision.

**Bank enumeration regression (2026-11-16):** Maintainer captured an open bank containing visible Hojaplata (Silverleaf) stacks while the previous `C_Item.GetItemCount(itemID, true)` adapter showed `0/1`, despite reading other materials correctly. The implementation now scans the active Forever Classic bank containers (`-1`, bank bags `5..11`) using guarded `C_Container.GetContainerNumSlots` and `C_Container.GetContainerItemInfo`, with support for legacy APIs, before trusting native combined counts. `tests/test_craftable_tracking.lua` reproduces 35 banked Silverleaf versus a broken native count of 0; tests zero-bank, multi-stack and bag-plus-bank arithmetic. **Actual Forever retest: NOT RUN** on the revised adapter. Do not claim this report fixed until the maintainer confirms the live bank count.

**Maintainer Forever confirmation (2026-11-16):** After the bank-slot enumeration correction on PR #55, the maintainer explicitly confirmed **“ya funciona”** in the context of the previously failing open-bank Silverleaf/Hojaplata stock count. This is **owner-reported PASS for the previously failing open-bank material availability scenario**; screenshot before the fix showed a bank with Silverleaf but 0/1 in the tracker. Do not infer an exact Forever build, counts after the fix, bank-closed behavior, both locales, character isolation, reload persistence, empty/complete bags or all compact-scale cases from this confirmation. Those unobserved acceptance scenarios remain **NOT RUN / NOT EVIDENCED**; therefore the change remains active and archive blocked.

**Native progress color semantics (2026-11-16):** status bars show no fill for zero, amber/yellow for any nonzero incomplete material coverage, and green when the required units are fully present and observed. Total follows the same rule, weighted by required ingredient units and never green for unverified completion. Lua regression checks partial (60%), full (100%) and native bar colors. Final Forever screenshot for these color changes is NOT RUN.

## Automated PR and release gate

The same command is used by `.github/workflows/ci.yml` and `.github/workflows/publish-release.yml`:

```sh
bash scripts/validate_release_checks.sh
```

It runs repository validation, Python catalog/generator regressions, `scripts/build_materials.py --check` and package/release tests. SDD Compliance separately runs OpenSpec traceability, validator tests and strict OpenSpec validation.

For additional local diagnostics:

```sh
python3 scripts/coverage_report.py
python3 -m unittest discover -s tests -p 'test_toc_modules.py' -v
texlua tests/test_addon.lua
texlua tests/test_material_search.lua
texlua tests/test_recipe_usage.lua
texlua tests/test_recipe_info.lua
texlua tests/test_recipe_pagination.lua
texlua tests/test_recipe_cards.lua
texlua tests/test_explorer_close.lua
texlua tests/test_explorer_layout.lua
texlua tests/test_recipe_catalog.lua
texlua tests/test_shared_widgets.lua
texlua tests/test_profession_tree.lua
texlua tests/test_release_version.lua
texlua tests/test_explorer_locales.lua
texlua tests/test_catalog_progress.lua
texlua tests/test_catalog_preparation.lua
texlua tests/test_catalog_scheduler_failure.lua
texlua tests/test_catalog_header.lua
```

Run applicable commands in a local checkout with a compatible interpreter. **This document does not claim each Lua command was executed in CI.** `python3 scripts/build_materials.py --release --check` includes a stricter catalog live-evidence gate and may intentionally reject a snapshot without full accepted evidence.

## Owner screenshot: intermediate Fabricables progress (2026-11-16)

The owner supplied an actual WoW Forever screenshot of Fabricables during first-use processing, showing the Spanish progress label at **66%**, partial result count, and visible native recipe details. This demonstrates that the intermediate build rendered the percentage and continued showing results; it is **not** a measured frame-rate improvement, and not proof of finished loading, compact-scale compatibility, or name-cache completeness. The owner requested a visual refinement because the label/bar sat too close to the header's gold divider. The subsequent revision moves the progress indicator out of the cramped title header and into the unused toolbar band between Fabricables and Back. A second owner screenshot showed that stretching the track across the entire toolbar separated the tiny fill at 11% from its centered label. The latest revision centers a **width-capped 6px track immediately beneath the high-contrast label**, using 130–252px depending on panel width while the holder remains anchored to both neighboring controls, with no additional frames per update. **Final width-capped appearance in Forever: NOT RUN** (the screenshot demonstrates the previous intermediate state, not the latest revision). The large yellow "Captura de pantalla realizada" message visible over the recipe detail is a screenshot notification, not a CraftAtlas widget.

## Catalog preparation regression and performance protocol

The optimization implementation adds `tests/test_catalog_progress.lua` (progress math and one-refresh gate), `tests/test_catalog_preparation.lua` (20/25-unit fake-timer schedules, no duplicate workers), `tests/test_catalog_scheduler_failure.lua` (missing scheduler), `tests/test_catalog_header.lua` (native bounded indicator) and `tests/test_catalog_progress_contract.py` (source/refresh/locale constraints). **Standalone Lua tests and Forever-client profiling were NOT RUN in the original connector-only implementation environment.** The implementation later merged in PR #38 and GitHub Actions provides separately recorded automated validation. Neither source contracts nor CI prove frame timing or FPS gains.

**How to capture real evidence (owner):** on the same client build/hardware/UI scale/locale, compare a fresh `/reload` with baseline v0.2.0 and this implementation branch. Open Materiales, switch to Fabricables, repeat opening and switching; note visible stutter, time until progress disappears, missing name counts, Lua errors, worst observed FPS/frame-time. After each initial load run `/craftatlas perf` in the optimized branch to capture item/recipe work units, batch counts and worst observed batch times (when supported), search and refresh counts. Source-level baseline had roughly 30 material batches and 101 recipe batches each requesting full-view updates; these are **derived from queue lengths**, not measured render counts. Record real measured improvements or regressions, without asserting a predetermined FPS benefit. Test enUS/esES, 800×600 and compact UI scale, no timer API, missing client metadata, rapid typing, Back and tooltip navigation. Completion at 100% must **not** imply all names are resolved.

Implementation PR [#38](https://github.com/hectoresen/CraftAtlas/pull/38) **merged on 2026-11-16**, following approved spec PR #37. Real-client benchmarking and the final progress-bar/interaction matrix are still **NOT RUN**; older screenshots are not runtime performance evidence.

## Reported in-game acceptance

The maintainer reported that the previous material explorer's six-card pagination and native close control worked in Forever (merged PR #23), and that the revised **Materiales / Fabricables** interface was tested and accepted (merged PR #25). Earlier in-game screenshots helped correct cached item icons/names, profession-label/section-title overlap, misplaced Back navigation and visible result density.

This is user-reported **functional acceptance**, not proof of all possible client conditions. The exact client build, UI-scale matrix and test logs for bank, guild bank, vendor, auction, chat links, mail and quest rewards were not independently recorded. Do not retroactively check them off.

## Manual game-client matrix for subsequent releases

- Record exact Forever build and Lua errors at startup and on `/craftatlas` and `/craftatlas <itemID>`.
- Inspect grouped Materiales search, profession filter, unique global counts, per-group matching counts, multi-profession entries, group collapse/restore, row recycling, non-row profession divider appearance, source-backed native profession icons with pagination/section collapse, recipe-area reflow/page-size restoration, client item metadata and vertical use pagination at multiple UI scales.
- Inspect Fabricables by spell/name, crafted-output name, numeric ID and profession; distinguish missing spell name cache from genuine empty results.
- Compare every ingredient and quantity for a selected verified recipe to the current live client (e.g., spell 19093 consumes items 14044, 14341 and 15410 in the pinned source). Confirm correct enchantment/non-item fallback.
- Verify native tooltip data for items and recipes; no fabricated quality, stats or learned/craftable status.
- Verify material → craftable → ingredient → material navigation, Back history, preserved searches, languages, search-clear X inside the input (hidden while empty, shown after typing, click clears and returns focus), installed release version/hidden development version and X close/reopen from minimap and slash.
- Test separate tooltip origins (bags, bank, guild bank, chat, auction, vendor, mail, quest rewards and crafting); record each as PASS/FAIL/NOT RUN.
- Check source licenses/provenance, current-server recipe mapping and any known gaps before claiming live completeness.

## Expanded material tooltip verification

Run `lua tests/test_material_tooltips.lua`. The Lua 5.1.5 fixture passed the approved layout and order for Copper Ore (`2770`) and Linen Cloth (`2589`), verified Silverleaf (`765`) still displays only Alchemy, and exercised unknown and protected tooltips, a missing icon, gold fallback, language changes, repeated callbacks and tooltip rebuilds. The broader Lua run passed 12 of 16 files. `test_addon.lua`, `test_item_info.lua`, `test_recipe_cards.lua` and `test_release_version.lua` failed with the same errors on a clean `main` at `29d6a1b`.

**Final Forever visual comparison for the styled tooltip: NOT RUN** (the offline fixtures below are a different kind of evidence). Compare CraftAtlas and the pinned Profession Reagents build separately at matching locale and UI scale. Use `2770` and `2589` for appearance, `765` for differing catalog membership, and `25` as the unknown control. Switch between enUS and esES, exercise quick hover and rebuilds in bags and chat item links, and record the Forever build, scales, screenshots and each surface's outcome. The source lookup for icon identifiers does not establish that a texture displayed in the client.

## Final profession density / title / release preparation

The owner requested four visible consuming professions without pager for three or four matches. The implementation uses a width-aware, bounded profession row (four on normal panes, two on compact panes), hides horizontal pager controls unless there are more entries, and centers the CraftAtlas title vertically and horizontally. The tiny bottom-right footer reads only the **official packaged version**. The tracked development manifest is `0.2.0-dev`, not an official v0.2.0 release. When merged, the owner must run the release workflow with **minor** increment against the existing v0.1.0 tag; the workflow derives v0.2.0 and rewrites ZIP metadata. The source checkout must not claim to be a published release. Added Lua tests for page thresholds and official versus development version. Final in-client density/title/footer verification: **NOT RUN**; these changes are already present in `main`.

## Fabricables detail and inline-clear refinement

Added `tests/test_fabricables_detail.lua` for the native ingredient-section title/collapse and changes to `tests/test_shared_widgets.lua` for the embedded search X, input focus and empty/nonempty visibility. Existing pagination, item tooltip and navigation semantics remain required. **Final in-game detail and inline-clear interaction matrix: NOT RUN**, awaiting documented owner retest; merged source and offline tests do not establish final visual acceptance.

## Grouped-tree implementation evidence

The implementation merged in PR #36 (historically developed on `feat/native-wow-profession-tree-redesign`) added new native divider/section UI mock coverage and pure grouping and state regression tests, native vertical recipe row mocks, item metadata and search-clear icon tests, release version tests, locale checks and viewport geometry tests. The connected repository interface does not provide an executable local checkout. **The following were NOT RUN in the original connector-only implementation environment** (historical record, not a claim that the later merged PR #36 lacked CI): `bash scripts/validate_release_checks.sh`, `python3 scripts/build_materials.py --check`, `python3 -m unittest discover -s tests -v`, all `texlua` suites and strict `openspec validate`. This is not a declaration of passing test results; check the implementation PR's GitHub Actions for executed CI evidence.

**Owner screenshot evidence:** the owner supplied successive real-client screenshots of Materiales and Fabricables (including the grouped tree, native selectors, ingredient and crafting-use rows) and approved the general appearance. The final four-profession pagination, centered title and release-version footer have not been separately retested. **Full documented Forever acceptance matrix: NOT RUN** for the final refined build (the owner did provide partial in-client screenshots). The previous maintainer acceptance of PRs #23/#25 does not cover the grouped profession tree, the current inline clear X, tooltip interactions or compact layouts. Owner must record an exact build, enUS/esES, itemIDs 2447/159/14341/14044 and spell 19093, unknown names, non-item action, long list and scale screenshots before approving a release.

Record build, screenshots, IDs, locale, UI scale, commands executed, results and explicitly untested cases. **Working addon ≠ live-verified recipe catalog.**

## In-game defect: opening material detail (owner report, 2026-11-16)

The owner reported a reproducible Lua error opening the redesigned explorer: `Settings.lua:159: attempt to index field 'detailHeading' (a nil value)` with selected material itemID 765. The obsolete heading was removed when `createProfessionDetail()` replaced it. The implementation branch now refreshes `ui.professionUses.section` instead and includes `tests/test_explorer_detail_contract.py` to detect stale frame references. **Fix in Forever:** subsequent owner screenshots show Materiales opening and rendering selected details without this crash. A full scripted regression matrix remains NOT RUN; CI and screenshots are separate evidence.

## Owner visual comparison: second in-game capture (2026-11-16)

The owner confirmed the post-crash revision opens and displays a selected material, but does **not** accept the overall visual fidelity to the reference. Observed on the provided capture: a clipped border emblem, an apparent question-mark search-clear icon, unrendered profession disclosure glyph, low-contrast search hint, and weak visual hierarchy/density. The implementation branch removes the clipped border emblem, uses native plus/minus disclosure artwork and an inline panel-close X for active search text, improves group/section contrast and row spacing, and restores Classic red buttons and uses guarded Blizzard dropdown APIs for profession/language (with fallback), plus native disclosure icons; controls still require in-game validation. The owner subsequently supplied a Fabricables screenshot showing the restored native red buttons and Blizzard selectors. **The latest inline-clear and collapsible-ingredient refinements have NOT RUN in the real Forever client**. Do not mark full visual acceptance complete.

## Contributor PR quality gates (implementation of approved PR #41)

Merged PR #42 added **lua-compatibility**: install the explicit Lua 5.1 interpreter and parse every addon and test Lua module with `luac5.1 -p`. **lua-regressions** runs every isolated `tests/test_*.lua` with `lua5.1` and fails on the first non-zero exit, including pre-existing failures; this is not a World of Warcraft integration test. `repository-validation` retains the shared release-readiness, Python/data and documentation review gate; `traceability` retains strict OpenSpec/SDD validation. Workflow PRs run under read-only token permissions without privileged `pull_request_target` execution.

A stale fixture `tests/test_addon.lua` previously contained Markdown instead of Lua and is replaced by a genuine pure-domain smoke test. PR #42 subsequently merged and both `lua-compatibility` and `lua-regressions` are configured as required checks in the active main ruleset, alongside `repository-validation` and `traceability`. This does not certify in-game behavior. The developer environment lacks a networked checkout; exact local shell/Lua commands are **NOT RUN** unless stated separately. Actual two-user rule enforcement is **NOT RUN**, although both rulesets' configuration has been checked via API. No addon runtime features changed, so additional in-game Forever testing is not required for this governance change.

### Change-aware GitHub Actions execution

The CI workflow classifies the **actual changed paths** against the base commit using a fail-closed read-only `classify-pr` job. A pure `openspec/changes/**` or `openspec/specs/**` PR runs SDD/OpenSpec verification only; `repository-validation` stays present as a tiny success status because GitHub already requires that name, and heavy Python release checks and both Lua jobs are skipped. A pure Markdown/text PR runs only lightweight repository Markdown validation and SDD scope/provenance verification, without Lua/Python catalog/package tests or installing OpenSpec CLI. **Any source code, workflow, script, non-doc file, or mixed code+docs PR** gets the full release-readiness, policy and Lua 5.1 suites plus full OpenSpec validation. Classification failure makes the required `repository-validation` check fail; it cannot silently skip enforcement. GitHub reports intentional skipped Lua jobs as skipped/success for requirements, not tests executed. `push main` also classifies the last pushed diff; manual release runs its independent full validation unchanged.

## Same-PR archive validation

The SDD regression suite now tests the normal implementation `OpenSpec-Archive: prepared|blocked` contract: lossless approved copies of proposal/design/delta/scope, dated same-change archive, fully preserved task descriptions, synchronized named canonical capabilities, explicit status evidence, and rejection of incomplete/malicious/foreign archives. Missing approved client evidence must be `blocked`; status may not claim gameplay proof based on offline tests. SDD tests are not a real WoW Forever run. The project-scoped `lifecycle` legacy reconciliation remains unchanged. The stable required checks and docs-only/spec-only fast paths remain in place.

Archive transaction for merged PR #47: the approved same-change copy and canonical capability entered `main` together. SDD `traceability` passed on its archival commit `43a0b7a821cd41d4979a9da991d8d2b0a23c345c`; the implementation is now merged, not merely prepared. This is governance evidence, not a live-client test.

## Typed spec/branch and required-check regression tests

The rollout regression covers implementations of the three approved proposals that merged after the frozen naming baseline. It exercises the original PR number and change ID pairs, a mismatched or absent approval reference, owner review, the approved artifacts on `main`, scope enforcement, and LF/CRLF PR metadata. The corrected validator passed a local replay using PR #60's actual diff, Windows line endings, and the approval pulled from GitHub. The validator on `main` failed the same replay with both line-ending variants. The actual `traceability` rerun on #60 is pending the validator change on `main`.

`tests/test_validate_sdd.py` exercises lowercase, padded type IDs for FEAT/FIX/CHORE/UPD/DEL, exact uppercase proposal/implementation branch derivation, rejected malformed/uppercase OpenSpec IDs, per-type sequence reservations against active/archived specs and open GitHub PRs, grandfathered legacy PRs, and the separation of an actual skipped Lua job from an **absent** required check-run. Pure-spec PRs should not execute Lua suites. A repo connector or GitHub Actions permission may prevent automatic event chaining; the agent must re-read actual current-head check-runs after its single metadata edit. No fixture can prove GitHub will dispatch its event.

## Contributor-review governance validation (implementation of spec #58)

Added SDD regression scenarios for a contributor-merged owner-approved specification; missing, dismissed, changes-requested, third-party or post-merge owner review; and missing trustworthy PR author. Test suite and strict OpenSpec validation **NOT RUN locally** because this change was authored through the GitHub connector; GitHub CI job evidence on the implementation PR is the required verification. Two-account live GitHub review behavior and 'Require review from Code Owners' settings change remain **NOT RUN** until the repository administrator enables and verifies the review ruleset. Existing SDD scope/chronology, release and CI bypass prohibitions remain required. For historical #44, GitHub review listing shows APPROVED by @hectoresen at 2026-11-16T16:07:45Z; do not require duplicate #57 merely due to the merger's identity.
