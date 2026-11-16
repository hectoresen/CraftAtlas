"""Tests for PR-to-OpenSpec policy. Python standard library only."""
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/validate_sdd.py"
spec = importlib.util.spec_from_file_location("sdd_gate", SCRIPT)
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)


class SddPolicyTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.change = "add-material-tooltip"
        self.prefix = "openspec/changes/" + self.change + "/"
        directory = self.root / self.prefix
        (directory / "specs" / "material-tooltip").mkdir(parents=True)
        for name in ("proposal.md", "design.md", "tasks.md"):
            (directory / name).write_text("# Example\n", encoding="utf-8")
        (directory / "specs/material-tooltip/spec.md").write_text(
            "## ADDED Requirements\n### Requirement: Example\n", encoding="utf-8")
        (directory / "sdd-scope.json").write_text(
            json.dumps({"allowed_paths": ["addon/CraftAtlas/**", "tests/**"]}))
        self.proposal = "OpenSpec-Change: " + self.change + "\nOpenSpec-Phase: proposal\n"
        self.implementation = (
            "OpenSpec-Change: " + self.change + "\n"
            "OpenSpec-Phase: implementation\nOpenSpec-Approval-PR: 9\n"
            "OpenSpec-Archive: blocked\n"
            "OpenSpec-Archive-Evidence: Incomplete acceptance: the approved client scenario is NOT RUN, so docs/TESTING.md records pending manual verification.\n")

    @staticmethod
    def api(path, token):
        if path == "pulls/9":
            return {"merged_at": "2026-11-01T00:00:00Z",
                    "merged_by": {"login": "hectoresen"}, "base": {"ref": "main"}}
        if path.startswith("pulls/9/files"):
            return [{"filename": "openspec/changes/add-material-tooltip/proposal.md"}]
        raise AssertionError(path)

    def check(self, paths, body, number=42, present=False, api=None, created=None):
        return gate.validate(set(paths), body, number, root=self.root,
                             token="mock-token", api=api or self.api,
                             exists_in_base=lambda path: present, implementation_created=created)

    def test_new_proposal_passes(self):
        self.assertEqual(self.check({self.prefix + "proposal.md"}, self.proposal), [])

    def test_proposal_with_lua_fails(self):
        self.assertTrue(self.check({self.prefix + "proposal.md", "addon/CraftAtlas/Core/Init.lua"},
                                   self.proposal))

    def test_proposal_reusing_old_id_fails(self):
        self.assertTrue(self.check({self.prefix + "proposal.md"}, self.proposal, present=True))

    def test_implementation_with_existing_approved_spec_passes(self):
        self.assertEqual(self.check({"addon/CraftAtlas/Core/Init.lua"},
                                    self.implementation, present=True), [])

    def test_code_without_spec_metadata_fails(self):
        self.assertTrue(self.check({"addon/CraftAtlas/Core/Init.lua"}, ""))

    def test_implementation_without_approval_fails(self):
        self.assertTrue(self.check({"addon/CraftAtlas/Core/Init.lua"},
                                   self.implementation.replace("OpenSpec-Approval-PR: 9", ""),
                                   present=True))

    def test_implementation_spec_must_be_in_main(self):
        self.assertTrue(self.check({"addon/CraftAtlas/Core/Init.lua"},
                                   self.implementation, present=False))

    def test_implementation_cannot_modify_approved_scope(self):
        self.assertTrue(self.check({"addon/CraftAtlas/Core/Init.lua",
                                    self.prefix + "sdd-scope.json"},
                                   self.implementation, present=True))

    def test_implementation_outside_scope_fails(self):
        self.assertTrue(self.check({"private/admin.lua"},
                                   self.implementation, present=True))

    def test_implementation_bad_owner_fails(self):
        def other_owner(path, token):
            if path == "pulls/9":
                return {"merged_at": "2026-11-01T00:00:00Z",
                        "merged_by": {"login": "someone-else"}, "base": {"ref": "main"}}
            return [{"filename": self.prefix + "proposal.md"}]
        self.assertTrue(self.check({"addon/CraftAtlas/Core/Init.lua"},
                                   self.implementation, present=True, api=other_owner))

    def test_implementation_unrelated_approval_fails(self):
        def unrelated(path, token):
            if path == "pulls/9":
                return {"merged_at": "2026-11-01T00:00:00Z",
                        "merged_by": {"login": "hectoresen"}, "base": {"ref": "main"}}
            return [{"filename": "openspec/changes/unrelated/proposal.md"}]
        self.assertTrue(self.check({"addon/CraftAtlas/Core/Init.lua"},
                                   self.implementation, present=True, api=unrelated))

    def test_approved_governance_may_update_agents_and_root_codeowners(self):
        change = "harden-contributor-pr-governance"
        old = self.change
        self.change = change
        folder = self.root / "openspec" / "changes" / change
        folder.mkdir(parents=True)
        (folder / "specs").mkdir()
        for name in ("proposal.md", "design.md", "tasks.md"):
            (folder / name).write_text("# Approved\n")
        (folder / "specs" / "spec.md").write_text("## ADDED Requirements\n")
        (folder / "sdd-scope.json").write_text(json.dumps({
            "allowed_paths": ["AGENTS.md", "CODEOWNERS", "tests/**",
                              "scripts/validate_sdd.py"]}))
        body = "OpenSpec-Change: " + change + (
            "\nOpenSpec-Phase: implementation\nOpenSpec-Approval-PR: 9\n" +
            "\nOpenSpec-Archive: blocked\nOpenSpec-Archive-Evidence: Incomplete manual client acceptance NOT RUN; docs/TESTING.md documents missing review evidence.\n")
        def approved(path, token):
            if path == "pulls/9":
                return {"merged_at": "2026-11-01T00:00:00Z",
                        "merged_by": {"login": "hectoresen"}, "base": {"ref": "main"}}
            return [{"filename": "openspec/changes/" + change + "/proposal.md"}]
        try:
            self.assertEqual(self.check({"AGENTS.md", "CODEOWNERS"}, body,
                                        present=True, api=approved), [])
            self.assertTrue(self.check({"AGENTS.md", ".github/CODEOWNERS"}, body,
                                       present=True, api=approved))
            (folder / "sdd-scope.json").write_text(json.dumps({
                "allowed_paths": ["tests/**", "scripts/validate_sdd.py"]}))
            self.assertTrue(self.check({"AGENTS.md", "CODEOWNERS"}, body,
                                       present=True, api=approved))
        finally:
            self.change = old

    def test_unrelated_governance_change_still_cannot_touch_agents(self):
        folder = self.root / self.prefix
        (folder / "sdd-scope.json").write_text(json.dumps({
            "allowed_paths": ["AGENTS.md", "CODEOWNERS", "tests/**"]}))
        self.assertTrue(self.check({"AGENTS.md"}, self.implementation, present=True))
        self.assertTrue(self.check({"CODEOWNERS"}, self.implementation, present=True))

    def test_docs_exemption_passes_for_readme(self):
        self.assertEqual(self.check({"README.md"},
                                    "OpenSpec-Exemption: docs-only\n"), [])

    def test_docs_exemption_fails_for_policy(self):
        self.assertTrue(self.check({"AGENTS.md"}, "OpenSpec-Exemption: docs-only\n"))

    def test_maintenance_cannot_modify_lua(self):
        self.assertTrue(self.check({"addon/CraftAtlas/Core/Init.lua"},
                                   "OpenSpec-Exemption: maintenance\n"))

    def test_bootstrap_only_pr2_with_allowlist(self):
        exemption = "OpenSpec-Exemption: bootstrap\n"
        self.assertEqual(self.check({"scripts/validate_sdd.py"}, exemption, number=2), [])
        self.assertTrue(self.check({"scripts/validate_sdd.py"}, exemption, number=3))
        self.assertTrue(self.check({"addon/CraftAtlas/Core/Init.lua"}, exemption, number=2))

    def test_fenced_metadata_does_not_count(self):
        fields = gate.parse_metadata(
            "~~~\nOpenSpec-Change: fake\n~~~\nOpenSpec-Exemption: docs-only\n")
        self.assertEqual(fields["change"], [])
        self.assertEqual(fields["exemption"], ["docs-only"])

    def test_unsafe_wildcard_scope_fails(self):
        (self.root / self.prefix / "sdd-scope.json").write_text(
            '{"allowed_paths": ["**"]}')
        self.assertTrue(self.check({self.prefix + "proposal.md"}, self.proposal))

    def test_missing_artifact_fails(self):
        (self.root / self.prefix / "design.md").unlink()
        self.assertTrue(self.check({self.prefix + "proposal.md"}, self.proposal))

    def test_duplicate_declarations_fail(self):
        self.assertTrue(self.check({"README.md"},
                                   "OpenSpec-Exemption: docs-only\n"
                                   "OpenSpec-Exemption: docs-only\n"))


    def test_docs_exception_cannot_edit_openspec(self):
        self.assertTrue(self.check({"openspec/changes/a/proposal.md"},
                                   "OpenSpec-Exemption: docs-only\n"))

    def test_docs_exception_cannot_edit_code_quality(self):
        self.assertTrue(self.check({"docs/CODE_QUALITY.md"},
                                   "OpenSpec-Exemption: docs-only\n"))

    def test_combined_only_authorized_pr_and_change(self):
        body = "OpenSpec-Change: improve-material-explorer-ui\nOpenSpec-Phase: combined\n"
        files = {self.prefix + "proposal.md", "addon/CraftAtlas/Core/Init.lua"}
        self.assertTrue(self.check(files, body, number=14))
        self.assertTrue(self.check(files, body, number=15))

    def test_combined_valid_authorization(self):
        change = "improve-material-explorer-ui"
        prefix = "openspec/changes/" + change + "/"
        folder = self.root / prefix
        (folder / "specs" / "material-explorer").mkdir(parents=True)
        for name in ("proposal.md", "design.md", "tasks.md", "sdd-scope.json"):
            (folder / name).write_text("# example" if name.endswith(".md")
                else '{"allowed_paths":["addon/CraftAtlas/**","tests/**"]}', encoding="utf-8")
        (folder / "specs/material-explorer/spec.md").write_text("## ADDED Requirements\n")
        body = "OpenSpec-Change: " + change + "\nOpenSpec-Phase: combined\n"
        paths = {prefix + "proposal.md", "addon/CraftAtlas/Core/Init.lua"}
        self.assertEqual(self.check(paths, body, number=14), [])
        self.assertTrue(self.check(paths, body, number=16))
        self.assertTrue(self.check(paths | {"private/secret"}, body, number=14))
        self.assertTrue(self.check(paths | {".github/workflows/ci.yml"}, body, number=14))
        self.assertTrue(self.check(paths, body + "OpenSpec-Approval-PR: 9\n", number=14))

    def test_implementation_cannot_precede_spec_approval(self):
        self.assertTrue(self.check({"addon/CraftAtlas/Core/Init.lua"},
                                   self.implementation, present=True,
                                   created="2026-10-01T00:00:00Z"))

    def set_scope(self, paths):
        (self.root / self.prefix / "sdd-scope.json").write_text(
            json.dumps({"allowed_paths": paths}), encoding="utf-8")

    def test_explicit_workflow_scope_is_accepted(self):
        self.set_scope([".github/workflows/publish-release.yml"])
        self.assertEqual(self.check({self.prefix + "proposal.md"}, self.proposal), [])
        self.assertEqual(
            self.check({".github/workflows/publish-release.yml"},
                       self.implementation, present=True), [])

    def test_unapproved_workflow_is_rejected(self):
        self.set_scope(["README.md"])
        self.assertTrue(self.check({".github/workflows/publish-release.yml"},
                                   self.implementation, present=True))

    def test_other_workflow_is_rejected_even_if_one_is_approved(self):
        self.set_scope([".github/workflows/publish-release.yml"])
        self.assertTrue(self.check({".github/workflows/ci.yml"},
                                   self.implementation, present=True))

    def test_workflow_wildcards_are_rejected(self):
        for unsafe in (".github/workflows/**", ".github/**",
                       ".github/workflows/*.yml",
                       ".github/workflows/../ci.yml",
                       ".github/CODEOWNERS"):
            with self.subTest(path=unsafe):
                self.set_scope([unsafe])
                self.assertTrue(self.check({self.prefix + "proposal.md"}, self.proposal))

    def test_hidden_file_cannot_be_whitelisted_via_broad_scope(self):
        self.set_scope([".github/workflows/publish-release.yml", "docs/**"])
        self.assertTrue(self.check({".github/CODEOWNERS"}, self.implementation, present=True))

    def test_approval_gates_apply_to_workflow_changes(self):
        self.set_scope([".github/workflows/publish-release.yaml"])
        self.assertTrue(self.check({".github/workflows/publish-release.yaml"},
                                   self.implementation, present=False))
        self.assertTrue(self.check({".github/workflows/publish-release.yaml"},
                                   self.implementation, present=True,
                                   created="2026-10-01T00:00:00Z"))

    def test_only_approved_documentation_gate_may_update_agents(self):
        change = "mandatory-multiagent-documentation-gate"
        prefix = "openspec/changes/" + change + "/"
        folder = self.root / prefix
        (folder / "specs" / "documentation-gate").mkdir(parents=True)
        for name in ("proposal.md", "design.md", "tasks.md"):
            (folder / name).write_text("# approved\n", encoding="utf-8")
        (folder / "specs/documentation-gate/spec.md").write_text(
            "## ADDED Requirements\n", encoding="utf-8")
        (folder / "sdd-scope.json").write_text(json.dumps({
            "allowed_paths": ["AGENTS.md", ".github/workflows/ci.yml",
                "skills/documentation-sync/**", "scripts/validate_sdd.py"]
        }))
        body = ("OpenSpec-Change: " + change +
                "\nOpenSpec-Phase: implementation\nOpenSpec-Approval-PR: 9\n" +
            "\nOpenSpec-Archive: blocked\nOpenSpec-Archive-Evidence: Incomplete manual client acceptance NOT RUN; docs/TESTING.md documents missing review evidence.\n")

        def approved_api(path, token):
            if path == "pulls/9":
                return {"merged_at": "2026-11-01T00:00:00Z",
                        "merged_by": {"login": "hectoresen"}, "base": {"ref": "main"}}
            return [{"filename": prefix + "proposal.md"}]

        self.assertEqual(self.check({"AGENTS.md", "skills/documentation-sync/SKILL.md"},
                                    body, present=True, api=approved_api), [])
        # A different change claiming AGENTS in scope still fails.
        self.set_scope(["AGENTS.md", "addon/CraftAtlas/**"])
        self.assertTrue(self.check({"AGENTS.md"}, self.implementation, present=True))
        # SDD rules remain strict: an unrelated spec approval cannot bless AGENTS.
        self.assertTrue(self.check({"AGENTS.md"}, body, present=True, api=self.api))
        self.assertTrue(self.check({"AGENTS.md"}, body, present=False, api=approved_api))
        self.assertTrue(self.check({"AGENTS.md"}, body, present=True,
                                   created="2026-10-01T00:00:00Z", api=approved_api))

    def test_governance_scope_cannot_glob_hidden_paths(self):
        self.set_scope([".github/**", "AGENTS.md"])
        self.assertTrue(self.check({self.prefix + "proposal.md"}, self.proposal))


    def lifecycle_fixture(self):
        change = "reconcile-openspec-lifecycle-and-status"
        folder = self.root / "openspec/changes" / change
        (folder / "specs/lifecycle-governance").mkdir(parents=True)
        for name in ("proposal.md", "design.md", "tasks.md"):
            (folder / name).write_text("# approved\n")
        (folder / "specs/lifecycle-governance/spec.md").write_text("## ADDED Requirements\n")
        (folder / "sdd-scope.json").write_text(json.dumps({"allowed_paths": [
            "scripts/validate_sdd.py", "tests/test_validate_sdd.py", "docs/SDD_COMPLIANCE.md"
        ]}))
        (self.root / "openspec/config.yaml").write_text(
            "schema: spec-driven\ncontext: Implemented addon, read README.md\n")
        (self.root / "docs").mkdir(exist_ok=True)
        (self.root / "docs/OPENSPEC_STATUS.md").write_text("# Verified status\n")
        body = ("OpenSpec-Change: reconcile-openspec-lifecycle-and-status\n"
                "OpenSpec-Phase: lifecycle\nOpenSpec-Approval-PR: 13\n")
        return body

    @staticmethod
    def lifecycle_api(path, token):
        if path == "pulls/13":
            return {"merged_at": "2026-11-15T12:31:03Z",
                    "merged_by": {"login": "hectoresen"}, "base": {"ref": "main"}}
        if path.startswith("pulls/13/files"):
            return [{"filename": "openspec/changes/reconcile-openspec-lifecycle-and-status/proposal.md"}]
        raise AssertionError(path)

    def test_lifecycle_accepts_owner_approved_config_repair(self):
        body = self.lifecycle_fixture()
        self.assertEqual(self.check({"openspec/config.yaml", "docs/OPENSPEC_STATUS.md"},
                                    body, present=True, api=self.lifecycle_api), [])

    def test_lifecycle_rejects_other_change_and_approval(self):
        body = self.lifecycle_fixture()
        self.assertTrue(self.check({"openspec/config.yaml"}, body.replace(
            "reconcile-openspec-lifecycle-and-status", "add-material-tooltip"),
            present=True, api=self.lifecycle_api))
        self.assertTrue(self.check({"openspec/config.yaml"}, body.replace(
            "OpenSpec-Approval-PR: 13", "OpenSpec-Approval-PR: 9"),
            present=True, api=self.api))

    def test_lifecycle_rejects_unrelated_and_tampered_changes(self):
        body = self.lifecycle_fixture()
        self.assertTrue(self.check({"addon/CraftAtlas/Core/Init.lua"},
                                   body, present=True, api=self.lifecycle_api))
        path = "openspec/changes/add-first-playable-material-tooltips/proposal.md"
        (self.root / path).parent.mkdir(parents=True)
        (self.root / path).write_text("tampered")
        self.assertTrue(self.check({path}, body, present=True, api=self.lifecycle_api))

    def test_lifecycle_limits_canonical_specs(self):
        body = self.lifecycle_fixture()
        self.assertTrue(self.check({"openspec/specs/new-feature/spec.md"},
                                   body, present=True, api=self.lifecycle_api))
        accepted = self.root / "openspec/changes/add-first-playable-material-tooltips/specs/material-lookup"
        accepted.mkdir(parents=True)
        (accepted / "spec.md").write_text("## ADDED Requirements\n")
        self.assertEqual(self.check({"openspec/specs/material-lookup/spec.md"},
                                    body, present=True, api=self.lifecycle_api), [])

    def test_lifecycle_requires_current_context_and_schema(self):
        body = self.lifecycle_fixture()
        path = self.root / "openspec/config.yaml"
        path.write_text("schema: spec-driven\n  v0.0.0 is documentation and folder structure only\n")
        self.assertTrue(self.check({"openspec/config.yaml"}, body,
                                   present=True, api=self.lifecycle_api))
        path.write_text("schema: invalid\n")
        self.assertTrue(self.check({"openspec/config.yaml"}, body,
                                   present=True, api=self.lifecycle_api))

    def test_lifecycle_preserves_owner_and_chronology(self):
        body = self.lifecycle_fixture()
        def other(path, token):
            if path == "pulls/13":
                return {"merged_at": "2026-11-15T12:31:03Z",
                        "merged_by": {"login": "someone"}, "base": {"ref": "main"}}
            return self.lifecycle_api(path, token)
        self.assertTrue(self.check({"openspec/config.yaml"}, body,
                                   present=True, api=other))
        self.assertTrue(self.check({"openspec/config.yaml"}, body,
                                   present=True, api=self.lifecycle_api,
                                   created="2026-11-01T00:00:00Z"))

    def test_lifecycle_cannot_delete_history_without_archive(self):
        body = self.lifecycle_fixture()
        self.assertTrue(self.check({
            "openspec/changes/add-first-playable-material-tooltips/design.md"},
            body, present=True, api=self.lifecycle_api))
        destination = ("openspec/changes/archive/2026-11-15-"
                       "add-first-playable-material-tooltips/design.md")
        (self.root / destination).parent.mkdir(parents=True)
        (self.root / destination).write_text("unverified")
        self.assertTrue(self.check({destination}, body,
                                   present=False, api=self.lifecycle_api))

    def test_lifecycle_does_not_weaken_normal_implementation(self):
        self.set_scope(["AGENTS.md", "addon/CraftAtlas/**"])
        self.assertTrue(self.check({"openspec/config.yaml"}, self.implementation,
                                   present=True))
        self.assertTrue(self.check({
            "openspec/changes/add-first-playable-material-tooltips/tasks.md"},
            self.implementation, present=True))


    def test_context_regression_cannot_reintroduce_historical_scaffold(self):
        old = ("schema: spec-driven\n"
               "  v0.0.0 is documentation and folder structure only, not a working addon.\n")
        current = ("schema: spec-driven\n"
                   "context: |\n  Current capability described in README.md.\n")
        self.assertEqual(gate.context_regression_errors(current, old), [])
        self.assertEqual(gate.context_regression_errors(old, old), [])
        self.assertTrue(gate.context_regression_errors(old, current))
        self.assertTrue(gate.context_regression_errors(
            "schema: spec-driven\ncontext: no reference\n", current))
        self.assertTrue(gate.context_regression_errors(
            "schema: unexpected\ncontext: README.md\n", current))
        self.assertTrue(gate.context_regression_errors(
            "schema: spec-driven\ncontext: README.md, current version v0.1.0-dev\n", current))


class AtomicArchiveTests(unittest.TestCase):
    """Owner-approved base bytes are immutable; archive is same-change only."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.change = "verified-fixture"
        self.prefix = "openspec/changes/" + self.change + "/"
        self.destination = "openspec/changes/archive/2026-11-16-" + self.change + "/"
        self.approved = {
            self.prefix + "proposal.md": b"# Approved proposal\\n",
            self.prefix + "design.md": b"# Accepted design\\n",
            self.prefix + "tasks.md": b"- [ ] Implement\\n- [ ] Verify\\n",
            self.prefix + "sdd-scope.json": b'{"allowed_paths":["addon/CraftAtlas/**"]}\\n',
            self.prefix + "specs/feature/spec.md": (
                b"## ADDED Requirements\\n### Requirement: Ready\\n"
                b"#### Scenario: Verified\\n- **WHEN** tested\\n- **THEN** works\\n"),
        }
        self.base = dict(self.approved)
        self.paths = {"addon/CraftAtlas/Domain/MaterialLookup.lua",
                      "docs/OPENSPEC_STATUS.md",
                      "openspec/specs/feature/spec.md"}
        for path, content in self.approved.items():
            rel = path[len(self.prefix):]
            if rel == "tasks.md":
                content = b"- [x] Implement\\n- [x] Verify\\n"
            target = self.destination + rel
            self.paths.add(target)
            (self.root / target).parent.mkdir(parents=True, exist_ok=True)
            (self.root / target).write_bytes(content)
            self.paths.add(path)
        canon = self.root / "openspec/specs/feature/spec.md"
        canon.parent.mkdir(parents=True)
        canon.write_text("## ADDED Requirements\\n### Requirement: Ready\\n")
        ledger = self.root / "docs/OPENSPEC_STATUS.md"
        ledger.parent.mkdir(parents=True)
        ledger.write_text(
            "| verified-fixture | #9 approved | #42 implementation "
            "| archived | tests/test_validate_sdd.py PASS acceptance evidence |\\n")
        self.evidence = (
            "tests/test_validate_sdd.py PASS all approved scenarios; "
            "docs/OPENSPEC_STATUS.md records complete acceptance with owner review."
        )

    def listing(self, base, prefix):
        return [p for p in self.base if p.startswith(prefix)]

    def reading(self, base, path):
        return self.base[path]

    def check(self, paths=None, state="prepared", evidence=None):
        return gate.validate_implementation_archive(
            self.paths if paths is None else paths,
            self.change, self.root, "main", state,
            self.evidence if evidence is None else evidence,
            file_list=self.listing, file_read=self.reading,
            pr_number=42, approval="9",
        )

    def test_complete_atomic_archive_passes(self):
        self.assertEqual(self.check(), [])

    def test_blocked_implementation_keeps_active_change(self):
        self.assertEqual(self.check(
            {"addon/CraftAtlas/Domain/MaterialLookup.lua", self.prefix + "tasks.md"},
            state="blocked", evidence=(
                "docs/TESTING.md records that Forever scenario is NOT RUN; "
                "manual acceptance remains pending and the change stays open.")), [])

    def test_missing_metadata_or_fake_prepared_fails(self):
        self.assertTrue(self.check(state=None))
        self.assertTrue(self.check(state="prepared", evidence="Reviewed"))
        self.assertTrue(self.check(paths={"addon/CraftAtlas/Domain/MaterialLookup.lua"}))

    def test_archive_requires_every_owner_approved_file(self):
        partial = {x for x in self.paths if not x.endswith("design.md")}
        self.assertTrue(self.check(paths=partial))

    def test_archive_rejects_tampered_approved_design_and_scope(self):
        for name in ("design.md", "sdd-scope.json", "specs/feature/spec.md"):
            p = self.root / (self.destination + name)
            before = p.read_bytes()
            p.write_bytes(b"# Malicious edit\\n")
            self.assertTrue(self.check(), name)
            p.write_bytes(before)

    def test_archive_rejects_unfinished_tasks_or_rewritten_task_names(self):
        p = self.root / (self.destination + "tasks.md")
        p.write_text("- [x] Implement\\n- [ ] Verify\\n")
        self.assertTrue(self.check())
        p.write_text("- [x] Implement\\n- [x] Rewrite acceptance\\n")
        self.assertTrue(self.check())

    def test_archive_rejects_unrelated_changes_and_bad_dates(self):
        stray = self.destination.replace(self.change, "other-change") + "proposal.md"
        self.assertTrue(self.check(paths=self.paths | {stray}))
        invalid = self.destination.replace("2026-11-16", "2026-02-30")
        self.assertTrue(self.check(paths={
            x.replace(self.destination, invalid) for x in self.paths
        }))

    def test_archive_rejects_incomplete_canonical_sync(self):
        canon = self.root / "openspec/specs/feature/spec.md"
        canon.write_text("## ADDED Requirements\\n### Requirement: Wrong\\n")
        self.assertTrue(self.check())

    def test_archive_preserves_existing_canonical_requirements(self):
        path = "openspec/specs/feature/spec.md"
        self.base[path] = b"### Requirement: Existing\\n"
        self.assertTrue(self.check())
        (self.root / path).write_text(
            "### Requirement: Ready\\n### Requirement: Existing\\n")
        self.assertEqual(self.check(), [])

    def test_blocked_cannot_touch_archive_or_canonical(self):
        self.assertTrue(self.check(state="blocked", evidence=(
            "docs/TESTING.md states mandatory client acceptance NOT RUN "
            "and the required manual scenario remains blocked.")))
        self.assertTrue(self.check(
            {"addon/CraftAtlas/Domain/MaterialLookup.lua",
             "openspec/specs/feature/spec.md"},
            state="blocked", evidence=(
                "docs/TESTING.md records mandatory tests NOT RUN; "
                "approval is pending and archiving is blocked.")))

    def test_requires_ledger_with_current_change_provenance(self):
        ledger = self.root / "docs/OPENSPEC_STATUS.md"
        ledger.write_text("| unrelated | #9 | archived | tests PASS |\\n")
        self.assertTrue(self.check())
        ledger.write_text("| verified-fixture | archived | tests PASS |\\n")
        self.assertTrue(self.check())

if __name__ == "__main__":
    unittest.main()
