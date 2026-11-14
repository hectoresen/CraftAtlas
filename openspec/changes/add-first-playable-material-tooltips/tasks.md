# v0.0.1 implementation tasks

> Planning only. Do NOT start until @hectoresen merges the specification PR and authorizes implementation. Keep tasks aligned with approved requirements.

## 1. Verify Forever runtime assumptions
- [ ] 1.1 Record actual client build, Interface number, addon folder, Lua capabilities and safe tooltip hook API.
- [ ] 1.2 Verify inventory/bag tooltip itemID extraction, slash command, SavedVariables and client locale APIs in-game.
- [ ] 1.3 Document supported/fallback adapter choices with evidence; stop if incompatible.

## 2. Build deterministic domain and data
- [ ] 2.1 Define immutable/side-effect-free material lookup contract and stable profession key registry.
- [ ] 2.2 Add reusable offline data schema, provenance/rights metadata and Lua generator.
- [ ] 2.3 Curate and verify ≥30 items for ≥5 consuming professions, including ≥2 multi-profession items (no invented coverage).
- [ ] 2.4 Add data integrity checks: duplicates, invalid IDs/keys, missing license/source, deterministic generation.
- [ ] 2.5 Add unit tests for unknown, known and multi-profession lookups and output ordering.

## 3. Tooltip integration
- [ ] 3.1 Add validated .toc and correct bootstrap ordering; no startup Lua errors.
- [ ] 3.2 Implement thin client adapter for inventory/bag itemIDs using verified API.
- [ ] 3.3 Integrate localized profession lines without duplication, side effects or repeated polling.
- [ ] 3.4 Add mocked callback/refresh/error-path tests and rapid-hover regression checks.

## 4. Localization and settings
- [ ] 4.1 Implement enUS/esES profession/UI labels, locale detection and English fallback.
- [ ] 4.2 Implement `/craftatlas` panel with auto/enUS/esES choice.
- [ ] 4.2a Review the approved provisional interactive prototype (`prototype/settings.html`) and implement native Forever UI styling consistent with its clean sans-serif header and **no decorative emblem**, falling back to compatible Classic frame/font templates; avoid external fonts, ornate visual assets and clutter.
- [ ] 4.2b Build compact reusable settings shell with title, close control, navigation region and General content; show no unimplemented future tabs.
- [ ] 4.2c Check default UI scale, normal text contrast, selected-state clarity and open/close behavior in-game; attach screenshots as verification evidence.
- [ ] 4.3 Persist account-wide language override with safe defaults and invalid-data recovery.
- [ ] 4.4 Add locale and persistence tests; verify UI/tooltip updates and reload in-game.

## 5. Quality and release
- [ ] 5.1 Run Lua unit tests, data validation/generation drift checks, repository CI and lint.
- [ ] 5.2 Run all documented Forever-client manual acceptance tests with exact game build and results.
- [ ] 5.3 Update README, ROADMAP, INSTALLATION, ARCHITECTURE, DATA_MODEL, TESTING and CHANGELOG with verified implementation details.
- [ ] 5.4 Package/install-test playable addon only, note initial catalog coverage limitations and installation steps.
- [ ] 5.5 Confirm approval PR linkage, scope and OpenSpec acceptance scenarios; submit implementation PR for owner review.

## Execution checkpoint — implementation branch

**Implemented in source, but not yet verified in the real client:**
- Lua namespace, pure itemID lookup and deterministic profession ordering.
- Mainline-style item-tooltip adapter with guarded callback and refresh deduplication.
- enUS/esES string catalog, account-level SavedVariables and native-inspired /craftatlas settings.
- Original fact-level research for six material IDs, with per-item public source references; generated offline Lua table.
- Source validator, byte-for-byte Lua generator, Python data tests and mocked Lua regression tests.
- Initial implementation and release-gate documentation.

**Not complete / not claimed as passed:**
- 24 more validated material IDs required to reach 30, with all relationships checked against Forever recipes.
- Real Forever build/API/.toc, native font/layout, inventory/bag tooltip and SavedVariables verification.
- Full Lua/data tests executed in a compatible test environment (checked into the repo but not wired into current CI due approved scope boundary).
- Any changes needed for guaranteed bank/auction/chat/global tooltip support; currently outside approved scope.
- Final installation ZIP, release and owner acceptance.

Do not mark a release, archive this change or merge implementation while these gates remain open.
