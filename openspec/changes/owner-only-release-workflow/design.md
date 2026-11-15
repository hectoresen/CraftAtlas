# Design — owner-only release workflow

## Trigger and authorization
Use workflow_dispatch with required choice input [patch, minor, major] and no other triggers. Gate at job level with github.ref == refs/heads/main, github.actor == 'hectoresen', github.triggering_actor == 'hectoresen' and github.repository == 'hectoresen/CraftAtlas'. If unauthorized, job is skipped before checkout. Separate a validation job (read permissions) from a publishing job (contents: write), with the same identity gate and successful validation dependency. Recheck identity in publish. Set concurrency group to prevent overlapping releases (cancel-in-progress false). GitHub users with repo write access may still see/click Run workflow, but cannot publish. For tamper resistance protect main and workflows via GitHub ruleset/CODEOWNERS outside this change.

## Input, version and tag
Checkout main by explicit ref and use fetch-depth: 0 to retrieve tags. Compute highest valid SemVer vMAJOR.MINOR.PATCH, ignoring other tags. For the first ever release with no SemVer tags, select v0.1.0 independent of increment choice, consistent with current 0.1.0-dev .toc. Otherwise patch/minor/major increment the highest tag. Reject duplicates before publishing and prevent overwriting existing releases; use gh release create --verify-tag or equivalent pre-created new tag referencing the exact validated main SHA. Keep tag creation as late as possible and fail safely on concurrent conflicts. Packaged .toc Version matches release version; never modify tracked source.

## Packaging
Add scripts/package_release.py using Python stdlib. Parse addon/CraftAtlas/CraftAtlas.toc: include the .toc itself and listed runtime files in exact manifest order; reject path traversal, duplicate entries, missing files, unsafe extensions or empty manifest. Include Data/LICENSE-LibProfessionDB.txt because shipped data requires attribution; exclude materials.source.json and coverage-report.json as data used only at build time. Archive paths start with CraftAtlas/ and never contain an extra nesting level. ZIP metadata stable/deterministic where feasible. Extract into Interface/AddOns/ directly.

## Checks and docs
Run scripts/validate_repo.py, python3 -m unittest discover -s tests -p test_material_data.py -v, scripts/build_materials.py --check and dedicated packaging tests. Verify ZIP content, Lua manifest paths and packaged .toc version before upload. Document that 0.x releases are prereleases, are not guaranteed to represent verified live-realm catalog coverage and are manually authorized only by @hectoresen. Mention the owner-controlled security boundary and branch protection recommendation.

## GitHub authorization
No new personal tokens; use GITHUB_TOKEN in publish job with contents: write only. Ensure tags/releases cannot be replaced. Avoid invoking untrusted local scripts with elevated token in PR context; workflow executes only from the trusted main branch.
