# CraftAtlas

> **Maintenance mode (since 2026-11-18).** No new features are planned until further notice. Work is limited to bug fixes, client compatibility, security, release maintenance and documentation corrections. The official latest release is [v0.4.2](https://github.com/hectoresen/CraftAtlas/releases/tag/v0.4.2). Historical OpenSpec changes can remain active where acceptance evidence is incomplete; this is not a new-feature backlog.

**CraftAtlas** is an offline, MIT-licensed addon for **World of Warcraft: Forever**. It shows which professions consume an item's materials and lets players explore materials and craftable results without requiring the character to know a profession.

**Source manifest:** `0.2.0-dev` (see `addon/CraftAtlas/CraftAtlas.toc`); the explorer hides the version for development or unknown builds and displays only the installed release manifest version for official packages. The latest official packaged release is **v0.4.2** (2026-11-22); the maintainer has accepted subsequent functional behavior including global crafting tracking, but comprehensive client matrices remain separate. This is not a claim that every imported recipe is available on the current live realm or that every client/tooltip origin has been individually tested.

## Current features

- **Material tooltips** add a gold **Used in:** / **Utilizado en:** heading and, by default, one white row per source-backed consuming profession to supported item tooltips. Rows are alphabetized in the addon language and show native profession icons where available. Unknown items receive no annotation.
- **Materiales / Materials:** searchable catalog grouped into collapsible consuming-profession sections with accurate matching per-group counts (and a deduplicated global total), per-view search/filter and persistent expansion choices. Profession groups use native disclosure buttons and group labels. Each indented material row shows an icon and item name. Items used by multiple professions appear in each relevant group and retain one itemID and detail.
- **Se utiliza para fabricar / Used to craft:** bounded vertical clickable recipe rows with exact material quantities, profession, client-provided output/spell icon/name, native hover and pagination into Fabricables. The material detail groups its source-backed consuming professions into a collapsible, icon-labeled section showing up to four professions on normal panes (two on compact panes, paging only beyond capacity), alongside a separate collapsible crafting-use section that reclaims room when the profession section is closed. Optional type/item level appears only when supplied by the client.
- **Fabricables / Craftables:** a separate view for source-backed craftable results and non-item profession actions. Search by known recipe name, crafted output name, profession name or spellID; filter by profession. The detail includes an output icon and a collapsible **Materiales necesarios** section with the source-backed ingredient count, **all known ingredient itemIDs and quantities**, and clickable ingredient navigation.
- **Native chat links:** Shift + left-click a clickable material, craftable, recipe use, ingredient or detail identity to insert the native item/spell hyperlink into chat when the client supplies one; normal clicks still navigate. Fabricables detail no longer draws the redundant inset slot overlay. Forever-client verification is pending.
- **Fabricables requirements:** The detail shows the catalog's minimum profession skill below the profession name. The level text stays the same in dark gray when met, dark red when unmet, and neutral when the character's skill is unverified. **Recipe required** appears for a catalog teaching item unless a trainer offer is verified. The label is dark gray if learned, dark red if unlearned, and neutral if unverified. The `ID: <spellID>` line aligns with **Track crafting** on the right.
- **Opt-in craftable tracking:** one persistent **Track crafting** checkbox per character applies across all Fabricables recipes. Once enabled, switching recipes keeps the checkbox on and recalculates each recipe's individual ingredient requirements; disabling hides progress for every recipe. Legacy per-recipe opt-ins do not automatically enable the global toggle. When enabled, the original Ingredients list remains unchanged and an independent Material progress section displays each ingredient's available/required count, missing amount and native WoW StatusBar, plus weighted total progress; optional bank quantities are counted only with the bank open and trustworthy combined/bag counts, otherwise shown as unknown. A full bar means observed ingredients are sufficient for one recipe output; it does not indicate a known profession or craft eligibility. The owner confirmed the open-bank Hojaplata correction in Forever for PR #55; the owner validated global checkbox persistence across recipe switches and `/reload` on 2026-11-16; exact client build and cross-character testing remain unrecorded.
- **Cross-navigation:** open a craftable result from Materiales, open one of its ingredients in Materiales, and use **Volver / Back** to return. Each view retains its own search/filter and browsing state.
- **Shared native UI:** both views use a WoW Options-style inset and recessed section headers. The tabs, Back and search share one row above the results sidebar and detail pane. The explorer sits above HUD elements such as buffs. **Escape** or the top-right **X** closes the explorer. If a dropdown is open, Escape dismisses it first. The X inside search clears the active query. The shell scales for compact viewports and shows the installed official version in its footer.
- **Minimap button:** left-click to open the explorer, drag to move the button along the minimap edge, or right-click to open **Options → AddOns → CraftAtlas**. The hover tooltip highlights those gestures in gold. Its position survives `/reload`. [Forever test results](docs/TESTING.md#minimap-button-interaction).
- **Local catalog preparation:** first-use material and craftable names and icons are attempted in bounded scheduled batches. The active view shows its localized percentage and compact progress bar in the center of the footer while preparing. The bar disappears after scheduled work completes. The result count and unavailable-name warnings stay visible independently. Background-driven searches and refreshes are coalesced, while direct searches and filters stay immediate.
- **Localization:** enUS and esES with automatic client-language selection or a saved manual preference. The selector in **Options → AddOns → CraftAtlas** marks the saved choice, including Automatic.
- **Addon options:** open the game's **Options → AddOns → CraftAtlas** to change the account language, show or hide the minimap button, or customize the profession annotation in item tooltips. You can hide the annotation, hide its icons or show the professions on one comma-separated line. Changes apply to new or rebuilt tooltips.

Names, icons, rarity and stats come from native WoW APIs; CraftAtlas does not invent missing item data. Client-cache misses may leave search results incomplete, and non-item recipes are distinguished from crafted items. The recipe indicator describes what the game can verify about the current character. CraftAtlas does **not** determine overall crafting eligibility, automate crafting, query auction data, sync over a network or build full dependency graphs. Opt-in Fabricables tracking *does* calculate observed bag quantities and, under supported open-bank conditions, bank quantities for the currently viewed recipe; it is not an inventory history or multi-recipe planner.

## Refreshed Forever catalog (pending implementation acceptance)

The proposed next data package uses a pinned MIT-licensed LibProfessionDB **v1.10.1 Forever 1.60.1.70938** mirror (SHA `c9425394`) and retains the old 1.60.1.69977 facts only for 28 disputed cases. It adds Herbalism/Herboristería and Skinning/Desuello camping recipes and source-backed skill, trainer/item and vendor metadata. Its canonical `Data/recipes.source.json` includes recipes without reagents; `recipe-uses.source.json` and Materials remain real-input-only projections. **The refreshed catalog is not part of an official release yet; its actual Forever client behavior is NOT RUN.**

The full per-recipe machine-readable change record lives in `Data/reconciliation-report.json`. Changes from 593 to 592 material IDs result from removing item `4321` from four recipes; no new unique reagent IDs were introduced, but several new recipes reuse existing items. The 27 conflicting empty-reagent recipes and Alchemy 1251750 remain deliberately retained until verified; full live coverage is not claimed.

## Catalog and data limitations

| Source-backed metric | Current bundled snapshot |
| --- | ---: |
| Distinct reagent itemIDs | **592** |
| Consuming profession categories | **12** |
| Reagents used by multiple professions | **240** |
| Reagent-to-recipe input relationships | **8,471** |
| Unique profession + spellID recipes | **2,518** |

The dataset is a pinned MIT-licensed **LibProfessionDB** snapshot from Forever beta client **1.60.1.69977**, transformed from [detok/ChalkBox](https://github.com/detok/ChalkBox/tree/f8bbc3e7af7476b5685f999b79b2470cd905e014/ChalkBox/Libs/LibProfessionDB-1.0). Upstream license and attribution are included in `addon/CraftAtlas/Data/LICENSE-LibProfessionDB.txt`. It is **not** a comprehensive or independently live-verified catalog. A crafted/equippable item can still be a reagent for another recipe (e.g., item 14044 is consumed by recipe 19093). The catalog is generated from `materials.source.json`, `professions.source.json` and `recipe-uses.source.json`; do not hand-edit generated Lua.

## Install and use

1. Download an installable `CraftAtlas-vX.Y.Z.zip` from [GitHub Releases](https://github.com/hectoresen/CraftAtlas/releases), if available, and extract it into `Interface/AddOns/`; or copy only `addon/CraftAtlas/` from a source checkout.
2. Confirm `Interface/AddOns/CraftAtlas/CraftAtlas.toc` exists (no double-nested directory). In the game's AddOns list, look for **CraftAtlas** under **Professions** (enUS) or **Profesiones** (esES) and enable it. The manifest declares these categories and the minimap's blacksmithing icon; see [in-game test evidence](docs/TESTING.md#native-addons-list-registration).
3. Run `/craftatlas` or click the minimap button. The explorer opens on **Materiales**; switch to **Fabricables** to browse craftable results.
4. Use `/craftatlas 159` to open a known material directly. `/craftatlas perf` prints local, session-only preparation units, batches, worst observed batch times (when supported), search and redraw counts for diagnosis (not actual FPS). For Lua errors: `/console scriptErrors 1`, then `/reload`.
5. Use **Options → AddOns → CraftAtlas → General** to restore the minimap button if it is hidden. The button returns to its saved position. [Verification status](docs/TESTING.md#native-addon-options).

Do not install GitHub's autogenerated **Source code** ZIP as though it were the addon package. See [installation](docs/INSTALLATION.md).

## Source layout

```text
addon/CraftAtlas/
  Core/             Initialization and lifecycle
  Data/             Compiled materials, recipe uses and unique recipe index
  Domain/           Pure searches, profession grouping/state, lookups and pagination
  Infrastructure/   Client API, tooltip, cache, minimap and preferences
  Features/         Native Materiales/Fabricables views and tooltip display
    Settings/Shared/ Reusable search, profession, row and pager widgets
  Localization/     enUS/esES labels
scripts/            Deterministic generator, validation, release packaging
tests/              Offline Lua and Python regressions
openspec/           Requirements, change proposals and approval scopes
docs/               Installation, technical documentation and testing
```

## Development and validation

Review [AGENTS.md](AGENTS.md) for agent instructions and [CONTRIBUTING.md](CONTRIBUTING.md) for the spec-first, owner-merged PR process. **Before any functional PR**, explicitly run the [documentation-sync skill](skills/documentation-sync/SKILL.md) and provide documentation evidence as explained in the [documentation protocol](docs/DOCUMENTATION_PROTOCOL.md). Technical references: [architecture](docs/ARCHITECTURE.md), [data model](docs/DATA_MODEL.md), [testing](docs/TESTING.md), [roadmap](docs/ROADMAP.md), [OpenSpec](openspec/README.md) and [changelog](CHANGELOG.md).

```sh
bash scripts/validate_release_checks.sh
python3 scripts/build_materials.py --check
```

The first script is the **shared PR CI and release validation gate** (repository checks, dataset/Python tests, generated-data drift and package tests). The SDD workflow separately validates OpenSpec provenance. Lua test suites and actual Forever-client smoke tests require their own execution and evidence; passing CI does not prove all in-game UI behaviors.

## Owner-only GitHub Releases

The repository owner `hectoresen` can manually run **Actions → Publish CraftAtlas Release** against `main` with patch/minor/major selection. The workflow verifies both initiating and rerunning actors, executes the shared release-readiness gate, packages only the installable addon and publishes a SemVer release. It does not run automatically on merge and does not alter the tracked dev `.toc` version. Version numbers under 1.0 are prereleases. For details see [installation](docs/INSTALLATION.md) and [GitHub settings](docs/GITHUB_SETTINGS.md).

CraftAtlas is independent of Blizzard and the Forever project operators.
