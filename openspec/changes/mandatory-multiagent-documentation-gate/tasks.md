# Tasks: mandatory multiagent documentation skill

## Owner approval
- [x] Owner merged specification PR #31.
- [x] Canonical skill is a plain readable file under skills/documentation-sync/SKILL.md; automatic vendor discovery is deliberately not asserted.

## Implementation — portable skill and instructions
- [x] Create canonical `skills/documentation-sync/SKILL.md` with portable frontmatter, required pre-PR trigger, code-to-doc audit, evidence hierarchy, single-agent and optional parallel audit roles, minimal precise doc updates and report.
- [x] Document explicit file-path invocation from AGENTS for Codex/Claude/Copilot and generic agents, with no duplicated content.
- [x] Refactor `AGENTS.md` to agent contract only, current stack/architecture boundaries, OpenSpec gating, owner-only actions, table of documented skills and mandatory invocation.
- [x] Update `CONTRIBUTING.md`, `docs/AGENT_WORKFLOW.md` and create `docs/DOCUMENTATION_PROTOCOL.md` with skill entry points, invocation and evidence.
- [x] Record the stale `openspec/config.yaml` context for a separately scoped governance update; no unauthorized edit.

## Implementation — guardrail
- [x] Add documented PR review declaration and documentation evidence in `docs/DOCUMENTATION_PROTOCOL.md`.
- [x] Add `scripts/validate_documentation.py` + focused tests: PR metadata, README change/justification, feature vs docs-only vs spec proposals, incomplete review and SDD independence.
- [x] Add documentation gate to `.github/workflows/ci.yml` with read-only permissions and PR event metadata; keep release validator shared as-is.
- [x] Modify `scripts/validate_sdd.py` narrowly to allow AGENTS.md only under this exact approved governance change with explicit paths, and add regression tests for all bypass cases.

## Verification and handoff
- [x] Review canonical skill references and examples; make no unsupported auto-discovery claims.
- [x] GitHub CI (including Python documentation regressions and release-readiness checks) and SDD Compliance passed on PR #32. Local commands and real-client checks NOT RUN; no Lua/gameplay changes.
- [x] Confirm README accurately describes source functionality; AGENTS contains no duplicate outdated feature statuses.
- [x] Open implementation PR #32 referring to merged specification PR #31, without merging.
