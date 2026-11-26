"""Pinned Forever catalog regression and source-diff acceptance boundaries."""
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("materials", ROOT / "scripts/build_materials.py")
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)


class CatalogRefreshTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.materials, cls.registry = g.load()
        cls.uses = json.loads(g.RECIPE_SOURCE.read_text(encoding="utf-8"))
        cls.source = g.load_recipe_catalog()
        cls.report = json.loads((g.DATA / "reconciliation-report.json").read_text(encoding="utf-8"))
        cls.by_key = {f'{r["professionKey"]}:{r["spellID"]}': r for r in cls.source["recipes"]}

    def test_pinned_rights_and_source_identity(self):
        self.assertEqual(self.source["sourceRevision"],
                         "c942539402802f2ec837cac1788f8c24fea374ed")
        self.assertEqual(self.source["clientBuild"], "Forever 1.60.1.70938")
        self.assertIn("Pimptasty", self.source["license"])
        self.assertFalse(self.source["liveClientValidated"])

    def test_full_source_accounting(self):
        self.assertEqual(len(self.source["recipes"]), 2518)
        self.assertEqual(len(self.uses["uses"]), 8471)
        self.assertEqual(len(self.materials["materials"]), 592)
        self.assertEqual(len(self.registry["professions"]), 12)
        self.assertEqual(len(self.report["addedRecipes"]), 12)
        self.assertEqual(len(self.report["confirmedChanges"]), 9)
        self.assertEqual(len(self.report["sourceEmptyConflictsRetained"]), 27)
        self.assertEqual(len(self.report["missingFromPrimaryRetained"]), 1)
        self.assertEqual(len(self.by_key), 2518)
        self.assertEqual(len(g.group_recipe_catalog(self.uses, self.registry, self.source)), 2518)

    def test_new_camping_professions_and_outputs(self):
        for profession, spells in (
            ("HERBALISM", [1229705, 1262980, 1263070]),
            ("SKINNING", [1229517, 1262982, 1262985]),
        ):
            actual = sorted(r["spellID"] for r in self.source["recipes"]
                            if r["professionKey"] == profession)
            self.assertEqual(actual, spells)
            for spell in spells:
                r = self.by_key[f"{profession}:{spell}"]
                self.assertTrue(r["camping"])
                self.assertGreater(r["outputItemID"], 0)
                self.assertTrue(r["ingredients"])
                self.assertGreater(r["requiredSkill"], 0)

    def test_changed_material_counts(self):
        cases = {
            "TAILORING:3758": (2997, 5),
            "TAILORING:6688": (2997, 5),
            "TAILORING:6693": (4305, 5),
            "TAILORING:6695": (4305, 6),
            "TAILORING:12079": (4339, 5),
        }
        for key, (material, quantity) in cases.items():
            self.assertEqual(dict(self.by_key[key]["ingredients"])[material], quantity)

    def test_source_backed_recipe_and_leather_reagent_corrections(self):
        self.assertEqual(dict(self.by_key["ENCHANTING:1328948"]["ingredients"]),
                         {11175: 2, 11176: 8, 11178: 2, 12361: 1})
        for spell in (1301431, 1301437, 1301455, 1301461):
            self.assertNotIn(4321, dict(self.by_key[f"LEATHERWORKING:{spell}"]["ingredients"]))

    def test_legacy_conflicts_remain_visible_not_silently_deleted(self):
        statuses = [r for r in self.source["recipes"] if r.get("evidenceStatus")]
        self.assertEqual(len(statuses), 28)
        self.assertEqual(
            self.by_key["ALCHEMY:1251750"]["evidenceStatus"],
            "retained-legacy-missing-from-new-source",
        )
        self.assertTrue(all(r["ingredients"] for r in statuses))

    def test_zero_reagent_actions_are_not_material_uses(self):
        no_inputs = [r for r in self.source["recipes"] if not r["ingredients"]]
        self.assertEqual(len(no_inputs), 5)
        projection_keys = {(row[2], row[1]) for row in self.uses["uses"]}
        self.assertTrue(all((r["professionKey"], r["spellID"]) not in projection_keys
                            for r in no_inputs))

    def test_vendor_and_skill_metadata(self):
        self.assertEqual(sum(bool(r.get("foreverVendorIDs")) for r in self.source["recipes"]), 316)
        self.assertGreater(sum(bool(r.get("requiredSkill")) for r in self.source["recipes"]), 2000)
        self.assertGreater(sum(bool(r.get("difficulty")) for r in self.source["recipes"]), 2000)
        self.assertTrue(all(r.get("acquisitionEvidence") for r in self.source["recipes"]
                            if r.get("acquisition")), "Borrowed acquisition must be identified")

    def test_regeneration_consistency(self):
        self.assertEqual(g.RECIPES_TARGET.read_text(encoding="utf-8"),
                         g.generate_recipes(self.uses, self.registry, self.source))
        self.assertEqual(g.RECIPE_TARGET.read_text(encoding="utf-8"),
                         g.generate_recipe_uses(self.uses, self.registry))
        self.assertEqual(g.validate_recipe_uses(self.uses, self.materials, self.registry), [])


if __name__ == "__main__":
    unittest.main()
