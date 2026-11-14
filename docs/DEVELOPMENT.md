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
