// yaxUnit-тесты разбора MSPDI XML подсистемы Проджект
// (ОбщийМодуль.ОбменMSProject, разделы 4.6 и 6 документации).
// Чистые функции: XML задан строкой-фикстурой, база данных не используется.

Процедура ИсполняемыеСценарии() Экспорт

	ЮТТесты
		.ДобавитьТестовыйНабор("Разбор MSPDI")
			.ДобавитьТест("ТЕСТ_Проект_ПоляСчитаны")
			.ДобавитьТест("ТЕСТ_Календарь_ДниИнтервалыИсключения")
			.ДобавитьТест("ТЕСТ_Задачи_ДлительностьСвязиВеха")
			.ДобавитьТест("ТЕСТ_РесурсыИНазначения_Конвертации")
			.ДобавитьТест("ТЕСТ_ПустыеУзлы_НеПадают")
	;

КонецПроцедуры

#Область Тесты

Процедура ТЕСТ_Проект_ПоляСчитаны() Экспорт

	Данные = ОбменMSProject.Разобрать(Фикстура());

	ЮТест.ОжидаетЧто(Данные.Проект.UID)
		.Равно("11111111-1111-1111-1111-111111111111", "UID проекта");
	ЮТест.ОжидаетЧто(Данные.Проект.Name)
		.Равно("Тестовый проект", "Имя из Title");
	ЮТест.ОжидаетЧто(Данные.Проект.StartDate)
		.Равно(Дата(2026, 11, 9, 8, 0, 0), "Дата начала");
	ЮТест.ОжидаетЧто(Данные.Проект.MinutesPerDay)
		.Равно(480, "Минут в дне");
	ЮТест.ОжидаетЧто(Данные.Проект.CurrencyCode)
		.Равно("RUB", "Валюта");
	ЮТест.ОжидаетЧто(Данные.Календари.Количество())
		.Равно(1, "Один календарь");
	ЮТест.ОжидаетЧто(Данные.Задачи.Количество())
		.Равно(3, "Три задачи");
	ЮТест.ОжидаетЧто(Данные.Ресурсы.Количество())
		.Равно(2, "Два ресурса");
	ЮТест.ОжидаетЧто(Данные.Назначения.Количество())
		.Равно(1, "Одно назначение");

КонецПроцедуры

Процедура ТЕСТ_Календарь_ДниИнтервалыИсключения() Экспорт

	Данные = ОбменMSProject.Разобрать(Фикстура());
	Календарь = Данные.Календари[0];

	ЮТест.ОжидаетЧто(Календарь.IsBaseCalendar)
		.Равно(Истина, "Базовый календарь");
	ЮТест.ОжидаетЧто(Календарь.WeekDays.Количество())
		.Равно(2, "Два описанных дня недели");
	ЮТест.ОжидаетЧто(Календарь.WeekDays[0].DayType)
		.Равно(1, "MSPDI-день 2 (понедельник) стал днём 1С 1");
	ЮТест.ОжидаетЧто(Календарь.WeekDays[0].Интервалы.Количество())
		.Равно(2, "Понедельник: два рабочих интервала");
	ЮТест.ОжидаетЧто(Календарь.WeekDays[0].Интервалы[0].FromTime)
		.Равно(Дата(1, 1, 1, 8, 0, 0), "Первый интервал с 8:00");
	ЮТест.ОжидаетЧто(Календарь.WeekDays[0].Интервалы[1].ToTime)
		.Равно(Дата(1, 1, 1, 17, 0, 0), "Второй интервал до 17:00");
	ЮТест.ОжидаетЧто(Календарь.WeekDays[1].DayType)
		.Равно(7, "MSPDI-день 1 (воскресенье) стал днём 1С 7");
	ЮТест.ОжидаетЧто(Календарь.WeekDays[1].DayWorking)
		.Равно(Ложь, "Воскресенье нерабочее");
	ЮТест.ОжидаетЧто(Календарь.Exceptions.Количество())
		.Равно(1, "Рекуррентное исключение пропущено, диапазонное загружено");
	ЮТест.ОжидаетЧто(Календарь.Exceptions[0].Name)
		.Равно("Новый год", "Название исключения");
	ЮТест.ОжидаетЧто(Календарь.Exceptions[0].FromDate)
		.Равно(Дата(2027, 1, 1, 0, 0, 0), "Дата начала исключения");
	ЮТест.ОжидаетЧто(ЕстьПодстрока(Данные.Предупреждения, "Рекуррентное исключение"))
		.Равно(Истина, "О пропуске рекуррентного исключения предупреждено");

КонецПроцедуры

Процедура ТЕСТ_Задачи_ДлительностьСвязиВеха() Экспорт

	Данные = ОбменMSProject.Разобрать(Фикстура());
	СписокЗадач = Данные.Задачи;

	ЮТест.ОжидаетЧто(СписокЗадач[0].Summary)
		.Равно(Истина, "Первая задача - сводная");
	ЮТест.ОжидаетЧто(СписокЗадач[0].OutlineLevel)
		.Равно(1, "Уровень структуры сводной");
	ЮТест.ОжидаетЧто(СписокЗадач[0].Duration)
		.Равно(0, "У сводной длительность не задана");

	ЗадачаА = СписокЗадач[1];
	ЮТест.ОжидаетЧто(ЗадачаА.Duration)
		.Равно(480, "PT8H0M0S стал 480 рабочими минутами");
	ЮТест.ОжидаетЧто(ЗадачаА.Start)
		.Равно(Дата(2026, 11, 9, 8, 0, 0), "Дата старта прочитана");
	ЮТест.ОжидаетЧто(ЗадачаА.IsActive)
		.Равно(Истина, "Active=1 -> IsActive");
	ЮТест.ОжидаетЧто(ЗадачаА.Предшественники.Количество())
		.Равно(2, "Две связи-предшественника");
	ЮТест.ОжидаетЧто(ЗадачаА.Предшественники[0].PredecessorUID)
		.Равно("cccccccc-cccc-cccc-cccc-cccccccccccc", "UID предшественника");
	ЮТест.ОжидаетЧто(ЗадачаА.Предшественники[0].Lag)
		.Равно(120, "LinkLag 1200 десятых стал 120 минутами");
	ЮТест.ОжидаетЧто(ЗадачаА.Предшественники[0].LinkType)
		.Равно(1, "Тип FS");
	ЮТест.ОжидаетЧто(ЗадачаА.Предшественники[1].LinkType)
		.Равно(2, "Неподдерживаемый тип связи сохранён как есть");
	ЮТест.ОжидаетЧто(ЕстьПодстрока(Данные.Предупреждения, "не поддерживается"))
		.Равно(Истина, "О неподдерживаемом типе связи предупреждено");

	Веха = СписокЗадач[2];
	ЮТест.ОжидаетЧто(Веха.Milestone)
		.Равно(Истина, "Признак вехи");
	ЮТест.ОжидаетЧто(Веха.ConstraintType)
		.Равно(2, "Ограничение SNET");
	ЮТест.ОжидаетЧто(Веха.ConstraintDate)
		.Равно(Дата(2026, 11, 10, 8, 0, 0), "Дата ограничения");

КонецПроцедуры

Процедура ТЕСТ_РесурсыИНазначения_Конвертации() Экспорт

	Данные = ОбменMSProject.Разобрать(Фикстура());

	Иванов = Данные.Ресурсы[0];
	ЮТест.ОжидаетЧто(Иванов.ResourceType)
		.Равно(1, "Трудовой ресурс");
	ЮТест.ОжидаетЧто(Иванов.MaxUnits)
		.Равно(100, "Доля 1.0 стала 100 процентами");
	ЮТест.ОжидаетЧто(Иванов.IsActive)
		.Равно(Истина, "IsInactive=0 -> IsActive=Истина");

	Материал = Данные.Ресурсы[1];
	ЮТест.ОжидаетЧто(Материал.ResourceType)
		.Равно(0, "Материальный ресурс");
	ЮТест.ОжидаетЧто(Материал.MaterialLabel)
		.Равно("кг", "Единица материала");
	ЮТест.ОжидаетЧто(Материал.IsActive)
		.Равно(Ложь, "IsInactive=1 -> IsActive=Ложь");

	Назначение = Данные.Назначения[0];
	ЮТест.ОжидаетЧто(Назначение.TaskUID)
		.Равно("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb", "UID задачи");
	ЮТест.ОжидаетЧто(Назначение.ResourceUID)
		.Равно("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee", "UID ресурса");
	ЮТест.ОжидаетЧто(Назначение.Units)
		.Равно(50, "Доля 0.5 стала 50 процентами");
	ЮТест.ОжидаетЧто(Назначение.Work)
		.Равно(240, "PT4H0M0S стал 240 минутами");

КонецПроцедуры

Процедура ТЕСТ_ПустыеУзлы_НеПадают() Экспорт

	Данные = ОбменMSProject.Разобрать(ФикстураПустыхУзлов());

	ЮТест.ОжидаетЧто(Данные.Задачи.Количество())
		.Равно(1, "Задача с пустыми узлами разобрана");
	ЮТест.ОжидаетЧто(Данные.Задачи[0].Duration)
		.Равно(0, "Пустая длительность стала нулём");
	ЮТест.ОжидаетЧто(Данные.Задачи[0].Name)
		.Равно("", "Пустое имя осталось пустым");
	ЮТест.ОжидаетЧто(Данные.Задачи[0].Milestone)
		.Равно(Ложь, "Пустой признак вехи остался ложью");

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Мини-файл MSPDI: проект, календарь с исключением, сводная + 2 задачи,
// связь FS с lag и связь неподдерживаемого типа, ресурсы, назначение.
Функция Фикстура()

	Возврат
	"<?xml version=""1.0"" encoding=""UTF-8""?>
	|<Project xmlns=""http://schemas.microsoft.com/project"">
	|  <UID>11111111-1111-1111-1111-111111111111</UID>
	|  <Title>Тестовый проект</Title>
	|  <StartDate>2026-11-09T08:00:00</StartDate>
	|  <MinutesPerDay>480</MinutesPerDay>
	|  <MinutesPerWeek>2400</MinutesPerWeek>
	|  <DaysPerMonth>20</DaysPerMonth>
	|  <CurrencyCode>RUB</CurrencyCode>
	|  <CalendarUID>22222222-2222-2222-2222-222222222222</CalendarUID>
	|  <Calendars>
	|    <Calendar>
	|      <UID>22222222-2222-2222-2222-222222222222</UID>
	|      <Name>Стандартный</Name>
	|      <IsBaseCalendar>1</IsBaseCalendar>
	|      <WeekDays>
	|        <WeekDay>
	|          <DayType>2</DayType>
	|          <DayWorking>1</DayWorking>
	|          <WorkingTimes>
	|            <WorkingTime><FromTime>T08:00:00</FromTime><ToTime>T12:00:00</ToTime></WorkingTime>
	|            <WorkingTime><FromTime>T13:00:00</FromTime><ToTime>T17:00:00</ToTime></WorkingTime>
	|          </WorkingTimes>
	|        </WeekDay>
	|        <WeekDay>
	|          <DayType>1</DayType>
	|          <DayWorking>0</DayWorking>
	|        </WeekDay>
	|      </WeekDays>
	|      <Exceptions>
	|        <Exception>
	|          <Name>Новый год</Name>
	|          <Type>1</Type>
	|          <TimePeriod>
	|            <FromDate>2027-01-01T00:00:00</FromDate>
	|            <ToDate>2027-01-01T00:00:00</ToDate>
	|          </TimePeriod>
	|          <DayWorking>0</DayWorking>
	|        </Exception>
	|        <Exception>
	|          <Name>Ежегодное</Name>
	|          <Type>9</Type>
	|          <TimePeriod>
	|            <FromDate>2027-03-08T00:00:00</FromDate>
	|            <ToDate>2027-03-08T00:00:00</ToDate>
	|          </TimePeriod>
	|          <DayWorking>0</DayWorking>
	|        </Exception>
	|      </Exceptions>
	|    </Calendar>
	|  </Calendars>
	|  <Tasks>
	|    <Task>
	|      <UID>aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa</UID>
	|      <ID>1</ID>
	|      <Name>Этап</Name>
	|      <OutlineLevel>1</OutlineLevel>
	|      <Summary>1</Summary>
	|    </Task>
	|    <Task>
	|      <UID>bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb</UID>
	|      <ID>2</ID>
	|      <Name>Задача А</Name>
	|      <OutlineLevel>2</OutlineLevel>
	|      <Duration>PT8H0M0S</Duration>
	|      <DurationFormat>7</DurationFormat>
	|      <Start>2026-11-09T08:00:00</Start>
	|      <Finish>2026-11-09T17:00:00</Finish>
	|      <ConstraintType>0</ConstraintType>
	|      <TotalSlack>0</TotalSlack>
	|      <Critical>1</Critical>
	|      <Active>1</Active>
	|      <PredecessorLinks>
	|        <PredecessorLink>
	|          <PredecessorUID>cccccccc-cccc-cccc-cccc-cccccccccccc</PredecessorUID>
	|          <Type>1</Type>
	|          <LinkLag>1200</LinkLag>
	|          <LagFormat>7</LagFormat>
	|        </PredecessorLink>
	|        <PredecessorLink>
	|          <PredecessorUID>aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa</PredecessorUID>
	|          <Type>2</Type>
	|          <LinkLag>0</LinkLag>
	|        </PredecessorLink>
	|      </PredecessorLinks>
	|    </Task>
	|    <Task>
	|      <UID>cccccccc-cccc-cccc-cccc-cccccccccccc</UID>
	|      <ID>3</ID>
	|      <Name>Веха</Name>
	|      <OutlineLevel>2</OutlineLevel>
	|      <Milestone>1</Milestone>
	|      <ConstraintType>2</ConstraintType>
	|      <ConstraintDate>2026-11-10T08:00:00</ConstraintDate>
	|    </Task>
	|  </Tasks>
	|  <Resources>
	|    <Resource>
	|      <UID>eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee</UID>
	|      <ID>1</ID>
	|      <Name>Иванов</Name>
	|      <Type>1</Type>
	|      <MaxUnits>1</MaxUnits>
	|      <IsInactive>0</IsInactive>
	|    </Resource>
	|    <Resource>
	|      <UID>ffffffff-ffff-ffff-ffff-ffffffffffff</UID>
	|      <ID>2</ID>
	|      <Name>Материал</Name>
	|      <Type>0</Type>
	|      <MaterialLabel>кг</MaterialLabel>
	|      <IsInactive>1</IsInactive>
	|    </Resource>
	|  </Resources>
	|  <Assignments>
	|    <Assignment>
	|      <TaskUID>bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb</TaskUID>
	|      <ResourceUID>eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee</ResourceUID>
	|      <Units>0.5</Units>
	|      <Work>PT4H0M0S</Work>
	|    </Assignment>
	|  </Assignments>
	|</Project>";

КонецФункции

// Задача с пустыми и самозакрытыми узлами.
Функция ФикстураПустыхУзлов()

	Возврат
	"<Project xmlns=""http://schemas.microsoft.com/project"">
	|  <Tasks>
	|    <Task>
	|      <UID>dddddddd-dddd-dddd-dddd-dddddddddddd</UID>
	|      <Name></Name>
	|      <Duration></Duration>
	|      <Milestone/>
	|    </Task>
	|  </Tasks>
	|</Project>";

КонецФункции

// Есть ли в массиве строк элемент с подстрокой.
Функция ЕстьПодстрока(Строки, Подстрока)

	Для Каждого Строка Из Строки Цикл
		Если СтрНайти(Строка, Подстрока) > 0 Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	Возврат Ложь;

КонецФункции

#КонецОбласти
