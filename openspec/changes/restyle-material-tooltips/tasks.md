# Tasks for the material tooltip restyle

- [x] 1. Obtain the owner merge of the spec-only PR before starting a separate implementation branch.
- [x] 2. Update the material tooltip presenter with native gold heading, spacer, localized alphabetical rows and the pinned 14 × 14 icons. Add a dedicated enUS/esES heading key. Keep the explorer, catalog and existing item-tooltip adapter path intact.
- [x] 3. Update duplicate and reuse handling for the variable line count. Add a focused Lua mock suite for layouts, locale changes and fallback, missing icons, invalid and unknown items, repeated callbacks, rebuilds and reuse.
- [x] 4. Run the shared release-readiness checks, the targeted Lua tooltip suite, documentation validation and strict OpenSpec validation where available. Record actual results and unrun checks.
- [ ] 5. Compare both addons separately in Forever using the cases in `design.md`. Record the exact build, screenshots, locale and scale coverage, tooltip surface and actual outcomes. Report unavailable checks as `NOT RUN`.
- [ ] 6. Run `skills/documentation-sync/SKILL.md` after implementation and checks. Update the README, changelog, architecture and testing docs with the verified behavior, reference attribution and evidence. Open the implementation PR with the owner-merged approval PR number and the required SDD and documentation metadata.

## Implementation evidence

- Approval PR [#39](https://github.com/hectoresen/CraftAtlas/pull/39) was merged by `hectoresen` before the branch at `29d6a1b` was created.
- The approved Spanish scenario specifies `Costura`. The tooltip uses that label for Tailoring, and the catalog and explorer retain their existing `Sastrería` label.
- The shared release gate, 96 Python tests, the targeted Lua 5.1.5 tooltip test and strict OpenSpec validation passed. The four other Lua failures listed in `docs/TESTING.md` reproduce on the clean base.
- Forever visual and tooltip-surface acceptance are **NOT RUN**. The documentation-sync review updated the README, changelog, architecture and test evidence. The catalog, installation steps, developer setup and milestones have no change from this restyle.
