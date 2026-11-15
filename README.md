# CraftAtlas

**CraftAtlas** is an MIT-licensed, offline addon for **World of Warcraft: Forever**. When hovering a catalogued ingredient, it shows which professions use that item, independently of the character's learned professions.

**Current state: v0.1.0-dev, implemented and tested in-game by the maintainer (15 November 2026).** It is development software, not a tagged stable release. The maintainer reports that the current addon functions in Forever; the complete tooltip-origin matrix and exact game build have not been supplied as reproducible test evidence.

## Working features

- **Item tooltips:** a localized **Used by** annotation lists all known consuming professions for the numeric itemID. Multiple professions are supported; unknown items are left unchanged. Uses a modern structured-item tooltip hook, which may cover multiple UI origins; only claim individual origins tested after recording their results.
- **Offline catalog:** **593 distinct reagent IDs**, **10 consuming profession categories**, and **237 multi-profession items**, compiled from a pinned MIT-licensed LibProfessionDB Forever beta snapshot. Counts describe imported data, **not complete coverage of the current Forever server**.
- **Settings:** `/craftatlas` opens the in-game panel. Language choices: Auto, Español (esES), and English (enUS), saved account-wide.
- **Minimap:** a profession-themed button opens the same panel on left click; its position is draggable and persisted.
- **Settings search:** **visual placeholder only**. It cannot accept queries, filter materials, or display search results. The General page is the only available settings category.

There is **no standalone material search, recipe browser, ingredient quantities UI, crafting graph, or remote sync** in the current version.

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
