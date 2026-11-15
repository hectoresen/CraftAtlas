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
- [ ] Validate all skill references and command examples; no fabricated supported automatic invocation.
- [ ] Execute Python documentation/SDD regressions, repository validator, relevant Lua tests, shared release checker, strict OpenSpec and CI; report not-run commands.
- [ ] Confirm README accurately describes source functionality; AGENTS contains no duplicate outdated feature statuses.
- [ ] Open a separate implementation PR with `OpenSpec-Approval-PR` referencing the real owner-merged spec PR, no automatic merge.
