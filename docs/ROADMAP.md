# Roadmap and release gates

**v0.0.0 (foundation):** repository documentation, OpenSpec config, agent protocol, templates, CI and folder skeleton. No working gameplay.

**v0.0.1 (first playable baseline — pending):** itemID-based profession tooltip for player inventory/bags, local vetted starter catalog (at least 30 itemIDs, five professions, two cross-profession items), enUS/esES and persisted language selection, minimalist native Forever/Classic-style settings. Current implementation branch is a preview, not a released addon; game-client acceptance and catalog completion remain gates.

**v0.1.0 (wider tooltip coverage and improvements):** numeric itemID profession identification in inventory/bank and wider supported item tooltips; all related professions regardless of character training; local audited dataset; enUS/esES language auto detection and persisted override; settings panel; no duplicates, no guessed associations; real Forever client validation. Do not declare *all material coverage* without an audited coverage report.

**v0.2.0:** improve dataset coverage and attribution; diagnose unknown IDs; optimize performance; usability fixes.

**v0.3.0:** offline material search, profession filters, local result UI.

**v0.4.0:** recipe usage, crafted output items and ingredient quantities, with source provenance.

**v0.5.0:** reverse dependency explorer (crafted item → recipe → required materials), cycle/error handling.

**v1.0.0:** stable tested feature set, clear compatibility declaration, mature catalog and docs.

Release gates for every version: approved OpenSpec change, passing automated checks, real-client testing where relevant, supported locales, changelog, release notes and maintainer approval. A scope/version change must update this file and the relevant spec.
