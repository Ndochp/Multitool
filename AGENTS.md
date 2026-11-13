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
- **Use vrunner for all 1C launches** (tests, config update, compilation). Unica запускает 1C только через `unica_run` (push/launch/dump и т.п.), но для тестов и сборки здесь — vrunner. vrunner is at `C:\Users\Ndochp\AppData\Local\ovm\current\bin\vrunner.bat` (v3.0.0).
- vrunner 3.0 command syntax (differs from older `.cmd` scripts in repo root):
  - Load config: `vrunner cf load --ibcmd src/cf` — **всегда с опцией `--ibcmd`** (загрузка через утилиту `ibcmd` вместо конфигуратора; опция ставится до positional-пути). В MCP `cf_load` — тот же параметр `ibcmd: true`.
  - Load test extension: `vrunner cfe load tests/cfe/test`
  - Эквивалент загрузки конфигурации через Unica — `unica_run` op `push` (пуш source set'ов + применение конфигурации БД; обязателен сначала `dryRun: true`-preview; `force: true` перезаписывает БД без проверки поколения; отсутствие базы — `infobase.create`). Это не «cf load из каталога», а push декларированных source set'ов проекта.
  - Run tests: `vrunner test yaxunit --yaxunit-config tools/yaxunit.json`
  - **Каждый тест обязан быть зарегистрирован** в тестовом модуле в `Процедура ИсполняемыеСценарии() Экспорт` (`.ДобавитьТестовыйНабор(...).ДобавитьТест("ИмяМетода")`). Без регистрации тест молча не выполнится — счётчик «всего N» не изменится. Признак проблемы: junit-отчёт не содержит новых имён. Диагностика: `vrunner cfe decompile --extension-name test <каталог>` — выгрузит реальный модуль из ИБ, сравнить с исходником.
  - **Перед запуском YAxUnit всегда сперва проверка компиляции/синтаксиса**: `vrunner validate syntax-check` (в MCP — `validate_syntax_check`) или Unica (`unica_check`). Это не всегда помогает — обращения «через точку» (`НеизвестныйТип.Член`) проверяются плохо — но хоть так: непойманный дефект модуля даёт модальное окно и вечное зависание тестовой сессии.
- Config: `tools/yaxunit.json` — filters by extension `"test"`, runs in transaction mode (`ВТранзакции: true`)
- Reports/log to `build/out/yaxunit/`, exit code to `build/out/yaxunit/result.txt`

## vrunner MCP server (preferred for AI agents)
- Entry: `vrunner-mcp.bat` = `oscript <ovm>/lib/vanessa-runner/src/mcp.os` (stdio MCP server, built on `autumn-mcpify`).
- Register in `.mcp.json`: `{"mcpServers": {"vrunner": {"command": "oscript", "args": ["C:/Users/Ndochp/AppData/Local/ovm/current/lib/vanessa-runner/src/mcp.os"]}}}`. Run from project root.
- Tools = CLI subcommands marked `&ДоступноВMCP`, named by path with `_`: `cf_load`, `cfe_load`, `test_yaxunit`, `test_xunit`, `test_vanessa`, `validate_syntax_check`, `infobase_update`, `extensions_list`, `repo_*`, `cluster_*`, `task_status`, `task_result`, `task_cancel`, `cache_show`, `cache_clear`.
- `test_yaxunit` is `&MCPДлительная` → runs in background, returns `taskId`; poll with `task_status` / `task_result` (live log). Pass `background:false` (or `debug:true`) to run synchronously with streamed log — use this to diagnose launch issues.
- Session cache: options like `ibconnection` are remembered per session by name and auto-applied to later calls. Pass `nocache:true` for independent/parallel calls; inspect with `cache_show`, reset with `cache_clear`.
- `test_yaxunit` options: `yaxunit-config`, `ext`, `modules`, `tests`, `tags`, `suites`, `report`, `exitcode`, `show-report`, `no-close`, `no-wait`, `background`, `nocache`, `debug` + connection/platform options (`ibconnection`, `v8version`, `locale`, ...).
- Docs: `autumn-mcpify` README at `<ovm>/lib/vanessa-runner/oscript_modules/autumn-mcpify/README.md`; online: https://autumn-library.github.io/vanessa-runner

## Config files that matter
- **`autumn-properties.json`** (repo root) — settings for vrunner 3.0: `ibconnection` `/F./build/ib`, `v8version`, `locale`/`language`, vanessa paths. vrunner auto-loads it from the working directory, or pass `--settings <file>`. v3 does **not** read `env.json` or `tools/vrunner.json` (2.x-era, kept only for reference) — without this file vrunner silently creates a throwaway `v8r_TempDB`.
- **`.bsl-language-server.json`** — LSP diagnostics settings (line length, magic numbers, typos)

## Context optimization
- **Skill list abbreviation:** when the system skill reminder exceeds 30 entries, output only skills relevant to this repo (Unica MCP tools, code-diagnostics, meta-edit, form-edit, module-placement, object-events, form-events, form-compile, query-optimize, log-analysis, source-access, platform-help, interface-edit). Skip browser-use, computer-use, documents, pdf, presentations, spreadsheets, plugin-creator, skill-creator.
- **Unica MCP preferred:** use `mcp_plugin_unica_*` tools for all 1C configuration operations (view, search, apply, check, diff). They are more reliable than raw file reads for XML metadata.

## Gotchas
- `env.json` is legacy and gitignored — vrunner 3.0 ignores it; the live settings file is `autumn-properties.json` (committed at repo root)
- BSL has no `Массив.Сортировать()`/global `Сортировать()` — sort arrays manually (see `ОтсортироватьСтроки` in `ТаймлогиGitlab`)
- Source files use UTF-8 (`@chcp 65001` in all `.cmd` scripts)
- Токены шаблона `Формат` (`ДФ=`) чувствительны к регистру: день — строчные `д`/`дд`, год — `гггг`; заглавные `Д`/`Г` токенами не являются и выдаются литералом (заглавные `М`/`ММММ` — корректны). См. справку платформы «Форматная строка»
- Присваивание объекта ссылочного типа (`Справочники.Х.СоздатьЭлемент()`) типизированному реквизиту/свойству ТЧ не вызывает ошибки, но сохраняет пустое значение — присваивать `Элемент.Ссылка`
