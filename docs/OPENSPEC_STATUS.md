# OpenSpec acceptance and current-source evidence

This ledger is an evidence record, **not** an automatic certification of requirements. Historical acceptance last reconciled on 2026-11-16; maintenance audit of current `main` on 2026-11-18 (head `50ddf27`, merged PR #67). The current source feature summary lives in [README](../README.md), and the documented Python/Forever test distinction lives in [TESTING](TESTING.md). The historical proposal, designs, delta specs and original tasks are retained unmodified except additive status checkpoints.

## Historical owner-approved changes

| Change | Spec PR | Implementation PR | Evidence and limits | Disposition |
| --- | --- | --- | --- | --- |
| `add-first-playable-material-tooltips` | [#3](https://github.com/hectoresen/CraftAtlas/pull/3), merged | [#4](https://github.com/hectoresen/CraftAtlas/pull/4), merged | Base tooltip functionality and language/settings were implemented and subsequently accepted by maintainer, but initial ≥30 item criterion was **not verified in PR #4**; first baseline imported six. Actual Forever build and per-origin matrix were not recorded. Current catalog later expanded. | **Partially accepted, OPEN** for historical unmet acceptance and real-client evidence; no archive |
| `enhance-addon-icon-minimap-settings` | [#7](https://github.com/hectoresen/CraftAtlas/pull/7), merged | [#8](https://github.com/hectoresen/CraftAtlas/pull/8), merged | Minimap entry, branding/icon, language header and native settings shell implemented and maintainer reported the addon operational. Its originally specified noninteractive search and empty General content were **superseded** by later approved/merged functional Materiales/Fabricables exploration, not independently satisfied as present-day behavior. Precise build and historical mock-test outcomes not recorded. | **Superseded in part, OPEN** until acceptance/scope exception reviewed; no archive |
| `expand-all-profession-material-coverage` | [#5](https://github.com/hectoresen/CraftAtlas/pull/5), merged | [#6](https://github.com/hectoresen/CraftAtlas/pull/6), merged | Pinned MIT beta source provides 593 reagent itemIDs, 237 multi-profession IDs, ten consuming profession classes; generator and source provenance implemented. Unknown live reference denominator; every relation was **not** independently verified against live Forever, and all claimed tooltip origins were not manually checked. | **Partially implemented, OPEN** for reconciliation/coverage/client evidence; no archive |

The maintainer reported acceptance of the Materiales/Fabricables UI delivered by PRs #23 and #25. Later UI redesign (#36), first-use preparation (#38) and tooltip restyling (#40) are also merged, but that earlier acceptance does not automatically cover their refinements. Those reports **do not** establish a specific game build, each tooltip origin, or full beta-to-live recipe accuracy. CI on implementation PRs verifies automation only; it is not a substitute for in-game tests.

## Canonical specification synchronization

Canonical specifications represent capabilities synchronized from their approved deltas; existing historical client acceptance gaps remain explicit and separate. The historical lifecycle change reconciled **only** capabilities for which approved deltas and code provided sufficient support. Files under `openspec/specs/` may state stable current contracts; they do not turn historical *unmet* acceptance gates into passed results.

| Canonical capability | Approved source delta | Current evidence |
| --- | --- | --- |
| `material-lookup` | #3 numeric itemID/lookup | `Domain/MaterialLookup.lua`; source-backed deterministic profession lookup |
| `localization` | #3 locale fallback | `Localization/Locales.lua`, `Localization/ProfessionLabels.lua`; maintained enUS/esES |
| `minimap-button` | #7 minimap entry | `Infrastructure/MinimapButton.lua`, `Core/Bootstrap.lua`; maintainer-reported UI checks |
| `profession-registry` | #5 consumption and stable keys | `Data/professions.source.json`, generated `Professions.lua`; bounded source-backed registry |

**Not certified as fully live-verified:** exhaustive live-realm coverage, complete hover-origin compatibility, historical initial 30 verified itemIDs, obsolete General-only/nonfunctional search requirements, or any claim requiring unrecorded client-build evidence. Current Materiales/Fabricables source exists in `main`; this ledger does not imply that every associated active change was archived or every client-required acceptance criterion was verified. Consult the active `openspec/changes/` folders before declaring an individual change closed.

## Evidence categories / outstanding work

- **Implemented in main:** Materiales search with grouped collapsible profession tree and **vertical paginated recipe-use rows** (replacing the old six-card tiles in merged PR #36), Fabricables explorer, cross-navigation, ingredient quantities, reusable native UI, enUS/esES, account-wide preferences, native tooltip adapters, first-use local preparation progress (#38), tooltip restyling (#40), and the manual release workflow.
- **Maintainer-reported Forever checks:** prior #23/#25 UI operation and later screenshots showing material details after the `detailHeading` fix and intermediate Fabricables progress. These are **partial observations**, not acceptance of the final #36/#38/#40 UI across all scales/locales or measured performance. No exact client build or complete tooltip-origin matrix was supplied.
- **Catalog-only source-backed:** source verified within the licensed LibProfessionDB beta snapshot, not across current live Forever.
- **Not run/not evidenced:** exhaustive live recipe-by-recipe verification, original starter 30 individual live entries at PR #4 time, all bank/auction/mail/chat tooltip origins, final progress-bar appearance, final material-tooltip art, complete scale/locale matrix, measured FPS comparison and all historical command logs.
- **Archives:** none of these three legacy changes is archived. Their original folders remain because incomplete SHALL acceptance must not be silently waived.

## Governance rules

The lifecycle mechanism from spec PR #13 permits this evidence-focused update **only** with its owner approval and exact path allowlist. It prohibits rewriting immutable historical proposal/design/delta specs or source scope. Subsequent functional PRs must invoke `skills/documentation-sync/SKILL.md`, report accurate test evidence and keep README/current context aligned.

## Atomic archive protocol — merged governance implementation

| Change | Approved spec | Implementation | Evidence | Status |
| --- | --- | --- | --- | --- |
| `archive-openspec-with-implementation` | [#45](https://github.com/hectoresen/CraftAtlas/pull/45), owner merged | [#47](https://github.com/hectoresen/CraftAtlas/pull/47), merged 2026-11-16 | `tests/test_validate_sdd.py` PASS via `traceability`; canonical `openspec/specs/atomic-implementation-archival/spec.md` synced; scope and immutable originals retained; no game-facing changes or required Forever acceptance | **ARCHIVED in `main`** at `openspec/changes/archive/2026-11-16-archive-openspec-with-implementation/` after merged PR #47 |

Older partially accepted historical changes listed above remain **OPEN**; #47 does not retroactively establish their acceptance. The archival governance transaction itself is merged, unlike the previous pre-merge record.

## Recently merged changes: implementation versus acceptance (2026-11-16)

| Change or milestone | PR evidence | Source state on `main` | Acceptance / archival boundary |
| --- | --- | --- | --- |
| Grouped Materiales tree and vertical crafting-use rows | [#35](https://github.com/hectoresen/CraftAtlas/pull/35) spec; [#36](https://github.com/hectoresen/CraftAtlas/pull/36) implementation | **Merged**, replaces six-card UI | Owner screenshots support partial visual operation; exact client build, full layouts/scales/locales matrix and final refinements remain unverified |
| First-use catalog preparation and bounded progress | [#37](https://github.com/hectoresen/CraftAtlas/pull/37) spec; [#38](https://github.com/hectoresen/CraftAtlas/pull/38) implementation | **Merged** | Intermediate 66% Fabricables screenshot observed; final width-capped bar appearance and measured FPS impact **NOT RUN** |
| Material tooltip restyling | [#39](https://github.com/hectoresen/CraftAtlas/pull/39) spec; [#40](https://github.com/hectoresen/CraftAtlas/pull/40) implementation | **Merged** | Offline tooltip fixtures exist; final direct in-game locale/origin/style comparison **NOT RUN** |
| Contributor reviews and required Lua CI | [#41](https://github.com/hectoresen/CraftAtlas/pull/41) spec; [#42](https://github.com/hectoresen/CraftAtlas/pull/42) implementation | **Merged**; four mandatory contexts enabled in main ruleset | CI existence does not constitute a two-user permission-matrix test or Forever gameplay acceptance |
| Atomic OpenSpec archive | [#45](https://github.com/hectoresen/CraftAtlas/pull/45) spec; [#47](https://github.com/hectoresen/CraftAtlas/pull/47) implementation | **Merged and archived** for its own governance change | Historical incomplete changes remain OPEN; no blanket archive |
| Typed change IDs, branch linkage and PR check discovery | [#48](https://github.com/hectoresen/CraftAtlas/pull/48), [#49](https://github.com/hectoresen/CraftAtlas/pull/49) specs; [#50](https://github.com/hectoresen/CraftAtlas/pull/50) implementation | **Merged**; lowercase OpenSpec IDs with uppercase branch categories | Its `resolve-typed-openspec-cli-compatibility` active change still exists on `main`: **not archived**. Do not infer archival just because implementation merged |

**Ledger policy:** `merged/implemented`, `owner-observed in game`, `automated CI checked`, and `accepted + archived` are different states. Do not create duplicate implementation work for already merged #36/#38/#40/#42/#47/#50; track actual missing client evidence or incomplete archival separately through a newly authorized change when required.

## Maintenance reconciliation checkpoint (2026-11-18)

**No mass archive is authorized by this documentation-only audit.** The repository contains 27 active change directories under `openspec/changes/`, plus the archived atomic governance change. Of the 27 active changes, 26 retain at least one unchecked task in their original `tasks.md`; `mandatory-multiagent-documentation-gate` has its tasks checked but remains active. These counts refer to task bookkeeping, not to 26 missing implementations. Original tasks/proposals are preserved.

**Merged and present in current source, previously described as pending in roadmap or changelog:** native Shift-click chat links and Fabricables detail icon fix (`fix001-native-chat-links-and-recipe-icon`), global per-character Fabricables tracking (`upd001-global-craftable-tracking`), native AddOn options (`upd002-native-addon-options`), and current minimap/list improvements. PR #67 is merged into `main`; the latest packaged release is [v0.4.0](https://github.com/hectoresen/CraftAtlas/releases/tag/v0.4.0). No feature was introduced by this audit.

**Observed acceptance superseding older provisional wording:** the owner confirmed global tracker toggle retention after switching recipes, disabling and returning, and persistence on `/reload` on 2026-11-16 (recorded in `docs/TESTING.md`); the owner also confirmed the open-bank Hojaplata correction. These do **not** prove distinct-character isolation, every tooltip origin, all locale/scale combinations or exact client build. Historical unmet acceptance is not silently waived.

**Explicit closure blockers / classifications:**

- `add-first-playable-material-tooltips`, `expand-all-profession-material-coverage`: original starter-count, live-dataset denominator and per-origin client evidence are not completely met; retain active.
- `enhance-addon-icon-minimap-settings` and `native-wow-profession-tree-redesign`: some original UI requirements were subsequently superseded (notably the spec's broom icon vs approved inline X); require formal specification/owner scope reconciliation before archive.
- `feat001-track-craftable-materials`, `upd001-global-craftable-tracking`, `upd002-native-addon-options`, `fix001-native-chat-links-and-recipe-icon`: implemented; mandatory unchecked client/release-evidence tasks remain a separate acceptance matter. Preserve as blocked pending genuine evidence or approved change.
- `mandatory-multiagent-documentation-gate`: task checklist complete; archive readiness still requires matching approved scope, canonical sync and owner acceptance, not merely checked boxes.
- Remaining historical proposal folders: evaluate individually against actual implementation PRs, required evidence and immutable delta specs. Do not infer archived status from merge alone or check tasks retroactively without proof.

**Repository governance observed 2026-11-18:** two active rulesets protect `main`; all four CI contexts (`repository-validation`, `traceability`, `lua-compatibility`, `lua-regressions`) are required with no CI bypass, and the review ruleset has `require_code_owner_review: true`. The two-account behavior matrix remains untested. This supersedes older instructions asking the owner to enable CODEOWNERS.

**Disposition:** enter maintenance with a truthful *open but documented* OpenSpec ledger rather than label unverified changes complete. A future archive transaction must follow `docs/SDD_COMPLIANCE.md`, not a docs-only exemption.

## Forever screenshot documentation (2026-11-27)

| Change | Approved spec | Implementation | Acceptance evidence | Archive state |
| --- | --- | --- | --- | --- |
| `upd006-document-forever-screenshots` | [#81](https://github.com/hectoresen/CraftAtlas/pull/81), approved by @hectoresen and merged | [#82](https://github.com/hectoresen/CraftAtlas/pull/82) | Six PNG signatures, chunk checksums, and SHA-256 hashes match the contributor originals. The [gallery](v0.5.0/README.md) loads all six images when opened from the root README on GitHub. Repository and package tests passed. The test ZIP contained 32 runtime files and excluded the screenshots. | **Prepared** in PR #82 at `openspec/changes/archive/2026-11-27-upd006-document-forever-screenshots/` with the canonical requirements synchronized. |
