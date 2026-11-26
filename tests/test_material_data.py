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
        self.recipes = json.loads(g.RECIPE_SOURCE.read_text(encoding="utf-8"))

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

    def test_importer_keeps_recipe_boundaries(self):
        fixture = (
            'lib:LoadCore(171, {\n'
            '\t\t[2329] = {\n'
            '\t\t\t["reagents"] = { [765] = 1, [2449] = 2 },\n'
            '\t\t},\n'
            '\t\t[2331] = {\n'
            '\t\t\t["reagents"] = { [785] = 1 },\n'
            '\t\t},\n'
            '})'
        )
        self.assertEqual(g.extract_reagent_facts(fixture),
                         [(2329, 765), (2329, 2449), (2331, 785)])

    def test_recipe_source_has_valid_reagent_relationships(self):
        self.assertEqual(g.validate_recipe_uses(self.recipes, self.data, self.registry), [])
        self.assertEqual(len(self.recipes["uses"]), 8471)
        self.assertEqual(len({row[0] for row in self.recipes["uses"]}), 592)

    def test_recipe_relationship_validator_rejects_missing_source_relation(self):
        clone = dict(self.recipes)
        clone["uses"] = [list(row) for row in self.recipes["uses"]]
        clone["uses"].pop()
        self.assertEqual(
            g.validate_recipe_uses(clone, self.data, self.registry),
            ["missing 1 recipe source reagent relationships"],
        )

    def test_recipe_index_is_deterministic(self):
        expected = g.generate_recipe_uses(self.recipes, self.registry)
        self.assertEqual(g.RECIPE_TARGET.read_text(encoding="utf-8"), expected)
        self.recipes["uses"].reverse()
        self.assertEqual(g.generate_recipe_uses(self.recipes, self.registry), expected)

    def test_unique_recipe_compiler_and_source_consistency(self):
        grouped = g.group_recipe_catalog(self.recipes, self.registry)
        self.assertEqual(len(grouped), 2518)
        self.assertEqual(sum(len(value["inputs"]) for value in grouped.values()), 8471)
        self.assertEqual(
            g.RECIPES_TARGET.read_text(encoding="utf-8"),
            g.generate_recipes(self.recipes, self.registry),
        )
        for (profession, spell), value in grouped.items():
            self.assertTrue(profession and spell > 0)
            self.assertTrue(all(item > 0 and amount > 0 for item, amount in value["inputs"].items()))

    def test_unique_recipes_deterministic_after_reordering(self):
        first = g.generate_recipes(self.recipes, self.registry)
        self.recipes["uses"].reverse()
        self.assertEqual(g.generate_recipes(self.recipes, self.registry), first)

    def test_unique_recipe_conflicting_output_rejected(self):
        sample = list(self.recipes["uses"][0])
        same_recipe_new_input = [999999, sample[1], sample[2], 1, sample[4] + 1, sample[5]]
        changed = dict(self.recipes)
        changed["uses"] = self.recipes["uses"] + [same_recipe_new_input]
        with self.assertRaises(ValueError):
            g.group_recipe_catalog(changed, self.registry)

    def test_unique_recipe_duplicate_ingredient_rejected(self):
        changed = dict(self.recipes)
        changed["uses"] = self.recipes["uses"] + [list(self.recipes["uses"][0])]
        with self.assertRaises(ValueError):
            g.group_recipe_catalog(changed, self.registry)

    def test_recipe_ingredients_are_complete(self):
        # Cindercloth Cloak is a reagent in the Onyxia Scale Cloak recipe.
        grouped = g.group_recipe_catalog(self.recipes, self.registry)
        inputs = grouped[("LEATHERWORKING", 19093)]["inputs"]
        self.assertEqual(inputs[14044], 1)
        self.assertEqual(inputs[14341], 1)
        self.assertEqual(inputs[15410], 1)
        self.assertEqual(grouped[("LEATHERWORKING", 19093)]["output"], 15138)

    def test_cloak_is_valid_second_stage_reagent(self):
        cloak = [r for r in self.recipes["uses"] if r[0] == 14044]
        self.assertEqual(cloak, [[14044, 19093, "LEATHERWORKING", 1, 15138, "item"]])
        self.assertNotIn(15138, {r[0] for r in self.recipes["uses"]},
                         "crafted output alone does not make an item a reagent")

    def test_output_only_cannot_become_reagent(self):
        clone = dict(self.recipes)
        clone["uses"] = self.recipes["uses"] + [[15138, 19093, "LEATHERWORKING", 1, 15138, "item"]]
        self.assertTrue(g.validate_recipe_uses(clone, self.data, self.registry))

    def test_reject_bad_recipe_count_and_duplicate(self):
        clone = dict(self.recipes)
        clone["uses"] = [list(x) for x in self.recipes["uses"]]
        clone["uses"][0][3] = 0
        self.assertTrue(g.validate_recipe_uses(clone, self.data, self.registry))
        clone["uses"][0][3] = 2
        clone["uses"].append(list(clone["uses"][0]))
        self.assertTrue(g.validate_recipe_uses(clone, self.data, self.registry))

    def test_non_item_recipe_is_not_fabricated(self):
        enchanted = [x for x in self.recipes["uses"] if x[5] == "enchant"]
        self.assertTrue(enchanted)
        self.assertTrue(all(x[4] == 0 for x in enchanted))

    def test_imported_source_is_substantial(self):
        self.assertGreaterEqual(len(self.data["materials"]), 500)
        self.assertGreaterEqual(len(self.registry["professions"]), 10)

    def test_licensed_source_attribution(self):
        license_file = g.DATA / "LICENSE-LibProfessionDB.txt"
        self.assertIn("Pimptasty", license_file.read_text(encoding="utf-8"))
        for item in self.data["materials"]:
            for relation in item["relations"]:
                if relation["rights"] == "compatible-licensed-source":
                    self.assertTrue(relation["source"])
                    self.assertTrue(relation.get("recipeIDs"))

    def test_unknown_universe_has_no_completeness_claim(self):
        report = g.coverage_report(self.data, self.registry)
        self.assertIsNone(report["coveragePercent"])
        self.assertFalse(report["fullCoverageClaimAllowed"])


if __name__ == "__main__":
    unittest.main()
