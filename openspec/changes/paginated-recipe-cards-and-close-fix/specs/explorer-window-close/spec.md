# Explorer window close

## ADDED Requirements

### Requirement: Native close control works
The native top-right CraftAtlas X SHALL hide the explorer reliably regardless of whether the client template supplies a CloseButton. Close behavior SHALL not depend on Blizzard's managed-panel registration.

#### Scenario: User clicks top-right X
- **WHEN** CraftAtlas is visible and the user activates the top-right native close button
- **THEN** the window closes without an addon Lua error
- **AND** language/profession dropdowns, edit focus and any owned recipe tooltip are cleared

#### Scenario: Reopen after closing
- **WHEN** the player opens CraftAtlas again using `/craftatlas` or the minimap button
- **THEN** one usable window is displayed with the close button working
- **AND** the saved language and current browsing state remain valid

#### Scenario: Native template absent
- **WHEN** the client does not supply the basic frame template or its close button
- **THEN** CraftAtlas uses a safe built-in close button fallback with the same explicit handler
