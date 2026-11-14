# Proposal: First playable CraftAtlas material tooltips (v0.0.1)

## Why

CraftAtlas v0.0.0 provides developer infrastructure but no user-visible functionality. The first playable milestone must establish a reliable, offline foundation that tells players **which professions use an item as a crafting ingredient**, without depending on the professions learned by their character. We must verify the real Forever client before promising compatibility and avoid inaccurate or unlicensed material data.

## What changes

- Introduce an installable Lua addon with a verified Forever-compatible .toc and safe initialization.
- Resolve material identity using numeric itemID from inventory item tooltips; show all *verified* consuming professions for known IDs.
- Introduce a curated, locally bundled starter material catalog and automated integrity checks with provenance and redistribution rights. Unknown IDs remain unknown.
- Provide enUS/esES labels, automatic locale selection and explicit persisted language preference.
- Provide an in-game settings entry point via `/craftatlas` and a simple settings interface.
- Add offline unit tests, client smoke-test instructions and release packaging/validation suitable for a playable pre-release.
- Update changelog, documentation and milestone scope on implementation.

## Target scope — v0.0.1

**Included:** standard inventory/bag item tooltips (including equipment/materials as encountered there), WoW Forever compatibility confirmed by real-client smoke tests, identity by numeric itemID, deterministic many-to-many profession lookup, a **minimum starter dataset of 30 verified distinct itemIDs** spanning **at least five distinct consuming professions**, enUS and esES translation, settings and persistence, error-safe behavior. The starter target must include at least two verified multi-profession items and at least one verified no-match case; the count is a quality gate, **not** a claim of comprehensive coverage.

**Excluded:** bank, guild bank, auction house, chat links, merchant windows, quest rewards, global tooltip coverage, search, recipe listings, material quantities, crafting dependency diagrams, online sync, automatic tooltip-text inference, and exhaustive coverage of Forever-custom items. Bank and broad coverage remain planned for v0.1.0+; the earlier roadmap is updated during implementation as required.

## Capabilities

- **material-lookup** — deterministic numeric itemID to zero/many consuming profession keys, independent of character state.
- **inventory-tooltips** — safe injection of verified relations into supported inventory/bag tooltips, no duplicates.
- **material-catalog** — offline curated, legally redistributable starter dataset with provenance and validation.
- **localization** — enUS/esES labels, automatic locale choice and predictable fallback.
- **user-settings** — `/craftatlas` language settings UI, persisted account-wide override.
- **client-compatibility** — verified packaging, lifecycle and real Forever-client release gate.

## Risks and constraints

1. Actual Forever interface number, tooltip hooks, slash command and locale APIs must be verified using the deployed client. They are not assumed to match Retail or Vanilla.
2. Some published databases may be unavailable or unsuitable for redistribution. Unverifiable/unlicensed data must NOT be included to reach quantity targets; if target cannot be met, **release is blocked** until data provenance is resolved or proposal amended with owner approval.
3. Tooltip callbacks may fire repeatedly or encounter incomplete item information. Add idempotence, graceful fallback and no costly polling.
4. Some professions and items may be custom to Forever; identify only verified consuming profession relations.

## Success / release acceptance

- Official `openspec validate` and repo CI pass; offline Lua tests and deterministic data validation pass.
- Starter dataset meets provenance, count, profession-diversity, and multi-profession gates.
- Actual Forever client test shows correct known, unknown, multi-profession, Spanish, English, override-persistence and repeated-hover behavior without Lua errors.
- ZIP/release instructions install cleanly and match the tested client build; no in-game claim before real verification.
- Owner approves spec PR first, then separately reviews implementation PR. No code implementation in this specification PR.
