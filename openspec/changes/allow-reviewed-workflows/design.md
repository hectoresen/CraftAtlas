# Design

Current scripts/validate_sdd.py scope_patterns rejects any allowed_paths entry that starts with ".". During implementation, validate rejects any changed path beginning ".github/" unconditionally.

Implement a narrow carve-out for exact .github/workflows/<safe-filename>.yml or .yaml patterns (no glob, dots other than extension, parent segments, arbitrary .github paths). Existing scope rules remain for all other paths. The implementation phase shall accept a .github/workflows file only when that exact file is listed in the frozen scope and authorized by a merged proposal. Reject unrelated .github files and AGENTS.md. No change to bootstrap/maintenance exemptions.

Add tests covering: valid exact workflow path; rejected directory wildcard; unapproved workflow; other .github paths; malicious path; approved workflow implementation. Update docs/SDD_COMPLIANCE.md to explain how to govern workflow changes. These changes affect CI authorization, not gameplay or release publication.
