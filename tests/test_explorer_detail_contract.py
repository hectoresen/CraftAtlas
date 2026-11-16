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

    def test_four_professions_fit_without_paging_and_title_is_centered(self):
        source = SETTINGS.read_text(encoding="utf-8")
        self.assertIn('for i = 1, 4 do', source)
        self.assertIn('local pageSize = ns.ExplorerProfessionPageSize(width)', source)
        self.assertIn('local first = (state.page - 1) * state.pageSize + 1', source)
        self.assertIn('math.ceil(#state.keys / state.pageSize)', source)
        self.assertIn('if state.section.expanded and pages > 1 then', source)
        self.assertIn('title:SetPoint("CENTER", header, "CENTER", 0, 0)', source)

    def test_release_footer_is_installed_only_and_02_source_is_dev(self):
        source = SETTINGS.read_text(encoding="utf-8")
        self.assertIn("ns.GetInstalledReleaseVersion(ns.name)", source)
        self.assertIn('caption:SetPoint("BOTTOMRIGHT"', source)
        manifest = (SETTINGS.parents[2] / "CraftAtlas.toc").read_text(encoding="utf-8")
        self.assertIn("## Version: 0.2.0-dev", manifest)
        self.assertNotIn("## Version: 0.2.0\\n", manifest)

    def test_profession_section_created_before_initial_material_refresh(self):
        source = SETTINGS.read_text(encoding="utf-8")
        self.assertIn("createProfessionDetail(right)", source)
        self.assertLess(source.index("createProfessionDetail(right)\n    ns.InitRecipePanel"),
                        source.index("    ui.itemListener = CreateFrame"))
        self.assertIn("ui.professionUses = state", source)


if __name__ == "__main__":
    unittest.main()
