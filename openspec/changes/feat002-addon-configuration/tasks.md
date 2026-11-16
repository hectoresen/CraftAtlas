# Tasks

## 1. Approval and persisted preferences

- [ ] 1.1 Obtain the owner merge of this specification PR before starting implementation on a separate branch.
- [ ] 1.2 Add the four account-wide preferences and normalize missing and invalid values. Verify explicit false values and existing language and minimap positions survive initialization.

## 2. Configuration controls and minimap

- [ ] 2.1 Add localized General and Tooltip controls to the existing window, reusing the language selector, native widget patterns and existing locale fallback. Verify that visiting Configuration preserves browsing state and does not add a cross-explorer Back entry.
- [ ] 2.2 Apply the minimap visibility preference immediately and on reload. Cover toggling, slash-command recovery, position restoration and duplicate prevention with focused mocks.
- [ ] 2.3 Bind the tooltip controls to the saved preferences, including disabled layout controls that remember their selections.

## 3. Tooltip rendering

- [ ] 3.1 Implement annotation visibility and the independent icon and single-line options in the existing presenter.
- [ ] 3.2 Test all icon/layout combinations, annotation disable and re-enable, localized ordering, unknown items, missing icons, repeated callbacks and tooltip rebuilds.

## 4. Validation and documentation

- [ ] 4.1 Run the shared release gate, Lua 5.1 checks, relevant preference and UI regressions, and strict OpenSpec/SDD validation. Record actual outcomes.
- [ ] 4.2 In Forever, verify settings navigation, language synchronization, checkbox persistence after reload, slash-command recovery, minimap positioning and normal click, and tooltip variants on the tested surfaces. Record the build, locales, UI scales and outcomes, or mark unexecuted cases NOT RUN.
- [ ] 4.3 Execute the documentation-sync skill. Update README, architecture, installation, testing evidence and changelog for the implemented behavior. Submit a separate implementation PR with the approval PR number and documentation evidence.
