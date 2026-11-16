---
name: documentation-sync
description: Mandatory pre-pull-request audit and synchronization of README, technical documentation, changelog, tests and OpenSpec evidence for CraftAtlas. Use after code and tests, before opening or updating a functional PR; works in Codex, Claude Code, GitHub Copilot, OpenCode and any agent that can read Markdown.
---

# Documentation sync — mandatory before PR

**Trigger:** Run this skill **after implementation and checks, before opening every functional PR**. Re-run it after review changes that affect behavior, tests, scope or documentation. For spec-only and docs-only PRs perform a scope-appropriate factual review. Do not open a functional PR if this review is incomplete. If blocked, stop and report the blocker to the owner; never assert the skill ran when it did not.

## Inputs and evidence

Read `AGENTS.md`, `README.md`, `openspec/README.md`, the applicable **owner-merged** `openspec/changes/<change-id>/` proposal/specs/design/tasks/scope, `docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, `docs/INSTALLATION.md`, `docs/TESTING.md`, `docs/ROADMAP.md`, `docs/DEVELOPMENT.md`, `CHANGELOG.md`, and all affected source/tests. Obtain the actual base/head diff (`git diff --name-status origin/main...HEAD` when locally available; when using connectors, inspect the PR file list and branch contents). Inspect current code, not only spec/roadmap claims. Preserve provenance and attribution.

Separate evidence categories: **implemented in code**, **tested by a named human in the real Forever client**, **executed offline**, and **source-backed but not live verified**. Only the exact supplied evidence can support claims; unrun commands are `NOT RUN`. Do not guess game builds, current live recipe availability, client API availability, item rarity, numbers, tests, or merge/release status.

## Multiagent roles (parallel optional, single-agent required fallback)

A coordinator owns the final diff and acceptance. Run these audits in parallel only when separate agents/tools exist and each has disjoint write ownership; otherwise perform sequentially.

| Audit role | Source of truth | Owns |
| --- | --- | --- |
| Feature reality auditor | Code, user journeys, accepted spec, localized labels | README current features/usage/limitations; identifies obsolete promises |
| Technical documentation auditor | Domain/infrastructure code, generated data, provenance | Architecture, data model, installation, development |
| QA and evidence auditor | Tests, CI workflows, user-reported real-client results | TESTING, commands/results/NOT RUN, compatibility claims |
| Milestone and history auditor | Merged source, PR scope, outstanding requirements | ROADMAP, CHANGELOG, OpenSpec task status |

**Never** allow multiple agents to edit the same file concurrently. Coordinator reconciles contradictions and reviews final changed files against approved `sdd-scope.json`.

## Procedure

1. **Audit:** Build a compact truth table: affected feature → source file/function → implemented vs planned → existing docs claim → required correction. Confirm the public tab names **Materiales / Fabricables**, Lua API names, locale strings, itemIDs/recipe keys, output types and source catalog counts directly from source when relevant.
2. **README first:** Update user-visible feature documentation, examples, commands and limits for actual implementation. Do not append unbounded "candidate" paragraphs or duplicate milestone summaries. If no README change is warranted, state exactly why and show it was reviewed.
3. **Technical docs:** Review architecture, data model, installation, testing, roadmap, developer guidance and changelog. Update each affected file; for unchanged files record a one-line reason. Keep `AGENTS.md` for **agent protocol only**: no feature status or fluctuating catalog statistics.
4. **OpenSpec and archive decision:** Verify actual implementation against every approved SHALL scenario, separate offline PASS from actual Forever-client evidence and update the current `tasks.md` truthfully. Decide archive eligibility before opening the implementation PR. If every mandatory acceptance criterion has evidence, sync only the accepted canonical capability specs and prepare a complete, lossless dated archive of *this* change (the owner-approved proposal/design/deltas/scope are immutable); remove its active folder, update `docs/OPENSPEC_STATUS.md` with the implementation PR evidence, and declare `OpenSpec-Archive: prepared`. If any mandatory check is NOT RUN/failed/unverified, retain the active folder and unchecked task(s), declare `OpenSpec-Archive: blocked` with exact named gaps, and do not claim acceptance. A merge of the implementation PR is the final acceptance; a rejected/closed PR leaves main unchanged. Follow `docs/SDD_COMPLIANCE.md`. Never archive unrelated historical changes.
5. **Checks:** Inspect references, paths, links, source license and generated files; confirm documentation uses real commands and includes what CI actually runs. Execute available `bash scripts/validate_release_checks.sh`, applicable Lua/Python tests, and documentation validation. Record results and `NOT RUN` for unavailable checks and Forever client.
6. **Final gate:** Review `git diff origin/main...HEAD` / connector change summary, verify no unsupported current claims and no out-of-scope edits. Produce a concise handoff including docs reviewed/updated/unchanged+reason, code evidence, tests executed/not run and risks. **Only then** construct/open the PR.

## Review-ready evidence contract for contributors

Before authoring a PR body, explicitly verify and record: (1) which implementation paths changed and user-visible behavior, (2) README claims compared against code, (3) exact technical documentation and CHANGELOG reviewed or updated, (4) actual test commands/results and `NOT RUN` client coverage, (5) matching approved OpenSpec scope and unfinished tasks, and (6) no missing licenses/provenance for changed data. An `updated` declaration must correspond to changed documentation; a `not-applicable` declaration requires an explicit reason connected to source files and existing documentation. The structural CI checks these artifacts, **not** whether a private agent invoked a particular internal tool.

The GitHub PR review and technical checks rulesets are independent. The owner may bypass only the review rule by submitting a PR; no owner or contributor should bypass required CI. Do not merge or enable auto-merge yourself.

## OpenSpec archival attestation (required for implementation)

In the PR body, in addition to the ordinary OpenSpec change, phase and approval fields, provide exactly one state and one substantive explanation:

```text
OpenSpec-Archive: prepared
OpenSpec-Archive-Evidence: tests/<fixture>.py PASS and real-client acceptance recorded where required; canonical openspec/specs/<capability>/spec.md synchronized; complete openspec/changes/archive/YYYY-MM-DD-<change-id>/ prepared and docs/OPENSPEC_STATUS.md updated.
```

Alternatively, when mandatory acceptance is missing:

```text
OpenSpec-Archive: blocked
OpenSpec-Archive-Evidence: docs/TESTING.md lists the specific mandatory client scenario NOT RUN; the corresponding task stays unchecked and openspec/changes/<change-id>/ remains active.
```

For a `prepared` PR, ensure archive files equal the approved base artifacts byte-for-byte except truthful task checkmarks/evidence. The canonical spec must retain prior requirements and include the approved delta. An archive path only becomes accepted on the owner's merge; the PR itself must not claim already-merged provenance. For `blocked`, never create partial archives, modify canonical specs or mark unresolved acceptance fulfilled. CI can check structure and file integrity; an agent must not claim CI proves semantic/client verification.

## PR attestation (required for implementation)

Include exact standalone PR-body lines:

```text
Documentation-Review: updated
Documentation-Evidence: README.md, docs/ARCHITECTURE.md, CHANGELOG.md — audited against implementation; tests recorded separately.
```

For legitimately unchanged README and other functional docs, instead use:

```text
Documentation-Review: not-applicable
Documentation-Evidence: <specific source-to-doc review, why no user-visible documentation changed, and which technical/test docs were checked>
```

`not-applicable` is **not** permission to skip the audit. `updated` must correspond to actual documentation file changes. CI performs **structural** checks on attestation and changed paths; only maintainer review can assess semantic correctness and whether this skill was actually invoked.

## Blockers and hard limits

If a functional change lacks an approved spec, scope, or adequate evidence, **stop before PR** and report what must be resolved. Never fabricate tests/game evidence, invent files or PR approvals, skip copyright attribution, grant approval to yourself, push to main, merge, publish releases, change protected settings, or use PR metadata to bypass SDD. Read the compatible provider's filesystem/connector APIs; this Markdown protocol does not require a proprietary multiagent runtime.

## Action-cost awareness

OpenSpec-only proposal PRs should not force unrelated Lua/client test execution. Documentation-only PRs should not require full catalog/Lua regressions. The workflow classifies actual changed paths and retains a minimal required-status job; any mixed source/technical change receives the full suite. **This optimization never waives the skill review**: spec-only and docs-only changes still require the appropriate documentation/scope audit and truthful test evidence. Do not falsely claim intentionally skipped checks were executed.
