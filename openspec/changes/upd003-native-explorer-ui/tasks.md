## 1. Explorer and shared controls

- [ ] 1.1 Reproduce the Craftables layering report and verify native Escape, popup and template behavior on the target Forever build.
- [ ] 1.2 Bind native Escape to the explorer lifecycle and verify cleanup parity with the top-right X, including edit focus and owned popups.
- [ ] 1.3 Align persistent controls in one frame strata and apply the minimalist native shell, list and detail presentation to both views.
- [ ] 1.4 Keep the saved language indicator in native AddOn options and remove the explorer selector.
- [ ] 1.5 Use the Options tabs and constrain Craftables profession labels to their rows.
- [ ] 1.6 Open the native CraftAtlas AddOn category on minimap right-click and retain drag and primary click.
- [ ] 1.7 Match the inset and header depth, align search with the tabs, and update the minimap tooltip colors and order.

## 2. Verification and evidence

- [ ] 2.1 Extend the applicable Lua fixtures for close behavior, layout and selected language. Run the Lua 5.1 syntax and regression suites, `bash scripts/validate_release_checks.sh` and the OpenSpec/SDD checks.
- [ ] 2.2 In Forever, verify Escape and X from both views, with search focus and popups, after repeated opens and alongside native game UI. Check that the game menu opens without a protected-action warning. Overlap HUD buffs and ordinary game panels with the explorer and verify the window and both lists stay above them and accept input at standard and compact scales in both locales.
- [ ] 2.3 In Forever, verify the options-only language selector and `/reload`, matching Options tabs, bounded profession labels, and the minimap right-click destination. Smoke-test browsing, navigation, links, tracker and bank behavior, left-click, drag and tooltip preferences. Record the build, scales, screenshots and outcomes in `docs/TESTING.md`.
- [ ] 2.4 Run `skills/documentation-sync/SKILL.md` after implementation and validation. Update affected documentation and assess archive readiness using the actual acceptance evidence.
