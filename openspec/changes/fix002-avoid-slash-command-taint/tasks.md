## 1. Correct and test command registration

- [x] 1.1 Register the alias and handler in the native command table without assigning the global registry. Skip registration safely when it is unavailable.
- [x] 1.2 Extend the Lua 5.1 regression fixture to detect a global reassignment, verify other entries are preserved and exercise missing or non-table registry values, minimap access and existing command dispatch.

## 2. Verify and document

- [x] 2.1 Run the Lua compatibility and regression checks, `bash scripts/validate_release_checks.sh` and strict OpenSpec validation. Record the results.
- [ ] 2.2 On Forever, exercise all three command forms and repeat the DungeonJournal portrait click in a fresh UI session with taint logging enabled. Record the client build, addon versions, marking result and relevant trace.
- [x] 2.3 Run the documentation-sync skill before the implementation PR, document the fix and its test evidence, and assess archive readiness.
