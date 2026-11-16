# Design

## Approval source of truth
Use GitHub REST `pulls/{number}/reviews?per_page=100&page=N` to examine reviews submitted before the specification's merge. For contributor-authored specification PRs, require a valid `APPROVED` by `hectoresen`, without depending on `merged_by`. Handle a later dismissed or changes-requested review as invalidation, and fail closed on missing API evidence. The review's submitted timestamp must predate merge. GitHub branch protections remain authoritative for merge-time approval and stale-review behavior; the validator does not replace them.

## Owner-authored PR exception
GitHub forbids self-approval. Preserve the existing owner PR-only administrator bypass for owner-authored changes; never exempt required CI. Limit this exception to verified PR author identity obtained from the GitHub API, not text supplied by the contributor.

## Ruleset
The administrator must enable 'Require review from Code Owners' on the active main review ruleset. Root CODEOWNERS already maps * to @hectoresen. Keep one review, dismiss stale approvals, resolve conversations, and no status-check bypass. Verify effectiveness via GitHub UI/API and manual two-account acceptance.

## Legacy
Do not change immutable historical spec files or hardcode a blanket exception for #44. If prior review evidence is absent, document the recovery route without duplicating an existing spec ID.
