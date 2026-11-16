"""Guard against unloaded or misordered Lua modules in CraftAtlas.toc."""
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "addon" / "CraftAtlas"


class TocModuleTests(unittest.TestCase):
    def test_registered_modules_exist_and_are_unique(self):
        entries = [
            line.strip()
            for line in (ADDON / "CraftAtlas.toc").read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.lstrip().startswith("##")
        ]
        self.assertEqual(len(entries), len(set(entries)), "Duplicate TOC modules")
        for entry in entries:
            self.assertTrue((ADDON / entry).is_file(), f"Unloaded/missing module: {entry}")

    def test_recipe_panel_loads_before_settings(self):
        toc = (ADDON / "CraftAtlas.toc").read_text(encoding="utf-8")
        self.assertIn("Features/Settings/RecipePanel.lua", toc)
        self.assertLess(
            toc.index("Features/Settings/RecipePanel.lua"),
            toc.index("Features/Settings/Settings.lua"),
            "Settings.lua requires ns.InitRecipePanel defined by RecipePanel.lua",
        )

    def test_configuration_panel_loads_between_shared_widgets_and_settings(self):
        toc = (ADDON / "CraftAtlas.toc").read_text(encoding="utf-8").splitlines()
        panel = toc.index("Features/Settings/PreferencesPanel.lua")
        self.assertLess(toc.index("Features/Settings/Shared/ExplorerWidgets.lua"), panel)
        self.assertLess(panel, toc.index("Features/Settings/Settings.lua"))


if __name__ == "__main__":
    unittest.main()
