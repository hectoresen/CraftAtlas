# Installing and using CraftAtlas in WoW Forever

**Current source:** `0.1.0-dev` (`CraftAtlas.toc`). The maintainer has accepted current UI features in Forever; imported recipe data remain a bounded beta snapshot rather than a live-realm guarantee.

## Installation

1. If published, download the installable `CraftAtlas-vX.Y.Z.zip` from [GitHub Releases](https://github.com/hectoresen/CraftAtlas/releases), not GitHub's automatic source-code archive. Alternatively copy only `addon/CraftAtlas/` from a repository checkout.
2. Extract or copy the directory under `Interface/AddOns/`. The correct path is `Interface/AddOns/CraftAtlas/CraftAtlas.toc`; avoid a second nested `CraftAtlas/`.
3. Enable CraftAtlas in the AddOns list and log in.
4. Use `/craftatlas` or its draggable minimap icon. The window opens on **Materiales**; switch to **Fabricables** to browse what professions produce. Use `/craftatlas 159` to select a known material by itemID.
5. In Materiales, type a material name or itemID, apply a profession filter, select an item and inspect its fabrication-use cards. Click a card to open the Fabricables detail; click an ingredient to navigate back to its material and **Volver** to return.
6. Choose Auto, Español or English in the language selector; the preference is saved between reloads. The top-right X closes the window.

## Diagnostics and limitations

For Lua errors, run `/console scriptErrors 1`, then `/reload`. For bug reports include the game build (`/dump select(4, GetBuildInfo())`), language, material/recipe ID and steps. The `.toc` declares `## Interface: 16001`; the exact tested build is not recorded in the repository.

The bundled offline source has 593 reagent itemIDs, ten professions, 8,455 reagent uses and 2,506 unique recipes from an MIT-licensed Forever 1.60.1.69977 beta database. It does not require a runtime network connection or the source addon. Some client-cached names may be unavailable; the search shows incomplete/unknown states rather than inventing data. Unknown material itemIDs are not annotated. Real craftability, learned recipes, item availability and full server coverage are **not** inferred.

## Owner-only publishing

The manual `Publish CraftAtlas Release` GitHub Actions workflow runs from `main` for repository user `hectoresen`, executes `scripts/validate_release_checks.sh`, selects the SemVer increment and produces an installable runtime-only ZIP, preserving license attribution. It does not publish on merge. Releases below 1.0 are prereleases. See [GitHub governance](GITHUB_SETTINGS.md), [data model](DATA_MODEL.md) and [tests](TESTING.md).
