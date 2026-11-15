# Tooltip material navigation

## ADDED Requirements

### Requirement: Safe direct opening of known material details
CraftAtlas SHALL support a deliberate player-triggered action to open the explorer on the currently catalogued tooltip material **only when a safe compatible interaction is demonstrated in the actual Forever client**. This SHALL NOT modify protected frames, hijack standard item actions, or change existing tooltip annotation behavior. Unsupported interaction SHALL remain explicitly gated rather than simulated or marked verified.

#### Scenario: Supported direct interaction
- **WHEN** the player invokes the approved direct-entry action on a supported tooltip containing a known catalog itemID
- **THEN** CraftAtlas opens the existing explorer on that material
- **AND** offers return navigation preserving the prior text query, profession filter and selection

#### Scenario: Unknown item tooltip
- **WHEN** the tooltip represents an unknown itemID
- **THEN** the addon does not fabricate a material detail or extra action

#### Scenario: Interaction unsupported or protected
- **WHEN** the Forever client does not expose a safe verified direct-entry interaction
- **THEN** the addon leaves the ordinary tooltip and item actions untouched
- **AND** the feature is reported as not implemented pending owner decision
- **AND** the normal profession-use tooltip annotations continue working

#### Scenario: Repeated tooltip refresh
- **WHEN** the tooltip refreshes repeatedly or is reused for other items
- **THEN** there are no duplicate controls, stale item links or Lua errors
