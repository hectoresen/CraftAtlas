# Implementation tasks

## 1. Confirm and update manifest metadata

- [ ] 1.1 Identify the exact target Forever build and confirm how it resolves the current icon declaration and locale-specific category metadata.
- [ ] 1.2 Update `CraftAtlas.toc` with `Professions` and `Profesiones` and ensure its icon metadata resolves the minimap's existing artwork. Preserve the title, load configuration, and minimap behavior.

## 2. Verify the source and packaged install

- [x] 2.1 Run the shared release checks. Build a local installable ZIP and compare its icon and category metadata with the source manifest after version stamping.
- [ ] 2.2 Install that ZIP and restart Forever. Check the disabled CraftAtlas entry, title search, and icon under `Profesiones` at character selection on esES. Check the enabled entry and icon under `Professions` in game on enUS.
- [ ] 2.3 Confirm the list artwork matches the minimap after enabling CraftAtlas, the minimap still opens the explorer, and no Lua errors appear. Record the exact build, locale, enable state, and observed results; explicitly record any unrun checks.

## 3. Document and hand off

- [x] 3.1 Update the installation guidance, test evidence, and changelog for the verified behavior; run `documentation-sync` before the implementation PR.
- [ ] 3.2 Open the separate implementation PR with the owner-merged proposal PR number, test evidence, and any remaining client limitations.

The shared release checks and the version-stamped ZIP comparison passed. The contributor tested the initial ZIP on the local Forever 1.60.1.70938 installation and reported that it looked correct. Specific evidence for both locale and enable states, title search, and minimap/error checks is still missing. See [test evidence](../../../docs/TESTING.md#native-addons-list-registration).
