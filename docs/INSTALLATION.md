# Install CraftAtlas in World of Warcraft: Forever

**Current source version:** `0.1.0-dev`. The maintainer has tested the addon in-game and reports it functional. This is not a tagged stable release. Imported beta-catalog relations have not all been individually checked on the current live server.

1. Obtain the repository (or an agreed release package) and locate `addon/CraftAtlas/`.
2. Copy that **folder**, not the entire repository, to the active Forever installation's `Interface/AddOns/` directory.
3. Confirm this exact structure: `Interface/AddOns/CraftAtlas/CraftAtlas.toc`. Avoid a second nested `CraftAtlas/` folder.
4. Start the game, enable CraftAtlas in the AddOns list and enter the world.
5. Hover a catalogued crafting ingredient. A tooltip lists its known consuming professions. Use `/craftatlas` or click the minimap button to open settings.
6. Select Auto, Español or English. The selection is saved between reloads. The minimap button can be dragged to a preferred position.

The **search-looking element in settings is only a non-interactive visual placeholder**. It does not support typing, filtering or searching. Only the General settings category is currently available.

## Troubleshooting / compatibility evidence

The .toc declares `## Interface: 16001`; the exact Forever build tested by the maintainer is not recorded here. When reporting a regression, provide the client version (`/dump select(4, GetBuildInfo())`), language and steps to reproduce. Use `/console scriptErrors 1` and `/reload` for Lua diagnostics.

The offline catalog currently contains **593 itemIDs, ten consuming professions and 237 cross-profession materials**, sourced from LibProfessionDB Forever beta 1.60.1.69977. It requires no runtime network connection or installed LibProfessionDB addon. This is a bounded import, **not a guarantee that every Forever material is supported**. Unmapped itemIDs receive no extra profession lines.

See [Testing](TESTING.md) and [Data model](DATA_MODEL.md).
