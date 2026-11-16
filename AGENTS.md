# AGENTS.md — CraftAtlas agent instructions

This file is an **agent contract**, not a functional product manual. Read [README.md](README.md) for current behavior and limitations. Applies to Codex, Claude Code, GitHub Copilot, OpenCode and any other coding agent.

## First read and source of truth

1. Read `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, `docs/ARCHITECTURE.md`, `docs/CODE_QUALITY.md`, `docs/DEVELOPMENT.md`, `docs/TESTING.md` and `openspec/README.md`.
2. Inspect current `main`, branch, PRs, `openspec/changes/`, accepted specifications, tests and relevant code. Do not trust historical roadmap text without verifying code.
3. For observed implemented behavior consult current source; for intended changes consult the **owner-merged** OpenSpec delta. Report discrepancies rather than silently changing requirements.

All **source code, project documentation, tests, specs and PR text are in English**. Only addon-visible strings are localized (enUS/esES). Keep advice and components small and reusable; favor deterministic, testable domain logic over framework-like abstractions.

## Implementation boundaries and practices

| Area | Responsibility |
| --- | --- |
| `Core/` | Addon lifecycle and wiring |
| `Domain/` | Pure, deterministic lookups, filters and pagination; no WoW globals |
| `Data/` | Licensed, version-pinned sources and generated Lua indices |
| `Infrastructure/` | Guarded Forever WoW APIs, name caches, SavedVariables, tooltip and minimap adapters |
| `Features/` | Thin native-WoW views and tooltip presenters |
| `Features/Settings/Shared/` | Reusable search, filter, list, pager and layout controls |
| `Localization/` | enUS/esES strings and client-locale fallback |

Use numeric itemID to identify reagents and profession+spellID to identify recipes. Names and rarity come from the client; never invent catalog facts, learned status or live compatibility. No runtime network service, unlicensed data, telemetry or mandatory external addon. Avoid duplicate tooltip hooks and expensive per-frame scanning. Follow `docs/CODE_QUALITY.md` for tests, error paths and straightforward interfaces.

## Mandatory OpenSpec / SDD lifecycle

Functional behavior, schema, client compatibility or nontrivial refactors require the standard **two PRs**:

1. Propose `openspec/changes/<id>/` with proposal, design, SHALL scenarios, tasks, and `sdd-scope.json`; open a **spec-only PR** and stop for @hectoresen to merge it.
2. After that owner merge, implement only approved scope in a new branch. Implementation PR must include `OpenSpec-Change: <id>`, `OpenSpec-Phase: implementation`, `OpenSpec-Approval-PR: <owner-merged number>`. Only `tasks.md` may advance; approved specs/design/scope stay unchanged.
3. Verify actual behavior, tests, documentation and acceptance scenarios, then open PR for **owner review**. No combined proposal/code exceptions except the historical PR #14; do not reuse it.

The official OpenSpec CLI (`@fission-ai/openspec`, using a supported Node.js version) can provide `/opsx:propose`, `/opsx:apply`, `/opsx:verify`, `/opsx:sync` and `/opsx:archive` according to installed profile. Do not invent commands when unsupported. See `openspec/README.md` and `docs/SDD_COMPLIANCE.md`. Documentation-only and tiny maintenance exemptions are narrowly restricted.

## Contributor review and non-bypassable checks

`main` has two independent active rulesets: one requires independent approval for contributors (owner/admin bypass **for pull requests only**), and the other requires CI/SDD status checks with **no bypass, even for the owner**. A PR author can never record a GitHub self-approval. Review requests in root `CODEOWNERS` do not replace actual ruleset permissions. Never enable auto-merge or merge contributors' PRs without explicit owner direction. For updates to required checks consult `docs/GITHUB_SETTINGS.md`; the dedicated Lua check names must exist and pass before the owner adds them to the mandatory checks ruleset.

## Skill catalog and mandatory pre-PR gate

| Skill | When to use | Path |
| --- | --- | --- |
| **documentation-sync** | **MANDATORY after implementation/testing and before opening or updating any functional PR**; also review doc-only/spec PRs | [`skills/documentation-sync/SKILL.md`](skills/documentation-sync/SKILL.md) |

**Explicitly read and execute the canonical skill every time.** Codex, Claude, Copilot, OpenCode or generic agents must use the file path even when automatic discovery is unavailable. The skill checks code→README, architecture/data/install/development/testing/roadmap/changelog, license, OpenSpec tasks and test evidence; optional audit subagents have non-overlapping ownership. `AGENTS.md` must **not** accumulate current feature documentation. A functional PR declares `Documentation-Review: updated` or `Documentation-Review: not-applicable`, plus `Documentation-Evidence: ...` with specific evidence; see [documentation protocol](docs/DOCUMENTATION_PROTOCOL.md). CI checks structural evidence but cannot prove internal invocation or semantic accuracy.

## Quality and handoff

Run `bash scripts/validate_release_checks.sh`, relevant Lua/Python tests, generated-data checks, documentation validation and SDD/OpenSpec checks where available. For game-facing changes record the real Forever build and manual test evidence or explicitly say **NOT RUN**. CI success is not proof of gameplay; imported source evidence is not live-realm validation.

Before asking for a merge, summarize: goal, approved spec, branch/PR, source and docs changed, tests **passed/failed/not run**, client evidence, unknowns and remaining owner decisions.

**Never** direct-push `main`, self-approve/merge, publish a release, change repository settings/rulesets/permissions, modify secrets or mark unexecuted checks passed without a separate explicit owner instruction. An instruction to implement does **not** authorize merging.

## Mandatory implementation archive readiness

For every implementation PR, explicitly run `skills/documentation-sync/SKILL.md` after code/test changes, verify all approved acceptance criteria and choose **exactly one** OpenSpec archive state. When all mandatory tests and in-game evidence required by the accepted spec are available, prepare same-PR canonical sync + lossless dated archive of **only** the approved change and remove its active folder. If evidence is missing, leave it active, preserve unchecked tasks, and declare `OpenSpec-Archive: blocked` with specific missing tests or acceptance. Never mark `NOT RUN` as passed. `OpenSpec-Archive: prepared` describes a proposed transaction; only the owner merge completes acceptance. Do not archive other active or historical changes. See `docs/SDD_COMPLIANCE.md` for exact contract. Archive preparation is mandatory to assess even when archive is blocked.

