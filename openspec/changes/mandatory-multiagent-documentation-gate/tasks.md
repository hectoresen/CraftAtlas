# Tasks: mandatory multiagent documentation skill

## Owner approval
- [ ] Owner reviews and merges the spec-only proposal PR.
- [ ] Confirm the canonical repository skill path can be explicitly read from Codex/Claude/Copilot and generic agents; do not assert automatic discovery.

## Implementation — portable skill and instructions
- [ ] Create canonical `skills/documentation-sync/SKILL.md` with portable frontmatter, required pre-PR trigger, code-to-doc audit, evidence hierarchy, single-agent and optional parallel audit roles, minimal precise doc updates and report.
- [ ] Document explicit file-path invocation from AGENTS for Codex/Claude/Copilot and generic agents, with no duplicated content.
- [ ] Refactor `AGENTS.md` to agent contract only, current stack/architecture boundaries, OpenSpec gating, owner-only actions, table of documented skills and mandatory invocation.
- [ ] Update `CONTRIBUTING.md`, `docs/AGENT_WORKFLOW.md` and create `docs/DOCUMENTATION_PROTOCOL.md` with skill entry points, invocation and evidence.
- [ ] Record the stale `openspec/config.yaml` context for a separately scoped governance update; no unauthorized edit.

## Implementation — guardrail
- [ ] Add documented PR review declaration and documentation evidence in `docs/DOCUMENTATION_PROTOCOL.md`.
- [ ] Add `scripts/validate_documentation.py` + focused tests: PR metadata, README change/justification, feature vs docs-only vs spec proposals, incomplete review and SDD independence.
- [ ] Add documentation gate to `.github/workflows/ci.yml` with read-only permissions and PR event metadata; keep release validator shared as-is.
- [ ] Modify `scripts/validate_sdd.py` narrowly to allow AGENTS + OpenSpec config only under this exact approved governance change with explicit paths, and add regression tests for all bypass cases.

## Verification and handoff
- [ ] Validate all skill references and command examples; no fabricated supported automatic invocation.
- [ ] Execute Python documentation/SDD regressions, repository validator, relevant Lua tests, shared release checker, strict OpenSpec and CI; report not-run commands.
- [ ] Confirm README accurately describes source functionality; AGENTS contains no duplicate outdated feature statuses.
- [ ] Open a separate implementation PR with `OpenSpec-Approval-PR` referencing the real owner-merged spec PR, no automatic merge.
