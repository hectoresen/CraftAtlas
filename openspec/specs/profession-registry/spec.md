# Profession registry

## Requirements

### Requirement: Registry covers every verified consuming profession in the reference client
CraftAtlas SHALL use a versioned profession registry with stable language-neutral keys for every verified item-consuming profession (including eligible secondary and Forever-custom professions) in the approved client scope. It SHALL NOT exclude a supported profession merely because it is outside a fixed Classic eight-key list.

#### Scenario: A new Forever profession uses an item
- **WHEN** a custom profession is verified to consume a material and a reviewed registry entry exists
- **THEN** the material's tooltip can list that profession with a localized display name

#### Scenario: A registry entry is absent
- **WHEN** validated source data references an unknown profession key
- **THEN** catalog generation fails with an actionable error instead of silently omitting that profession

### Requirement: Display consumption rather than gathering or item creation
Only item-consuming profession relationships SHALL be listed as "Used by professions"; gathering-only or production-only associations SHALL NOT count as consumption without evidence of a consuming action.

#### Scenario: Herb gathered by Herbalism, consumed by Alchemy
- **WHEN** the record shows Herbalism gathers an herb and Alchemy consumes it
- **THEN** the tooltip lists Alchemy, but not Herbalism solely because it gathers the herb

#### Scenario: Multiple verified consumers
- **WHEN** a material is consumed by three distinct registered professions
- **THEN** each consuming profession appears exactly once in a stable order

### Requirement: All profession labels are localized
Every published profession key SHALL have reviewed enUS and esES labels or an explicit English fallback, with no raw key exposed to the player.

#### Scenario: Locale override
- **WHEN** the player changes CraftAtlas from enUS to esES
- **THEN** all displayed profession labels resolve in Spanish where reviewed, independent of itemID matching
