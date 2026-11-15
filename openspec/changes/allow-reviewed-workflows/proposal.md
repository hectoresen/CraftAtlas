# Permit approved workflow changes through SDD

## Why
The current validator rejects every .github path in an OpenSpec scope and rejects workflow changes during implementation, even when a maintainer has approved the change. This blocks the approved manual release workflow.

## In scope
- Update the SDD scope parser to allow explicit file paths under .github/workflows/ while keeping wildcard, parent traversal and unsafe hidden paths rejected.
- Allow implementation changes to such workflow files ONLY when listed in the merged, maintainer-approved sdd-scope.json.
- Keep all current approval, chronology, owner, changed-file and unrelated-governance gates.
- Add regression tests for a positively authorized workflow and for missing/unapproved permissions; document the policy adjustment.

## Out of scope
No workflow publication, gameplay modification, changes to repository permissions or CI bypass. The actual release workflow requires a separate owner-approved change whose scope explicitly lists its file.

## Risk
Workflows are executable privileged automation. Constrain approval to individually enumerated files, reject any broad .github wildcard and require owner-reviewed spec PR before accepting workflow edits. Revert validator change if it weakens existing gates.
