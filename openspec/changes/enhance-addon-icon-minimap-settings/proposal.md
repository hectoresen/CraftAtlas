# Proposal: Improve CraftAtlas identity, minimap access and settings shell

## Why

CraftAtlas currently uses the default question-mark addon icon, has no minimap entry point, and exposes a small settings window whose only active content is the language selector. These details make the addon harder to recognize and less consistent with the native World of Warcraft addon experience.

## What changes

- Replace the default addon-list question-mark icon with a native WoW/Forever icon that clearly represents professions or crafting.
- Add a minimap button that is visible by default and opens the same CraftAtlas settings window as `/craftatlas` when clicked.
- Expand the settings window into a larger reusable shell with a centered `CraftAtlas` header title.
- Move the existing language selector into the right side of the header.
- Add a non-functional search affordance on the left side of the header with the placeholder `Buscar objetos, profesiones..` and a prohibited/unavailable cursor state.
- Leave the General section empty except for a centered “Coming soon” style message.
- Reserve a future settings toggle for hiding/showing the minimap button; this change does not implement that toggle.

## Scope

### Included

- Native client icon selection and addon metadata/resource wiring.
- Always-visible minimap button with a left-click action equivalent to `/craftatlas`.
- Larger settings shell, header layout, language-selector relocation and placeholder search affordance.
- English and Spanish user-facing strings, with the repository's existing fallback behavior.
- Offline tests/mocks and documentation of the required Forever-client verification.

### Excluded

- Functional object/profession search or filtering.
- Minimap visibility/position settings or persistence.
- New settings categories beyond the existing General category.
- Recipe data, broader tooltip coverage or any other roadmap feature.
- Runtime network services or a mandatory third-party addon dependency.

## Target milestone

This is an incremental UI/accessibility change to the current v0.0.1 implementation candidate. It must not be presented as a release or as Forever-compatible until the real-client gates pass.

## Risks and rollback

- Native texture names, addon-list metadata fields, cursor APIs and frame templates may differ in Forever. The implementation must verify them in the actual client and provide a safe fallback where the API permits it.
- A minimap button implemented with a library could add an unwanted dependency. Prefer native client facilities; introduce a small compatible library only if the client cannot support the required behavior without it, and document the dependency and license before approval.
- Reusing a client-provided texture avoids shipping a web-style replacement asset, but the exact texture path must be confirmed against the supported client.

Rollback is removal of the new metadata/resource wiring, minimap registration and settings-shell changes. The existing `/craftatlas` entry point and language behavior must remain recoverable.

## Approval gate

This directory is a proposal only. No production code or shipped asset may be changed until @hectoresen explicitly approves the proposal and the implementation is performed in a separate implementation PR within the approved scope.
