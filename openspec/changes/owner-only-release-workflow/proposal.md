# Implement maintainer-only installable GitHub Releases

## Why
The previously approved manual release design (add-manual-github-release, PR #15) cannot be implemented because its approved path manifest excludes the Actions workflow. The owner has now approved tightly scoped workflow governance (PRs #16–17) and explicitly requires that only @hectoresen be able to publish.

## Scope
- Implement a workflow_dispatch-only release action at .github/workflows/publish-release.yml.
- Accept patch/minor/major increments and release from the main branch commit only.
- Enforce the maintainer identity @hectoresen for both github.actor and github.triggering_actor before any write operations; fail closed for everyone else.
- Run repository, material-data and package tests before publication.
- Package the manifest-referenced runtime addon only into CraftAtlas-vX.Y.Z.zip, rooted at CraftAtlas/; preserve needed licensing attributions.
- Generate versioned packaged .toc (no tracked source version mutations), a new GitHub tag and GitHub Release with a ZIP asset.
- Reject duplicate releases, serialize publishing, and mark 0.x versions as prerelease.
- Document usage, limitations, and permissions. Include deterministic packaging/versioning tests.

## Out of scope
No gameplay/Lua changes, in-game compatibility claims, automatic releases on pushes, direct main writes, or branch protection/ruleset modifications. The workflow cannot remove the GitHub Actions Run workflow control for writers; authorization must prevent publishing, not pretend to hide that control.

## Security and release limitations
Identity checks in YAML are only effective if the code on main is trusted. Strong enforcement requires protected main and limiting workflow edits/merges to the owner (separate repository settings). GitHub's GITHUB_TOKEN is job-scoped with contents: write for the publisher. Never allow input-supplied git ref, shell injection or file paths. No release is created by merging the workflow PR; only explicit owner invocation can publish.

## Rollback
Disable the workflow or revert its implementation PR. If a faulty release was created, owner deletes the release and tag after review.
