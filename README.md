# CraftAtlas

**CraftAtlas** is an offline, MIT-licensed addon for **World of Warcraft: Forever**. It shows which professions consume an item's materials and lets players explore materials and craftable results without requiring the character to know a profession.

**Source version:** `0.2.0-dev` (see `addon/CraftAtlas/CraftAtlas.toc`); the explorer hides the version for development or unknown builds and displays only the installed release manifest version for official packages. The maintainer has tested and accepted the in-game UI through merged PR #25. This is not a claim that every imported recipe is available on the current live realm or that every client/tooltip origin has been individually tested.

## Current features

- **Material tooltips** add a gold **Used in:** / **Utilizado en:** heading and one white row per source-backed consuming profession to supported item tooltips. Rows are alphabetized in the addon language and show native profession icons where available. Unknown items receive no annotation.
- **Materiales / Materials:** searchable catalog grouped into collapsible consuming-profession sections with accurate matching per-group counts (and a deduplicated global total), per-view search/filter and persistent expansion choices. Profession groups have dedicated gold dividers and disclosure controls; each indented compact material row shows an icon and item name, without redundant profession subtitles. Items used by multiple professions appear in each relevant group but retain one itemID/detail.
- **Se utiliza para fabricar / Used to craft:** bounded vertical clickable recipe rows with exact material quantities, profession, client-provided output/spell icon/name, native hover and pagination into Fabricables. The material detail groups its source-backed consuming professions into a collapsible, icon-labeled section showing up to four professions on normal panes (two on compact panes, paging only beyond capacity), alongside a separate collapsible crafting-use section that reclaims room when the profession section is closed. Optional type/item level appears only when supplied by the client.
- **Fabricables / Craftables:** a separate view for source-backed craftable results and non-item profession actions. Search by known recipe name, crafted output name, profession name or spellID; filter by profession. Open a detail with a native-framed output icon and a collapsible **Materiales necesarios** section showing the source-backed ingredient count, **all known ingredient itemIDs and quantities**, and clickable ingredient navigation.
- **Native chat links:** Shift + left-click a clickable material, craftable, recipe use, ingredient or detail identity to insert the native item/spell hyperlink into chat when the client supplies one; normal clicks still navigate. Fabricables detail no longer draws the redundant inset slot overlay. Forever-client verification is pending.
- **Opt-in craftable tracking (implementation branch, not yet on main; visual refinements pending client retest):** each Fabricables recipe has a character-scoped, persistent tracking checkbox. When enabled, ingredient rows explicitly show current bag count, bank count (if confirmed), required quantity and missing quantity, plus a unit-weighted material progress indicator in a separate panel; optional bank quantities are counted only with the bank open and trustworthy combined/bag counts, otherwise shown as unknown. A full bar means observed ingredients are sufficient for one recipe output; it does not indicate a known profession or craft eligibility. Forever testing for inventory and bank API semantics is still **NOT RUN**.
- **Cross-navigation:** open a craftable result from Materiales, open one of its ingredients in Materiales, and use **Volver / Back** to return. Each view retains its own search/filter and browsing state.
- **Shared native UI:** both views reuse a cohesive dark WoW window, classic red WoW-native tabs and Blizzard dropdown selectors for language and profession when supported, with classic red-button fallbacks, search, recyclable rows and pager. A native close X embedded inside the search input appears only when text is entered, clears the active query and hides again when empty, separate from the top-right X that closes the window. The native shell centers the CraftAtlas title in the header and shows the installed official version unobtrusively in its bottom-right footer; it uses an emphasized CraftAtlas header and scales for compact viewports; the minimap button opens the explorer and can be repositioned.
- **Local catalog preparation:** first-use material and craftable names/icons are attempted in bounded scheduled batches; Materiales and Fabricables each show an independent, localized real work-percentage in a compact, width-capped progress bar directly beneath its centered percentage label in the free toolbar space between the native tabs and Back while active. The bar disappears after scheduled work completes. The result count and unavailable-name warnings remain separate, because 100% means attempts completed, not all client names resolved. Background-driven full searches/refreshes are coalesced; direct searches and filters remain immediate.
- **Localization:** enUS and esES with automatic client-language selection or saved manual preference.

Names, icons, rarity and stats come from native WoW APIs; CraftAtlas does not invent missing item data. Client-cache misses may leave search results incomplete, and non-item recipes are distinguished from crafted items. It does **not** track learned recipes, inventory quantities or crafting eligibility, automate crafting, query auction data, sync over a network or build full dependency graphs.

## Catalog and data limitations

| Source-backed metric | Current bundled snapshot |
| --- | ---: |
| Distinct reagent itemIDs | **593** |
| Consuming profession categories | **10** |
| Reagents used by multiple professions | **237** |
| Reagent-to-recipe input relationships | **8,455** |
| Unique profession + spellID recipes | **2,506** |

The dataset is a pinned MIT-licensed **LibProfessionDB** snapshot from Forever beta client **1.60.1.69977**, transformed from [detok/ChalkBox](https://github.com/detok/ChalkBox/tree/f8bbc3e7af7476b5685f999b79b2470cd905e014/ChalkBox/Libs/LibProfessionDB-1.0). Upstream license and attribution are included in `addon/CraftAtlas/Data/LICENSE-LibProfessionDB.txt`. It is **not** a comprehensive or independently live-verified catalog. A crafted/equippable item can still be a reagent for another recipe (e.g., item 14044 is consumed by recipe 19093). The catalog is generated from `materials.source.json`, `professions.source.json` and `recipe-uses.source.json`; do not hand-edit generated Lua.

## Install and use

1. Download an installable `CraftAtlas-vX.Y.Z.zip` from [GitHub Releases](https://github.com/hectoresen/CraftAtlas/releases), if available, and extract it into `Interface/AddOns/`; or copy only `addon/CraftAtlas/` from a source checkout.
2. Confirm `Interface/AddOns/CraftAtlas/CraftAtlas.toc` exists (no double-nested directory). Enable the addon in the game.
3. Run `/craftatlas` or click the minimap button. The explorer opens on **Materiales**; switch to **Fabricables** to browse craftable results.
4. Use `/craftatlas 159` to open a known material directly. `/craftatlas perf` prints local, session-only preparation units, batches, worst observed batch times (when supported), search and redraw counts for diagnosis (not actual FPS). For Lua errors: `/console scriptErrors 1`, then `/reload`.

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
