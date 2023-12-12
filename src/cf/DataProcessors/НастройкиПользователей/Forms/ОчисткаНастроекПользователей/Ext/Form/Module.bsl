﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ИспользоватьВнешнихПользователей = ПолучитьФункциональнуюОпцию("ИспользоватьВнешнихПользователей");
	ВыбранныеПользователи.Добавить(Пользователи.ТекущийПользователь());
	ОбновитьСсылкуВыбораПользователей(ЭтотОбъект);
	
	ПереключательКомуОчищатьНастройки = "ВыбраннымПользователям";
	ПереключательОчищаемыеНастройки   = "ОчиститьВсе";
	ОчиститьИсториюВыбораНастроек     = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ВРег(ИмяСобытия) = ВРег("ВыборПользователя") Тогда
		Если Источник <> ИмяФормы Тогда
			Возврат;
		КонецЕсли;
		
		ВыбранныеПользователи.ЗагрузитьЗначения(Параметр.ПользователиПриемник);
		ОбновитьСсылкуВыбораПользователей(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПереключательКомуОчищатьНастройкиПриИзменении(Элемент)
	
	Если ПереключательКомуОчищатьНастройки = "ВыбраннымПользователям"
		И КоличествоПользователей = 0 Тогда
		Элементы.ГруппаОчищаемыеНастройки.Доступность = Ложь;
	Иначе
		Элементы.ГруппаОчищаемыеНастройки.Доступность = Истина;
		ПереключательОчищаемыеНастройкиПриИзменении(Элементы.ПереключательОчищаемыеНастройки);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПереключательОчищаемыеНастройкиПриИзменении(Элемент)
	
	Если ПереключательОчищаемыеНастройки = "ОтдельныеНастройки" Тогда
		Если ПереключательКомуОчищатьНастройки <> "ВыбраннымПользователям"
		 Или КоличествоПользователей <> 1 Тогда
			ПереключательОчищаемыеНастройки = "ОчиститьВсе";
			Элементы.ВыбратьНастройки.Доступность = Ложь;
			ПоказатьПредупреждение(,НСтр("ru = 'Очистка отдельных настроек доступна только при выборе одного пользователя.'"));
		Иначе
			Элементы.ВыбратьНастройки.Доступность = Истина;
		КонецЕсли;
	Иначе
		Элементы.ВыбратьНастройки.Доступность = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьПользователейНажатие(Элемент)
	
	Если ИспользоватьВнешнихПользователей Тогда
		ВыборТипаПользователей = Новый СписокЗначений;
		ВыборТипаПользователей.Добавить("ВнешниеПользователи", НСтр("ru = 'Внешние пользователи'"));
		ВыборТипаПользователей.Добавить("Пользователи",        НСтр("ru = 'Пользователи'"));
		
		Оповещение = Новый ОписаниеОповещения("ВыбратьПользователейНажатиеВыбратьЭлемент", ЭтотОбъект);
		ВыборТипаПользователей.ПоказатьВыборЭлемента(Оповещение);
		Возврат;
	КонецЕсли;
	
	ОткрытьФормуВыбораПользователей(ПредопределенноеЗначение("Справочник.Пользователи.ПустаяСсылка"));
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьНастройки(Элемент)
	
	Если КоличествоПользователей = 1 Тогда
		ПользовательСсылка = ВыбранныеПользователи[0].Значение;
		ПараметрыФормы = Новый Структура("Пользователь, ДействиеСНастройками, ОчиститьИсториюВыбораНастроек",
			ПользовательСсылка, "Очистка", ОчиститьИсториюВыбораНастроек);
		ОткрытьФорму("Обработка.НастройкиПользователей.Форма.ВыборНастроек", ПараметрыФормы, ЭтотОбъект,,,,
			Новый ОписаниеОповещения("ВыбратьНастройкиПослеВыбора", ЭтотОбъект));
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Очистить(Команда)
	
	ОчиститьСообщения();
	ОчисткаНастроек();
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьИЗакрыть(Команда)
	
	ОчиститьСообщения();
	НастройкиОчищены = ОчисткаНастроек();
	Если НастройкиОчищены Тогда
		ОбщегоНазначенияКлиент.ОбновитьИнтерфейсПрограммы();
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ОбновитьСсылкуВыбораПользователей(Форма)
	Форма.КоличествоПользователей = Форма.ВыбранныеПользователи.Количество();
	Если Форма.КоличествоПользователей = 0 Тогда
		Форма.Элементы.ВыбратьНастройки.Заголовок = НСтр("ru = 'Выбрать'");
		Форма.ВыбранныеНастройки = Неопределено;
		Форма.КоличествоНастроек = Неопределено;
	ИначеЕсли Форма.КоличествоПользователей = 1 Тогда
		Форма.Элементы.ВыбратьПользователей.Заголовок = Строка(Форма.ВыбранныеПользователи[0].Значение);
		Форма.Элементы.ГруппаОчищаемыеНастройки.Доступность = Истина;
	Иначе
		ЧислоИПредмет = Формат(Форма.КоличествоПользователей, "ЧДЦ=0") + " "
			+ ПользователиСлужебныйКлиентСервер.ПредметЦелогоЧисла(Форма.КоличествоПользователей,
				"", НСтр("ru = 'пользователь,пользователя,пользователей,,,,,,0'"));
		Форма.Элементы.ВыбратьПользователей.Заголовок = ЧислоИПредмет;
		Форма.ПереключательОчищаемыеНастройки = "ОчиститьВсе";
	КонецЕсли;
КонецПроцедуры
	
&НаКлиенте
Процедура ВыбратьПользователейНажатиеВыбратьЭлемент(ВыбранныйВариант, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныйВариант = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ВыбранныйВариант.Значение = "Пользователи" Тогда
		Пользователь = ПредопределенноеЗначение("Справочник.Пользователи.ПустаяСсылка");
		
	ИначеЕсли ВыбранныйВариант.Значение = "ВнешниеПользователи" Тогда
		Пользователь = ПредопределенноеЗначение("Справочник.ВнешниеПользователи.ПустаяСсылка");
	КонецЕсли;
	
	ОткрытьФормуВыбораПользователей(Пользователь);
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФормуВыбораПользователей(Пользователь)
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Пользователь",          Пользователь);
	ПараметрыФормы.Вставить("ТипДействия",           "Очистка");
	ПараметрыФормы.Вставить("ВыбранныеПользователи", ВыбранныеПользователи.ВыгрузитьЗначения());
	ПараметрыФормы.Вставить("Источник", ИмяФормы);
	
	ОткрытьФорму("Обработка.НастройкиПользователей.Форма.ВыборПользователей", ПараметрыФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьНастройкиПослеВыбора(Параметр, Контекст) Экспорт
	
	Если ТипЗнч(Параметр) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	ВыбранныеНастройки = Новый Структура;
	ВыбранныеНастройки.Вставить("ВнешнийВид",       Параметр.ВнешнийВид);
	ВыбранныеНастройки.Вставить("НастройкиОтчетов", Параметр.НастройкиОтчетов);
	ВыбранныеНастройки.Вставить("ПрочиеНастройки",  Параметр.ПрочиеНастройки);
	
	ВыбранныеНастройки.Вставить("ТаблицаВариантовОтчетов",  Параметр.ТаблицаВариантовОтчетов);
	ВыбранныеНастройки.Вставить("ВыбранныеВариантыОтчетов", Параметр.ВыбранныеВариантыОтчетов);
	
	ВыбранныеНастройки.Вставить("ПерсональныеНастройки",           Параметр.ПерсональныеНастройки);
	ВыбранныеНастройки.Вставить("ПрочиеПользовательскиеНастройки", Параметр.ПрочиеПользовательскиеНастройки);
	
	КоличествоНастроек = Параметр.КоличествоНастроек;
	
	Если КоличествоНастроек = 0 Тогда
		ТекстЗаголовка = НСтр("ru = 'Выбрать'");
	ИначеЕсли КоличествоНастроек = 1 Тогда
		ПредставлениеНастройки = Параметр.ПредставленияНастроек[0];
		ТекстЗаголовка = ПредставлениеНастройки;
	Иначе
		ТекстЗаголовка = Формат(КоличествоНастроек, "ЧДЦ=0") + " "
			+ ПользователиСлужебныйКлиентСервер.ПредметЦелогоЧисла(КоличествоНастроек,
				"", НСтр("ru = 'настройка,настройки,настроек,,,,,,0'"));
	КонецЕсли;
	
	Элементы.ВыбратьНастройки.Заголовок = ТекстЗаголовка;
	Элементы.ВыбратьНастройки.Подсказка = "";
	
КонецПроцедуры

&НаКлиенте
Функция ОчисткаНастроек()
	
	Если ПереключательКомуОчищатьНастройки = "ВыбраннымПользователям"
		И КоличествоПользователей = 0 Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Выберите пользователя или пользователей,
				|которым необходимо очистить настройки.'"), , "Источник");
		Возврат Ложь;
	КонецЕсли;
	
	Если ПереключательКомуОчищатьНастройки = "ВыбраннымПользователям" Тогда
			
		Если КоличествоПользователей = 1 Тогда
			ПояснениеУКогоОчищеныНастройки = НСтр("ru = 'пользователя ""%1""'");
			ПояснениеУКогоОчищеныНастройки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				ПояснениеУКогоОчищеныНастройки, ВыбранныеПользователи[0].Значение);
		Иначе
			ПояснениеУКогоОчищеныНастройки = НСтр("ru = '%1 пользователям'");
			ПояснениеУКогоОчищеныНастройки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ПояснениеУКогоОчищеныНастройки, КоличествоПользователей);
		КонецЕсли;
		
	Иначе
		ПояснениеУКогоОчищеныНастройки = НСтр("ru = 'всем пользователям'");
	КонецЕсли;
	
	Если ПереключательОчищаемыеНастройки = "ОтдельныеНастройки"
		И КоличествоНастроек = 0 Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Выберите настройки, которые необходимо очистить.'"), , "ПереключательОчищаемыеНастройки");
		Возврат Ложь;
	КонецЕсли;
	
	Если ПереключательОчищаемыеНастройки = "ОтдельныеНастройки" Тогда
		ОчиститьВыбранныеНастройки();
		
		Если КоличествоНастроек = 1 Тогда
			
			Если СтрДлина(ПредставлениеНастройки) > 24 Тогда
				ПредставлениеНастройки = Лев(ПредставлениеНастройки, 24) + "...";
			КонецЕсли;
			
			ТекстПояснения = НСтр("ru = '""%1"" очищена у %2'");
			ТекстПояснения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстПояснения, ПредставлениеНастройки, ПояснениеУКогоОчищеныНастройки);
			
		Иначе
			ПрописьПредмета = Формат(КоличествоНастроек, "ЧДЦ=0") + " "
				+ ПользователиСлужебныйКлиентСервер.ПредметЦелогоЧисла(КоличествоНастроек,
					"", НСтр("ru = 'настройка,настройки,настроек,,,,,,0'"));
			
			ТекстПояснения = НСтр("ru = 'Очищено %1 у %2'");
			ТекстПояснения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстПояснения, ПрописьПредмета, ПояснениеУКогоОчищеныНастройки);
		КонецЕсли;
		
		ПоказатьОповещениеПользователя(НСтр("ru = 'Очистка настроек'"), , ТекстПояснения, БиблиотекаКартинок.Информация32);
		
	ИначеЕсли ПереключательОчищаемыеНастройки = "ОчиститьВсе" Тогда
		ОчиститьВсеНастройки();
		
		ТекстПояснения = НСтр("ru = 'Очищены все настройки %1'");
		ТекстПояснения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстПояснения, ПояснениеУКогоОчищеныНастройки);
		ПоказатьОповещениеПользователя(НСтр("ru = 'Очистка настроек'"), , ТекстПояснения, БиблиотекаКартинок.Информация32);
		
	ИначеЕсли ПереключательОчищаемыеНастройки = "УстаревшиеНастройки" Тогда
		ОчиститьУстаревшиеНастройки();
		
		ТекстПояснения = НСтр("ru = 'Очищены устаревшие настройки %1'");
		ТекстПояснения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстПояснения, ПояснениеУКогоОчищеныНастройки);
		ПоказатьОповещениеПользователя(НСтр("ru = 'Очистка настроек'"), , ТекстПояснения, БиблиотекаКартинок.Информация32);
	КонецЕсли;
	
	КоличествоНастроек = 0;
	Элементы.ВыбратьНастройки.Заголовок = НСтр("ru = 'Выбрать'");
	Возврат Истина;
	
КонецФункции

&НаСервере
Процедура ОчиститьВыбранныеНастройки()
	
	Источник = ВыбранныеПользователи[0].Значение;
	Пользователь = Обработки.НастройкиПользователей.ИмяПользователяИБ(Источник);
	СведенияОПользователе = Новый Структура;
	СведенияОПользователе.Вставить("ПользовательСсылка", Источник);
	СведенияОПользователе.Вставить("ИмяПользователяИнформационнойБазы", Пользователь);
	
	Если ВыбранныеНастройки.НастройкиОтчетов.Количество() > 0 Тогда
		Обработки.НастройкиПользователей.УдалитьВыбранныеНастройки(
			СведенияОПользователе, ВыбранныеНастройки.НастройкиОтчетов, "ХранилищеПользовательскихНастроекОтчетов");
		
		Обработки.НастройкиПользователей.УдалитьВариантыОтчетов(
			ВыбранныеНастройки.ВыбранныеВариантыОтчетов, ВыбранныеНастройки.ТаблицаВариантовОтчетов, Пользователь);
	КонецЕсли;
	
	Если ВыбранныеНастройки.ВнешнийВид.Количество() > 0 Тогда
		Обработки.НастройкиПользователей.УдалитьВыбранныеНастройки(
			СведенияОПользователе, ВыбранныеНастройки.ВнешнийВид, "ХранилищеСистемныхНастроек");
	КонецЕсли;
	
	Если ВыбранныеНастройки.ПрочиеНастройки.Количество() > 0 Тогда
		Обработки.НастройкиПользователей.УдалитьВыбранныеНастройки(
			СведенияОПользователе, ВыбранныеНастройки.ПрочиеНастройки, "ХранилищеСистемныхНастроек");
	КонецЕсли;
	
	Если ВыбранныеНастройки.ПерсональныеНастройки.Количество() > 0 Тогда
		Обработки.НастройкиПользователей.УдалитьВыбранныеНастройки(
			СведенияОПользователе, ВыбранныеНастройки.ПерсональныеНастройки, "ХранилищеОбщихНастроек");
	КонецЕсли;
	
	Для Каждого ПрочиеПользовательскиеНастройки Из ВыбранныеНастройки.ПрочиеПользовательскиеНастройки Цикл
		ПользователиСлужебный.ПриУдаленииПрочихНастроекПользователя(
			СведенияОПользователе, ПрочиеПользовательскиеНастройки);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ОчиститьВсеНастройки()
	
	МассивНастроек = Новый Массив;
	МассивНастроек.Добавить("НастройкиОтчетов");
	МассивНастроек.Добавить("НастройкиВнешнегоВида");
	МассивНастроек.Добавить("ПерсональныеНастройки");
	МассивНастроек.Добавить("ДанныеФорм");
	МассивНастроек.Добавить("Избранное");
	МассивНастроек.Добавить("НастройкиПечати");
	МассивНастроек.Добавить("ПрочиеПользовательскиеНастройки");
	
	Если ПереключательКомуОчищатьНастройки = "ВыбраннымПользователям" Тогда
		Источники = ВыбранныеПользователи.ВыгрузитьЗначения();
	Иначе
		Источники = Новый Массив;
		ТаблицаПользователей = Новый ТаблицаЗначений;
		ТаблицаПользователей.Колонки.Добавить("Пользователь");
		ТаблицаПользователей.Колонки.Добавить("Подразделение");
		ТаблицаПользователей.Колонки.Добавить("ФизическоеЛицо");

		ТаблицаПользователей = Обработки.НастройкиПользователей.ПользователиДляКопирования("", ТаблицаПользователей, Ложь, Истина);
		Для Каждого СтрокаТаблицы Из ТаблицаПользователей Цикл
			Источники.Добавить(СтрокаТаблицы.Пользователь);
		КонецЦикла;
		
	КонецЕсли;
	
	Обработки.НастройкиПользователей.УдалитьНастройкиПользователей(МассивНастроек, Источники,, Истина);
	
КонецПроцедуры

&НаСервере
Процедура ОчиститьУстаревшиеНастройки()
	
	Источники = ?(ПереключательКомуОчищатьНастройки = "ВыбраннымПользователям", 
		ВыбранныеПользователи.ВыгрузитьЗначения(), Неопределено);
	Обработки.НастройкиПользователей.УдалитьУстаревшиеНастройкиПользователей(Источники);
	
КонецПроцедуры

#КонецОбласти
