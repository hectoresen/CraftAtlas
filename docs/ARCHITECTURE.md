# Architecture

CraftAtlas uses a modest modular architecture; keep Lua runtime lean. Target layout:

- `Core/`: bootstrap, events, wiring and lifecycle.
- `Domain/`: deterministic lookup rules and profession relationships, no WoW globals.
- `Data/`: offline versioned material database (future recipes).
- `Infrastructure/`: API adapters and SavedVariables persistence.
- `Features/Tooltip/`: tooltip integration and presentation; no business logic.
- `Features/Settings/`: user-facing language settings.
- `Localization/`: enUS and esES messages and profession labels.

Flow: tooltip event → WoW item adapter → numeric itemID → domain lookup → local data → localized presentation. The domain layer MUST NOT call WoW APIs. Keep all side effects at the edges and avoid per-frame polling.

The folders are intentionally empty until a v0.1.0 OpenSpec proposal is approved. Select a tooltip hook only after verifying support in Forever, and explicitly handle repeated tooltip refreshes without duplicate lines. The UI should not pretend an unknown material has a known profession. No required external addon and no game-time HTTP.
