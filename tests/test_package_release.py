"""Tests for minimal, directly installable GitHub Release ZIPs."""
import importlib.util
import tempfile
import unittest
import zipfile
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/package_release.py"
spec = importlib.util.spec_from_file_location("package_release", SCRIPT)
release = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release)


class ReleasePackagingTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.addon = self.root / "CraftAtlas"
        (self.addon / "Core").mkdir(parents=True)
        (self.addon / "Data").mkdir()
        (self.addon / "Core/Init.lua").write_text("print('ok')\n")
        (self.addon / "Data/LICENSE-LibProfessionDB.txt").write_text("MIT attribution\n")
        (self.addon / "Data/materials.source.json").write_text("{}")
        self.toc = self.addon / "CraftAtlas.toc"
        self.toc.write_text("## Interface: 16001\n## Version: 0.1.0-dev\nCore/Init.lua\n")
        self.out = self.root / "release.zip"

    def test_initial_version_and_semver_increments(self):
        self.assertEqual(release.next_version([], "patch"), "0.1.0")
        self.assertEqual(release.next_version(["v0.1.0"], "patch"), "0.1.1")
        self.assertEqual(release.next_version(["v0.1.0"], "minor"), "0.2.0")
        self.assertEqual(release.next_version(["v0.1.0"], "major"), "1.0.0")
        self.assertEqual(release.next_version(["other", "v0.3.0", "v0.2.9"], "patch"), "0.3.1")

    def test_invalid_version_or_increment_rejected(self):
        for invalid in ("0.1.0-dev", "01.2.0", "1.2", "1.2.3.4"):
            with self.subTest(version=invalid), self.assertRaises(ValueError):
                release.package(invalid, self.out, self.addon)
        with self.assertRaises(ValueError):
            release.next_version(["v0.1.0"], "nonsense")

    def test_installable_layout_and_exclusions(self):
        release.package("0.1.0", self.out, self.addon)
        with zipfile.ZipFile(self.out) as archive:
            self.assertEqual(set(archive.namelist()), {
                "CraftAtlas/CraftAtlas.toc",
                "CraftAtlas/Core/Init.lua",
                "CraftAtlas/Data/LICENSE-LibProfessionDB.txt",
            })
            self.assertIn(b"## Version: 0.1.0\n", archive.read("CraftAtlas/CraftAtlas.toc"))
            self.assertNotIn(b"-dev", archive.read("CraftAtlas/CraftAtlas.toc"))
        self.assertIn("0.1.0-dev", self.toc.read_text())

    def test_missing_runtime_file_is_rejected(self):
        (self.addon / "Core/Init.lua").unlink()
        with self.assertRaisesRegex(ValueError, "Missing runtime dependency"):
            release.package("0.1.0", self.out, self.addon)

    def test_missing_attribution_is_rejected(self):
        (self.addon / "Data/LICENSE-LibProfessionDB.txt").unlink()
        with self.assertRaisesRegex(ValueError, "Missing runtime dependency"):
            release.package("0.1.0", self.out, self.addon)

    def test_traversal_and_absolute_entries_rejected(self):
        for entry in ("../bad.lua", "/tmp/bad.lua", "Core/../../bad.lua",
                      "Core/bad.txt", "Core/evil;echo.lua"):
            with self.subTest(entry=entry):
                self.toc.write_text("## Version: 0.1.0-dev\n" + entry + "\n")
                with self.assertRaisesRegex(ValueError, "Unsafe"):
                    release.package("0.1.0", self.out, self.addon)

    def test_duplicate_entries_rejected(self):
        self.toc.write_text("## Version: 0.1.0-dev\nCore/Init.lua\nCore/Init.lua\n")
        with self.assertRaisesRegex(ValueError, "Duplicate"):
            release.package("0.1.0", self.out, self.addon)

    def test_empty_or_missing_version_rejected(self):
        self.toc.write_text("## Version: 0.1.0-dev\n")
        with self.assertRaisesRegex(ValueError, "No runtime"):
            release.package("0.1.0", self.out, self.addon)
        self.toc.write_text("Core/Init.lua\n")
        with self.assertRaisesRegex(ValueError, "Version"):
            release.package("0.1.0", self.out, self.addon)

    def test_output_is_reproducible(self):
        release.package("0.2.0", self.out, self.addon)
        expected = self.out.read_bytes()
        release.package("0.2.0", self.out, self.addon)
        self.assertEqual(self.out.read_bytes(), expected)

    def test_real_addon_manifest_is_complete(self):
        paths = release.runtime_files()
        self.assertGreater(len(paths), 3)
        self.assertEqual(paths[0], "CraftAtlas.toc")
        self.assertIn("Data/LICENSE-LibProfessionDB.txt", paths)
        self.assertNotIn("Data/materials.source.json", paths)


if __name__ == "__main__":
    unittest.main()
