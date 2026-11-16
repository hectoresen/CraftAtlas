# Design

## Drag and persistence

`Infrastructure/MinimapButton.lua` owns the button anchor and drag lifecycle. Replace free frame movement with angular projection. Convert the pointer coordinates to the minimap's coordinate space using its effective scale, calculate the angle from the minimap center, and use the angle to anchor the button's center on the circular edge. Distance from the center has no effect on the radius. If the pointer is at the exact center or cursor geometry is temporarily unavailable, use the most recent valid angle, starting with the angle at drag start.

Run the position update only during an active drag. On release, sample the pointer once more, apply the resulting anchor, stop drag updates, and save the angle through the existing `GetMinimapAngle` and `SetMinimapAngle` preferences interface. Restore the saved angle on initialization. The existing default position applies to new installs and preferences without a usable angle.

Use native drag and click callbacks, and verify their order on the target Forever build. Any click callback from the completed drag belongs to that gesture. The first subsequent ordinary left-click must call `ns.OpenSettings` through the existing entry point.

## Hover tooltip

Use the existing native `GameTooltip`, the `TITLE` locale key and one locale key per instruction. Resolve the strings when the pointer enters the button so the next hover uses the effective addon locale. Close the tooltip on pointer leave. Guard frame geometry and tooltip calls using the project's native adapter conventions.

## Verification

Mock cursor coordinates, effective scale, anchor updates, persistence, mouse events and tooltip lines. In Forever, verify a continuous sweep around the minimap, a release outside the map, reload persistence, the next left-click and hover in both locales. Repeat drag and release at two UI scales and record the exact client build and per-case outcomes.
