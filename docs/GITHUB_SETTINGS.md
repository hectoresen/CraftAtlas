# GitHub governance (maintainer-only)

## Currently tracked in Git

- `.github/CODEOWNERS` points to `@hectoresen`.
- PR/issue templates and read-only CI workflow exist.
- `AGENTS.md`, `CONTRIBUTING.md` and `docs/AGENT_WORKFLOW.md` prohibit agents/contributors from merging without the owner's explicit decision.

**These are policy instructions, not server-side access controls.** GitHub branch rulesets, permissions, squash merge settings and labels require repository API/CLI or UI changes. They are **not yet applied**. The owner has requested deferring ruleset creation to a later GitHub CLI operation.

## Deferred GitHub CLI / ruleset task (DO NOT silently apply now)

When @hectoresen explicitly requests it: use authenticated `gh` with sufficient administrator permissions and GitHub repository rulesets API. Inspect existing rulesets first; do not overwrite someone else's policy. Aim for:

- Restrict `main`: all changes via PR, no direct pushes or force pushes/deletions.
- Require human review (at least one approval) and successful CI `repository-validation` after the first successful workflow run.
- Only @hectoresen may perform merges, even after other users' approvals. **Important:** branch review requirements do not automatically restrict *who* clicks merge. Confirm actual collaborator roles, fork model, repository owner rights and GitHub plan/ruleset capabilities before asserting this can be enforced.
- Avoid global bypass actors that allow unintended direct pushes. Test restrictions with a non-owner role.
- Prefer squash merge and cleanup of merged branches if available.
- Verify newly saved rulesets are **active**, correctly scoped and actually enforced; record evidence.

Other optional administration: repository description/topics, Issues, Discussions, code/security advisories, vulnerability reporting, standard labels and release settings. Never claim these are configured merely because this document describes them.

## Security

Avoid privileged workflows on untrusted PR code, never leak tokens or repository secrets, and prefer minimal `GITHUB_TOKEN` permissions. No releases without explicit owner approval.
