"""Data source and deterministic generated Lua regression tests."""
import importlib.util
import tempfile
import unittest
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1] / "scripts/build_materials.py"
spec = importlib.util.spec_from_file_location("materials", MODULE)
generator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generator)


class MaterialsTests(unittest.TestCase):
    def valid(self, item_id, professions):
        return {"itemID": item_id, "professions": professions,
                "source": "hand-checked game recipe evidence", "reviewed": "2026-11-14",
                "clientScope": "Forever review pending",
                "rights": "original-factual-research"}

    def test_valid_record(self):
        self.assertEqual(generator.validate([self.valid(2589, ["TAILORING"])]), [])

    def test_duplicate_ids(self):
        row = self.valid(2589, ["TAILORING"])
        self.assertTrue(generator.validate([row, row]))

    def test_bad_profession(self):
        self.assertTrue(generator.validate([self.valid(2589, ["NOT_A_PROFESSION"])]))

    def test_missing_evidence(self):
        row = self.valid(2589, ["TAILORING"])
        del row["source"]
        self.assertTrue(generator.validate([row]))

    def test_unapproved_rights(self):
        row = self.valid(2589, ["TAILORING"])
        row["rights"] = "unknown"
        self.assertTrue(generator.validate([row]))

    def test_release_gate_requires_minimum(self):
        self.assertTrue(generator.validate([], release=True))

    def test_generation_is_deterministic(self):
        rows = [self.valid(2840, ["ENGINEERING"]), self.valid(2589, ["TAILORING"])]
        self.assertEqual(generator.generate(rows), generator.generate(rows[::-1]))

    def test_current_source_matches_output(self):
        import json
        source = json.loads(generator.SOURCE.read_text(encoding="utf-8"))
        self.assertEqual(generator.TARGET.read_text(encoding="utf-8"),
                         generator.generate(source["materials"]))


if __name__ == "__main__":
    unittest.main()
