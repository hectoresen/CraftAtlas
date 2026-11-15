# Design: CraftAtlas identity, minimap button and settings shell

## Module boundaries

- `CraftAtlas.toc` and addon resources own the addon-list icon declaration and load order.
- `Infrastructure/MinimapButton.lua` owns client registration, visibility and click handling. It must call the same public open-settings action used by the slash command rather than duplicate window logic.
- `Features/Settings/Settings.lua` owns the larger window, header, General content and language-selector presentation.
- `Localization/Locales.lua` owns all visible strings, including the search placeholder, unavailable state text and General empty-state message.
- Domain/material lookup code is out of scope and must not be changed for this proposal.

## Native icon strategy

The implementation should first identify a native WoW/Forever texture that visually represents professions/crafting and can be used by both the addon-list metadata and the minimap button. The exact texture path, atlas name or metadata mechanism must be recorded after inspection of the actual supported client. Do not invent a web-style monochrome icon and do not copy an unlicensed external asset.

If the client does not expose a shared usable icon, the implementation must stop and report the incompatibility rather than silently substituting an unrelated image. Any fallback requires owner approval.

## Minimap behavior

The button is visible by default on addon initialization and has a left-click action equivalent to `/craftatlas`. It must not create duplicate buttons on reload or repeated initialization. The initial implementation may keep placement fixed or use the client's native default placement, but must not add a user-facing position/visibility setting in this change.

The future visibility toggle is intentionally reserved in the design but must not appear as an operational setting yet.

## Settings layout

The settings window should be enlarged enough for the three-part header and remain readable at the ordinary UI scale. The header contains:

- left: a disabled/non-interactive search affordance showing `Buscar objetos, profesiones..`;
- center: the `CraftAtlas` title;
- right: the existing Auto / English / Español selector.

The search affordance must not accept text or pretend to search. Its visual state and cursor communicate that it is unavailable. It must not intercept clicks in a way that prevents normal window interaction.

The existing General navigation category remains available. Its content area contains only a centered localized “Coming soon” message. The language selector is removed from that content area and continues to apply immediately and persist through the existing preferences path.

Use native Forever/Classic-compatible frames, font objects, controls, textures and cursor behavior. Do not import web fonts or external art. Keep `/craftatlas` and the minimap button routed through `ns.OpenSettings`.

## Compatibility and verification

Before implementation, verify in the actual Forever client:

- addon-list icon metadata/resource support;
- availability and identity of the selected native profession icon;
- minimap button/frame APIs, default placement and click handling;
- supported cursor and disabled-control behavior;
- frame templates, font objects and sizing at ordinary UI scale;
- no Lua errors and no duplicate button/window registration after reload.

Offline tests should cover routing, idempotent initialization, localization, selector persistence and non-functional search state. They cannot replace the client test.
