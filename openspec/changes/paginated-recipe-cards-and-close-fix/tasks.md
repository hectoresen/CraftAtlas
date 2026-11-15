# Tasks: paginated native recipe cards and close behavior

## Owner approval
- [x] Owner merged specification PR #22; this implementation PR cites it.
- [x] Confirmed current main and inspected native template/RecipePanel source. Client behavior remains for manual QA.

## Domain and UI
- [x] Add pure deterministic 6-use pagination helper and tests, independent of UI headings.
- [x] Replace recipe list/scrollbar with six reusable native cards and appropriate 3×2 layout or safe compact fallback.
- [x] Use one primary icon/title per card, prioritize actual crafted output, and show profession and xN quantity.
- [x] Add localized pagination footer (Previous, Page X of Y, Next; total recipe count); disable page boundary buttons.
- [x] Preserve selection and page behavior across refreshes; reset only when material changes.
- [x] Bind card hover to native item/spell tooltip and clean up tooltip state on page/selection/close.
- [x] Fix native frame X close using explicit handler and frame stacking, preserving other existing UI behavior.
- [x] Add enUS/esES labels and fallback; ensure long Spanish names do not overlap.

## QA and documentation
- [ ] Run pure Lua tests for 0/1/6/7/14 uses, clamping and ordering, plus adapter/UI mocks and TOC regression.
- [ ] Run Python repo and data validators, OpenSpec strict and SDD CI; report any not-run checks.
- [x] Update README, ARCHITECTURE, TESTING, CHANGELOG and ROADMAP for actual implementation.
- [ ] Test in real Forever at several UI scales, hover, X close and reopen; capture screenshots and exact client version.
- [ ] Open scoped implementation PR referencing the merged spec PR; no direct main writes or auto-merge.
