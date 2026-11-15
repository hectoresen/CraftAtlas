# Development setup

Requirements for foundation: Git, Python 3.11+, optional Node.js + OpenSpec CLI, optional OpenCode; later Lua 5.1/Luacheck/LuaUnit as implementation tests are added.

```sh
git clone https://github.com/hectoresen/CraftAtlas.git
cd CraftAtlas
python3 scripts/validate_repo.py
npm install -g @fission-ai/openspec@latest
# If agent skills are not yet installed locally:
openspec init
```

OpenSpec change: propose → review → approve → apply → test → verify/sync/archive → PR. Use `/opsx:propose` and `/opsx:apply` in OpenCode after the official integration has been installed.

Branch patterns: feat/*, fix/*, chore/*, docs/*. Write code/docs in English, locale strings in esES and enUS.

For a future working addon, load source files from its `.toc` in dependency order. Do not write production game logic until an approved spec and an actual Forever API compatibility plan exist. Run the actual Forever client smoke tests in `docs/TESTING.md` for game-facing changes.

## First playable development workflow

Run the in-repository tests from the project root:

```sh
python3 scripts/validate_repo.py
python3 -m unittest discover -s tests -p 'test_material_data.py' -v
python3 scripts/build_materials.py --check
texlua tests/test_addon.lua
```

The Lua tests use a small local fixture (never substitute that fixture for
production material relations). Rebuild the catalog from the audited JSON:
`python3 scripts/build_materials.py`. Full release must additionally pass
`python3 scripts/build_materials.py --release --check`, official OpenSpec
validation, and the actual client matrix. Do not infer Forever compatibility
from mocks or automatically passing foundation CI.
