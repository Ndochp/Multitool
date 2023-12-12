﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ПрограммноеЗакрытие;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	НастройкиПользователя = Параметры.НастройкиПользователя;
	
	Если НастройкиПользователя <> Неопределено Тогда
		ЗаполнитьСпискиФормы(НастройкиПользователя);
	КонецЕсли;
	
	Если Параметры.Свойство("ПоляЗапроса") 
		И ТипЗнч(Параметры.ПоляЗапроса) = Тип("Соответствие") Тогда
		ЗаполнитьПоляЗапроса(Параметры.ПоляЗапроса);
	КонецЕсли;
	
	УправлениеФормой();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	СервисКриптографииDSSСлужебныйКлиент.ПриОткрытииФормы(ЭтотОбъект, ПрограммноеЗакрытие);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если СервисКриптографииDSSСлужебныйКлиент.ПередЗакрытиемФормы(
			ЭтотОбъект,
			Отказ,
			ПрограммноеЗакрытие,
			ЗавершениеРаботы) Тогда
		ЗакрытьФорму(Неопределено);
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИННПриИзменении(Элемент)

	УправлениеФормой();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СоздатьЗапрос(Команда)
	
	Если ПроверитьПоляЗапроса() Тогда
		ПараметрыЗапроса = ПодготовитьЗапросНаСертификат();
		ЗакрытьФорму(ПараметрыЗапроса);
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗакрытьФорму(ПараметрыЗакрытия = Неопределено)
	
	ПрограммноеЗакрытие = Истина;
	РезультатВызова		= СервисКриптографииDSSКлиент.ОтветСервисаПоУмолчанию(Ложь);
	Если ПараметрыЗакрытия <> Неопределено Тогда
		РезультатВызова.Выполнено = Истина;
		РезультатВызова.Вставить("Результат", ПараметрыЗакрытия);
	КонецЕсли;
	
	Закрыть(РезультатВызова);
	
КонецПроцедуры

&НаКлиенте
Процедура УдостоверяющийЦентрПриИзменении(Элемент)
	
	Элементы.ШаблонСертификата.СписокВыбора.Очистить();
	ЗаполнитьСписокШаблонов(УдостоверяющийЦентр.Шаблоны);
	
	УправлениеФормой();
	
КонецПроцедуры

&НаСервере
Функция ПроверитьПоляЗапроса()
	
	Результат	= Истина;
	Если ЗначениеЗаполнено(УдостоверяющийЦентр) Тогда
		ВсеАтрибуты = СервисКриптографииDSS.ПолучитьРеестрПолейУдостоверяющегоЦентра(УдостоверяющийЦентр);
	Иначе
		ВсеАтрибуты = Новый Массив;
	КонецЕсли;
	
	ВсеОшибки	= Неопределено;
	КодЯзыка 	= СервисКриптографииDSSСлужебный.КодЯзыка();
	
	Для Каждого СтрокаМассива Из ВсеАтрибуты Цикл
		Если НайтиЭлементФормы(СтрокаМассива.Представление) Тогда
			ЗначениеПоля = ЭтотОбъект[СтрокаМассива.Представление];
			Если НЕ ЗначениеЗаполнено(ЗначениеПоля) И СтрокаМассива.Обязательно Тогда
				ТекстОшибки = НСтр("ru = 'Поле: %1 не заполнено'", КодЯзыка);
				ДобавитьОшибкуПользователю(ВсеОшибки, 
					СтрокаМассива.Представление, 
					СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстОшибки, СтрокаМассива.Представление));
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;	
	
	Если НЕ ЗначениеЗаполнено(УдостоверяющийЦентр) Тогда
		ДобавитьОшибкуПользователю(ВсеОшибки, 
			"УдостоверяющийЦентр", 
			НСтр("ru = 'Поле: Удостоверяющий центр не заполнено'", КодЯзыка));
	КонецЕсли;	
	
	Если НЕ ЗначениеЗаполнено(ШаблонСертификата) Тогда
		ДобавитьОшибкуПользователю(ВсеОшибки, 
		"ШаблонСертификата", 
		НСтр("ru = 'Поле: Шаблон сертификата не заполнено'", КодЯзыка));
	КонецЕсли;	
	
	Если НЕ ЗначениеЗаполнено(КриптоПровайдер) Тогда
		ДобавитьОшибкуПользователю(ВсеОшибки, 
		"КриптоПровайдер", 
		НСтр("ru = 'Поле: Криптопровайдер не заполнено'", КодЯзыка));
	КонецЕсли;	
	
	Если ЗначениеЗаполнено(ВсеОшибки) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьОшибкиПользователю(ВсеОшибки);
		Результат = Ложь;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ПодготовитьЗапросНаСертификат(ИмяПоля = "OID")
	
	Результат   	= Новый Структура;
	ПоляАтрибутов	= Новый Соответствие;
	ВсеАтрибуты		= СервисКриптографииDSS.ПолучитьРеестрПолейУдостоверяющегоЦентра(УдостоверяющийЦентр);
	ИмяСертификата	= "";
	
	Для Каждого СтрокаМассива Из ВсеАтрибуты Цикл
		ЗначениеПоля = ЭтотОбъект[СтрокаМассива.Представление];
		Если ЗначениеЗаполнено(ЗначениеПоля) ИЛИ СтрокаМассива.Обязательно Тогда
			ПоляАтрибутов.Вставить(СтрокаМассива[ИмяПоля], ЗначениеПоля);
		КонецЕсли;
		Если ЗначениеЗаполнено(ЗначениеПоля) Тогда
			ИмяСертификата = ИмяСертификата + ?(ПустаяСтрока(ИмяСертификата), "", ",") + СтрокаМассива.Имя + "=" + ЗначениеПоля;
		КонецЕсли;	
	КонецЦикла;	
	
	Результат.Вставить("ПоляАтрибутов", ПоляАтрибутов);
	Результат.Вставить("УдостоверяющийЦентр", СервисКриптографииDSSКлиентСервер.ПолучитьПолеСтруктуры(УдостоверяющийЦентр, "Идентификатор"));
	Результат.Вставить("Криптопровайдер", СервисКриптографииDSSКлиентСервер.ПолучитьПолеСтруктуры(КриптоПровайдер, "Идентификатор"));
	Результат.Вставить("ШаблонСертификата", ШаблонСертификата);
	Результат.Вставить("ИмяСертификата", ИмяСертификата);
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура ЗаполнитьПоляЗапроса(ПоляЗапроса)
	
	ВсеПоля = СервисКриптографииDSSASNКлиентСервер.ОпределитьТип_OID(, "10");
	
	Для каждого СтрокаПоля Из ВсеПоля Цикл
		Представление	= СтрокаПоля.Значение.Представление;
		Если НайтиЭлементФормы(Представление) Тогда
			ЗначениеПоля 	= ПоляЗапроса[СтрокаПоля.Ключ];
			Если НЕ ЗначениеЗаполнено(ЗначениеПоля) Тогда
				ЗначениеПоля = ПоляЗапроса[Представление];
			КонецЕсли;
			ЭтотОбъект[Представление] = ЗначениеПоля;
			Элементы[Представление].Доступность = НЕ ЗначениеЗаполнено(ЗначениеПоля);
		КонецЕсли;
	КонецЦикла;	
	
КонецПроцедуры

// Параметры:
//  ТекущиеНастройки - см. СервисКриптографииDSS.НастройкиПользователяПоУмолчанию
//
&НаСервере
Процедура ЗаполнитьСпискиФормы(ТекущиеНастройки)
	
	Для каждого СтрокаМассива Из ТекущиеНастройки.Политика.УЦ Цикл
		Элементы.УдостоверяющийЦентр.СписокВыбора.Добавить(СтрокаМассива, СтрокаМассива.Имя);
	КонецЦикла;
	
	Если ТекущиеНастройки.Политика.УЦ.Количество() = 1 Тогда
		УдостоверяющийЦентр = ТекущиеНастройки.Политика.УЦ[0];
	КонецЕсли;
	
	Для каждого СтрокаМассива Из ТекущиеНастройки.Политика.Криптопровайдеры Цикл
		Элементы.КриптоПровайдер.СписокВыбора.Добавить(СтрокаМассива, СтрокаМассива.Описание);
	КонецЦикла;
	
	Если ТекущиеНастройки.Политика.Криптопровайдеры.Количество() = 1 Тогда
		КриптоПровайдер = ТекущиеНастройки.Политика.Криптопровайдеры[0];
	КонецЕсли;
	
КонецПроцедуры

// Параметры:
//  Шаблоны - Массив из Структура:
//    * Шаблон 		- Строка
//    * Наименование	- Строка
//
&НаСервере
Процедура ЗаполнитьСписокШаблонов(Шаблоны)

	Для каждого СтрокаМассива Из Шаблоны Цикл
		Элементы.ШаблонСертификата.СписокВыбора.Добавить(СтрокаМассива.Шаблон, СтрокаМассива.Наименование);
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Функция НайтиЭлементФормы(ИмяЭлемента)
	
	Результат = Ложь;
	
	НашлиЭлемент = Элементы.Найти(ИмяЭлемента);
	Если НашлиЭлемент <> Неопределено Тогда
		Результат = Истина;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура УправлениеФормой()
	
	ЭтоЮрЛицо		= ЗначениеЗаполнено(ИННЮЛ);
	ЭлементыФормы 	= Элементы;
	
	СимволОбязательности = "(*)";
	
	// вернем в исходное состояние
	ВсеПоля = СервисКриптографииDSSASNКлиентСервер.ОпределитьТип_OID(, "10");
	Для каждого СтрокаМассива Из ВсеПоля Цикл
		Представление = СтрокаМассива.Значение.Представление;
		Если НайтиЭлементФормы(Представление) Тогда
			ЭлементФормы = ЭлементыФормы[Представление];
			ЭлементФормы.Заголовок = СтрЗаменить(ЭлементФормы.Заголовок, СимволОбязательности, "");
			ЭлементФормы.ТолькоПросмотр = Истина;
			ЭлементФормы.ОтметкаНезаполненного = Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(УдостоверяющийЦентр) Тогда
		ИменаПолей = СервисКриптографииDSS.ПолучитьРеестрПолейУдостоверяющегоЦентра(УдостоверяющийЦентр);
		Для каждого СтрокаМассива Из ИменаПолей Цикл
			Если НайтиЭлементФормы(СтрокаМассива.Представление) Тогда
				ЭлементФормы = ЭлементыФормы[СтрокаМассива.Представление];
				ЭлементФормы.ТолькоПросмотр = Ложь;
				Если СтрокаМассива.Обязательно Тогда
					ЭлементФормы.Заголовок = ЭлементФормы.Заголовок + СимволОбязательности;
					ЭлементФормы.ОтметкаНезаполненного = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;	
	
	ЭлементыФормы.ОГРНИП.Видимость = НЕ ЭтоЮрЛицо;
	ЭлементыФормы.ОГРН.Видимость = ЭтоЮрЛицо;
	
КонецПроцедуры	

&НаСервере
Процедура ДобавитьОшибкуПользователю(
		Ошибки,
		ПолеОшибки,
		ТекстДляОднойОшибки)

	ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю(
		Ошибки, 
		ПолеОшибки, 
		ТекстДляОднойОшибки, 
		Неопределено);

КонецПроцедуры

#КонецОбласти
