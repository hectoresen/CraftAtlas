# Implementation checklist

- [ ] Create workflow_dispatch-only publish-release.yml with owner identity and main-only gates.
- [ ] Add release packaging/versioning script with manifest validation, minimal ZIP and safe SemVer behavior.
- [ ] Add unit tests covering initial, patch, minor, major, duplicate tag, malicious path, missing runtime module, excluded data and ZIP layout.
- [ ] Run existing repository/material checks and packaging tests.
- [ ] Update README, docs/INSTALLATION.md and CHANGELOG.md with manual release instructions and permission boundary.
- [ ] Create implementation PR referencing this owner-approved proposal, not a release or direct main commit.
- [ ] Verify CI and document no in-game testing performed for packaging-only change.
