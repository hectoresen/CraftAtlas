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
```

Run applicable commands in a local checkout with a compatible interpreter. **This document does not claim each Lua command was executed in CI.** `python3 scripts/build_materials.py --release --check` includes a stricter catalog live-evidence gate and may intentionally reject a snapshot without full accepted evidence.

## Reported in-game acceptance

The maintainer reported that the previous material explorer's six-card pagination and native close control worked in Forever (merged PR #23), and that the revised **Materiales / Fabricables** interface was tested and accepted (merged PR #25). Earlier in-game screenshots helped correct cached item icons/names, profession-label/section-title overlap, misplaced Back navigation and visible result density.

This is user-reported **functional acceptance**, not proof of all possible client conditions. The exact client build, UI-scale matrix and test logs for bank, guild bank, vendor, auction, chat links, mail and quest rewards were not independently recorded. Do not retroactively check them off.

## Manual game-client matrix for subsequent releases

- Record exact Forever build and Lua errors at startup and on `/craftatlas` and `/craftatlas <itemID>`.
- Inspect grouped Materiales search, profession filter, unique global counts, per-group matching counts, multi-profession entries, group collapse/restore, row recycling, non-row profession divider appearance, source-backed native profession icons with pagination/section collapse, recipe-area reflow/page-size restoration, client item metadata and vertical use pagination at multiple UI scales.
- Inspect Fabricables by spell/name, crafted-output name, numeric ID and profession; distinguish missing spell name cache from genuine empty results.
- Compare every ingredient and quantity for a selected verified recipe to the current live client (e.g., spell 19093 consumes items 14044, 14341 and 15410 in the pinned source). Confirm correct enchantment/non-item fallback.
- Verify native tooltip data for items and recipes; no fabricated quality, stats or learned/craftable status.
- Verify material → craftable → ingredient → material navigation, Back history, preserved searches, languages, clear-search broom (asset visibility without item-cache metadata, empty state and safe fallback), installed release version/hidden development version and X close/reopen from minimap and slash.
- Test separate tooltip origins (bags, bank, guild bank, chat, auction, vendor, mail, quest rewards and crafting); record each as PASS/FAIL/NOT RUN.
- Check source licenses/provenance, current-server recipe mapping and any known gaps before claiming live completeness.

## Grouped-tree implementation evidence

The implementation branch `feat/native-wow-profession-tree-redesign` adds new native divider/section UI mock coverage and pure grouping and state regression tests, native vertical recipe row mocks, item metadata and search-clear icon tests, release version tests, locale checks and viewport geometry tests. The connected repository interface does not provide an executable local checkout. **The following were NOT RUN in this implementation environment** pending CI or a local developer checkout: `bash scripts/validate_release_checks.sh`, `python3 scripts/build_materials.py --check`, `python3 -m unittest discover -s tests -v`, all `texlua` suites and strict `openspec validate`. This is not a declaration of passing test results; check the implementation PR's GitHub Actions for executed CI evidence.

**Owner screenshot evidence:** the owner supplied an in-game screenshot of the earlier grouped-tree implementation and identified visual hierarchy defects. This verifies that an earlier version rendered on the client, not that the latest section/divider refinements work. **Full Forever acceptance: NOT RUN** for the refined build. The previous maintainer acceptance of PRs #23/#25 does not cover the grouped profession tree, broom icon availability, tooltip interactions or compact layouts. Owner must record an exact build, enUS/esES, itemIDs 2447/159/14341/14044 and spell 19093, unknown names, non-item action, long list and scale screenshots before approving a release.

Record build, screenshots, IDs, locale, UI scale, commands executed, results and explicitly untested cases. **Working addon ≠ live-verified recipe catalog.**

## In-game defect: opening material detail (owner report, 2026-11-16)

The owner reported a reproducible Lua error opening the redesigned explorer: `Settings.lua:159: attempt to index field 'detailHeading' (a nil value)` with selected material itemID 765. The obsolete heading was removed when `createProfessionDetail()` replaced it. The implementation branch now refreshes `ui.professionUses.section` instead and includes `tests/test_explorer_detail_contract.py` to detect stale frame references. **Fix in Forever: NOT RUN**, awaiting owner retest; CI and local test evidence are separate.

## Owner visual comparison: second in-game capture (2026-11-16)

The owner confirmed the post-crash revision opens and displays a selected material, but does **not** accept the overall visual fidelity to the reference. Observed on the provided capture: a clipped border emblem, an apparent question-mark search-clear icon, unrendered profession disclosure glyph, low-contrast search hint, and weak visual hierarchy/density. The implementation branch removes the clipped border emblem, uses a cache-independent native broom texture path, Classic-safe ASCII disclosure characters, improves group/section contrast and row spacing, and restores Classic red buttons and uses guarded Blizzard dropdown APIs for profession/language (with fallback), plus native disclosure icons; controls still require in-game validation. **These visual corrections have NOT RUN in the real Forever client**; an owner screenshot from the corrected commit is still required. Do not mark full visual acceptance complete.
