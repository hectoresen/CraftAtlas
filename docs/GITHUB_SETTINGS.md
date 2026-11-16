# GitHub repository protection and contributor verification

This page documents GitHub administrator settings; merging this file cannot apply or edit a ruleset.

## Verified protections (2026-11-16)

Repository `hectoresen/CraftAtlas` is public and user-owned. Two **active rulesets** target `refs/heads/main`:

| Ruleset (ID) | Enforcement | Bypass |
| --- | --- | --- |
| `main — mandatory CI` (`27371162`) | Prevent deletion and force pushes; require `repository-validation` and `traceability`; require latest branch | **None** |
| `main — contributor reviews` (`27376786`) | PR required, 1 independent approval, dismiss stale reviews, resolve conversations | Repository admin role, **For pull requests only** |

Confirmed via GitHub API after owner configured them. GitHub does not allow PR authors, including the owner, to approve their own PR. The owner uses an admin PR-only *review bypass*, not self-approval. Rulesets for CI and review must stay separate.

`CODEOWNERS` at repository root requests `@hectoresen` reviews but **does not** independently enforce approvals. `Require review from Code Owners` is not enabled, intentionally: it would conflict with owner-authored PRs without the configured bypass.

## Add mandatory Lua checks after the implementation merges

Once this implementation PR is merged and its new jobs have completed successfully on a subsequent PR, open https://github.com/hectoresen/CraftAtlas/settings/rules and edit **main — mandatory CI**:

1. Confirm the exact branch match `main`, enforcement `Active`, and **empty bypass list**.
2. Under **Require status checks to pass**, retain `repository-validation` and `traceability`, then add exactly **`lua-compatibility`** and **`lua-regressions`**.
3. Leave **Require branches to be up to date before merging** enabled. Do not select `Do not require status checks on creation`.
4. Keep force-push and deletion restrictions. Save and verify the effective ruleset via GitHub UI/API.
5. Do **not** add Lua checks before they have appeared as successful job names in GitHub; a missing required check makes every PR unmergeable.

On **main — contributor reviews**, retain **1 approval**, stale-review dismissal, conversation resolution and `Repository admins → For pull requests only`. No check requirement or unrestricted/Always allow bypass belongs there.

## Permissions and optional auto-merge

Under https://github.com/hectoresen/CraftAtlas/settings/access, avoid granting Write/Maintain/Admin privileges to untrusted external contributors who only need to submit fork PRs. A reviewer who also has merge permission may merge an approved PR; a ruleset requiring approvals does **not** exclusively reserve the Merge button for the owner. The admin bypass is role-based; do not grant Admin to additional people if it must remain owner-only.

Optionally enable **Allow auto-merge** under repository General → Pull Requests. GitHub auto-merge is not automatically owner-exclusive: people with merge permissions can enable it. It only merges an explicitly armed PR after requirements pass. No workflow or bot should auto-merge external contributors' PRs.

The manual release workflow stays limited to actor and triggering actor `hectoresen`, to the validated exact `main` commit and to the installable ZIP.

## Manual acceptance matrix (NOT RUN)

The ruleset *configuration* was verified via API, but actual two-account merge behavior has not been tested:

1. Contributor PR with green CI and **no** independent approval: blocked.
2. Contributor PR approved by another authorized person with green CI: mergeable by a user with merge rights.
3. Further commits after approval: approval dismissed and merge blocked pending fresh review.
4. Owner-authored PR, green required checks, no separate approval: owner may merge via PR-only admin bypass.
5. Owner-authored PR with failing required check: blocked.
6. Direct push, force-push and deletion of `main`: blocked.

Record observed UI results before claiming these end-to-end cases passed.

## Security and recovery

Untrusted fork PR code must never run with privileged `pull_request_target` checkout, PATs or access to release tokens. Keep Actions `contents: read` and explicit `pull-requests: read` where needed. If required checks become stuck, confirm actual emitted job names and fix the root cause; do not disable mandatory checks or grant a CI bypass to make the PR green.

Only the owner modifies GitHub rulesets, collaborator permissions and release settings. Save previous Settings before administrative changes.
