# Install and test in World of Warcraft: Forever

**Release status:** v0.0.0 on main is scaffold-only. v0.0.1 implementation is under review and has NOT passed in-game acceptance. **Do not publish or describe it as client-verified** until actual Forever testing and the data gate are complete.

**v0.0.0 is not playable**: the addon skeleton does not implement a feature. Use the following steps to smoke-test a v0.0.1 development branch; treat API and client compatibility as provisional.

1. Find the active Forever game installation's `Interface/AddOns` directory (verify the client's actual game folder, which may vary by installation and platform).
2. Copy the CONTENTS of `addon/CraftAtlas/` into `Interface/AddOns/CraftAtlas/`; `CraftAtlas.toc` must sit directly inside that folder.
3. Launch the Forever client and verify the addon appears in the character selection AddOns panel; enable out-of-date addons only when appropriate for an explicitly tested build.
4. Enable Lua errors if appropriate; test inventory and bank item tooltips, language auto-detection, manual language setting, reload persistence, unknown IDs and multi-profession IDs.
5. Record exact game build, addon version, client language and any errors. Report compatibility regressions as issues.

The implementation branch currently sets provisional `## Interface: 16001` based on third-party Forever API reports, not direct testing. Verify it with `/dump select(4, GetBuildInfo())` and record the build. Game UI APIs are Mainline-family in Forever; do not assume Classic Era's legacy `OnTooltipSetItem` works. See docs/TESTING.md.

The minimum release catalog contains 30 verified itemIDs; the preview currently contains only six externally researched ones. Unknown IDs deliberately produce no annotation.
