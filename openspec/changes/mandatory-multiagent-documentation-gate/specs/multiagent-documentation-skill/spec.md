# Portable pre-PR documentation synchronization skill

## ADDED Requirements

### Requirement: Define one cross-agent documentation skill
The project SHALL provide a discoverable, canonical Agent Skills-compatible documentation-sync SKILL.md reusable by Codex, Claude Code, Copilot and generic agents, with non-duplicated provider pointers as appropriate.

#### Scenario: Agent supports skill discovery
- **WHEN** an agent recognizes the canonical skill path or its provider-specific alias
- **THEN** it can read complete portable documentation-sync instructions
- **AND** does not require access to proprietary tooling

#### Scenario: Generic agent does not support skills
- **WHEN** a simple coding agent reads AGENTS.md
- **THEN** it is explicitly instructed to open the canonical SKILL.md before opening functional PRs
- **AND** can perform all steps serially without subagent support

### Requirement: Review docs before a functional PR
An implementing agent SHALL invoke documentation-sync **after implementing/testing and before opening a functional PR**, compare the source diff and accepted OpenSpec with README/current technical documentation, update affected docs and supply an evidence report.

#### Scenario: New Fabricables behavior
- **WHEN** implementation changes user-visible crafting functionality
- **THEN** README/current features and limits are updated
- **AND** architecture, testing, data, installation, roadmap and changelog are reviewed and updated where relevant
- **AND** AGENTS.md stays dedicated to agent instructions and skill discovery

#### Scenario: No user-facing documentation impact
- **WHEN** a functional PR has no actual README impact
- **THEN** the agent records a substantive reason and still reviews relevant tests and technical docs
- **AND** CI can require truthful review metadata but does not demand meaningless README edits

#### Scenario: Parallel auditors
- **WHEN** multiagent execution is available
- **THEN** functionality, technical documentation, QA/evidence and release-history audits may run concurrently with disjoint ownership
- **AND** one coordinator reconciles all edits and verdicts before PR creation

### Requirement: Preserve evidence and source rights
The skill SHALL distinguish code-implemented, maintainer-tested and source-catalog-verified claims; it SHALL never mark unrun Forever tests complete or fabricate item/recipe data, and SHALL preserve required licenses/attribution.

#### Scenario: No live client test
- **WHEN** an agent cannot run Forever
- **THEN** its PR report states `NOT RUN` for game tests
- **AND** documentation does not claim verified client compatibility beyond provided owner evidence
