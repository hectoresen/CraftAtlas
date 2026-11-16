# Developer setup and repository conventions

CraftAtlas is a **Lua World of Warcraft: Forever addon**, source version `0.2.0-dev`. Source code, PRs, agent instructions and engineering documentation use English; user-facing strings support enUS/esES. The maintainer has reviewed and approved the overall Materiales/Fabricables UI in-game, but dataset completeness, every tooltip origin and exact game-build compatibility remain separate QA tasks.

## Local environment

Use Git, Python 3.11+, and a Lua/texlua interpreter for offline Lua tests. The official OpenSpec CLI requires its supported Node.js version (currently documented as Node 22.12+ in project governance). Start by reading [AGENTS.md](../AGENTS.md), [OpenSpec](../openspec/README.md), [architecture](ARCHITECTURE.md) and [data model](DATA_MODEL.md).

```sh
git clone https://github.com/hectoresen/CraftAtlas.git
cd CraftAtlas
bash scripts/validate_release_checks.sh
python3 scripts/build_materials.py --check
python3 scripts/coverage_report.py
texlua tests/test_addon.lua
texlua tests/test_recipe_catalog.lua
texlua tests/test_explorer_layout.lua
texlua tests/test_profession_tree.lua
texlua tests/test_release_version.lua
texlua tests/test_recipe_cards.lua
texlua tests/test_catalog_progress.lua
texlua tests/test_catalog_preparation.lua
texlua tests/test_catalog_scheduler_failure.lua
texlua tests/test_catalog_header.lua
texlua tests/test_chat_links.lua
```

The shared shell script runs the same **Python release-readiness tests** required by both PR CI and manual release; individual Lua tests and actual game-client smoke tests must be executed and reported separately. `/craftatlas perf` prints in-memory session counters (attempted/total units, batches, worst observed batch times (when supported), full-search and refresh counts) on demand, without sending or persisting diagnostics. Compare the same cache/build conditions before and after an optimization; a reduction in refreshes is not proof of increased FPS. For the full matrix see [testing](TESTING.md).

## Implementation boundaries

- `Core/`: initialization, wiring and lifecycle.
- `Data/`: pinned source/license evidence and deterministic generated runtime indices.
- `Domain/`: pure material lookup, filtering, profession grouping/expansion, recipe identity/ingredient logic and catalog progress/coalescing arithmetic, no WoW globals.
- `Infrastructure/`: guarded client APIs, asynchronous names/icons/tooltips, minimap and preferences.
- `Features/`: native Materiales and Fabricables UI and tooltip annotation.
- `Features/Settings/Shared/ExplorerWidgets.lua`: reusable native search, inline clear X, profession layout, filter, virtualized rows, pager and layout; avoid duplicating a separate explorer implementation.
- `Localization/`: enUS/esES client-facing text and fallbacks.

Use `scripts/build_materials.py` to regenerate source-backed data; never edit `Materials.lua`, `RecipeUses.lua` or `Recipes.lua` by hand. Recipe identity is profession+spellID, not output itemID. Never infer recipe availability/quality or learned-status from the imported dataset.

## Spec-first workflow and PR quality

For behavior or source changes, propose an OpenSpec change, obtain its **owner-merged specification PR**, then implement in a separate PR within the approved `sdd-scope.json`. An implementation PR may update the change's `tasks.md`, but not silently change its approved spec/design/scope. The single PR #14 combined exception is historical and nonreusable. Only @hectoresen may decide merges, release publication, repository permissions or protected settings.

Before opening any PR, compare new behavior with README, architecture, data model, installation, testing, roadmap, changelog and relevant specs. Reconcile only factual updates; do not call unrun tests passed. Each PR must declare exact test commands/results, unrun Forever checks, relevant source rights, rollback and a clear review request. More precise rules live in [AGENTS.md](../AGENTS.md), [AGENT_WORKFLOW.md](AGENT_WORKFLOW.md) and [SDD compliance](SDD_COMPLIANCE.md).

## Contributor CI and review workflow

Code PRs run read-only Python/release readiness and SDD/OpenSpec validation plus `lua-compatibility` (Lua 5.1 parsing) and `lua-regressions` (each isolated Lua fixture). The latter job names are not required in GitHub rulesets until the implementation is merged and observed successful; see `docs/GITHUB_SETTINGS.md`. All agents must explicitly run `skills/documentation-sync/SKILL.md` after changes and before functional PR review, including a substantive no-change rationale when applicable.

### Cost-aware pull request validation

GitHub Actions distinguishes **OpenSpec-only**, **Markdown/text-only** and **code/mixed** changes using the actual base/head diff. Specs only: strict OpenSpec/SDD, with no Lua or release readiness. Docs only: lightweight Markdown and SDD policy checks without costly Lua/Python/catalog/npm setup. Code or workflow changes: all checks, including Lua 5.1 syntax and regressions, Python/catalog/package/documentation source evidence, and strict OpenSpec. A stable `repository-validation` required status always reports, including for spec-only PRs, and fails closed if classification fails. No required status is omitted solely to save cost. See `docs/TESTING.md` and `docs/GITHUB_SETTINGS.md`.

## Same-PR OpenSpec archival for implementation agents

When implementing an owner-approved change, treat archive preparation as part of `documentation-sync`, not as a new follow-up PR. If accepted scenarios are actually verified, sync approved canonical specs and move the full original change to `openspec/changes/archive/YYYY-MM-DD-<change-id>/` **in the implementation branch**; otherwise retain active files and mark `OpenSpec-Archive: blocked` with named acceptance gaps. No direct main merges, no speculative checkmarks and no changes to unrelated approved specs. Reference `docs/SDD_COMPLIANCE.md` and include evidence in the PR body.

## Branch discipline for coding agents

New OpenSpec IDs are lowercase CLI-compatible `feat001-scope`, with the next free padded type-local sequence: `feat`, `fix`, `chore`, `upd`, `del`. Create proposal branches as `SPEC/FEAT001-scope` and implementation branches as `FEAT/001-scope` (substitute corresponding category). Keep exact identity across PR metadata and archived spec. Before each PR, check current `main`, active+archive folder names and concurrent open PRs. Old accepted specs keep original IDs. After GitHub PR creation verify the mandatory Actions checks exist on current commit; one PR metadata retry is allowed if absent. Missing/failed checks block handoff, even when local tests pass.

