# GitHub maintainer setup checklist

Some settings cannot be represented by tracked files or may be restricted by the plan. Maintainer should configure in repository Settings:

1. About: describe "Open-source WoW Forever profession-material knowledge addon"; website optional; topics: `world-of-warcraft`, `wow-addon`, `lua`, `openspec`, `crafting`.
2. Features: enable Issues, Discussions if community wants them, preserve public visibility.
3. Settings → Rules → Rulesets: protect `main`, require PR, require one human review where supported, dismiss stale approvals, require passing `repository-validation` CI, disable force push and deletion. Rules may require higher plan for a public personal repo: document any unavailability.
4. Prefer squash merge; delete branches after merging. Enable Dependabot/security advisories as relevant.
5. Set GitHub Releases from SemVer tags `vX.Y.Z`; don't call v0.0.0 a playable release. Confirm artifacts include only the installable addon directory.
6. Prefer private vulnerability reporting. CODEOWNERS already points to @hectoresen.
7. Add labels `bug`, `enhancement`, `documentation`, `good first issue`, `help wanted`, `data`, `compatibility`.
8. Ensure CI runs with read-only `GITHUB_TOKEN`; do not expose deploy credentials or secrets to untrusted PRs.

**Verification:** check settings in GitHub UI after saving. A committed documentation checklist does not itself enable branch protection or other repository settings.
