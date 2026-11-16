"""Guard the native profession-section migration against stale frame references."""
import unittest
from pathlib import Path

SETTINGS = (Path(__file__).resolve().parents[1] / "addon" / "CraftAtlas"
            / "Features" / "Settings" / "Settings.lua")


class DetailSectionContractTests(unittest.TestCase):
    def test_opening_material_detail_uses_existing_profession_section(self):
        source = SETTINGS.read_text(encoding="utf-8")
        detail = source.split("local function showDetail()", 1)[1].split(
            "local function updateRows()", 1
        )[0]
        self.assertNotIn("ui.detailHeading", detail)
        self.assertNotIn("ui.detailProfessions", detail)
        self.assertIn("ui.professionUses.section:Refresh()", detail)
        self.assertIn("professionState.keys = keys", detail)
        self.assertIn("refreshProfessionDetail()", detail)

    def test_profession_section_created_before_initial_material_refresh(self):
        source = SETTINGS.read_text(encoding="utf-8")
        self.assertIn("createProfessionDetail(right)", source)
        self.assertLess(source.index("createProfessionDetail(right)\n    ns.InitRecipePanel"),
                        source.index("    ui.itemListener = CreateFrame"))
        self.assertIn("ui.professionUses = state", source)


if __name__ == "__main__":
    unittest.main()
