#!/usr/bin/env python3
"""Print the audited offline coverage summary."""
import json
from build_materials import COVERAGE

if __name__ == "__main__":
    print(json.dumps(json.loads(COVERAGE.read_text(encoding="utf-8")), indent=2, ensure_ascii=False))
