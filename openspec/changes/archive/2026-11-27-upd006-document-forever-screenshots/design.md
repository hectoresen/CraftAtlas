## Context

The six PNGs were supplied by the contributor and attached to implementation PR #80. They cover Materials and Craftables details, crafting tracking, AddOn options, the minimap button tooltip, and the material tooltip. The repository docs-only exemption accepts Markdown and text, so the PNG paths require reviewed scope. PR #80's approved scope covers its own implementation and textual documentation.

## Goals / Non-Goals

**Goals:** Check in the original captures with explicit paths and an accessible gallery that works in a repository checkout.

**Non-goals:** Change the addon, package contents, release history, or Forever acceptance status.

## Decisions

1. Keep the six PNGs byte-for-byte under `docs/v0.5.0/`. The scope lists each filename, including `icon_minimap_tooltip.png` with underscores.
2. Use standard Markdown image links to the adjacent files. Add descriptive alt text and short captions in English. Link the gallery from the root README.
3. Describe the captures as visual examples and link to PR #80 for provenance. Keep the published release information and tests separate from the gallery.
4. Check the local file signatures, PNG chunk checksums, and hashes against the contributor's originals. Verify each relative path and the gallery link. Run the packaging tests to confirm that the documentation folder is outside the addon package.

## Risks / Trade-offs

- Including six PNGs increases the repository checkout size. The files are limited to this gallery.
- The screenshots illustrate captured states. They do not establish the exact client build or full acceptance matrix.
