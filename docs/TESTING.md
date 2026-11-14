# Testing strategy

## Foundation
`python3 scripts/validate_repo.py` verifies required files, Markdown formatting and OpenSpec config; CI runs it for PRs/pushes to main. This does NOT validate playable functionality.

## Future automated tests
Use deterministic Lua tests for material lookup, multi-profession resolution, unknown IDs, localization fallback and SavedVariables preference behavior. Static analysis (Luacheck) and dataset/schema validation must be introduced with the first implementation. CI must fail on invalid data, tests or lint errors.

## Manual Forever-client matrix (required for game-facing changes)
- Exact client build + interface version recorded
- Addon detected/enabled, no Lua startup errors
- Inventory item and bank item tooltip behavior
- Known single-profession and multi-profession materials
- Unrecognized item adds no false information
- No duplicate lines on repeated hovers/reloads
- enUS/esES and unknown-locale fallback
- Manual language override survives reload/restart
- Performance acceptable under rapid tooltip changes
- Screenshots or reproducible evidence attached to PR

Mark each test *passed*, *failed* or *not run*. Never present an unrun game test as passing.
