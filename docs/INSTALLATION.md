# Install and test in World of Warcraft: Forever

**v0.0.0 is not playable**: the addon skeleton does not implement a feature, and its `.toc` is a placeholder. Follow this process after the v0.1.0 implementation is reviewed.

1. Find the active Forever game installation's `Interface/AddOns` directory (verify the client's actual game folder, which may vary by installation and platform).
2. Copy the CONTENTS of `addon/CraftAtlas/` into `Interface/AddOns/CraftAtlas/`; `CraftAtlas.toc` must sit directly inside that folder.
3. Launch the Forever client and verify the addon appears in the character selection AddOns panel; enable out-of-date addons only when appropriate for an explicitly tested build.
4. Enable Lua errors if appropriate; test inventory and bank item tooltips, language auto-detection, manual language setting, reload persistence, unknown IDs and multi-profession IDs.
5. Record exact game build, addon version, client language and any errors. Report compatibility regressions as issues.

The current `Interface` metadata is intentionally NOT hard-coded until validated on a running Forever client. Never infer that Retail or Vanilla examples are supported.
