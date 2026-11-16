"""Contracts for catalog preparation, cache invalidation and native header placement."""
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "addon" / "CraftAtlas"


def source(path):
    return (ROOT / path).read_text(encoding="utf-8")


class CatalogPreparationContracts(unittest.TestCase):
    def test_real_progress_for_both_views(self):
        item = source("Infrastructure/ItemInfo.lua")
        recipe = source("Infrastructure/RecipeNameCache.lua")
        domain = source("Domain/CatalogProgress.lua")
        self.assertIn("ns.NewCatalogProgress(#ids)", item)
        self.assertIn("ns.NewCatalogProgress(#records)", recipe)
        self.assertIn("ns.AdvanceCatalogProgress", item)
        self.assertIn("ns.AdvanceCatalogProgress", recipe)
        self.assertIn("math.floor(100 *", domain)
        self.assertNotIn('GetTime() - started', domain)
        self.assertIn("ns.StopCatalogProgress", item)
        self.assertIn("ns.StopCatalogProgress", recipe)
        self.assertIn("started = true", item)
        self.assertIn("if started then return end", recipe)

    def test_refresh_is_coalesced_not_direct_per_batch(self):
        item = source("Infrastructure/ItemInfo.lua")
        recipe = source("Infrastructure/RecipeNameCache.lua")
        settings = source("Features/Settings/Settings.lua")
        self.assertNotIn("ns.RefreshMaterialResults()", item)
        self.assertNotIn("ns.RefreshExplorer()", recipe)
        self.assertIn("ns.MarkCatalogRefreshDirty(refreshGate)", settings)
        self.assertIn("ns.ConsumeCatalogRefresh(refreshGate)", settings)
        self.assertIn("pcall(timer, 0.4, flush)", settings)
        self.assertIn("catalogGenerations.materials = catalogGenerations.materials + 1", settings)
        self.assertIn("catalogGenerations.recipes = catalogGenerations.recipes + 1", settings)
        self.assertIn("cache.generation == catalogGenerations[currentView]", settings)
        self.assertIn("cache.locale == locale", settings)
        self.assertIn("cache.query == searchQuery", settings)
        self.assertIn("cache.profession == selectedProfession", settings)

    def test_header_uses_native_progress_with_locales(self):
        settings = source("Features/Settings/Settings.lua")
        widgets = source("Features/Settings/Shared/ExplorerWidgets.lua")
        locale = source("Localization/Locales.lua")
        toc = source("CraftAtlas.toc")
        self.assertIn("CreateExplorerCatalogProgress(panel, recipesTab, back)", settings)
        self.assertIn('title:SetPoint("CENTER", header, "CENTER", 0, 0)', settings)
        self.assertIn('local bar = CreateFrame("StatusBar", nil, holder)', widgets)
        self.assertIn('holder:SetPoint("LEFT", recipesTab, "RIGHT", 12, 0)', widgets)
        self.assertIn('holder:SetPoint("RIGHT", back, "LEFT", -12, 0)', widgets)
        self.assertIn('holder:SetHeight(20)', widgets)
        self.assertIn('label:SetPoint("CENTER", holder, "CENTER", 0, 0)', widgets)
        self.assertIn('track:SetColorTexture(0.055, 0.048, 0.039, 0.94)', widgets)
        self.assertIn("CATALOG_PREPARING_MATERIALS", locale)
        self.assertIn("CATALOG_PREPARING_CRAFTABLES", locale)
        self.assertIn("CATALOG_PREPARATION_PAUSED", locale)
        self.assertIn("Domain/CatalogProgress.lua", toc)
        self.assertNotIn("## Version: 0.3.0\n", toc)

    def test_no_generated_catalog_or_external_telemetry(self):
        module = source("Domain/CatalogProgress.lua")
        self.assertNotIn("CreateFrame", module)
        self.assertNotIn("C_Timer", module)
        self.assertNotIn("SendAddonMessage", module)
        self.assertNotIn("HTTP", module)


if __name__ == "__main__":
    unittest.main()
