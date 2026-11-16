# Testing strategy and evidence

Automated tests, maintainer-reported game checks and source-data verification are three **distinct** categories. Do not mark one as proof of the others.

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

The owner supplied an actual WoW Forever screenshot of Fabricables during first-use processing, showing the Spanish progress label at **66%**, partial result count, and visible native recipe details. This demonstrates that the intermediate build rendered the percentage and continued showing results; it is **not** a measured frame-rate improvement, and not proof of finished loading, compact-scale compatibility, or name-cache completeness. The owner requested a visual refinement because the label/bar sat too close to the header's gold divider. The subsequent revision moves the progress indicator out of the cramped title header and into the unused toolbar band between Fabricables and Back. A second owner screenshot showed that stretching the track across the entire toolbar separated the tiny fill at 11% from its centered label. The latest revision centers a **width-capped 6px track immediately beneath the high-contrast label**, using 130–252px depending on panel width while the holder remains anchored to both neighboring controls, with no additional frames per update. **This latest appearance: NOT RUN** in Forever. **This revised appearance: NOT RUN** in the client, awaiting owner screenshot and review. The large yellow "Captura de pantalla realizada" message visible over the recipe detail is a screenshot notification, not a CraftAtlas widget.

## Catalog preparation regression and performance protocol

The optimization implementation adds `tests/test_catalog_progress.lua` (progress math and one-refresh gate), `tests/test_catalog_preparation.lua` (20/25-unit fake-timer schedules, no duplicate workers), `tests/test_catalog_scheduler_failure.lua` (missing scheduler), `tests/test_catalog_header.lua` (native bounded indicator) and `tests/test_catalog_progress_contract.py` (source/refresh/locale constraints). **Standalone Lua tests and Forever-client profiling: NOT RUN in the connector-only implementation environment.** The Python CI checks exercise source contracts, but do not simulate frame timing or confirm FPS gains.

**How to capture real evidence (owner):** on the same client build/hardware/UI scale/locale, compare a fresh `/reload` with baseline v0.2.0 and this implementation branch. Open Materiales, switch to Fabricables, repeat opening and switching; note visible stutter, time until progress disappears, missing name counts, Lua errors, worst observed FPS/frame-time. After each initial load run `/craftatlas perf` in the optimized branch to capture item/recipe work units, batch counts and worst observed batch times (when supported), search and refresh counts. Source-level baseline had roughly 30 material batches and 101 recipe batches each requesting full-view updates; these are **derived from queue lengths**, not measured render counts. Record real measured improvements or regressions, without asserting a predetermined FPS benefit. Test enUS/esES, 800×600 and compact UI scale, no timer API, missing client metadata, rapid typing, Back and tooltip navigation. Completion at 100% must **not** imply all names are resolved.

Implementation PR: [#38](https://github.com/hectoresen/CraftAtlas/pull/38), owner-approved OpenSpec proposal PR #37. Real-client benchmarking and full interaction checks remain **NOT RUN** until the maintainer tests this exact branch; prior screenshot approvals relate to the v0.2.0 UI and are not runtime performance evidence.

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

## Final profession density / title / release preparation

The owner requested four visible consuming professions without pager for three or four matches. The implementation uses a width-aware, bounded profession row (four on normal panes, two on compact panes), hides horizontal pager controls unless there are more entries, and centers the CraftAtlas title vertically and horizontally. The tiny bottom-right footer reads only the **official packaged version**. The tracked development manifest is `0.2.0-dev`, not an official v0.2.0 release. When merged, the owner must run the release workflow with **minor** increment against the existing v0.1.0 tag; the workflow derives v0.2.0 and rewrites ZIP metadata. The source checkout must not claim to be a published release. Added Lua tests for page thresholds and official versus development version. Latest in-client verification: **NOT RUN**.

## Fabricables detail and inline-clear refinement

Added `tests/test_fabricables_detail.lua` for the native ingredient-section title/collapse and changes to `tests/test_shared_widgets.lua` for the embedded search X, input focus and empty/nonempty visibility. Existing pagination, item tooltip and navigation semantics remain required. **New in-game detail and inline-clear visual acceptance: NOT RUN**, awaiting owner retest.

## Grouped-tree implementation evidence

The implementation branch `feat/native-wow-profession-tree-redesign` adds new native divider/section UI mock coverage and pure grouping and state regression tests, native vertical recipe row mocks, item metadata and search-clear icon tests, release version tests, locale checks and viewport geometry tests. The connected repository interface does not provide an executable local checkout. **The following were NOT RUN in this implementation environment** pending CI or a local developer checkout: `bash scripts/validate_release_checks.sh`, `python3 scripts/build_materials.py --check`, `python3 -m unittest discover -s tests -v`, all `texlua` suites and strict `openspec validate`. This is not a declaration of passing test results; check the implementation PR's GitHub Actions for executed CI evidence.

**Owner screenshot evidence:** the owner supplied successive real-client screenshots of Materiales and Fabricables (including the grouped tree, native selectors, ingredient and crafting-use rows) and approved the general appearance. The final four-profession pagination, centered title and release-version footer have not been separately retested. **Full Forever acceptance: NOT RUN** for the refined build. The previous maintainer acceptance of PRs #23/#25 does not cover the grouped profession tree, the current inline clear X, tooltip interactions or compact layouts. Owner must record an exact build, enUS/esES, itemIDs 2447/159/14341/14044 and spell 19093, unknown names, non-item action, long list and scale screenshots before approving a release.

Record build, screenshots, IDs, locale, UI scale, commands executed, results and explicitly untested cases. **Working addon ≠ live-verified recipe catalog.**

## In-game defect: opening material detail (owner report, 2026-11-16)

The owner reported a reproducible Lua error opening the redesigned explorer: `Settings.lua:159: attempt to index field 'detailHeading' (a nil value)` with selected material itemID 765. The obsolete heading was removed when `createProfessionDetail()` replaced it. The implementation branch now refreshes `ui.professionUses.section` instead and includes `tests/test_explorer_detail_contract.py` to detect stale frame references. **Fix in Forever:** subsequent owner screenshots show Materiales opening and rendering selected details without this crash. A full scripted regression matrix remains NOT RUN; CI and screenshots are separate evidence.

## Owner visual comparison: second in-game capture (2026-11-16)

The owner confirmed the post-crash revision opens and displays a selected material, but does **not** accept the overall visual fidelity to the reference. Observed on the provided capture: a clipped border emblem, an apparent question-mark search-clear icon, unrendered profession disclosure glyph, low-contrast search hint, and weak visual hierarchy/density. The implementation branch removes the clipped border emblem, uses native plus/minus disclosure artwork and an inline panel-close X for active search text, improves group/section contrast and row spacing, and restores Classic red buttons and uses guarded Blizzard dropdown APIs for profession/language (with fallback), plus native disclosure icons; controls still require in-game validation. The owner subsequently supplied a Fabricables screenshot showing the restored native red buttons and Blizzard selectors. **The latest inline-clear and collapsible-ingredient refinements have NOT RUN in the real Forever client**. Do not mark full visual acceptance complete.
