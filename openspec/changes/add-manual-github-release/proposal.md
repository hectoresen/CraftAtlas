# Add manual GitHub Release packaging

## Why
The repository source archive contains development-only files and cannot be extracted directly into World of Warcraft's AddOns directory. The maintainer needs a one-click, repeatable way to ship a clean installable zip from main.

## Scope
- Add a manually triggered GitHub Actions workflow, callable on main only, that runs repository and material-data checks before publishing.
- Select a SemVer increment (patch/minor/major), compute a unique tag from existing release tags, and create a GitHub Release with one ready-to-install ZIP asset.
- Package only runtime files from addon/CraftAtlas, under a single top-level CraftAtlas directory.
- Rewrite the packaged .toc Version metadata to match the selected release version; do not commit any generated version change to main.
- Document usage, installation, versioning, prerequisites and failure behavior; add deterministic packaging tests.
- Initial 0.x releases are prereleases, subject to the maintainer's explicit manual invocation.

## Out of scope
- No addon UI, gameplay behavior, data-set changes, automatic release on push, runtime dependency, external distribution or direct changes to main.
- No relaxation of release-quality gates or claims of verified current Forever data coverage.

## Risks and rollback
- GitHub's repository Actions policy and GITHUB_TOKEN permissions must permit publishing releases; fail safely otherwise.
- Concurrent manual runs could allocate the same tag; use a single concurrency group, reject existing tags/releases and do not overwrite.
- A release remains an owner-controlled operation: the workflow makes publication possible only when manually invoked. If the workflow fails or produces an invalid archive, disable the workflow, delete the erroneous release/tag manually if necessary and revert the implementation PR.
- The initial published version may still be development-level and must not imply stable/fully verified Forever compatibility.
