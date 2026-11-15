# Design: one portable skill, traceable documentation review

## Source-of-truth architecture
- **README.md**: user-facing current product description, major features, usage, supported limitations, source scope and installation entry point.
- **AGENTS.md**: short **agent contract only** — read order, architecture rules, code standards, SDD/OpenSpec process, skills catalog, pre-PR invocation and owner-controlled actions. Do not duplicate evolving README feature lists, counts or historic milestones.
- **docs/ARCHITECTURE.md / DATA_MODEL.md / DEVELOPMENT.md / INSTALLATION.md / TESTING.md / ROADMAP.md**: domain-specific truth, including evidence vs claims.
- **CHANGELOG.md**: source change history separated from future roadmap.
- **openspec/changes/<id>/**: accepted requirement deltas and source of approvals. Implementation can tick tasks.md but cannot rewrite accepted specs or scope.
- **docs/AGENT_WORKFLOW.md / DOCUMENTATION_PROTOCOL.md**: portable protocol lifecycle and review guidance.
- **.agents/skills/documentation-sync/SKILL.md**: the **canonical skill**, with frontmatter+instructions; the universally readable canonical Markdown file; automatic vendor discovery is not assumed.

## Execution order
```text
DISCOVER → SPEC PROPOSAL PR → OWNER MERGE → IMPLEMENT → TEST
   → documentation-sync skill (audit → update → validate → attest)
   → PR → CI/Security/SDD → OWNER TEST/REVIEW → OWNER MERGE
```
For a proposal-only PR, still review docs impact but no premature feature claim. For a docs-only PR, run a lighter truth check. Agents supporting subagents can run the four audit roles in parallel and use a single editor coordinator; others perform the same steps sequentially.

## Skill steps
1. Read current source with real tools: `git diff --name-status origin/main...HEAD`, current code, README and all touched docs, accepted spec, tests and data manifests.
2. Build evidence table: feature/behavior, code location, released/merged/proposed state, source rights, screenshot or game test, docs claim and correction required.
3. Assign isolated roles: `functionality-audit`, `technical-documentation`, `qa-evidence`, `release-history`. One coordinator resolves conflicts and owns integration.
4. Update README first for behavior, then relevant technical docs, CHANGELOG and roadmap. Leave unrelated docs unchanged with explicit reason; no hollow timestamp-only edits.
5. Check enUS/esES names, commands/API usage, data counts and unsupported claims; treat live-client test vs beta data validation separately.
6. Execute available local checks, generated drift and docs gate; list commands and `NOT RUN` exactly. Preview diff and verify no policy violation, then prepare PR.
7. PR body includes `Documentation-Review: updated` (with changed doc paths) or `Documentation-Review: not-applicable` (with reason) plus a short evidence report. CI reports structural completeness, not that semantic truth is guaranteed.

## CI enforcement
- `scripts/validate_documentation.py` accepts `--base`, `--head`, `--event` or a testable pure `validate(changed_paths, pr_body, phase, ...)`.
- Functional changes (addon source, data generators or user-facing behavior) require README update **or a substantive, reviewable justification of no README change**, updated CHANGELOG where history changes, and `Documentation-Review` PR metadata; prevent empty `updated` attestations. Docs-only changes use a lighter mode.
- Keep `spec-compliance.yml` authoritative for all OpenSpec metadata. Never accept `not-applicable` as permission to bypass SDD. Avoid duplicate nontrivial parsing in PR CI unless necessary.
- Tests cover: happy path with README/other docs, missing attestation, fabricated pass wording, unrelated/no-op README edits, justified no-change, spec-only changes, docs-only changes, and the governance-specific installation PR.
- `ci.yml` adds a PR event-scoped docs check with `pull-requests: read` only if metadata is read via GitHub API; prefer `GITHUB_EVENT_PATH` and read-only checkout/base diff. Also keep push-to-main checks unaffected.

## SDD governance exception
The current `scripts/validate_sdd.py` rejects `AGENTS.md` from every implementation PR. To implement this approved governance update, permit the file *only* when
`change_id == mandatory-multiagent-documentation-gate`, `OpenSpec-Phase: implementation`, the actual owner-merged proposal PR is referenced and `AGENTS.md` is listed in the approved sdd-scope.json. All other changes retain existing protected-path restriction. The OpenSpec config file remains protected outside this approved scope; the explicit CI workflow is allowed by the existing validator. Regression test unauthorized changes, fake approvals and non-owner mergers. Do not create another combined-phase exception.

## Documentation truth and OpenSpec lifecycle
This feature's governance update does **not** silently close unrelated historical OpenSpec changes or rewrite their approved delta specs. The separately proposed `reconcile-openspec-lifecycle-and-status` change owns historical archive/status migration; maintain accurate pending markers until approved evidence and authorized lifecycle sync are available.
