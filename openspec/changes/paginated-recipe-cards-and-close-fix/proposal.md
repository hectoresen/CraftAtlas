# Proposal: Paginated recipe cards and reliable window close

## Why
After merging PR #21, the maintainer tested the in-game material explorer and reported that the right-side recipe area is visually cluttered: each recipe repeats an icon and label for recipe and product, rows are cramped/misaligned, and the native top-right X does not close the window. The owner requests a grid of recipe cards with clear icon/name, hover tooltip, six items per page and visible pagination.

## Changes
- Replace the existing vertical recipe rows/scrollbar with a fixed-size grid of six compact square-ish clickable cards (three columns × two rows at the normal window size), keeping the selected material's icon/name, professions and recipe count above.
- Every card represents **one** `RecipeUse` and contains one primary icon, preferably the crafted output's native icon. If no output icon exists, fall back to the recipe/spell icon; if neither is known, use a safe client placeholder. Avoid duplicate icon/name rows.
- Under the icon show one compact localized output or recipe name, truncated/wrapped within the card, and subtle secondary text with profession and required reagent quantity `xN`. Ensure card styling fits native WoW colors/textures/fonts; visible borders, hover and focus states.
- On card hover use the existing native **output item tooltip** when there is a verified output itemID, otherwise the existing native recipe/spell tooltip/factual fallback. Reset ownership on mouse leave, page change, selection change or window close; no fabricated quality or item metadata.
- Add **Previous** and **Next** page buttons, current page/total pages text and total verified-recipe count, with disabled controls at the boundaries. Pages have six recipes, not six section headings. No duplicated recipe cards or loss of results during navigation.
- Fix the existing native X: explicitly close the CraftAtlas frame, properly clear focus/dropdowns/tooltip, and ensure the close control is not obscured by overlaid child frames. Keep reopening via slash/minimap functional.
- Preserve prior search, profession filtering, selected material, enUS/esES, other tooltip annotations and data sources.

## In scope
Native UI-only layout and event handling, deterministic pure pagination helper, localization, automated regression tests, in-game QA and documentation. No changes to the recipe catalog, provenance, material classification or SDD validator.

## Out of scope
Dedicated searchable recipe tab, crafting automation, inventory stock/availability, skill filtering, new data imports, shopping lists, alternate UI skins or any offline recipe-source changes.

## Acceptance and risks
Desktop normal-size target: 3×2 cards with readable content and native tooltips, page indicator `1 / 3` for 14 recipes and a total of 14 distinct recipes. Clamp or adapt on small UI scales without clipping (if six cards cannot physically fit, scale/arrange the same six-card page rather than allowing content outside the window); test at multiple resolutions and UI scales. A 0-recipe or loading case shows an honest empty state. On selection changes reset to page 1; refreshes of the same selection retain a valid page.

Risks: WoW frame levels can make the X unclickable, native template close scripts may assume managed UI panels, item names can arrive asynchronously, long localized labels can overlap, and 6-card layout can clip on small windows. Mitigate with explicit ownership, guarded API calls, reusable card pool, frame geometry checks and in-game smoke testing.

## Approval and handoff
Owner requested the feature and approved its direction in conversation. The repository's default SDD policy nevertheless requires a **specification-only PR merged by @hectoresen** before a separate implementation PR. PR #14's one-time combined exception does not apply. No gameplay code or validator changes in this proposal.
