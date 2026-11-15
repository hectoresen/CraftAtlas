# Design: manual installable GitHub Releases

## Entry point and authority
A workflow_dispatch-only action on main accepts one required choice: patch, minor or major. Checkout main explicitly, rather than trusting an arbitrary dispatch ref, and gate execution to refs/heads/main. Use permissions: contents: write only for the publishing job; no personal access token or additional secrets. Prevent overlapping releases with concurrency.

## Version policy
Use git tags matching vMAJOR.MINOR.PATCH as the release baseline. When no such tags exist, use v0.1.0 as initial release (source .toc currently says 0.1.0-dev). From then on, increment the highest SemVer tag according to the selected type. Reject a tag that already exists. Mark all pre-1.0 releases as GitHub prereleases. Confirm any mismatch between current source .toc metadata and intended policy in tests and documentation. Only the generated ZIP's .toc is rewritten.

## Packaging
Read addon/CraftAtlas/CraftAtlas.toc. Derive packaged files from runtime manifest entries, including referenced directories/files (and relevant runtime license attribution); do not blindly zip the repository or development data such as materials.source.json, coverage-report.json and other non-runtime files. Preserve a single CraftAtlas/ prefix in the archive, normalize separators and reject unsafe paths, missing referenced Lua modules or empty manifests. Ensure the archive can be extracted directly under Interface/AddOns. Preserve third-party attribution required for packaged data in Data/LICENSE-LibProfessionDB.txt.

## Tests and publish
Run scripts/validate_repo.py, the material-data unit tests and scripts/build_materials.py --check. Add deterministic unit tests for exact ZIP paths, .toc version replacement, exclusions, missing dependencies, SemVer selection and duplicate tag prevention. Upload ZIP to a GitHub Release using gh release create with generated notes; ensure the tag points at checked-out main commit and cannot overwrite an existing release. Store release metadata in the GitHub Release and link in README / installation documentation.

## Non-functional requirements
Linux runner, Python 3.11 standard library only for packaging, GitHub hosted CLI for publishing. No mutations to addon source on main and no extra in-game runtime dependencies.
