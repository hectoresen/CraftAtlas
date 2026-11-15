# Install CraftAtlas in World of Warcraft: Forever

**Current source version:** `0.1.0-dev`. The maintainer has tested the addon in-game and reports it functional. This is not a tagged stable release. Imported beta-catalog relations have not all been individually checked on the current live server.

1. Download `CraftAtlas-vX.Y.Z.zip` from [GitHub Releases](https://github.com/hectoresen/CraftAtlas/releases) when one is available. Avoid GitHub's automatic source-code archives, which include development files.
2. Extract the **ZIP directly** into your Forever installation's `Interface/AddOns/` folder. The ZIP already includes `CraftAtlas/`. For source checkouts instead, copy only `addon/CraftAtlas/`.
3. Confirm this exact structure: `Interface/AddOns/CraftAtlas/CraftAtlas.toc`. Avoid a second nested `CraftAtlas/` folder.
4. Start the game, enable CraftAtlas in the AddOns list and enter the world.
5. Hover a catalogued crafting ingredient. A tooltip lists its known consuming professions. Use `/craftatlas` or click the minimap button to open settings.
6. Select Auto, Español or English. The selection is saved between reloads. The minimap button can be dragged to a preferred position.

The **search-looking element in settings is only a non-interactive visual placeholder**. It does not support typing, filtering or searching. Only the General settings category is currently available.

## Publishing (repository owner only)

The `Publish CraftAtlas Release` workflow is run manually in GitHub Actions from `main`, with a patch, minor or major increment. Only `hectoresen` can publish; other writers may see the Run workflow action but cannot publish. The first SemVer release is `v0.1.0`; below `1.0.0` releases are marked prerelease. A release ZIP contains the runtime files referenced by `CraftAtlas.toc` plus required license attribution, not tests, docs or generated-data source JSON. No release is created merely by merging a PR. Protect `main` and GitHub Actions workflows to prevent unauthorized policy changes.

## Troubleshooting / compatibility evidence

The .toc declares `## Interface: 16001`; the exact Forever build tested by the maintainer is not recorded here. When reporting a regression, provide the client version (`/dump select(4, GetBuildInfo())`), language and steps to reproduce. Use `/console scriptErrors 1` and `/reload` for Lua diagnostics.

The offline catalog currently contains **593 itemIDs, ten consuming professions and 237 cross-profession materials**, sourced from LibProfessionDB Forever beta 1.60.1.69977. It requires no runtime network connection or installed LibProfessionDB addon. This is a bounded import, **not a guarantee that every Forever material is supported**. Unmapped itemIDs receive no extra profession lines.

See [Testing](TESTING.md) and [Data model](DATA_MODEL.md).
