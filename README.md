# CraftAtlas

**CraftAtlas** is an MIT-licensed, offline addon for **World of Warcraft: Forever**. When hovering a catalogued ingredient, it shows which professions use that item, independently of the character's learned professions.

**Current state: v0.1.0-dev, implemented and tested in-game by the maintainer (15 November 2026).** It is development software, not a tagged stable release. The maintainer reports that the current addon functions in Forever; the complete tooltip-origin matrix and exact game build have not been supplied as reproducible test evidence.

## Working features

- **Item tooltips:** a localized **Used by** annotation lists all known consuming professions for the numeric itemID. Multiple professions are supported; unknown items are left unchanged. Uses a modern structured-item tooltip hook, which may cover multiple UI origins; only claim individual origins tested after recording their results.
- **Offline catalog:** **593 distinct reagent IDs**, **10 consuming profession categories**, and **237 multi-profession items**, compiled from a pinned MIT-licensed LibProfessionDB Forever beta snapshot. Counts describe imported data, **not complete coverage of the current Forever server**.
- **Settings:** `/craftatlas` opens the in-game panel. Language choices: Auto, Español (esES), and English (enUS), saved account-wide.
- **Minimap:** a profession-themed button opens the same panel on left click; its position is draggable and persisted.
- **Material explorer:** functional name/itemID search, profession filters, source-backed reagent selection and a reverse recipe-use panel (candidate under PR #21; client QA pending).

There is **no crafting automation, full dependency graph, or remote sync**. The reverse recipe-use browser is a development candidate and still needs Forever-client QA.

## Install

Download the installable ZIP from [GitHub Releases](https://github.com/hectoresen/CraftAtlas/releases) when one is published, and extract it directly into `Interface/AddOns/`. The archive already contains the top-level `CraftAtlas/` directory. Do **not** use GitHub's automatic Source code ZIP for installation.


1. Copy **only** `addon/CraftAtlas/` to the Forever installation at `Interface/AddOns/CraftAtlas/`.
2. Check that `CraftAtlas.toc` is directly inside the installed folder; enable the addon and launch the game.
3. Hover a known crafting material or type `/craftatlas` to open settings. Alternatively click the minimap button.
4. If something fails, use `/console scriptErrors 1` followed by `/reload` and include the client build in the report.

See [installation](docs/INSTALLATION.md) and [testing](docs/TESTING.md). The .toc currently declares `Interface: 16001`; document the exact tested client build before making a specific compatibility guarantee.

## Catalog provenance and limitations

The bundled generated Lua lookup is created from `addon/CraftAtlas/Data/materials.source.json` by `scripts/build_materials.py`. The 593-item index was transformed from the MIT-licensed **LibProfessionDB**, by Pimptasty, from Forever beta client **1.60.1.69977**, vendored in [detok/ChalkBox](https://github.com/detok/ChalkBox/tree/f8bbc3e7af7476b5685f999b79b2470cd905e014/ChalkBox/Libs/LibProfessionDB-1.0). Attribution/license: `addon/CraftAtlas/Data/LICENSE-LibProfessionDB.txt`. The newer Forever 1.60.1.70938 data has not yet been reconciled. `coverage-report.json` explicitly marks `liveClientValidated: false` for **catalog accuracy**, which is distinct from the maintainer's confirmation that the addon runs in-game.

## Repository structure

```text
addon/CraftAtlas/       Installable Lua addon
  Core/                Bootstrap and lifecycle
  Domain/              Pure itemID → profession lookup
  Data/                Generated offline catalog, source evidence, profession registry
  Infrastructure/      Tooltip API, minimap and SavedVariables
  Features/            Tooltip display and settings window
  Localization/        enUS/esES strings
openspec/               Approved requirements and changes
docs/                   Functional, technical and contributor documentation
scripts/                Dataset compilation and quality checks
tests/                  Offline regression tests
```

## Manual releases (maintainer only)

From GitHub **Actions → Publish CraftAtlas Release → Run workflow**, select `main` and the patch/minor/major increment. Only GitHub user `hectoresen` can publish, including on reruns; both the original and rerunning actor are checked. The first version is `v0.1.0` when no SemVer tags exist. Later versions increment from the highest valid `vMAJOR.MINOR.PATCH` tag. The workflow runs repository/material/package checks, creates a minimal `CraftAtlas-vX.Y.Z.zip`, and publishes it as a GitHub Release. Versions below 1.0 are marked as prereleases. This action does not run automatically on merges or pushes and does not edit the tracked `.toc` version in `main`.

Anyone with write access may still see the manual action; only `hectoresen` is authorized to publish. Protecting `main` and workflow changes from unauthorized edits is required for strong enforcement. Releases are not evidence of complete live-realm catalog validation.

## Development and governance

Start with [AGENTS.md](AGENTS.md), [contribution rules](CONTRIBUTING.md), [OpenSpec](openspec/README.md), [architecture](docs/ARCHITECTURE.md), [data model](docs/DATA_MODEL.md) and [testing](docs/TESTING.md). Behavioral changes follow a reviewed OpenSpec proposal and implementation PR. **Only @hectoresen authorizes merges/releases.** Run repository checks from the repository root:

```sh
python3 scripts/validate_repo.py
python3 -m unittest discover -s tests -p 'test_material_data.py' -v
python3 scripts/build_materials.py --check
```

Further information: [Roadmap](docs/ROADMAP.md) · [Installation](docs/INSTALLATION.md) · [Changelog](CHANGELOG.md) · [Agent workflow](docs/AGENT_WORKFLOW.md) · [SDD compliance](docs/SDD_COMPLIANCE.md). The project is independent of Blizzard and Forever operators.


## Material explorer (implemented in source; client QA pending)

A native-frame material explorer with instant search by cached item name or numeric itemID, profession filtering, a scrollable list, and a selected material detail view is implemented in [PR #14](https://github.com/hectoresen/CraftAtlas/pull/14). It reads the **existing local catalog** and shows known consuming professions. The follow-up PR adds a pinned MIT reverse recipe-use index, source-proven reagent quantities and crafted outputs. `/craftatlas 2447` is a safe itemID deep-link alternative. Client-cache misses show item IDs and partial-result warnings. **Not game-verified; release support depends on the owner's Forever smoke tests.** Clickable tooltips are pending verified Forever API support.


## Reagent → recipe usage (unreleased, client QA pending)

The reverse lookup source contains **8,455 source-backed recipe reagent uses** over **593 reagent itemIDs**, from the pinned MIT LibProfessionDB Forever beta snapshot. The right pane groups uses by consuming profession, shows source-proven ingredient quantity and crafted output item when known, and uses native item/spell tooltips when supported. Actual live-realm recipe availability and tooltip API compatibility are **not claimed**. A crafted/equippable item remains listed if another recipe consumes it: item `14044` (Cindercloth Cloak) is an ingredient of Leatherworking recipe `19093` (Onyxia Scale Cloak, output item `15138`). Output-only items do not enter the reagent list. Run `python3 scripts/build_materials.py --check` and the new recipe tests before release.

## Paginated recipe detail — implementation candidate

The material detail now uses **six native recipe cards per page** (3×2 at normal window width) instead of duplicate recipe/result rows. Each card shows **one** item-output icon/name when available, otherwise its recipe/spell, plus the consuming profession and material quantity. Hover uses the client's ordinary tooltip; previous/next controls show current and total pages (14 uses → 6 + 6 + 2). The top-right X explicitly hides CraftAtlas and clears any active recipe tooltip. **Forever-client layout and close behavior still require an in-game smoke test before release.**

## Recipe Explorer (unreleased implementation, pending Forever QA)

CraftAtlas now has **Materiales / Materials** and **Recetas / Recipes** inside the same native window. Materials retains its original source-backed search and six-card consuming-recipe detail. Recipes browses a generated catalog of **2,506 distinct recipes** derived from the same pinned MIT source's 8,455 reagent uses, with source-backed input quantities and optional crafted output IDs. The recipe list searches client-resolved recipe names, crafted-output names and numeric spell IDs, and filters by profession; missing client names are indicated rather than fabricated. Each recipe detail shows its profession, output or non-item action and every known ingredient with original icon, quantity and native tooltip. Clicking a material's consuming-recipe card opens Recipes; clicking an ingredient opens Materials, with a bounded Back action. Search, profession filter and reusable list/pagination controls are shared natively in Lua, while each view maintains its own browsing state. **This implementation is not yet tested inside Forever**; the exact game-build API compatibility and search/name loading need owner QA. No recipe learned-status, inventory quantities, live-server completeness or crafting actions are inferred.

### In-PR visual refinement (same approved change)

The new end-user tab is named **Fabricables / Craftables** rather than Recipes: it lists craftable results (with clearly identified enchantment/non-item actions) and reveals the ingredients/quantities of their source-backed crafting recipes. In the Materials detail, the section title reads **Se utiliza para fabricar / Used to craft** below profession metadata, with a dedicated vertical gap. The shared results list fits **seven** 34px rows at the standard 510px window height. The Back button sits in the navigation toolbar, never over the crafting cards. No change to the underlying profession+spellID identities, data or approved feature scope.
