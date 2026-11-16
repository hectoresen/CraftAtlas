## 1. Implement the approved interaction

- [ ] 1.1 Keep the button anchored to the minimap edge during drag, handle centered or unavailable cursor geometry, save the release angle through existing preferences, and restore it on initialization.
- [ ] 1.2 Verify that drag release keeps the explorer closed and that the first subsequent ordinary left-click opens it through `ns.OpenSettings`.
- [ ] 1.3 Render the `CraftAtlas` title and both localized tooltip lines using the native tooltip and existing locale resolution. Hide the tooltip when the pointer leaves.

## 2. Verify and document

- [ ] 2.1 Add and run a Lua adapter regression covering drag geometry at multiple scales, release and reload, click after drag, and tooltip text, fallback and dismissal.
- [ ] 2.2 Run the shared release checks and strict OpenSpec validation. Record exact commands and outcomes.
- [ ] 2.3 Exercise the acceptance scenarios in Forever at two UI scales, including release outside the minimap, `/reload`, and hover in both locales. Record the client build and each result, using `NOT RUN` for any unexecuted case.
- [ ] 2.4 Run `documentation-sync`, update the affected behavior and testing docs, and include the findings in the separate implementation PR with the owner-merged approval reference.
