"""Validation of data migration, deterministic artifacts and honest coverage."""
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "materials", Path(__file__).resolve().parents[1] / "scripts/build_materials.py")
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)


class MaterialsTests(unittest.TestCase):
    def setUp(self):
        self.data, self.registry = g.load()

    def test_valid_source(self):
        self.assertEqual(g.validate_catalog(self.data, self.registry), [])

    def test_generated_files_in_sync(self):
        self.assertEqual(g.TARGET.read_text(encoding="utf-8"), g.generate(self.data, self.registry))
        self.assertEqual(g.REGISTRY_LUA.read_text(encoding="utf-8"), g.generate_registry(self.registry))
        self.assertEqual(json.loads(g.COVERAGE.read_text(encoding="utf-8")), g.coverage_report(self.data, self.registry))

    def test_determinism(self):
        before = g.generate(self.data, self.registry)
        self.data["materials"].reverse()
        self.assertEqual(g.generate(self.data, self.registry), before)

    def test_unregistered_profession(self):
        self.data["materials"][0]["relations"][0]["professionKey"] = "CUSTOM_UNKNOWN"
        self.assertTrue(g.validate_catalog(self.data, self.registry))

    def test_duplicate_relation(self):
        self.data["materials"][0]["relations"].append(self.data["materials"][0]["relations"][0].copy())
        self.assertTrue(g.validate_catalog(self.data, self.registry))

    def test_missing_provenance(self):
        del self.data["materials"][0]["relations"][0]["rights"]
        self.assertTrue(g.validate_catalog(self.data, self.registry))

    def test_duplicate_item(self):
        self.data["materials"].append(self.data["materials"][0].copy())
        self.assertTrue(g.validate_catalog(self.data, self.registry))

    def test_missing_localized_profession_label(self):
        del self.registry["professions"][0]["esES"]
        self.assertTrue(g.validate_catalog(self.data, self.registry))

    def test_release_gate_blocks_unverified_catalog(self):
        self.assertTrue(g.validate_catalog(self.data, self.registry, release=True))

    def test_unknown_universe_has_no_completeness_claim(self):
        report = g.coverage_report(self.data, self.registry)
        self.assertIsNone(report["coveragePercent"])
        self.assertFalse(report["fullCoverageClaimAllowed"])


if __name__ == "__main__":
    unittest.main()
