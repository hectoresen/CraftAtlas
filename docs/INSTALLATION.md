# Installing and using CraftAtlas in WoW Forever

**Current source:** `0.2.0-dev` (`CraftAtlas.toc`). See [testing](TESTING.md) for in-game evidence by revision. The imported catalog is a bounded beta snapshot.

## Installation

1. If published, download the installable `CraftAtlas-vX.Y.Z.zip` from [GitHub Releases](https://github.com/hectoresen/CraftAtlas/releases), not GitHub's automatic source-code archive. Alternatively copy only `addon/CraftAtlas/` from a repository checkout.
2. Extract or copy the directory under `Interface/AddOns/`. The correct path is `Interface/AddOns/CraftAtlas/CraftAtlas.toc`; avoid a second nested `CraftAtlas/`.
3. Start or restart Forever after installing. In the native AddOns list, look for **CraftAtlas** under **Professions** (enUS) or **Profesiones** (esES). The game language determines the category, including when the addon is disabled. Enable CraftAtlas and log in. The manifest declares the same blacksmithing artwork used by the minimap button; see [in-game test evidence](TESTING.md#native-addons-list-registration).
4. Use `/craftatlas` or left-click the minimap icon. The window opens on **Materiales**; switch to **Fabricables** to browse what professions produce. Use `/craftatlas 159` to select a known material by itemID. Drag the icon to move it along the minimap edge; its position survives `/reload`. Hover over it for localized controls.
5. In Materiales, search by name or itemID in the upper-right search box. Choose a profession in the sidebar to browse one list of its matching materials. Choose **All professions / Todas las profesiones** to browse groups with plus and minus buttons. Select a material to inspect its consuming professions and crafting uses in the detail pane. Click a recipe to enter Fabricables, an ingredient to return to Materiales, or **Volver** to restore the prior browsing state.
6. Right-click the minimap button or open **Options → AddOns → CraftAtlas**. Under **General**, the language selector marks the saved choice and the minimap setting controls button visibility. Under **Tooltip**, choose whether to show consuming professions, hide their icons, or display their names on a comma-separated line. Turning the annotation off retains the layout choices. Settings save for the account and apply to new or rebuilt tooltips.
7. The X inside search appears when text is entered and clears only the active query. Press **Escape** or click the top-right **X** to close the explorer. Escape dismisses an open dropdown before closing the window. Official packaged releases display their locally stamped version in the bottom-right footer. The source manifest is prepared as 0.2.0-dev. After merging, select the **minor** increment in the owner's release workflow to publish v0.2.0, which stamps the installed manifest automatically.

## Diagnostics and limitations

The small header bar briefly reports local preparation attempts for the active Materiales or Fabricables view. It hides after those attempts finish, even if WoW cannot resolve certain names. It does not download or synchronize a database. Run `/craftatlas perf` to print local per-session operation counts for performance diagnostics, not FPS results.

For Lua errors, run `/console scriptErrors 1`, then `/reload`. For bug reports include the game build (`/dump select(4, GetBuildInfo())`), language, material/recipe ID and steps. The `.toc` declares `## Interface: 16001`; the exact tested build is not recorded in the repository.

The bundled offline source has 593 reagent itemIDs, ten professions, 8,455 reagent uses and 2,506 unique recipes from an MIT-licensed Forever 1.60.1.69977 beta database. It does not require a runtime network connection or the source addon. Some client-cached names may be unavailable; the search shows incomplete/unknown states rather than inventing data. Unknown material itemIDs are not annotated. Real craftability, learned recipes, item availability and full server coverage are **not** inferred.

## Owner-only publishing

The manual `Publish CraftAtlas Release` GitHub Actions workflow runs from `main` for repository user `hectoresen`, executes `scripts/validate_release_checks.sh`, selects the SemVer increment and produces an installable runtime-only ZIP, preserving license attribution. It does not publish on merge. Releases below 1.0 are prereleases. See [GitHub governance](GITHUB_SETTINGS.md), [data model](DATA_MODEL.md) and [tests](TESTING.md).
