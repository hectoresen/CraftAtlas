# Tasks: paginated native recipe cards and close behavior

## Owner approval
- [ ] Review and merge this specification-only PR; only owner merges. Implement separately under merged spec approval.
- [ ] Confirm latest main and native Forever client behavior before the code PR.

## Domain and UI
- [ ] Add pure deterministic 6-use pagination helper and tests, independent of UI headings.
- [ ] Replace recipe list/scrollbar with six reusable native cards and appropriate 3×2 layout or safe compact fallback.
- [ ] Use one primary icon/title per card, prioritize actual crafted output, and show profession and xN quantity.
- [ ] Add localized pagination footer (Previous, Page X of Y, Next; total recipe count); disable page boundary buttons.
- [ ] Preserve selection and page behavior across refreshes; reset only when material changes.
- [ ] Bind card hover to native item/spell tooltip and clean up tooltip state on page/selection/close.
- [ ] Fix native frame X close using explicit handler and frame stacking, preserving other existing UI behavior.
- [ ] Add enUS/esES labels and fallback; ensure long Spanish names do not overlap.

## QA and documentation
- [ ] Run pure Lua tests for 0/1/6/7/14 uses, clamping and ordering, plus adapter/UI mocks and TOC regression.
- [ ] Run Python repo and data validators, OpenSpec strict and SDD CI; report any not-run checks.
- [ ] Update README, ARCHITECTURE, TESTING, CHANGELOG and ROADMAP for actual implementation.
- [ ] Test in real Forever at several UI scales, hover, X close and reopen; capture screenshots and exact client version.
- [ ] Open scoped implementation PR referencing the merged spec PR; no direct main writes or auto-merge.
