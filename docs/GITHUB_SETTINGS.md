# GitHub repository protection and contributor verification

This page documents GitHub administrator settings; merging this file cannot apply or edit a ruleset.

## Verified protections (updated 2026-11-18)

Repository `hectoresen/CraftAtlas` is public and user-owned. Two **active rulesets** target `refs/heads/main`:

| Ruleset (ID) | Enforcement | Bypass |
| --- | --- | --- |
| `main — mandatory CI` (`27371162`) | Prevent deletion and force pushes; require `repository-validation` and `traceability`; require latest branch | **None** |
| `main — contributor reviews` (`27376786`) | PR required, 1 independent approval, dismiss stale reviews, resolve conversations; **code-owner review is enabled** | Repository admin role, **For pull requests only** |

Confirmed via GitHub API after owner configured them. GitHub does not allow PR authors, including the owner, to approve their own PR. The owner uses an admin PR-only *review bypass*, not self-approval. Rulesets for CI and review must stay separate.

`CODEOWNERS` at repository root requests `@hectoresen` reviews. GitHub's active contributor-review ruleset now has `require_code_owner_review: true` (verified via API on 2026-11-18). One approval is required for contributor PRs; the repository-admin bypass applies to review requirements on pull requests only, not to mandatory CI.

## Mandatory Lua checks — already configured

Verified on 2026-11-18: `main — mandatory CI` requires `repository-validation`, `traceability`, `lua-compatibility` and `lua-regressions`; strict up-to-date checks are enabled, with **no bypass actors**. `main — contributor reviews` requires a PR, one approval, code-owner approval, dismissal of stale approvals and resolved conversations. Its admin bypass is **For pull requests only**. Do not weaken either ruleset during maintenance.

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

## Historical spec #58 configuration status

The previously outstanding `Require review from Code Owners` administrator setting is **enabled and API-verified on 2026-11-18**. The two-account merge-eligibility matrix above remains **NOT RUN**; configuration evidence is not a live permission test.
