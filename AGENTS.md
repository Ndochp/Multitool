# AGENTS.md — Multitool (1C:Enterprise Toolkit)

## Repo at a glance
- **Platform:** 1С:Предприятие 8.3 (OneScript / BSL)
- **Template:** Vanessa-bootstrap (`vrunner` toolchain)
- **Source format:** XML metadata + `.bsl` files in `src/`
- **Build output:** `build/` directory (`.cf`, extensions, external processors)
- **Test info base:** `build/ib` (local file-based DB)
- **Slills for AI:** `.cline\skills`

## Coding rules
1. Never edit XML directly; use skills, MCP, or ask the user with a description of adding the required attributes or metadata.
2. Write according to 1C standards (which you know, or are available in skills or MCP).
3. Do not launch the 1C platform directly. For any operations (running tests, compilation, configuration update), use MCP tools: mcp-1c-platform-tools or unica, or invoke skills.
4. Decompose the task into small functions. Write code top-down: first define high-level steps, then implement each step as a separate function. Mark unfinished steps with comments.
5. Follow hexagonal architecture principles for separation of code responsibilities.
6. Follow DDD for separating functionality by subsystems.


## Architecture
- **`src/cf/`** — Main configuration source (metadata objects as XML + `.bsl`). Contains ~1300 BSL files across Catalogs, DataProcessors, CommonModules, Documents, etc.
- **`src/cfe/`** — Configuration extensions (compiled to `build/`)
- **`src/epf/`** — External processors (compilable via `vrunner compileepf`)
- **`tests/cfe/test/`** — Test extension with yaxUnit test modules and mock HTTP connector
- **`tools/`** — Tool configs (`yaxunit.json`, `vrunner.json`, `VAParams.json`)

## Coding conventions 
- look to `.bsl-language-server.json`

## Testing
- use mcp-1c-platform-tools for running tests and getting results
- Config: `tests/yaxUnit.json` — filters by extension `"test"`, runs in non-transaction mode (`ВТранзакции: false`)
- Reports/log to `build/`, exit code to `build/yaxUnit.Res`

## Config files that matter
- **`env.json`** — IB connection string, DB credentials, platform version (`--v8version`), locale
- **`.bsl-language-server.json`** — LSP diagnostics settings (line length, magic numbers, typos)

## Gotchas
- `env.json` is gitignored; copy from `env.json.sample` if needed
- Source files use UTF-8 (`@chcp 65001` in all `.cmd` scripts)
