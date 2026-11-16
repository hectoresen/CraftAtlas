# Design for the default expanded material tooltip

## Reference and current CraftAtlas behavior

The reference is [Profession Reagents 1.0.0 at `66555a5`](https://github.com/sebasgrios/profession-util/tree/66555a5c5c1d4ad3d3c2f8d5d0982beb2b23a4b8/addons/ProfessionReagents). The source points below were read from the local checkout of that revision.

| Reference file under `src/` | Observed default behavior |
| --- | --- |
| `Config/Settings.lua` | Enabled with icons and expanded layout by default |
| `UI/Tooltip.lua` | Blank spacer, gold heading via `NORMAL_FONT_COLOR` with RGB fallback of `(1, 0.82, 0)`, then one white line per profession through native `AddLine` |
| `Services/ProfessionService.lua` | Alphabetical localized labels with stable tie-breaking and inline `\|T<fileID>:14:14:0:0\|t` textures |
| `Locales/enUS.lua` and `Locales/esES.lua` | `Used in:` and `Utilizado en:` |
| `Database/Forever.lua` | Profession icon file IDs derived from `SkillLine.SpellIconFileID`, documented in the reference's `docs/DATA.md` |

CraftAtlas's `Features/Tooltip/Tooltip.lua` currently adds two lines. Its `USED_BY` locale key also labels the material detail section in the explorer. Add a tooltip-specific locale key, keeping the explorer's existing wording. The explorer also has its own icon presentation. Tooltip styling uses the icon IDs below to match the reference without changing explorer textures.

## Rendering and lifecycle

Keep item identity resolution and callback registration in the existing guarded `Infrastructure/TooltipAdapter.lua` integration. The tooltip presenter uses `FindProfessions` for the catalog-backed membership. Resolve existing localized labels and sort the small per-item list in the effective addon language, with a stable profession-key tie-breaker. Any optional native collation helper must be guarded, with a deterministic fallback for the supported locales. Preserve the registry and explorer ordering outside this presentation.

Append the separator, heading and profession rows with native tooltip fonts and spacing. Use the verified profession texture at 14 × 14 with a separating space before the label. If an icon is unavailable, emit the same white label as text. Retain the client layout, anchoring, ownership and native content. The presenter must remain safe when tooltip methods or optional client facilities are unavailable.

Update duplicate tracking to account for the actual number of lines appended, including the separator and heading. Preserve safe reuse when a tooltip is hidden or rebuilt. Any native clear handling used by the implementation should register at most once per supported tooltip frame. Keep the existing single item callback. The pass costs one lookup and formatting and sorting the item's small profession list, with no frame allocations, polling or catalog scan per hover.

## Native icon references

These client texture file IDs are recorded in the pinned reference's `Database/Forever.lua` for the professions recognized by CraftAtlas. Only the IDs are needed for the proposed presentation. Neither textures nor the reference's generated material index are bundled.

| CraftAtlas key | Native texture file ID |
| --- | ---: |
| `ALCHEMY` | 136240 |
| `BLACKSMITHING` | 136241 |
| `COOKING` | 133971 |
| `ENCHANTING` | 136244 |
| `ENGINEERING` | 136243 |
| `FIRST_AID` | 135966 |
| `FISHING` | 136245 |
| `LEATHERWORKING` | 136247 |
| `MINING` | 136248 |
| `TAILORING` | 136249 |

The reference repository's `LICENSE` is MIT, copyright 2026 sebasgrios. Implement the behavior with CraftAtlas code and native client artwork. Keep this reference and the existing catalog attribution in the implementation documentation.

## Verification

Compare the addons separately in the same Forever build, locale and UI scale using Copper Ore (`2770`) and Linen Cloth (`2589`), which have matching profession sets in the two local snapshots. Record the spacer, heading color and wording, white icon rows, alphabetical order and absence of duplicates. In esES, Linen Cloth shows Costura, Herrería, Ingeniería and Primeros auxilios. In enUS it shows Blacksmithing, Engineering, First Aid and Tailoring.

Use Silverleaf (`765`) to check that presentation parity preserves CraftAtlas's own Alchemy-only membership even though the reference also displays Herbalism. Use a catalog-absent item such as `25` as the control. Cover bag and chat item-link tooltips on the supported item path, rapid hover and same-item rebuilds, a language change followed by reopening the tooltip, and a long list at a compact UI scale. Record build, UI scales, locales, surfaces and screenshots. Mark each unavailable client check `NOT RUN`.
