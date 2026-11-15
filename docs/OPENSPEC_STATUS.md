# OpenSpec acceptance and current-source evidence

This ledger is an evidence record, **not** an automatic certification of requirements. Last reviewed 2026-11-15. The current source feature summary lives in [README](../README.md), and the documented Python/Forever test distinction lives in [TESTING](TESTING.md). The historical proposal, designs, delta specs and original tasks are retained unmodified except additive status checkpoints.

## Historical owner-approved changes

| Change | Spec PR | Implementation PR | Evidence and limits | Disposition |
| --- | --- | --- | --- | --- |
| `add-first-playable-material-tooltips` | [#3](https://github.com/hectoresen/CraftAtlas/pull/3), merged | [#4](https://github.com/hectoresen/CraftAtlas/pull/4), merged | Base tooltip functionality and language/settings were implemented and subsequently accepted by maintainer, but initial ≥30 item criterion was **not verified in PR #4**; first baseline imported six. Actual Forever build and per-origin matrix were not recorded. Current catalog later expanded. | **Partially accepted, OPEN** for historical unmet acceptance and real-client evidence; no archive |
| `enhance-addon-icon-minimap-settings` | [#7](https://github.com/hectoresen/CraftAtlas/pull/7), merged | [#8](https://github.com/hectoresen/CraftAtlas/pull/8), merged | Minimap entry, branding/icon, language header and native settings shell implemented and maintainer reported the addon operational. Its originally specified noninteractive search and empty General content were **superseded** by later approved/merged functional Materiales/Fabricables exploration, not independently satisfied as present-day behavior. Precise build and historical mock-test outcomes not recorded. | **Superseded in part, OPEN** until acceptance/scope exception reviewed; no archive |
| `expand-all-profession-material-coverage` | [#5](https://github.com/hectoresen/CraftAtlas/pull/5), merged | [#6](https://github.com/hectoresen/CraftAtlas/pull/6), merged | Pinned MIT beta source provides 593 reagent itemIDs, 237 multi-profession IDs, ten consuming profession classes; generator and source provenance implemented. Unknown live reference denominator; every relation was **not** independently verified against live Forever, and all claimed tooltip origins were not manually checked. | **Partially implemented, OPEN** for reconciliation/coverage/client evidence; no archive |

The maintainer separately reported accepted current Materiales/Fabricables UI after PRs #23 and #25, but those reports **do not** establish a specific game build, each tooltip origin, or full beta-to-live recipe accuracy. CI on implementation PRs verifies automation only; it is not a substitute for in-game tests.

## Canonical specification synchronization

The lifecycle change reconciles **only** capabilities for which the above approved deltas and current code provide sufficient support. Files under `openspec/specs/` may state stable current contracts; they do not turn historical *unmet* acceptance gates into passed results.

| Canonical capability | Approved source delta | Current evidence |
| --- | --- | --- |
| `material-lookup` | #3 numeric itemID/lookup | `Domain/MaterialLookup.lua`; source-backed deterministic profession lookup |
| `localization` | #3 locale fallback | `Localization/Locales.lua`, `Localization/ProfessionLabels.lua`; maintained enUS/esES |
| `minimap-button` | #7 minimap entry | `Infrastructure/MinimapButton.lua`, `Core/Bootstrap.lua`; maintainer-reported UI checks |
| `profession-registry` | #5 consumption and stable keys | `Data/professions.source.json`, generated `Professions.lua`; bounded source-backed registry |

**Not synchronized as fully shipped:** exhaustive live-realm coverage, complete hover-origin compatibility, historical initial 30 verified itemIDs, obsolete General-only/nonfunctional search requirements, or any claim requiring unrecorded client-build evidence. Current user-visible Materiales/Fabricables requirements also have later owner-approved deltas; those changes require their own explicitly approved lifecycle synchronization before canonical archive status can be claimed.

## Evidence categories / outstanding work

- **Implemented in main:** Materiales search, six-card consuming-recipe pagination, Fabricables explorer, cross-navigation, reusable UI, enUS/esES, account-wide preference, native tooltip adapters, and the manual release workflow.
- **Maintainer-reported Forever checks:** addon and the relevant PR #23/#25 UI operation. No exact client build or per-origin test matrix was supplied.
- **Catalog-only source-backed:** source verified within the licensed LibProfessionDB beta snapshot, not across current live Forever.
- **Not run/not evidenced:** exhaustive live recipe-by-recipe verification, original starter 30 individual live entries at PR #4 time, all bank/auction/mail/chat tooltip origins, complete scale matrix and all historical command logs.
- **Archives:** none of these three legacy changes is archived. Their original folders remain because incomplete SHALL acceptance must not be silently waived.

## Governance rules

The lifecycle mechanism from spec PR #13 permits this evidence-focused update **only** with its owner approval and exact path allowlist. It prohibits rewriting immutable historical proposal/design/delta specs or source scope. Subsequent functional PRs must invoke `skills/documentation-sync/SKILL.md`, report accurate test evidence and keep README/current context aligned.
