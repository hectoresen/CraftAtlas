#!/usr/bin/env python3
"""Foundation-only check; not an in-game compatibility test."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    "README.md", "AGENTS.md", "CONTRIBUTING.md", "LICENSE",
    "CHANGELOG.md", "openspec/config.yaml", "openspec/README.md",
    "docs/ROADMAP.md", "docs/ARCHITECTURE.md", "docs/DATA_MODEL.md",
    "docs/INSTALLATION.md", "docs/DEVELOPMENT.md", "docs/TESTING.md",
    ".github/workflows/ci.yml", ".github/PULL_REQUEST_TEMPLATE.md",
    "addon/CraftAtlas/CraftAtlas.toc",
]
errors = []
for name in REQUIRED:
    path = ROOT / name
    if not path.is_file() or not path.read_text(encoding="utf-8").strip():
        errors.append(f"Missing or empty: {name}")
for path in ROOT.rglob("*.md"):
    if not path.read_text(encoding="utf-8").endswith("\n"):
        errors.append(f"Missing trailing newline: {path.relative_to(ROOT)}")
if "schema: spec-driven" not in (ROOT / "openspec/config.yaml").read_text(encoding="utf-8"):
    errors.append("OpenSpec schema should be spec-driven")
if errors:
    sys.exit("\n".join(errors))
print(f"OK: {len(REQUIRED)} foundation files and OpenSpec scaffold verified")
