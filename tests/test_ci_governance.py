"""Security and completeness contracts for PR workflows and governance documents."""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def source(path):
    return (ROOT / path).read_text(encoding="utf-8")


class WorkflowGovernanceTests(unittest.TestCase):
    def test_all_lua_sources_parsed_with_explicit_lua51(self):
        ci = source(".github/workflows/ci.yml")
        self.assertIn("lua-compatibility:", ci)
        self.assertIn("name: lua-compatibility", ci)
        self.assertIn("luac5.1 -p", ci)
        self.assertIn("find addon/CraftAtlas tests -type f -name '*.lua'", ci)
        self.assertIn("lua-regressions:", ci)
        self.assertIn("name: lua-regressions", ci)
        self.assertIn('lua5.1 "$file"', ci)
        self.assertIn("set -euo pipefail", ci)
        self.assertIn("test \"$count\" -gt 0", ci)

    def test_expensive_jobs_only_run_for_code(self):
        ci = source(".github/workflows/ci.yml")
        self.assertIn("name: classify-pr", ci)
        self.assertIn("mode=spec", ci)
        self.assertIn("mode=docs", ci)
        self.assertIn("mode=code", ci)
        self.assertIn("openspec/changes/*|openspec/specs/*", ci)
        self.assertIn("*.md|*.txt|CODEOWNERS", ci)
        self.assertEqual(
            ci.count("if: needs.classify.outputs.mode == 'code'\n    runs-on:"),
            2,
            "both Lua jobs must be skipped for documentation/spec-only changes",
        )
        self.assertIn("if: needs.classify.outputs.mode == 'spec'", ci)
        self.assertIn("if: needs.classify.outputs.mode == 'docs'", ci)
        self.assertIn("if: always()", ci)
        self.assertIn('test "$CLASSIFY_RESULT" = success', ci)
        self.assertIn('test "$total" -gt 0', ci)
        self.assertIn("if (( code == 0 ))", ci)
        self.assertIn('if: needs.classify.outputs.mode == \'code\' && github.event_name == \'pull_request\'', ci)
        self.assertIn('test "$failures" -eq 0', ci)

    def test_sdd_only_installs_openspec_when_relevant(self):
        sdd = source(".github/workflows/spec-compliance.yml")
        self.assertIn("Determine whether full OpenSpec CLI validation is needed", sdd)
        self.assertIn("openspec/*|*.lua|*.py|*.sh|*.yml|*.yaml|CODEOWNERS|AGENTS.md|skills/*", sdd)
        self.assertEqual(sdd.count("if: steps.changed.outputs.validate == 'true'"), 3)
        self.assertIn("python3 scripts/validate_sdd.py", sdd)

    def test_untrusted_pr_workflow_is_readonly(self):
        for path in (".github/workflows/ci.yml",
                     ".github/workflows/spec-compliance.yml"):
            content = source(path)
            self.assertRegex(content, r"(?m)^  pull_request:")
            self.assertIn("contents: read", content)
            self.assertNotIn("pull_request_target", content)
            self.assertNotIn("contents: write", content)
            self.assertNotIn("secrets.", content)
        self.assertIn("pull-requests: read", source(".github/workflows/spec-compliance.yml"))

    def test_release_owner_gate_not_changed(self):
        release = source(".github/workflows/publish-release.yml")
        self.assertIn("github.actor == 'hectoresen'", release)
        self.assertIn("github.triggering_actor == 'hectoresen'", release)
        self.assertIn("refs/heads/main", release)
        self.assertIn("test \"$(git rev-parse origin/main)\" = \"$VALIDATED_SHA\"", release)

    def test_documentation_skill_and_owner_scope(self):
        for path in ("AGENTS.md", "CONTRIBUTING.md",
                     "docs/DOCUMENTATION_PROTOCOL.md",
                     "docs/AGENT_WORKFLOW.md"):
            self.assertIn("skills/documentation-sync/SKILL.md", source(path))
        rules = source("docs/GITHUB_SETTINGS.md")
        self.assertIn("main — mandatory CI", rules)
        self.assertIn("main — contributor reviews", rules)
        self.assertIn("lua-compatibility", rules)
        self.assertIn("lua-regressions", rules)
        self.assertIn("For pull requests only", rules)
        self.assertIn("* @hectoresen", source("CODEOWNERS"))


if __name__ == "__main__":
    unittest.main()
