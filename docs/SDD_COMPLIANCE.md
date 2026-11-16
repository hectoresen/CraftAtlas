# CraftAtlas SDD compliance — specification-to-code contract

The policy in scripts/validate_sdd.py is enforced by .github/workflows/spec-compliance.yml on every pull request. It is **not** an OpenSpec command: OpenSpec generates and validates the specifications; CraftAtlas CI enforces their PR-level provenance.

## Governance changes and review protection (approved spec #41)

The repository now uses independent `main` review and status-check rulesets; their actual configuration is recorded in `docs/GITHUB_SETTINGS.md`. Reviewer bypass for repository admins applies **for pull requests only**, never to status checks. The author cannot approve their own PR. SDD validates **scope and provenance**, not a GitHub human approval.

The owner-approved `harden-contributor-pr-governance` change is a **narrow exception** to governance-file restrictions: its implementation may update `AGENTS.md` and root `CODEOWNERS` only when each path is explicitly listed in its approved `sdd-scope.json`. Unrelated OpenSpec changes remain prohibited from modifying AGENTS and hidden `.github/` governance paths. See regression fixtures in `tests/test_validate_sdd.py`.

## Two separate pull requests (default for functional work)

**Phase A: specification.** Start with the official OpenSpec /opsx:propose command inside OpenCode (or the officially generated equivalent). After review, open a PR changing **only** a new openspec/changes/<id>/ directory. In the PR description, on separate lines:

~~~text
OpenSpec-Change: add-material-profession-tooltips
OpenSpec-Phase: proposal
~~~

The change directory must contain proposal.md, design.md, tasks.md, at least one specs/**/spec.md and an additional project-specific manifest sdd-scope.json. The manifest is NOT an official OpenSpec artifact or command: it is a CraftAtlas CI policy input. Example:

~~~json
{
  "allowed_paths": [
    "addon/CraftAtlas/**",
    "tests/**",
    "docs/TESTING.md",
    "CHANGELOG.md"
  ]
}
~~~

Only an explicit file or a bounded directory/** pattern is accepted; * and ** alone are rejected. GitHub Actions changes require a **single explicit** `.github/workflows/<name>.yml` or `.yaml` path in the approved scope; `.github/workflows/**`, `.github/**` and arbitrary hidden paths are forbidden. This approval does not relax owner/chronology/approval gates or allow other governance files. The owner reviews the requirements, proposed paths, tests and dataset rights, then merges the spec-only PR. Do not implement before owner approval.

**Phase B: implementation.** Begin only after the approved specification PR has been merged into main by @hectoresen. Run the official /opsx:apply (or generated equivalent). Create a separate code PR with:

~~~text
OpenSpec-Change: add-material-profession-tooltips
OpenSpec-Phase: implementation
OpenSpec-Approval-PR: 17
~~~

Use the REAL number of the earlier merged spec PR. It must target main, have been merged by @hectoresen, and have modified the exact named OpenSpec change. The change's proposal, design, delta specs and scope must already exist in main. Implementation cannot change them; tasks.md may be updated as work progresses. Any changed files outside the pre-approved manifest cause CI failure. A spec needing revision requires a new reviewed specification proposal; do not silently modify its scope in the implementation PR.

## How the validator works, exactly

1. A pull_request event (opened, synchronize, reopened, edited, ready_for_review) triggers the job.
2. GitHub Actions checks out the PR merge/head, fetches the base branch and uses a three-dot git diff to identify changed paths, including deletions. Only read-only GitHub API access is granted.
3. Python tests run independently using mocked GitHub responses and temporary OpenSpec fixtures.
4. The validator parses exactly one set of machine-readable PR metadata, ignores fenced code examples and rejects duplicates.
5. For phase proposal, it checks the required artifacts, scope syntax, that the proposal is new relative to main, and that there are no other edits.
6. For phase implementation, it checks the artifacts in main, consults GitHub's API for the referenced merged specification PR and its merging user, and verifies that the actual changed files fit the frozen scope. Previously existing unrelated specs do not authorize new work.
7. The official OpenSpec CLI runs: openspec validate --all --strict --no-interactive. It checks OpenSpec syntax/requirements; it does not prove the developer followed the process.
8. CI fails on any policy failure. The owner still reviews the code's semantic match with SHALL scenarios, tests and actual Forever client compatibility.

## Owner-approved lifecycle reconciliation (spec PR #13)

This is a **separate, narrowly gated phase**, not a general exemption and not permission to bypass the default two-PR specification → implementation process.

**Stage B (governance implementation):** spec-only PR #13 was merged by @hectoresen on 2026-11-15. The corresponding implementation PR adds the lifecycle validator and regression tests without editing OpenSpec configuration or historical accepted specifications.

**Stage C (reconciliation PR after Stage B is merged):** use exact PR metadata on separate lines:

~~~text
OpenSpec-Change: reconcile-openspec-lifecycle-and-status
OpenSpec-Phase: lifecycle
OpenSpec-Approval-PR: 13
~~~

In lifecycle mode, the CI checks:
- The exact lifecycle change ID and spec approval PR **#13**, owner-merged before creation of the lifecycle PR, with no other change ID permitted.
- An immutable hardcoded allowlist: \`openspec/config.yaml\`, \`openspec/README.md\`, \`AGENTS.md\`, \`docs/OPENSPEC_STATUS.md\`, \`docs/AGENT_WORKFLOW.md\`, \`docs/ROADMAP.md\`, \`docs/TESTING.md\`, \`README.md\`, \`CHANGELOG.md\`, supported canonical \`openspec/specs/<capability>/spec.md\` paths and selected historical \`tasks.md\` files.
- Canonical capability names must exist in the already approved deltas for the three legacy changes covered by PR #13; new gameplay requirements cannot enter through lifecycle sync.
- Archived legacy files must match an approved original file byte-for-byte and be supported by an evidence ledger. Deleting an original requires a matching dated archive copy in the same PR. Historical proposals/designs/specs/scopes cannot be rewritten under the lifecycle shortcut.
- \`openspec/config.yaml\` must keep \`schema: spec-driven\` and must no longer claim the addon is a non-playable v0.0.0 scaffold.

**Context drift protection:** after the approved repair is merged, each subsequent SDD PR validation checks the current \`openspec/config.yaml\` against its base. Reintroducing the v0.0.0 non-playable statement, removing \`schema: spec-driven\`, or losing the \`README.md\` current-state pointer fails. Preexisting stale main context is tolerated **only until** the lifecycle reconciliation so Stage B is not blocked by legacy debt.

No automated check can prove semantic parity between all source code and current prose. Agents must still invoke \`skills/documentation-sync/SKILL.md\` before functional PRs, inspect \`README.md\` and report game-client evidence separately. Archiving incomplete requirements or claiming full live-realm coverage requires explicit owner acceptance and cannot be inferred from the addon merely working.

## Owner-authorized single-PR exception (PR #14 only)

On 2026-11-15, @hectoresen explicitly approved implementing the V3 visual material explorer and its behavior in the existing specification PR #14. `OpenSpec-Phase: combined` is accepted **only** when the PR number is 14 and the change ID is `improve-material-explorer-ui`. The PR must introduce its own proposal, design, delta specs, tasks and bounded scope, and contain real non-spec implementation changes within that scope. The only additional governance edits permitted here are the validator, its tests, AGENTS.md and this policy document. Any GitHub workflow change, unrelated change ID, different PR number or unrelated file still fails. This exception does not apply to future proposals; the two-PR contract remains in force otherwise.

The owner explicitly authorized this exception before implementation. Passing CI does not replace manual review or in-game verification, and only @hectoresen can merge.

## Small exceptions

- OpenSpec-Exemption: docs-only — only Markdown/text outside governance and runtime directories.
- OpenSpec-Exemption: maintenance — only .gitignore, .editorconfig or .luacheckrc.
- OpenSpec-Exemption: bootstrap — **one-time PR #2 only**, restricted to AGENTS.md, CONTRIBUTING.md, PR template, SDD workflow, validator, its tests and this document.

Do not combine an exemption with a change/phase/approval declaration. Unlisted files or any gameplay code reject the bootstrap exemption. Any other governance changes should follow the normal spec-first workflow.

## Examples

| PR change | Result |
| --- | --- |
| Lua only, no OpenSpec metadata | Rejected |
| Lua plus brand-new spec in same PR | Rejected; two phases must be separate |
| Lua plus an old unrelated spec ID | Rejected; no matching owner-merged approval PR |
| Code references unmerged or other person's spec PR | Rejected |
| Code modifies accepted delta spec or sdd-scope.json | Rejected |
| Code outside the approved path manifest | Rejected |
| Workflow explicitly enumerated in owner-merged spec manifest | Accepted subject to all other checks |
| Any other workflow or broad `.github/**` manifest pattern | Rejected |
| Valid spec-only PR with new change and no code | Accepted by structural check |
| Implementation after valid owner-merged spec PR, inside scope | Accepted by structural check; still needs code and human review |
| README-only with docs-only exemption | Accepted by structural check |
| Lua with maintenance exemption | Rejected |

## Testing locally

From a checkout containing both the base and PR branch:

~~~bash
python3 -m unittest discover -s tests -p 'test_validate_sdd.py' -v
python3 scripts/validate_sdd.py --base origin/main --head HEAD --event /path/to/pr-event.json
openspec validate --all --strict --no-interactive
~~~

The PR event JSON must contain number and pull_request.body. Implementation checks additionally require a read-only GITHUB_TOKEN to consult GitHub; this is available in Actions.

## Threat model and limits

- File paths and explicit approval evidence can be validated; **semantic equivalence of implementation and specs cannot**. The owner must review scenarios and implementation.
- GitHub confirms the approval PR was merged by the owner. This does not prove the original specification was *read* by a person or that implementation started only afterwards. Human review checks chronology.
- This workflow runs code from a proposed branch. A malicious contributor with write permissions might change its own validator or workflow, so for hard enforcement configure branch rulesets and protect the required check against bypass. We will do that later with GitHub CLI as requested.
- Until main is protected, a failing CI does not technically forbid merging or direct pushes. CODEOWNERS and Markdown policies do not enforce owner-only merging.
- A scope manifest proves only file boundaries, not that every changed line is justified. Broad directory scopes require careful human review.
- OpenSpec must be installed via the official package; no custom OpenSpec commands are required.

## Troubleshooting

"Missing OpenSpec-Approval-PR": first obtain a merged specification PR.
"Approved ... not present on main": update/rebase onto main after the spec is merged.
"Changed files outside approved scope": revise the implementation scope or submit a separate spec review.
"Governance": propose and approve a dedicated change, never bypass by claiming a docs exception.

Do not merge PR #2 before its tests and both GitHub Actions workflows are green. The future ruleset should require the stable SDD Compliance / traceability and CI / repository-validation checks.
