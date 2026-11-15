#!/usr/bin/env bash
# Single release-readiness gate shared by PR CI and manual GitHub Releases.
set -euo pipefail

python3 scripts/validate_repo.py
python3 -m unittest discover -s tests -p 'test_material_data.py' -v
python3 scripts/build_materials.py --check
python3 -m unittest discover -s tests -p 'test_package_release.py' -v
