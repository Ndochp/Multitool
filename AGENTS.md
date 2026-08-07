# AGENTS.md — Multitool (1C:Enterprise Toolkit)

## Repo at a glance
- **Platform:** 1С:Предприятие 8.3 (OneScript / BSL)
- **Template:** Vanessa-bootstrap (`vrunner` toolchain)
- **Source format:** XML metadata + `.bsl` files in `src/cf/`
- **Build output:** `build/` directory (`.cf`, extensions, external processors)
- **Test info base:** `build/ib` (local file-based DB)

## Commands (Windows cmd / PowerShell)
| Command | What it does |
|---------|-------------|
| `prepare.cmd` | One-time setup: builds config from `src/cf/`, creates test IB at `build/ib`, runs platform update sequence |
| `update.cmd` | Rebuilds config into `build/1cv8.cf`, loads extensions, pushes to `build/ib` (dev IB) |
| `build.cmd` | Compiles `src/cf/` → `build/1cv8.cf` only (no deploy) |
| `test.cmd` | Runs `update.cmd` then executes yaxUnit tests via `1cv8c.exe` against `build/ib` |
| `open.cmd` | Opens test IB in Enterprise mode (`vrunner run`) |
| `designer.cmd` | Opens test IB in Configurator mode (`vrunner designer --no-wait`) |

**Key detail:** `test.cmd` hardcodes the 1C compiler path: `"D:\Soft\1Cv8\8.3.27.2074\bin\1cv8c.exe"`. Change this if your platform version differs.

## Architecture
- **`src/cf/`** — Main configuration source (metadata objects as XML + `.bsl`). Contains ~1300 BSL files across Catalogs, DataProcessors, CommonModules, Documents, etc.
- **`src/cfe/`** — Configuration extensions (compiled to `build/`)
- **`src/epf/`** — External processors (compilable via `vrunner compileepf`)
- **`tests/cfe.test/`** — Test extension with yaxUnit test modules and mock HTTP connector
- **`tools/`** — Tool configs (`yaxunit.json`, `vrunner.json`, `VAParams.json`)

## Coding conventions (from `.bsl-language-server.json`)
- Line length: 150 chars max
- Magic numbers allowed: `-1, 0, 1, 60, 0.1`
- Magic indexes allowed
- Typo detection: min word length 4; ignore "Туду"
- Service tags pattern: `+++`, `todo`, `fixme`, `!!`, `mrg`, `@`, `отладка`, `debug`, `{}`, `MRG`, `Вставить содержимое обработчика`
- Diagnostics run on-save

## Integration architecture (from `doc/Agents/CodingRules.md`)
All integrations follow hexagonal architecture:
- **Domain layer:** Client processor operating on business entities (Employee, NomenclatureGroup, Task) — unaware of external API details
- **Adapters:** Transport (`КоннекторHTTP`), Auth, Serialization modules
- **Naming:** Processor = `Интеграция[ИмяСистемы]`, e.g. `ИнтеграцияGitlab`
- **Public methods** in `#Область ПрограммныйИнтерфейс`; internal in `#Область СлужебныеПроцедурыИФункции`
- **Auth pattern:** Token stored as processor property; `ВыполнитьЗапросСАвторизацией()` retries once on 401 with token refresh

## Testing
- Run: `test.cmd` (calls `update.cmd` then yaxUnit via `1cv8c.exe`)
- Config: `tests/yaxUnit.json` — filters by extension `"test"`, runs in non-transaction mode (`ВТранзакции: false`)
- Reports/log to `build/`, exit code to `build/yaxUnit.Res`
- Mock HTTP via `КоннекторHTTP` overloadable in test extensions

## Config files that matter
- **`env.json`** — IB connection string, DB credentials, platform version (`--v8version`), locale
- **`.bsl-language-server.json`** — LSP diagnostics settings (line length, magic numbers, typos)
- **`packagedef`** — OneScript package deps: `vanessa-automation-single`, `vanessa-runner`
- **`tools/JSON/vrunner.json`** — vrunner-specific config

## Gotchas
- `env.json` is gitignored; copy from `env.json.sample` if needed
- `test.cmd` uses a hardcoded 1C compiler path — adjust for your installation
- Source files use UTF-8 (`@chcp 65001` in all `.cmd` scripts)
- Test extensions compile separately: `vrunner compileext tests\cfe.test test` then `vrunner updateext test`
