# GitHub repository protection and contributor verification

This page documents GitHub administrator settings; merging this file cannot apply or edit a ruleset.

## Verified protections (2026-11-16)

Repository `hectoresen/CraftAtlas` is public and user-owned. Two **active rulesets** target `refs/heads/main`:

| Ruleset (ID) | Enforcement | Bypass |
| --- | --- | --- |
| `main — mandatory CI` (`27371162`) | Prevent deletion and force pushes; require `repository-validation` and `traceability`; require latest branch | **None** |
| `main — contributor reviews` (`27376786`) | PR required, 1 independent approval, dismiss stale reviews, resolve conversations; **code-owner review must be enabled separately** | Repository admin role, **For pull requests only** |

Confirmed via GitHub API after owner configured them. GitHub does not allow PR authors, including the owner, to approve their own PR. The owner uses an admin PR-only *review bypass*, not self-approval. Rulesets for CI and review must stay separate.

`CODEOWNERS` at repository root requests `@hectoresen` reviews but **does not** independently enforce approvals. `Require review from Code Owners` was not enabled at the last verified settings audit. **Enable it** on the active review ruleset to make @hectoresen's approval mandatory for contributor-authored PRs. Owner-authored PRs rely on the already configured PR-only admin bypass; CI never has a bypass.

## Add mandatory Lua checks after the implementation merges

Once this implementation PR is merged and its new jobs have completed successfully on a subsequent PR, open https://github.com/hectoresen/CraftAtlas/settings/rules and edit **main — mandatory CI**:

1. Confirm the exact branch match `main`, enforcement `Active`, and **empty bypass list**.
2. Under **Require status checks to pass**, retain `repository-validation` and `traceability`, then add exactly **`lua-compatibility`** and **`lua-regressions`**.
3. Leave **Require branches to be up to date before merging** enabled. Do not select `Do not require status checks on creation`.
4. Keep force-push and deletion restrictions. Save and verify the effective ruleset via GitHub UI/API.
5. Do **not** add Lua checks before they have appeared as successful job names in GitHub; a missing required check makes every PR unmergeable.

On **main — contributor reviews**, **enable Require review from Code Owners**, and retain **1 approval**, stale-review dismissal, conversation resolution and `Repository admins → For pull requests only`. No check requirement or unrestricted/Always allow bypass belongs there.

## Permissions and optional auto-merge

Under https://github.com/hectoresen/CraftAtlas/settings/access, avoid granting Write/Maintain/Admin privileges to untrusted external contributors who only need to submit fork PRs. A reviewer who also has merge permission may merge an approved PR; a ruleset requiring approvals does **not** exclusively reserve the Merge button for the owner. The admin bypass is role-based; do not grant Admin to additional people if it must remain owner-only.

Optionally enable **Allow auto-merge** under repository General → Pull Requests. GitHub auto-merge is not automatically owner-exclusive: people with merge permissions can enable it. It only merges an explicitly armed PR after requirements pass. No workflow or bot should auto-merge external contributors' PRs.

The manual release workflow stays limited to actor and triggering actor `hectoresen`, to the validated exact `main` commit and to the installable ZIP.

## Manual acceptance matrix (NOT RUN)

The ruleset *configuration* was verified via API, but actual two-account merge behavior has not been tested:

1. Contributor PR with green CI and **no** independent approval: blocked.
2. Contributor PR approved by another authorized person but not @hectoresen, with green CI: **blocked by code-owner review requirement** after the rule is enabled.
3. Further commits after approval: approval dismissed and merge blocked pending fresh review.
4. Owner-authored PR, green required checks, no separate approval: owner may merge via PR-only admin bypass.
5. Owner-authored PR with failing required check: blocked.
6. Direct push, force-push and deletion of `main`: blocked.

Record observed UI results before claiming these end-to-end cases passed.

## Security and recovery

Untrusted fork PR code must never run with privileged `pull_request_target` checkout, PATs or access to release tokens. Keep Actions `contents: read` and explicit `pull-requests: read` where needed. If required checks become stuck, confirm actual emitted job names and fix the root cause; do not disable mandatory checks or grant a CI bypass to make the PR green.

Only the owner modifies GitHub rulesets, collaborator permissions and release settings. Save previous Settings before administrative changes.

## Required checks and change-aware fast paths

On a pure OpenSpec proposal, the CI `repository-validation` job completes as a minimal required status while **SDD Compliance / traceability** validates the spec. Both Lua jobs are **skipped**, rather than run. On a Markdown/text-only PR, repository validation only runs a lightweight Markdown/foundation check and SDD verifies path policy; no full OpenSpec CLI install or Lua suite. On code/mixed PRs, all quality gates run. A failed classification fails `repository-validation`, so it cannot be used to evade required checks. GitHub treats an intentionally skipped job's conclusion as acceptable for required status checks; the technical ruleset still enforces the always-present `repository-validation` and `traceability` jobs. Do not replace those with workflow-level `paths-ignore`, because absent required checks can leave a PR stuck awaiting a status.

## Required administrator action for approved spec #58 (NOT YET VERIFIED)

In [repository rulesets](https://github.com/hectoresen/CraftAtlas/settings/rules), edit **main — contributor reviews** (ID `27376786`) and enable **Require review from Code Owners**. Keep active enforcement targeting `refs/heads/main`, one approval, stale-review dismissal, resolved conversations, and administrator bypass **For pull requests only**. Root `CODEOWNERS` already has `* @hectoresen`. Keep **main — mandatory CI** (ID `27371162`) independent and with zero bypass. Do not grant other users Admin access. After saving, verify via GitHub UI/API and two-account acceptance: a contributor PR approved by anyone else remains blocked; an owner-approved contributor PR with green checks may be merged by an authorized contributor; an owner-authored PR still uses review-only admin bypass. **The ruleset setting is not changed by this code PR and no verification is claimed here.**
