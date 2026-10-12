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
- **Use vrunner for all 1C launches** (tests, config update, compilation). Unica MCP does not run 1C. vrunner is at `C:\Users\Ndochp\AppData\Local\ovm\current\bin\vrunner.bat` (v3.0.0).
- vrunner 3.0 command syntax (differs from older `.cmd` scripts in repo root):
  - Load config: `vrunner cf load src/cf`
  - Load test extension: `vrunner cfe load tests/cfe/test`
  - Run tests: `vrunner test yaxunit --yaxunit-config tools/yaxunit.json`
- Config: `tools/yaxunit.json` — filters by extension `"test"`, runs in transaction mode (`ВТранзакции: true`)
- Reports/log to `build/out/yaxunit/`, exit code to `build/out/yaxunit/result.txt`

## Config files that matter
- **`env.json`** — IB connection string, DB credentials, platform version (`--v8version`), locale
- **`.bsl-language-server.json`** — LSP diagnostics settings (line length, magic numbers, typos)

## Context optimization
- **Skill list abbreviation:** when the system skill reminder exceeds 30 entries, output only skills relevant to this repo (Unica MCP tools, code-diagnostics, meta-edit, form-edit, module-placement, object-events, form-events, form-compile, query-optimize, log-analysis, source-access, platform-help, interface-edit). Skip browser-use, computer-use, documents, pdf, presentations, spreadsheets, plugin-creator, skill-creator.
- **Unica MCP preferred:** use `mcp_plugin_unica_*` tools for all 1C configuration operations (view, search, apply, check, diff). They are more reliable than raw file reads for XML metadata.

## Gotchas
- `env.json` is gitignored; copy from `env.json.sample` if needed
- Source files use UTF-8 (`@chcp 65001` in all `.cmd` scripts)
