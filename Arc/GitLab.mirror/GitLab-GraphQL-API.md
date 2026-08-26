# GitLab TimeLog: GraphQL API

## Описание

Данный документ описывает функции работы с GitLab GraphQL API (v4) для обработки `ИнтеграцияGitlab`. 
API GraphQL предоставляет более гибкий способ получения данных по сравнению с REST API, позволяя запрашивать 
только необходимые поля и избегать множественных запросов.

## Сравнение REST vs GraphQL

| Характеристика | REST API | GraphQL API |
|----------------|----------|-------------|
| Эндпоинт | `/api/v4/...` | `https://gitlab.com/api/graphql` |
| Метод HTTP | GET/POST | POST только |
| Формат запроса | URL параметры | JSON body с query/mutation |
| Гибкость выбора полей | Фиксированные эндпоинты | Произвольный выбор полей |
| Множественные ресурсы | Несколько запросов | Один запрос |
| Аутентификация | PRIVATE-TOKEN заголовок | PRIVATE-TOKEN заголовок |

## GraphQL Query (Запросы данных)

### GQL-Q001: QueryTimelogovПользователя — Получение таймлогов пользователя за период

**Назначение:** Получить все записи времени (time entries) конкретного пользователя за указанный период.

**GraphQL Query:**
```graphql
query GetUserTimeEntries($userId: ID!, $cursor: String, $first: Int!) {
  user(username: "username_placeholder") {
    timeEntries(first: $first, after: $cursor) {
      nodes {
        id
        duration
        message
        label
        spentAt
        createdAt
        updatedAt
        project {
          id
          name
          pathWithNamespace
          webUrl
        }
        issue {
          id
          iid
          title
          state
          webUrl
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
```

**Параметры запроса:**
| Параметр | Тип | Описание |
|----------|-----|----------|
| userId | ID | Идентификатор пользователя в GitLab |
| cursor | String | Курсор для пагинации (если используется) |
| first | Int | Количество записей для получения (макс. 100) |

**Возвращаемые данные (JSON → ТаблицаЗначений):**
| Колонка | Тип | Описание |
|---------|-----|----------|
| timeentry_id | Число | Уникальный ID записи времени |
| duration | Число | Длительность в секундах |
| message | Строка | Сообщение/описание работы |
| label | Строка | Метка (тег) записи |
| spent_at | Дата | Дата выполненной работы |
| project_id | Число | ID проекта |
| project_name | Строка | Название проекта |
| project_path | Строка | Путь к проекту (namespace/project) |
| project_web_url | Строка | URL проекта |
| issue_id | Число | ID задачи (если есть) |
| issue_iid | Число | Внутренний IID задачи |
| issue_title | Строка | Название задачи |
| issue_state | Строка | Статус задачи (opened/closed/merged) |
| issue_web_url | Строка | URL задачи |

**Функция-обёртка в обработке:**
```bsl
// ПолучитьТаймлогиПользователяGraphQL(ПользовательID, ПериодНач, ПериодКон, Параллельно=False)
// Возвращает: ТаблицаЗначений
```

---

### GQL-Q002: QueryПроектовПользователя — Получение проектов пользователя

**Назначение:** Получить все проекты, доступные пользователю (членство, участие).

**GraphQL Query:**
```graphql
query GetUserProjects($userId: ID!, $cursor: String, $first: Int!) {
  user(username: "username_placeholder") {
    projects(first: $first, after: $cursor, includeAllNamespaces: true) {
      nodes {
        id
        name
        pathWithNamespace
        description
        webUrl
        url
        archived
        visibility
        defaultBranchName
        createdAt
        updatedAt
        lastActivityAt
        statistics {
          repositorySize
          wikiSize
          storageStorageSize
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
```

**Параметры запроса:**
| Параметр | Тип | Описание |
|----------|-----|----------|
| userId | ID | Идентификатор пользователя в GitLab |
| cursor | String | Курсор для пагинации |
| first | Int | Количество проектов (макс. 100) |

**Возвращаемые данные:**
| Колонка | Тип | Описание |
|---------|-----|----------|
| project_id | Число | Уникальный ID проекта |
| project_name | Строка | Название проекта |
| project_path | Строка | Полный путь (namespace/project) |
| description | Строка | Описание проекта |
| web_url | Строка | URL проекта в веб-интерфейсе |
| api_url | Строка | URL API проекта |
| archived | Булево | Архивирован ли проект |
| visibility | Строка | Видимость (PRIVATE/INTERNAL/PUBLIC) |
| default_branch | Строка | Ветку по умолчанию |

**Функция-обёртка в обработке:**
```bsl
// ПолучитьПроектыПользователяGraphQL(ПользовательID, Параллельно=False)
// Возвращает: ТаблицаЗначений
```

---

### GQL-Q003: QueryЗадачПользователя — Получение задач пользователя

**Назначение:** Получить задачи (Issues/MergeRequests), назначенные пользователю, с фильтрацией по статусу.

**GraphQL Query:**
```graphql
query GetUserAssignedIssues($userId: ID!, $state: IssueState!, $cursor: String, $first: Int!) {
  user(username: "username_placeholder") {
    issues(first: $first, after: $cursor, states: $state) {
      nodes {
        id
        iid
        title
        description
        state
        stateReason
        createdAt
        updatedAt
        closedAt
        closedBy {
          username
        }
        author {
          username
          name
        }
        assignees(first: 10) {
          nodes {
            id
            username
            name
          }
        }
        project {
          id
          name
          pathWithNamespace
          webUrl
        }
        labels(first: 20) {
          nodes {
            id
            name
            description
            color
          }
        }
        timeStats {
          timeSpent
          totalTimeSpent
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
```

**Параметры запроса:**
| Параметр | Тип | Описание |
|----------|-----|----------|
| userId | ID | Идентификатор пользователя в GitLab |
| state | IssueState | Статус: OPENED, CLOSED, MERGED |
| cursor | String | Курсор для пагинации |
| first | Int | Количество задач (макс. 100) |

**Возвращаемые данные:**
| Колонка | Тип | Описание |
|---------|-----|----------|
| issue_id | Число | Уникальный ID задачи |
| issue_iid | Число | Внутренний IID задачи в проекте |
| title | Строка | Название задачи |
| description | Строка | Описание задачи |
| state | Строка | Статус (OPENED/CLOSED/MERGED) |
| created_at | DateTime | Дата создания |
| updated_at | DateTime | Дата обновления |
| closed_at | DateTime | Дата закрытия |
| author_username | Строка | Логин автора |
| project_id | Число | ID проекта |
| project_name | Строка | Название проекта |
| project_path | Строка | Путь к проекту |
| project_web_url | Строка | URL проекта |

**Функция-обёртка в обработке:**
```bsl
// ПолучитьЗадачиПользователяGraphQL(ПользовательID, Состояние, Параллельно=False)
// Возвращает: ТаблицаЗначений
// Состояние: "Открытые", "Закрытые", "Все"
```

---

### GQL-Q004: QueryВсехЗадачПроекта — Получение всех задач проекта

**Назначение:** Получить задачи конкретного проекта с фильтрацией по автору/назначенному.

**GraphQL Query:**
```graphql
query GetProjectIssues($projectId: ID!, $authorUsername: String, $assigneeUsername: String, 
                       $state: IssueState!, $cursor: String, $first: Int!) {
  resource(url: "https://gitlab.com/project_path_placeholder") {
    ... on Project {
      id
      name
      pathWithNamespace
      issues(first: $first, after: $cursor, state: $state, authorUsername: $authorUsername, 
              assigneeUsername: $assigneeUsername) {
        nodes {
          id
          iid
          title
          state
          description
          webUrl
          createdAt
          updatedAt
          author { username name }
          assignees(first: 10) {
            nodes { id username name }
          }
          labels(first: 20) {
            nodes { id name color }
          }
        }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}
```

**Функция-обёртка в обработке:**
```bsl
// ПолучитьЗадачиПроектаGraphQL(ПутьКПроекту, Состояние, Автор, Назначенный, Параллельно=False)
// Возвращает: ТаблицаЗначений
```

---

### GQL-Q005: QueryВремениПоЗадаче — Получение статистики времени по задаче

**Назначение:** Получить детальную статистику затраченного времени по конкретной задаче.

**GraphQL Query:**
```graphql
query GetIssueTimeStats($projectId: ID!, $issueIid: Int!) {
  project(fullPath: "project_path_placeholder") {
    id
    issues(iid: $issueIid) {
      nodes {
        id
        iid
        title
        timeStats {
          timeSpent
          totalTimeSpent
        }
        timeEntries(first: 100) {
          nodes {
            id
            duration
            message
            spentAt
            user { username name }
          }
          pageInfo { hasNextPage endCursor }
        }
      }
    }
  }
}
```

**Функция-обёртка в обработке:**
```bsl
// ПолучитьСтатистикуВремениЗадачиGraphQL(ПутьКПроекту, IssueIID)
// Возвращает: ТаблицаЗначений (таймлоги задачи) + Структура (статистика)
```

---

## GraphQL Mutation (Изменение данных)

### GQL-M001: MutationДобавленияTimelog — Создание записи времени

**Назначение:** Создать новую запись затраченного времени на задаче или проекте.

**GraphQL Mutation:**
```graphql
mutation CreateTimeEntry($projectId: ID!, $issueId: ID, $duration: Duration!, $spentAt: Date!, 
                         $message: String) {
  createTimeEntry(input: { projectId: $projectId, issueId: $issueId, duration: $duration, 
                          spentAt: $spentAt, note: $message }) {
    timeEntry {
      id
      duration
      message
      spentAt
      project {
        id
        name
        pathWithNamespace
      }
      issue {
        id
        iid
        title
      }
    }
    errors
  }
}
```

**Параметры:**
| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| projectId | ID | Да | ID проекта в GitLab (в формате GraphQL ID) |
| issueId | ID | Нет | ID задачи (Issue). Если не указан — время записывается на проект |
| duration | Duration | Да | Длительность в ISO 8601 формате (P1DT2H30M = 1 день 2 часа 30 мин) |
| spentAt | Date | Да | Дата выполнения работы (YYYY-MM-DD) |
| message | String | Нет | Описание выполненной работы |

**Формат Duration в GraphQL:** ISO 8601 период: `P[n]DT[n]H[n]M[n]S` или `P[n]W`

**Возвращаемые данные:**
- `timeEntry.id` — созданный ID записи времени
- `timeEntry.duration` — установленная длительность
- `errors` — массив ошибок (если есть)

**Функция-обёртка в обработке:**
```bsl
// ДобавитьTimelogGraphQL(ПроектID, IssueIIDИлиNull, ДлительностьВСекундах, ДатаРаботы, Описание="")
// Возвращает: Число (ID созданной записи) или 0 при ошибке
```

---

### GQL-M002: MutationОбновленияTimelog — Обновление записи времени

**Назначение:** Изменить существующую запись затраченного времени.

**GraphQL Mutation:**
```graphql
mutation UpdateTimeEntry($timeEntryId: ID!, $duration: Duration, $message: String) {
  updateTimeEntry(input: { id: $timeEntryId, duration: $duration, note: $message }) {
    timeEntry {
      id
      duration
      message
      spentAt
    }
    errors
  }
}
```

**Параметры:**
| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| timeEntryId | ID | Да | ID записи времени для обновления |
| duration | Duration | Нет | Новая длительность (если не указан — без изменений) |
| message | String | Нет | Новое описание (если не указан — без изменений) |

**Функция-обёртка в обработке:**
```bsl
// ОбновитьTimelogGraphQL(TimelogID, ДлительностьВСекундахИлиNull, ОписаниеИлиNull)
// Возвращает: Булево (True при успехе)
```

---

### GQL-M003: MutationУдаленияTimelog — Удаление записи времени

**Назначение:** Удалить существующую запись затраченного времени.

**GraphQL Mutation:**
```graphql
mutation DeleteTimeEntry($timeEntryId: ID!) {
  deleteTimeEntry(input: { id: $timeEntryId }) {
    deletedTimeEntryId
    errors
  }
}
```

**Параметры:**
| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| timeEntryId | ID | Да | ID записи времени для удаления |

**Возвращаемые данные:**
- `deletedTimeEntryId` — ID удалённой записи
- `errors` — массив ошибок (если есть)

**Функция-обёртка в обработке:**
```bsl
// УдалитьTimelogGraphQL(TimelogID)
// Возвращает: Булево (True при успехе)
```

---

### GQL-M004: MutationСозданияЗадачи — Создание задачи (Issue)

**Назначение:** Создать новую задачу в проекте GitLab.

**GraphQL Mutation:**
```graphql
mutation CreateIssue($projectId: ID!, $title: String!, $description: String, 
                     $assigneeIds: [ID!], $labelNames: [String!]) {
  createIssue(input: { projectId: $projectId, title: $title, description: $description, 
                      assigneeIds: $assigneeIds, labelNames: $labelNames }) {
    issue {
      id
      iid
      title
      state
      webUrl
    }
    errors
  }
}
```

**Функция-обёртка в обработке:**
```bsl
// СоздатьЗадачуGraphQL(ПроектID, Название, Описание=Null, Назначенные=ПустойМассив(), Метки=ПустойМассив())
// Возвращает: Структура с ID/IID созданной задачи или Null при ошибке
```

---

## HTTP-методы интеграции (Коннектор GraphQL)

### GQL-H001: ВыполнитьGraphQLЗапрос — Базовый метод выполнения запросов

**Назначение:** Отправить GET/POST запрос к GitLab GraphQL API и получить результат.

**Подписи методов:**
```bsl
// ВыполнитьGraphQLЗапрос(ТекстЗапроса, ПараметрыЗапроса, ТипЗапроса="Query")
// Возвращает: Структура или ТаблицаЗначений
// ПараметрыЗапроса: Структура с параметрами GraphQL запроса
// ТипЗапроса: "Query" | "Mutation"

// ВыполнитьGraphQLПолучить(URLЗапроса, Заголовки)
// Возвращает: Структура (JSON-объект ответа)

// ВыполнитьGraphQLОтправить(URLЗапроса, ТелоЗапроса, Заголовки)
// Возвращает: Структура (JSON-объект ответа)
```

**Реализация:**
```bsl
// Внутренний метод для выполнения GraphQL запросов
Функция ВыполнитьGraphQLЗапрос(ТекстЗапроса, ПараметрыЗапроса, ТипЗапроса="Query")
    
    // Формирование полного GraphQL запроса
    ПолныйЗапрос = ТекстЗапроса;
    
    // Подстановка параметров в GraphQL variables
    Для каждого Ключ Из ПараметрыЗапроса Цикл
        // Обработка параметра...
    КонецЦикла;
    
    // Подготовка заголовков
    Заголовки = Новый Соответствие();
    Заголовки.Вставить("Content-Type", "application/json");
    Заголовки.Вставить("PRIVATE-TOKEN", ТокенДоступа);
    
    // Формирование тела запроса
    ТелоЗапроса = СформироватьТелоGraphQLЗапроса(ПолныйЗапрос, ПараметрыЗапроса, ТипЗапроса);
    
    // Отправка POST запроса к GraphQL endpoint
    URL = БазовыйURL + "/api/graphql";
    Ответ = Get(URL, Заголовки, ТелоЗапроса);
    
    // Парсинг ответа
    Если Ответ.КодСостояния() = 200 Тогда
        Данные = РазобратьJSON(Ответ.ПолучитьТелоКакСтроку());
        
        // Проверка на ошибки GraphQL
        Если Данные.Ошибки <> Неопределено И Данные.Ошибки.Количество() > 0 Тогда
            Возврат СформироватьОшибкаGraphQL(Данные.Ошибки);
        КонецЕсли;
        
        Возврат Данные.Data;
    Иначе
        Возврат Неопределено;
    КонецЕсли;
    
КонецФункции
```

---

### GQL-H002: Пагинация GraphQL запросов

**Назначение:** Реализовать автоматическую пагинацию при получении большого объёма данных.

**Подпись метода:**
```bsl
// ВыполнитьGraphQLЗапросСПагинацией(ТекстЗапроса, ПараметрыЗапроса, МаксимумЗаписей=1000)
// Возвращает: ТаблицаЗначений (все записи из всех страниц)
```

**Логика реализации:**
```bsl
Функция ВыполнитьGraphQLЗапросСПагинацией(ТекстЗапроса, ПараметрыЗапроса, МаксимумЗаписей=1000)
    
    Результат = Новый ТаблицаЗначений;
    Курсор = Неопределено;
    ОбщееКоличество = 0;
    
    Пока ОбщееКоличество < МаксимумЗаписей Цикл
        
        // Установка курсора для пагинации
        Если Курсер <> Неопределено Тогда
            ПараметрыЗапроса.Вставить("cursor", Курсор);
        КонецЕсли;
        
        Данные = ВыполнитьGraphQLЗапрос(ТекстЗапроса, ПараметрыЗапроса);
        
        Если Данные = Неопределено Тогда
            Прервать;
        КонецЕсли;
        
        // Обработка полученных данных...
        // Добавление в Результат...
        
        // Проверка hasNextPage и получение endCursor для следующей страницы
        pageInfo = Данные.pageInfo;
        Если pageInfo.HasNextPage = Ложь Тогда
            Прервать;
        КонецЕсли;
        
        Курсор = pageInfo.EndCursor;
        ОбщееКоличество = ОбщееКоличество + Данные.Количество();
        
    КонецЦикла;
    
    Возврат Результат;
    
КонецФункции
```

---

## Примеры использования

### Пример 1: Получение таймлогов за период через GraphQL

```bsl
// Создание объекта интеграции
Интеграция = Обработки.ИнтеграцияGitlab.Создать();
Интеграция.УстановитьБазовыйURL("https://gitlab.example.com");
Интеграция.УстановитьТокен("glpat-your-token-here");

// Получение таймлогов пользователя за период
ДатаНач = "2024-01-01";
ДатаКон = "2024-01-31";
ПользовательID = 12345;

Таймлоги = Интеграция.ПолучитьТаймлогиПользователяGraphQL(ПользовательID, ДатаНач, ДатаКон);

// Обработка результатов
Пока Таймлоги.Следующий() Цикл
    Сообщить(СтрШаблон("%s: %d сек - %s", 
        Таймлоги.SpentAt, Таймлоги.Duration, Таймлоги.Message));
КонецЦикла;
```

### Пример 2: Создание записи времени через GraphQL

```bsl
Интеграция = Обработки.ИнтеграцияGitlab.Создать();
Интеграция.УстановитьБазовыйURL("https://gitlab.example.com");
Интеграция.УстановитьТокен("glpat-your-token-here");

// Создание записи времени: 2 часа работы над задачей #42
ПроектID = 98765;
IssueIID = 42;
Длительность = 7200; // 2 часа в секундах
ДатаРаботы = ТекущаяДата();
Описание = "Реализация модуля аутентификации";

IDЗаписи = Интеграция.ДобавитьTimelogGraphQL(ПроектID, IssueIID, Длительность, ДатаРаботы, Описание);

Если IDЗаписи > 0 Тогда
    Сообщить("Запись времени создана с ID: " + СТР(IDЗаписи));
Иначе
    Сообщить("Не удалось создать запись времени");
КонецЕсли;
```

---

## Форматы данных GraphQL

### Duration (Длительность)

GraphQL использует формат ISO 8601 для указания длительности:

| Формат | Пример | Значение |
|--------|--------|----------|
| P[n]S | PT30S | 30 секунд |
| P[n]M | PT15M | 15 минут |
| P[n]H | PT2H | 2 часа |
| P[n]D | P1D | 1 день |
| Комбинированный | P1DT2H30M | 1 день, 2 часа, 30 минут |
| Недели | P2W | 2 недели |

### Преобразование секунд в GraphQL Duration

```bsl
// Секунды в формат GraphQL Duration (ISO 8601)
Функция СекундыВGraphQLDuration(Секунды)
    
    Дни = Цел(Секунды / 86400);
    Остаток = Остаток(Секунды, 86400);
    Часы = Цел(Остаток / 3600);
    Остаток = Остаток(Остаток, 3600);
    Минуты = Цел(Остаток / 60);
    Сек = Остаток;
    
    Результат = "P";
    
    Если Дни > 0 Тогда
        Результат = Результат + СтрШаблон("%D", Дни);
    КонецЕсли;
    
    Если Часы > 0 Или Минуты > 0 Или Сек > 0 Тогда
        Результат = Результат + "T";
        
        Если Часы > 0 Тогда
            Результат = Результат + СтрШаблон("%DH", Часы);
        КонецЕсли;
        
        Если Минуты > 0 Тогда
            Результат = Результат + СтрШаблон("%DM", Минуты);
        КонецЕсли;
        
        Если Сек > 0 Тогда
            Результат = Результат + СтрШаблон("%DS", Сек);
        КонецЕсли;
    КонецЕсли;
    
    // Если ничего не указано — это 0 секунд
    Если Результат = "P" Или Результат = "PT" Тогда
        Возврат "PT0S";
    КонецЕсли;
    
    Возврат Результат;
    
КонецФункции
```

---

## Обработка ошибок GraphQL

### Типы ошибок

| Код | Описание | Действие |
|-----|----------|----------|
| `required` | Обязательный параметр не указан | Проверить параметры запроса |
| `invalid` | Неверный формат параметра | Исправить формат |
| `not_found` | Ресурс не найден | Проверить ID проекта/задачи |
| `forbidden` | Нет прав на ресурс | Проверить токен и доступы |
| `rate_limited` | Превышен лимит запросов | Подождать и повторить |

### Функция обработки ошибок

```bsl
// ОбработатьОшибкуGraphQL(МассивОшибок)
// Возвращает: Строка (текст ошибки для пользователя)
Функция ОбработатьОшибкуGraphQL(МассивОшибок)
    
    Ошибки = Новый Строка();
    
    Для каждого Ошибка Из МассивОшибок Цикл
        Ошибки = Ошибки + СтрШаблон("[%s] %s: %s\n", 
            Ошибка.Code, 
            Ошибка.Message, 
            Ошибка.Path);
    КонецЦикла;
    
    Возврат Ошибки;
    
КонецФункции
```

---

## Лимиты GraphQL API GitLab

| Параметр | Значение |
|----------|----------|
| Запросы в минуту (Free) | 300 |
| Запросы в минуту (Premium) | 1200 |
| Макс. записей на запрос | 100 |
| Макс. размер тела запроса | 1 МБ |

## См. также

- [GitLab GraphQL API Reference](https://docs.gitlab.com/ee/graphql/index.html)
- [GitLab REST API (Timelogs)](./GitlabTimeLog-ЗадачиКоманд.md)
- [Memory CLine — реализованные функции](../Agents/CLine/memory.md)