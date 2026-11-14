# AGENTS.md — Required onboarding for every coding agent

**Read this before changing any file.** CraftAtlas is an MIT-licensed World of Warcraft: Forever addon in Lua. The repository is currently a **nonfunctional v0.0.0 scaffold**. The roadmap is NOT implemented behavior.

## Onboarding sequence

1. Read `README.md`, this document, `CONTRIBUTING.md`.
2. Read `openspec/config.yaml`, `openspec/README.md`.
3. Inspect `openspec/specs/` for accepted requirements and `openspec/changes/` for pending changes.
4. Read applicable docs: `docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, `docs/DEVELOPMENT.md`, `docs/TESTING.md`, `docs/ROADMAP.md`.
5. Inspect git status and existing branches/PRs. Never overwrite other changes.
6. Identify the intended release scope and check client/API assumptions before implementation.

## Truth hierarchy

Approved canonical specs and approved active changes > accepted architecture decisions > existing source (for what is currently implemented) > future roadmap. Flag any inconsistency explicitly.

## Spec-driven development contract

- A new feature, changed behavior, compatibility strategy, data format or significant refactor requires an OpenSpec change named in kebab-case under `openspec/changes/<name>/`. Include proposal, delta specs, design when appropriate, and checkable tasks.
- Present the proposed scope to the maintainer for approval **before implementation**. OpenCode: `/opsx:propose`, then, after approval, `/opsx:apply`; verify, sync specs, archive after acceptance. Equivalent official OpenSpec commands/skills are allowed.
- Small typos, documentation fixes and trivial mechanical upkeep may skip a formal change; state why in the PR.
- Use branches `feat/`, `fix/`, `docs/`, `chore/`, or `refactor/`. No direct pushes to `main`, no autonomous merges/releases.

## Invariants

- Runtime code is Lua. No required online service, game-time HTTP or telemetry.
- Item lookup uses numeric itemID, **never translated names or tooltip phrases**.
- Profession relationships are independent of the current character and may be many-to-many.
- enUS and esES supported; unknown locale falls back to English. Manual override persists via SavedVariables.
- Use versioned local data only if license/provenance is documented. Never invent recipes or professions.
- Unknown IDs should not add guessed tooltip lines. Avoid duplicate lines and invasive hooks; protect game performance.
- Keep game API adapters separate from domain lookup, data, settings, UI and localization.
- **Never assume** Retail, Vanilla or legacy WoW APIs match Forever. Verify interface version and tooltip APIs against the current client.

## Definition of done

Approved change/spec; implemented scenarios, tests and docs; checks passing; data provenance reviewed; localization updated in both locales; real-client manual smoke testing for client integration (or explicitly flagged unverified); changelog/roadmap updated where applicable; PR with human approval.

## Handoff

Always report: goal, affected files, OpenSpec change, tests actually run, Forever-client checks (performed/unperformed), risks, and PR. Never claim success without evidence.
