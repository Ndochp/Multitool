# Проверка ЛУРВ по UC-00 через UNICA — 2026-10-02

Проверка документа «Лист учета рабочего времени» (ЛУРВ) по сценарию
[UC-00](Таймтрекинг.md) средствами UNICA 0.13.0-rc.3 (MCP: `unica.view`,
`unica.check`, `unica.run`, `unica.docs`).

## Подготовка рабочего пространства (выполнено, в git)

- `v8project.yaml` — конфигурация UNICA: source-set `main` (src/cf,
  CONFIGURATION) и `test` (tests/cfe/test, EXTENSION), ИБ `origin`
  (File=build/ib).
- `.gitattributes` — `*.gif -text`; XDTO `Package.bin` объявлены текстом
  (`src/cf/XDTOPackages/*/Ext/Package.bin text eol=crlf`).
- `.gitignore` — добавлены `.build/`, `DumpFilesIndex.txt`.
- Перенормализованы 11 текстовых блобов XDTO Package.bin (LF в индексе).
- `unica.check {}` → workspace ready, `repositoryReady: true`.

Коммиты: e19d52d1, 5fcf30e3.

## Результаты проверок узлов

| Узел | Валидатор | Итог |
| --- | --- | --- |
| `main:Document.ЛУРВ` | meta | ✅ passed, 0 diagnostics |
| `main:Document.ЛУРВ.Form.ФормаДокумента` | form | ❌ **failed: 1 error** |
| `test:CommonModule.тест_ЛУРВ` | bsl | ⛔ provider_unavailable (см. ниже) |

### Найденный дефект: команда «Отправить» без Action

`unica.check` формы: `[ERROR] Command 'Отправить': missing or empty Action`.

Подтверждено по исходникам:
`src/cf/Documents/ЛУРВ/Forms/ФормаДокумента/Ext/Form.xml:474` — команда
`Отправить` (id=5) объявлена **без `<Action>`**; обработчик
`Отправить(Команда)` при этом есть в
`src/cf/Documents/ЛУРВ/Forms/ФормаДокумента/Ext/Form/Module.bsl:148`
(заглушка «будет реализована в задачах синхронизации»). Кнопка
`ОтчетЗаДеньОтправить` (Form.xml:129) ссылается на команду, но действие
не привязано — обработчик не вызовется. Нужно либо добавить
`<Action>Отправить</Action>`, либо убрать команду/кнопку до реализации.

## Покрытие UC-00 тестами

Тестовый модуль `тест_ЛУРВ` (tests/cfe/test) покрывает шаги UC-00:
ЛУР-001..004, ЛУР-009..012, ЛУР-014, ЛУР-015 (35 тестов, наборы по задачам
плана). Запуск тестов — вне поверхности UNICA v0.13 (см. «Ограничения»).

## Ограничения UNICA v0.13 (по контракту)

1. **Прогон yaxUnit/Vanessa не входит в словарь `unica.run`** — только
   синтаксические проверки `unica.check`. Обход контракта прямым раннером
   запрещён правилами UNICA.
2. **BSL-диагностика (`unica.check` модулей) недоступна в автономном
   запуске unica.exe**: провайдер BSL-анализа поднимается хостом
   (ZCode-плагин передаёт host-context / состояние демона). Автономные
   вызовы дают `provider_unavailable: BSL analysis did not complete`.
   Движки bsl-analyzer 0.2.67 и v8-runner 0.11.2 установлены
   (unica-bootstrap prefetch, sha256 сверены) — дело в контексте хоста,
   не в отсутствии движков.

## Открытые вопросы

1. Прогон yaxUnit-тестов ЛУРВ: запускать вне UNICA (vrunner/yaxunit) или
   через mcp-1c-platform-tools?
2. Дефект команды «Отправить»: чинить через unica:form-edit или отложить
   до задач синхронизации (ЛУР-013)?
3. BSL-диагностика модулей ЛУРВ и тест_ЛУРВ: выполнить в сессии с
   подключённым UNICA MCP (хост-контекст) — требует перезапуска сессии
   с активным MCP-сервером unica.
