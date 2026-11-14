# SDD compliance gate

## Purpose and scope

Every CraftAtlas pull request must provide a **traceable reason** for its changes. This check does **not** prove that a person ran OpenSpec, that the proposed behavior is correct, or that the owner approved the work. It enforces structural evidence and rejects obvious missing or unrelated proposals.

The workflow is `.github/workflows/spec-compliance.yml`; its stdlib-only policy script is `scripts/validate_sdd.py`. It runs on every pull request (no path filters). `main` branch protection is **not yet active**; until an enforceable ruleset requires the `SDD Compliance / traceability` job, CI failure alone cannot prevent merging.

## Contributor contract

Place **exactly one** machine-readable line in your PR body, outside code fences:

```text
OpenSpec-Change: add-material-profession-tooltips
```

The named change must have all of:
- `openspec/changes/<id>/proposal.md`
- `openspec/changes/<id>/design.md`
- `openspec/changes/<id>/tasks.md`
- At least one `openspec/changes/<id>/specs/**/spec.md`

**At least one file inside that very change directory must be modified in this PR.** This avoids accepting an arbitrary, unchanged historical spec as a blanket justification. A spec-only PR is allowed; later implementation PRs should update that same change's tasks as they proceed. Do not archive an unfinished change before implementation.

For purely documentation or small mechanical maintenance changes, declare instead:

```text
OpenSpec-Exemption: docs-only
```
or
```text
OpenSpec-Exemption: maintenance
```

`docs-only` allows only `.md` and `.txt` files; both exemptions reject modifications classified as functional or governance. One-time exception: `OpenSpec-Exemption: bootstrap` is accepted **only for PR #2** and only when no functional code is changed, to introduce the governance gate itself. It cannot be reused in subsequent PRs. The owner must review whether the stated exemption is truthful. An unsupported or missing declaration fails.

## Detection details

The script compares the pull request head to the merge base with `git diff --name-only --diff-filter=ACMRT <base>...<head>`. Changes to `addon/**/*.lua`, `addon/Data/**`, `tests/**`, and project scripts (other than the validator itself) are considered functional; modifying policy files (including `AGENTS.md`, the validator and workflow files) is treated as governance and demands a traceable OpenSpec change. Other changes must still declare an exemption or a change ID.

If the PR contains a change ID, the script checks the files on disk, not merely a name in the description. The official OpenSpec CLI then validates the delta and canonical specs. Passing does not validate the mapping between each altered Lua function and individual SHALL scenarios.

## Execution / reproduction

On a local branch with fetched `origin/main`, save a GitHub `pull_request` event JSON containing `pull_request.body`, then run:

```sh
python3 scripts/validate_sdd.py --base origin/main --head HEAD --event /path/to/pr-event.json
```

The workflow uses `fetch-depth: 0`, fetches the base branch, and uses `github.event_path`. It installs an explicitly pinned OpenSpec major release from the official npm package; update its version separately after checking upstream compatibility. CLI validation is a separate step from policy validation.

## Failure examples

| Example | Outcome |
| --- | --- |
| Lua modified; no `OpenSpec-Change` | Fail |
| Lua modified; points to existing unrelated, unchanged spec | Fail |
| Lua modified; change has no delta `spec.md` | Fail |
| Documentation only; `OpenSpec-Exemption: docs-only` | Pass policy |
| Lua modified; `OpenSpec-Exemption: maintenance` | Fail |
| Governance workflow modified; maintenance exemption | Fail |
| Valid change + delta change in diff | Pass policy; CLI and review still required |

## Security model and limitations

- Pull-request jobs use `permissions: contents: read` and never use `pull_request_target` with untrusted code.
- A PR can edit its own workflow and policy files: **GitHub branch rulesets / required checks / restricted merge permissions are the ultimate enforcement**. CODEOWNERS by itself does not block merges until owner reviews are required by branch rules.
- The gate does not check when owner approval happened, whether `/opsx:propose` was actually used, or semantic alignment. Require explicit owner review of the proposed change **before** implementation, review tests against SHALL scenarios, and perform real Forever client verification.
- The initial bootstrap PR #2 is governance work and may use the uniquely scoped `OpenSpec-Exemption: bootstrap` to introduce this gate. All later governance PRs require a real OpenSpec change.
- No CI check alone can guarantee only @hectoresen merges; configure branch permissions/ruleset later.

## How to extend

Keep file classification explicit and covered by negative tests. If folders or governance policies change, update this document and the script together, through an owner-reviewed OpenSpec change. Prefer tighter machine-verifiable scope metadata in future versions rather than claiming semantic correctness from file paths.
