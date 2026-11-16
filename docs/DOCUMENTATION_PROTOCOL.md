# Mandatory documentation review before pull requests

The canonical, model-independent skill is **[documentation-sync](../skills/documentation-sync/SKILL.md)**. Every agent (Codex, Claude Code, Copilot, OpenCode, or a generic coding assistant) must **explicitly read and execute that file after implementation/testing and before opening a functional PR**, regardless of automatic skill discovery. It supports optional parallel subagents, but serial execution is fully supported.

## Executable acceptance for agents

Every agent must explicitly open the exact `skills/documentation-sync/SKILL.md` file, perform its feature, technical, QA and milestone audits after implementing tests, and reconcile those findings before opening **or updating** a functional PR. Automatic skill discovery is optional; executing the review is not. A standalone statement saying "skill completed" without concrete file/behavior evidence is insufficient. Source changes must be reflected in README and relevant technical docs, or include a precise README no-change rationale tied to the changed code paths and reviewed document names.

`Documentation-Evidence` is **evidence**, not a claim that CI can observe private agent execution. Record source paths, which docs were modified or inspected, relevant test names/results and real-client evidence or NOT RUN. The validator rejects empty/general boilerplate and requires meaningful source-to-doc explanations. After revisions change behavior or tests, rerun the skill and update the PR body. Maintain the accepted OpenSpec scope; do not rewrite proposal/design/scope in implementation PRs.

## Documents and ownership

- `README.md` owns the **current functional reality**: user features, limitations, commands, screenshots/examples and source/data scope.
- `AGENTS.md` owns **agent instructions**, OpenSpec, code boundaries, skills catalog, pre-PR verification and owner permissions. Avoid ever-growing product feature descriptions or unverified build numbers there.
- `docs/ARCHITECTURE.md`, `DATA_MODEL.md`, `INSTALLATION.md`, `DEVELOPMENT.md`, `TESTING.md` document technical implementation, source provenance, usage and evidence.
- `docs/ROADMAP.md` separates implemented from not implemented; `CHANGELOG.md` records actual source changes, not speculative features.
- `openspec/changes/<id>/tasks.md` records evidenced completed tasks. Approved specs/design/scope are immutable in ordinary implementation PRs. Historical archive/sync stays under its separately approved lifecycle process.

## When and how to invoke

1. Complete approved implementation and tests; gather the actual current branch diff and source.
2. Read `skills/documentation-sync/SKILL.md` **in full**. Assign its four audit roles sequentially or to nonoverlapping subagents, then reconcile findings.
3. Update README and affected docs. If no change is warranted, record a **substantive code-to-document explanation**, not an empty exemption.
4. Validate docs paths/links, actual source identifiers, locale names and catalog counts. Report `NOT RUN` for unavailable Forever/client tests; passing CI does not verify gameplay or the beta source against live realms.
5. Run the applicable tests and `python3 scripts/validate_documentation.py` with PR event/diff after PR details are available; pre-PR run its pure unit tests and review the diff. Open PR only after the skill is complete.

## PR metadata

For a functional PR with documentation changes:

```text
Documentation-Review: updated
Documentation-Evidence: README.md and CHANGELOG.md aligned to <specific implemented functionality>; <actual test/evidence details>.
```

For a functional PR with **no** user-facing documentation impact:

```text
Documentation-Review: not-applicable
Documentation-Evidence: <explicit inspected behavior/source and why README and other docs remain accurate; include relevant test evidence>.
```

CI validates **structure**, not inner agent execution or semantic truth. A missing attestation on functional PRs, an empty/superficial rationale, or `updated` without changed documentation fails. Spec-only proposal and docs-only changes receive lighter handling. The GitHub documentation gate complements, not replaces, the mandatory SDD traceability, owner-merged specification, and explicit owner merge decision.

## Local verification

```sh
python3 -m unittest discover -s tests -p 'test_validate_documentation.py' -v
python3 -m unittest discover -s tests -p 'test_validate_sdd.py' -v
bash scripts/validate_release_checks.sh
```

Agent adapters may provide GitHub file APIs instead of a local `git` checkout; verify changed files and README through those APIs. Never claim commands executed in a local checkout if only GitHub CI ran.

## Known protected-source debt

`openspec/config.yaml` still includes a historical `v0.0.0` scaffold description. Updating that protected file needs **separate approved scope and validator policy**; it is not silently changed by this skill implementation. A broader reconciliation/archival process is already separately proposed.

## Mandatory archive readiness audit

Documentation synchronization is not complete until the agent compares the approved delta specifications, actual source behavior, tests, README and technical docs; identifies mandatory acceptance scenarios requiring real WoW Forever evidence; and records either an eligible **same-PR archive transaction** or an explicit reason for remaining active. `OpenSpec-Archive: prepared` requires an exactly matching dated lossless copy of the approved change, synchronized canonical specs and a provenance/acceptance ledger. `OpenSpec-Archive: blocked` requires named missing scenarios/tests (`NOT RUN` or failed), active tasks preserved, and a maintainer handoff. Generic archive metadata does not demonstrate skill execution or game verification. Review again after every PR code/test/acceptance revision.

## New OpenSpec naming and PR-check audit

The mandatory `documentation-sync` agent audit must verify that a newly created change uses the official CLI-safe lowercase `feat001-kebab-name` identity, the proposal branch `SPEC/FEAT001-kebab-name`, the implementation branch `FEAT/001-kebab-name`, and a unique type-local sequence against trusted active+archive specs and open PRs. Verify immutable owner-approved legacy IDs remain unchanged. Before saying “ready for review,” inspect current-HEAD GitHub check-runs: `repository-validation`, `traceability`, `lua-compatibility`, `lua-regressions`. Record actual success/skipped/pending/failure; an absent run is not a skipped result. If absent, perform one safe PR-body update via GitHub integration and recheck; if missing/failed, stop handoff and report exact contexts. Never fabricate check results.

