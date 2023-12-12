﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Подставляет в шаблон переданные параметры.
//
// Параметры:
//   Шаблон - Строка - исходный шаблон. Например "Добрый день, [ФИО]".
//   Параметры - Структура:
//      * Ключ - Строка - имя параметра. Например "ФИО".
//      * Значение - Произвольный - строка подстановки. Например "Иванов Иван Иванович".
//
// Возвращаемое значение: 
//   Строка
//
Функция ЗаполнитьШаблон(Шаблон, Параметры) Экспорт
	НачалоПараметра = "["; 
	КонецПараметра = "]";
	НачалоФормата = "("; 
	КонецФормата = ")"; 
	ВырезатьОбрамление = Истина; // отладочный параметр
	
	Результат = Шаблон;
	Для Каждого КлючИЗначение Из Параметры Цикл
		// Замена "[ключ]" на "значение".
		Результат = СтрЗаменить(
			Результат,
			НачалоПараметра + КлючИЗначение.Ключ + КонецПараметра, 
			?(ВырезатьОбрамление, "", НачалоПараметра) + КлючИЗначение.Значение + ?(ВырезатьОбрамление, "", КонецПараметра));
		ДлинаФорматЛевый = СтрДлина(НачалоПараметра + КлючИЗначение.Ключ + НачалоФормата);
		// Замена "[ключ(формат)]" на "значение в формате".
		Позиция1 = СтрНайти(Результат, НачалоПараметра + КлючИЗначение.Ключ + НачалоФормата);
		Пока Позиция1 > 0 Цикл
			Позиция2 = СтрНайти(Результат, КонецФормата + КонецПараметра);
			Если Позиция2 = 0 Тогда
				Прервать;
			КонецЕсли;
			ФорматнаяСтрока = Сред(Результат, Позиция1 + ДлинаФорматЛевый, Позиция2 - Позиция1 - ДлинаФорматЛевый);
			Попытка
				Если ТипЗнч(КлючИЗначение.Значение) = Тип("СтандартныйПериод") Тогда
					ЗначениеСФорматом = НСтр("ru = '%ДатаНачала% - %ДатаОкончания%'");
					ЗначениеСФорматом = СтрЗаменить(ЗначениеСФорматом, "%ДатаНачала%", Формат(
						КлючИЗначение.Значение.ДатаНачала, ФорматнаяСтрока));
					ЗначениеСФорматом = СтрЗаменить(ЗначениеСФорматом, "%ДатаОкончания%", Формат(
						КлючИЗначение.Значение.ДатаОкончания, ФорматнаяСтрока));
				Иначе
					ЗначениеСФорматом = Формат(КлючИЗначение.Значение, ФорматнаяСтрока);
				КонецЕсли;
				НаЧтоЗаменить = ?(ВырезатьОбрамление, "", НачалоПараметра) + ЗначениеСФорматом + ?(ВырезатьОбрамление, "", КонецПараметра);
			Исключение
				НаЧтоЗаменить = ?(ВырезатьОбрамление, "", НачалоПараметра) + КлючИЗначение.Значение + ?(ВырезатьОбрамление, "", КонецПараметра);
			КонецПопытки;
			Результат = СтрЗаменить(
				Результат,
				НачалоПараметра + КлючИЗначение.Ключ + НачалоФормата + ФорматнаяСтрока + КонецФормата + КонецПараметра, 
				НаЧтоЗаменить);
			Позиция1 = СтрНайти(Результат, НачалоПараметра + КлючИЗначение.Ключ + НачалоФормата);
		КонецЦикла;
	КонецЦикла;
	Возврат Результат;
КонецФункции

// Формирует представление способов доставки в соответствии с параметрами доставки.
//
// Параметры:
//   ПараметрыДоставки - см. ВыполнитьРассылку.ПараметрыДоставки.
//
// Возвращаемое значение:
//   Строка
//
Функция ПредставлениеСпособовДоставки(ПараметрыДоставки) Экспорт
	Префикс = НСтр("ru = 'Результат'");
	ТекстПредставления = "";
	Суффикс = "";
	
	Если Не ПараметрыДоставки.ТолькоУведомить Тогда
		
		ТекстПредставления = ТекстПредставления 
		+ ?(ТекстПредставления = "", Префикс, " " + НСтр("ru = 'и'")) 
		+ " "
		+ НСтр("ru = 'отправлен по почте (см. вложения)'");
		
	КонецЕсли;
	
	Если ПараметрыДоставки.ВыполненаВПапку Тогда
		
		ТекстПредставления = ТекстПредставления 
		+ ?(ТекстПредставления = "", Префикс, " " + НСтр("ru = 'и'")) 
		+ " "
		+ НСтр("ru = 'доставлен в папку'")
		+ " ";
		
		Ссылка = ПолучитьНавигационнуюСсылкуИнформационнойБазы() +"#"+ ПолучитьНавигационнуюСсылку(ПараметрыДоставки.Папка);
		
		Если ПараметрыДоставки.ПисьмоВФорматеHTML Тогда
			ТекстПредставления = ТекстПредставления 
			+ "<a href = '"
			+ Ссылка
			+ "'>" 
			+ Строка(ПараметрыДоставки.Папка)
			+ "</a>";
		Иначе
			ТекстПредставления = ТекстПредставления 
			+ """"
			+ Строка(ПараметрыДоставки.Папка)
			+ """";
			Суффикс = Суффикс + ":" + Символы.ПС + "<" + Ссылка + ">";
		КонецЕсли;
		
	КонецЕсли;
	
	Если ПараметрыДоставки.ВыполненаВСетевойКаталог Тогда
		
		ТекстПредставления = ТекстПредставления 
		+ ?(ТекстПредставления = "", Префикс, " " + НСтр("ru = 'и'")) 
		+ " "
		+ НСтр("ru = 'доставлен в сетевой каталог'")
		+ " ";
		
		Если ПараметрыДоставки.ПисьмоВФорматеHTML Тогда
			ТекстПредставления = ТекстПредставления 
			+ "<a href = '"
			+ ПараметрыДоставки.СетевойКаталогWindows
			+ "'>" 
			+ ПараметрыДоставки.СетевойКаталогWindows
			+ "</a>";
		Иначе
			ТекстПредставления = ТекстПредставления 
			+ "<"
			+ ПараметрыДоставки.СетевойКаталогWindows
			+ ">";
		КонецЕсли;
		
	КонецЕсли;
	
	Если ПараметрыДоставки.ВыполненаНаFTP Тогда
		
		ТекстПредставления = ТекстПредставления 
		+ ?(ТекстПредставления = "", Префикс, " " + НСтр("ru = 'и'")) 
		+ " "
		+ НСтр("ru = 'доставлен на FTP ресурс'")
		+ " ";
		
		Ссылка = "ftp://"
		+ ПараметрыДоставки.Сервер 
		+ ":"
		+ Формат(ПараметрыДоставки.Порт, "ЧН=0; ЧГ=0") 
		+ ПараметрыДоставки.Каталог;
		
		Если ПараметрыДоставки.ПисьмоВФорматеHTML Тогда
			ТекстПредставления = ТекстПредставления 
			+ "<a href = '"
			+ Ссылка
			+ "'>" 
			+ Ссылка
			+ "</a>";
		Иначе
			ТекстПредставления = ТекстПредставления 
			+ "<"
			+ Ссылка
			+ ">";
		КонецЕсли;
		
	КонецЕсли;
	
	ТекстПредставления = ТекстПредставления + ?(Суффикс = "", ".", Суффикс);
	
	Возврат ТекстПредставления;
КонецФункции

Функция ПредставлениеСписка(Коллекция, ИмяКолонки = "", МаксимумСимволов = 60) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Всего", 0);
	Результат.Вставить("ДлинаПолного", 0);
	Результат.Вставить("ДлинаКраткого", 0);
	Результат.Вставить("Краткое", "");
	Результат.Вставить("Полное", "");
	Результат.Вставить("МаксимумПревышен", Ложь);
	Для Каждого Объект Из Коллекция Цикл
		ПредставлениеЗначения = Строка(?(ИмяКолонки = "", Объект, Объект[ИмяКолонки]));
		Если ПустаяСтрока(ПредставлениеЗначения) Тогда
			Продолжить;
		КонецЕсли;
		Если Результат.Всего = 0 Тогда
			Результат.Всего        = 1;
			Результат.Полное       = ПредставлениеЗначения;
			Результат.ДлинаПолного = СтрДлина(ПредставлениеЗначения);
		Иначе
			Полное       = Результат.Полное + ", " + ПредставлениеЗначения;
			ДлинаПолного = Результат.ДлинаПолного + 2 + СтрДлина(ПредставлениеЗначения);
			Если Не Результат.МаксимумПревышен И ДлинаПолного > МаксимумСимволов Тогда
				Результат.Краткое          = Результат.Полное;
				Результат.ДлинаКраткого    = Результат.ДлинаПолного;
				Результат.МаксимумПревышен = Истина;
			КонецЕсли;
			Результат.Всего        = Результат.Всего + 1;
			Результат.Полное       = Полное;
			Результат.ДлинаПолного = ДлинаПолного;
		КонецЕсли;
	КонецЦикла;
	Если Результат.Всего > 0 И Не Результат.МаксимумПревышен Тогда
		Результат.Краткое       = Результат.Полное;
		Результат.ДлинаКраткого = Результат.ДлинаПолного;
		Результат.МаксимумПревышен = Результат.ДлинаПолного > МаксимумСимволов;
	КонецЕсли;
	Возврат Результат;
КонецФункции

// Возвращает шаблон темы по умолчанию для доставки по электронной почте.
Функция ШаблонТемы(ВсеПараметрыТекстаПисьмаИФайлов = Неопределено) Экспорт
	Если ВсеПараметрыТекстаПисьмаИФайлов <> Неопределено Тогда 
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1 от %2'"), "[" + ВсеПараметрыТекстаПисьмаИФайлов.НаименованиеРассылки + "]",
			"[" + ВсеПараметрыТекстаПисьмаИФайлов.ДатаВыполнения + "(DLF='D')]");
	Иначе
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1 от %2'"), "[НаименованиеРассылки]", "[ДатаВыполнения(DLF='D')]");
	КонецЕсли;
КонецФункции

// Возвращает шаблон наименования архива по умолчанию.
Функция ШаблонИмениАрхива(ВсеПараметрыТекстаПисьмаИФайлов = Неопределено) Экспорт
	Если ВсеПараметрыТекстаПисьмаИФайлов <> Неопределено Тогда
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1 от %2'"), "[" + ВсеПараметрыТекстаПисьмаИФайлов.НаименованиеРассылки + "]",
			"[" + ВсеПараметрыТекстаПисьмаИФайлов.ДатаВыполнения + "(DF='yyyy-MM-dd')]");
	Иначе
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1 от %2'"), "[НаименованиеРассылки]", "[ДатаВыполнения(DF='yyyy-MM-dd')]");
	КонецЕсли;
КонецФункции

// Конструктор для значения параметра ПараметрыДоставки функции ВыполнитьРассылку.
//
// Возвращаемое значение:
//   Структура - настройки способа доставки отчетов. Состав свойств может отличаться для разных способов доставки.
//     Общие свойства:
//       * Автор - СправочникСсылка.Пользователи - автор рассылки.
//       * ИспользоватьПапку            - Булево - доставлять отчеты в папку подсистемы "Работа с файлами".
//       * ИспользоватьСетевойКаталог   - Булево - доставлять отчеты в папку файловой системы.
//       * ИспользоватьFTPРесурс        - Булево - доставлять отчеты на FTP.
//       * ИспользоватьЭлектроннуюПочту - Булево - доставлять отчеты по электронной почте.
//
//     Свойства, когда ИспользоватьПапку = Истина:
//       * Папка - СправочникСсылка.ПапкиФайлов - папка подсистемы "Работа с файлами".
//
//     Свойства, когда ИспользоватьСетевойКаталог = Истина:
//       * СетевойКаталогWindows - Строка - каталог файловой системы (локальный на сервере или сетевой).
//       * СетевойКаталогLinux   - Строка - каталог файловой системы (локальный на сервере или сетевой).
//
//     Свойства, когда ИспользоватьFTPРесурс = Истина:
//       * Владелец            - СправочникСсылка.РассылкиОтчетов
//       * Сервер              - Строка - имя FTP сервера.
//       * Порт                - Число  - порт FTP сервера.
//       * Логин               - Строка - имя пользователя FTP сервера.
//       * Пароль              - Строка - пароль пользователя FTP сервера.
//       * Каталог             - Строка - путь к каталогу на FTP сервере.
//       * ПассивноеСоединение - Булево - использовать пассивное соединение.
//
//     Свойства, когда ИспользоватьЭлектроннуюПочту = Истина:
//       * УчетнаяЗапись - СправочникСсылка.УчетныеЗаписиЭлектроннойПочты - для отправки почтового сообщения.
//       * Получатели - Соответствие из КлючИЗначение - набор получателей и их e-mail адресов:
//           ** Ключ - СправочникСсылка - получатель.
//           ** Значение - Строка - email-адреса получателя, разделенные запятыми.
//
//     Дополнительные свойства:
//       * Архивировать - Булево - архивировать все файлы сформированных отчетов в один архив.
//                                 Архивация может потребоваться, например, при рассылке графиков в формате html.
//       * ИмяАрхива    - Строка - имя архива.
//       * ПарольАрхива - Строка - пароль архива.
//       * ТранслитерироватьИменаФайлов - Булево - признак необходимости транслитерации имен файлов отчетов рассылки.
//       * СертификатДляШифрования - СправочникСсылка.СертификатыКлючейЭлектроннойПодписиИШифрования - если внедрена
//           подсистема ЭлектроннаяПодпись - Неопределено
//       * ТипПолучателейРассылки - ОписаниеТипов
//                                - Неопределено
//
//     Необязательные свойства, когда ИспользоватьЭлектроннуюПочту = Истина:
//       * Персонализирована - Булево - рассылка персонализирована получателями.
//           Значение по умолчанию Ложь.
//           Если установить значение Истина, то каждый получатель получит отчет с отбором по нему.
//           Для этого в отчетах следует установить отбор "[Получатель]" по реквизиту, совпадающем с типом получателя.
//           Применимо только только при доставке по почте,
//           поэтому когда устанавливается в Истина, то другие способы доставки отключаются.
//       * ТолькоУведомить - Булево - Ложь - отправлять только уведомления (не присоединять сформированные отчеты).
//       * СкрытыеКопии    - Булево - Ложь - если Истина, то при отправке вместо "Кому" заполняется "СкрытыеКопии".
//       * ШаблонТемы      - Строка -       тема письма.
//       * ШаблонТекста    - Строка -       тело письма.
//       * ПараметрыФорматов - Соответствие из КлючИЗначение:
//           ** Ключ - ПеречислениеСсылка.ФорматыСохраненияОтчетов
//           ** Значение - Структура:
//                *** Расширение - Строка
//                *** ТипФайла - ТипФайлаТабличногоДокумента
//                *** Имя - Строка
//       * ПараметрыПисьма - см. ПараметрыОтправкиПисьма
//       * ВставлятьОтчетыВТекстПисьма - Булево
//       * ПрикреплятьОтчетыВоВложения - Булево
//       * УстановитьПаролиЗашифровать - Булево
//       * ОтчетыДляТекстаПисьма - Массив из Соответствие
//
Функция ПараметрыДоставки() Экспорт
	
	ПараметрыДоставки = Новый Структура;
	ПараметрыДоставки.Вставить("ДатаВыполнения", Неопределено);
	ПараметрыДоставки.Вставить("Соединение", Неопределено);
	ПараметрыДоставки.Вставить("ЗапускЗафиксирован", Ложь);
	ПараметрыДоставки.Вставить("Автор", Неопределено);
	ПараметрыДоставки.Вставить("ПараметрыПисьма", ПараметрыОтправкиПисьма());
	
	ПараметрыДоставки.Вставить("НастройкиПолучателей", Новый Соответствие);
	ПараметрыДоставки.Вставить("Получатели", Неопределено);
	ПараметрыДоставки.Вставить("УчетнаяЗапись", Неопределено);
	ПараметрыДоставки.Вставить("Рассылка", "");
	
	ПараметрыДоставки.Вставить("ПисьмоВФорматеHTML", Ложь);
	ПараметрыДоставки.Вставить("Персонализирована", Ложь);
	ПараметрыДоставки.Вставить("ТранслитерироватьИменаФайлов", Ложь);
	ПараметрыДоставки.Вставить("ТолькоУведомить", Ложь);
	ПараметрыДоставки.Вставить("СкрытыеКопии", Ложь);
	
	ПараметрыДоставки.Вставить("ИспользоватьЭлектроннуюПочту", Ложь);
	ПараметрыДоставки.Вставить("ИспользоватьПапку", Ложь);
	ПараметрыДоставки.Вставить("ИспользоватьСетевойКаталог", Ложь);
	ПараметрыДоставки.Вставить("ИспользоватьFTPРесурс", Ложь);
	
	ПараметрыДоставки.Вставить("Каталог", Неопределено);
	ПараметрыДоставки.Вставить("СетевойКаталогWindows", Неопределено);
	ПараметрыДоставки.Вставить("СетевойКаталогLinux", Неопределено);
	ПараметрыДоставки.Вставить("КаталогВременныхФайлов", "");
	
	ПараметрыДоставки.Вставить("Владелец", Неопределено);
	ПараметрыДоставки.Вставить("Сервер", Неопределено);
	ПараметрыДоставки.Вставить("Порт", Неопределено);
	ПараметрыДоставки.Вставить("ПассивноеСоединение", Ложь);
	ПараметрыДоставки.Вставить("Логин", Неопределено);
	ПараметрыДоставки.Вставить("Пароль", Неопределено);
	
	ПараметрыДоставки.Вставить("Папка", Неопределено);
	ПараметрыДоставки.Вставить("Архивировать", Ложь);
	ПараметрыДоставки.Вставить("ИмяАрхива", ШаблонИмениАрхива());
	ПараметрыДоставки.Вставить("ПарольАрхива", Неопределено);
	ПараметрыДоставки.Вставить("СертификатДляШифрования", Неопределено);
		
	ПараметрыДоставки.Вставить("ЗаполнитьПолучателяВШаблонеТемы", Ложь);
	ПараметрыДоставки.Вставить("ЗаполнитьПолучателяВШаблонеСообщения", Ложь);
	ПараметрыДоставки.Вставить("ЗаполнитьСформированныеОтчетыВШаблонеСообщения", Ложь);
	ПараметрыДоставки.Вставить("ЗаполнитьСпособДоставкиВШаблонеСообщения", Ложь);
	ПараметрыДоставки.Вставить("ПредставлениеОтчетовПолучателя", "");
	ПараметрыДоставки.Вставить("ШаблонТемы", ШаблонТемы());
	ПараметрыДоставки.Вставить("ШаблонТекста", "");
	
	ПараметрыДоставки.Вставить("ПараметрыФорматов", Новый Соответствие);
	ПараметрыДоставки.Вставить("ТранслитерироватьИменаФайлов", Ложь);
	ПараметрыДоставки.Вставить("СтрокаОбщихОтчетов", Неопределено);
	ПараметрыДоставки.Вставить("ДобавлятьСсылки", "");
	
	ПараметрыДоставки.Вставить("РежимТестирования", Ложь);
	ПараметрыДоставки.Вставить("БылиОшибки", Ложь);
	ПараметрыДоставки.Вставить("БылиПредупреждения", Ложь);
	ПараметрыДоставки.Вставить("ВыполненаВПапку", Ложь);
	ПараметрыДоставки.Вставить("ВыполненаВСетевойКаталог", Ложь);
	ПараметрыДоставки.Вставить("ВыполненаНаFTP", Ложь);
	ПараметрыДоставки.Вставить("ВыполненаПоЭлектроннойПочте", Ложь);
	ПараметрыДоставки.Вставить("ВыполненныеСпособыПубликации", "");
	ПараметрыДоставки.Вставить("Получатель", Неопределено);
	ПараметрыДоставки.Вставить("Картинки", Новый Структура);
	ПараметрыДоставки.Вставить("Личная", Ложь);
	ПараметрыДоставки.Вставить("ТипПолучателейРассылки", Неопределено);
	ПараметрыДоставки.Вставить("ВставлятьОтчетыВТекстПисьма", Истина);
	ПараметрыДоставки.Вставить("ПрикреплятьОтчетыВоВложения", Ложь);
	ПараметрыДоставки.Вставить("УстановитьПаролиЗашифровать", Ложь);
	ПараметрыДоставки.Вставить("ОтчетыДляТекстаПисьма", Новый Соответствие);
	ПараметрыДоставки.Вставить("ДеревоОтчетов", Неопределено);
	
	Возврат ПараметрыДоставки;
	
КонецФункции

// Конструктор структуры с параметрами отправки письма.
//
// Возвращаемое значение:
//   Структура - содержит всю необходимую информацию о письме:
//     * Кому - Массив
//            - Строка - интернет адреса получателей письма.
//            - Массив - коллекция структур адресов:
//                * Адрес         - Строка - почтовый адрес (должно быть обязательно заполнено).
//                * Представление - Строка - имя адресата.
//            - Строка - интернет-адреса получателей письма, разделитель - ";".
//
//     * ПолучателиСообщения - Массив - массив структур, описывающий получателей:
//       ** Адрес - Строка - почтовый адрес получателя сообщения.
//       ** Представление - Строка - представление адресата.
//
//     * Копии        - Массив
//                    - Строка - адреса получателей копий письма. См. описание поля Кому.
//
//     * СкрытыеКопии - Массив
//                    - Строка - адреса получателей скрытых копий письма. См. описание поля Кому.
//
//     * Тема       - Строка - (обязательный) тема почтового сообщения.
//     * Тело       - Строка - (обязательный) текст почтового сообщения (простой текст в кодировке win-1251).
//
//     * Вложения - Массив - файлы, которые необходимо приложить к письму (описания в виде структур):
//       ** Представление - Строка - имя файла вложения;
//       ** АдресВоВременномХранилище - Строка - адрес двоичных данных вложения во временном хранилище.
//       ** Кодировка - Строка - кодировка вложения (используется, если отличается от кодировки письма).
//       ** Идентификатор - Строка - (необязательный) используется для отметки картинок, отображаемых в теле письма.
//
//     * АдресОтвета - Строка - E-mail адрес, на который будут приходить ответы на рассылку.
//     * ИдентификаторыОснований - Строка - идентификаторы оснований данного письма.
//     * ОбрабатыватьТексты  - Булево - необходимость обрабатывать тексты письма при отправке.
//     * УведомитьОДоставке  - Булево - необходимость запроса уведомления о доставке.
//     * УведомитьОПрочтении - Булево - необходимость запроса уведомления о прочтении.
//     * ТипТекста - Строка
//                 - ПеречислениеСсылка.ТипыТекстовЭлектронныхПисем
//                 - ТипТекстаПочтовогоСообщения - определяет тип
//                   переданного теста допустимые значения:
//                   HTML/ТипыТекстовЭлектронныхПисем.HTML - текст почтового сообщения в формате HTML.
//                   ПростойТекст/ТипыТекстовЭлектронныхПисем.ПростойТекст - простой текст почтового сообщения.
//                                                 Отображается "как есть" (значение по умолчанию).
//                   РазмеченныйТекст/ТипыТекстовЭлектронныхПисем.РазмеченныйТекст - текст почтового сообщения в формате
//                                                 Rich Text.
//     * Важность  - ВажностьИнтернетПочтовогоСообщения
//
Функция ПараметрыОтправкиПисьма() Экспорт
	
	ПараметрыПисьма = Новый Структура;
	ПараметрыПисьма.Вставить("Кому", Новый Массив);
	ПараметрыПисьма.Вставить("ПолучателиСообщения", Новый Массив);
	ПараметрыПисьма.Вставить("Копии", Новый Массив);
	ПараметрыПисьма.Вставить("СкрытыеКопии", Новый Массив);
	ПараметрыПисьма.Вставить("Тема", "");
	ПараметрыПисьма.Вставить("Тело", "");
	ПараметрыПисьма.Вставить("Вложения", Новый Соответствие);
	ПараметрыПисьма.Вставить("АдресОтвета", "");
	ПараметрыПисьма.Вставить("ИдентификаторыОснований", "");
	ПараметрыПисьма.Вставить("ОбрабатыватьТексты", Ложь);
	ПараметрыПисьма.Вставить("УведомитьОДоставке", Ложь);
	ПараметрыПисьма.Вставить("УведомитьОПрочтении", Ложь);
	ПараметрыПисьма.Вставить("ТипТекста", "ПростойТекст");
	ПараметрыПисьма.Вставить("Важность", "");
	
	Возврат ПараметрыПисьма;
	
КонецФункции

// Конструктор структуры с параметрами получателей.
//
// Возвращаемое значение:
//   Структура - содержит всю необходимую информацию о получателях рассылки отчетов:
//     * Ссылка - СправочникСсылка.РассылкиОтчетов
//     * Автор - СправочникСсылка.Пользователи
//     * ВидПочтовогоАдресаПолучателей - СправочникСсылка.ВидыКонтактнойИнформации
//     * Личная - Булево
//     * Получатели - СправочникТабличнаяЧасть.РассылкиОтчетов.Получатели
//                    - ТаблицаЗначений:
//                      ** Получатель - ОпределяемыйТип.ПолучательРассылки
//                      ** Исключен - Булево
//     * ТипПолучателейРассылки - СправочникСсылка.ИдентификаторыОбъектовМетаданных
//                              - СправочникСсылка.ИдентификаторыОбъектовРасширений
//
Функция ПараметрыПолучателей() Экспорт
	
	ПараметрыПолучателей = Новый Структура;
	ПараметрыПолучателей.Вставить("Ссылка", ПредопределенноеЗначение("Справочник.РассылкиОтчетов.ПустаяСсылка"));
	ПараметрыПолучателей.Вставить("Автор", ПредопределенноеЗначение("Справочник.Пользователи.ПустаяСсылка"));
	ПараметрыПолучателей.Вставить("ВидПочтовогоАдресаПолучателей", ПредопределенноеЗначение("Справочник.ВидыКонтактнойИнформации.ПустаяСсылка"));
	ПараметрыПолучателей.Вставить("Личная", Ложь);
	ПараметрыПолучателей.Вставить("Получатели", Неопределено);
	ПараметрыПолучателей.Вставить("ТипПолучателейРассылки", Неопределено);
	
	Возврат ПараметрыПолучателей;
	
КонецФункции

#КонецОбласти