﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем РеквизитыПроверкиАдреса;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПоказыватьПерсональныеДанные = Параметры.ПоказыватьПерсональныеДанные;
	
	ЗаполнитьСписокВидовДокументов();
	
	Ссылка = Параметры.Ссылка;
	
	Если Параметры.РедактированиеТаблицы Тогда
		ТипСсылкиСтрока = "ФизическоеЛицо";
		МашиночитаемыеДоверенностиФНССлужебный.ЗаполнитьТипыЗначения(ТипСсылкиСтрока,
			ТипСсылки, Элементы.Ссылка1);
		Если ТипСсылки <> Неопределено Тогда 
			ТипСсылкиМассив = ТипСсылки.ВыгрузитьЗначения();
			Элементы.Ссылка1.ОграничениеТипа = Новый ОписаниеТипов(ТипСсылкиМассив);
			Элементы.Ссылка1.Видимость = Истина;
		Иначе
			Элементы.Ссылка1.Видимость = Ложь;
			ТипСсылки = Неопределено;
		КонецЕсли;
	КонецЕсли;
		
	ЗаполнитьСведенияОФизическомЛице(ЭтотОбъект, Параметры.Реквизиты);
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.КонтактнаяИнформация") Тогда
		
		МодульУправлениеКонтактнойИнформацией = ОбщегоНазначения.ОбщийМодуль("УправлениеКонтактнойИнформацией");
		ВидКонтактнойИнформации = МодульУправлениеКонтактнойИнформацией.ПараметрыВидаКонтактнойИнформации(
			Перечисления["ТипыКонтактнойИнформации"].Адрес);
			
		ВидКонтактнойИнформации.НастройкиПроверки.ТолькоНациональныйАдрес = Истина;
		
		ВидКонтактнойИнформацииТелефон = МодульУправлениеКонтактнойИнформацией.ПараметрыВидаКонтактнойИнформации(
			Перечисления["ТипыКонтактнойИнформации"].Телефон);
		
	КонецЕсли;
	
	Если СведенияОФизическомЛице.ЭтоФизическоеЛицо Тогда
		ПроверитьАдрес("АдресРегистрации");
	КонецЕсли;
	
	Если Параметры.ТолькоПросмотр Тогда
		Элементы.ВсеЭлементы.ТолькоПросмотр = Истина;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Параметры.Поле) Тогда
		Элементы[Параметры.Поле].АктивизироватьПоУмолчанию = Истина;
	КонецЕсли;
	
	СтандартныеПодсистемыСервер.СброситьРазмерыИПоложениеОкна(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	РеквизитыПроверкиАдреса = Новый Структура;
	РеквизитыПроверкиАдреса.Вставить("АдресРегистрации", Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если Не Модифицированность Тогда
		Возврат;
	КонецЕсли;
	
	Отказ = Истина;
	СтандартнаяОбработка = Ложь;
	ЗадатьВопросПередЗакрытием();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия <> "ИзменениеСведенийОФизическомЛице" Тогда
		Возврат;
	КонецЕсли;
	
	ОчиститьСообщения();
	ЗаполнитьСведенияОФизическомЛице(ЭтотОбъект, Параметр);
	
	Если СведенияОФизическомЛице.ЭтоФизическоеЛицо Тогда
		РеквизитыПроверкиАдреса.АдресРегистрации = Истина;
		ПодключитьОбработчикОжидания("ПроверитьАдресОбработчикОжидания", 0.1, Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура РеквизитПриИзменении(Элемент)
	
	Модифицированность = Истина;
	Если ТипЗнч(ЭтотОбъект[Элемент.Имя]) = Тип("Строка") Тогда
		ЭтотОбъект[Элемент.Имя] = СокрЛП(ЭтотОбъект[Элемент.Имя]);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СтраховойНомерПФРПриИзменении(Элемент)
	
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ГражданствоПриИзменении(Элемент)
	
	Модифицированность = Истина;
	
	Если ЗначениеЗаполнено(Гражданство) Тогда
		БезГражданства = Ложь;
	КонецЕсли;
	
	ПриИзмененииГражданства(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура БезГражданстваПриИзменении(Элемент)
	
	Модифицированность = Истина;
	Если БезГражданства Тогда
		Гражданство = Неопределено;
	КонецЕсли;
	
	ПриИзмененииГражданства(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ДокументВидПриИзменении(Элемент)
	
	Модифицированность = Истина;
	ПриИзмененииВидаДокумента(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ДокументВидОчистка(Элемент, СтандартнаяОбработка)
	
	Модифицированность = Истина;
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ДокументНомерПриИзменении(Элемент)
	
	Модифицированность = Истина;
	Если ДокументВид = "21" Тогда
		ДокументНомер = МашиночитаемыеДоверенностиФНССлужебныйКлиентСервер.ТолькоЦифры(ДокументНомер);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДокументДатаВыдачиПриИзменении(Элемент)
	
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ДокументКодПодразделенияПриИзменении(Элемент)
	
	Модифицированность = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ВладелецАдресРегистрацииНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ПредставлениеАдресаНачалоВыбора(ЭтотОбъект, Элемент, ДанныеВыбора, СтандартнаяОбработка,
		"АдресРегистрации", НСтр("ru = 'Адрес регистрации физического лица'"));
	
КонецПроцедуры

&НаКлиенте
Процедура ВладелецАдресРегистрацииОчистка(Элемент, СтандартнаяОбработка)
	
	ПредставлениеАдресаОчистка(ЭтотОбъект, Элемент, СтандартнаяОбработка, "АдресРегистрации");
	
КонецПроцедуры

&НаКлиенте
Процедура ВладелецАдресРегистрацииОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Модифицированность = Истина;
	ПредставлениеАдресаОбработкаВыбора(ЭтотОбъект, Элемент, ВыбранноеЗначение, СтандартнаяОбработка, "АдресРегистрации");
	
КонецПроцедуры

&НаКлиенте
Процедура АдресПредупреждениеНажатие(Элемент)
	
	ПоказатьПредупреждение(, Элемент.Подсказка);
	
КонецПроцедуры

&НаКлиенте
Процедура ВладелецТелефонНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ПредставлениеТелефонаНачалоВыбора(ЭтотОбъект, Элемент, ДанныеВыбора, СтандартнаяОбработка,
		"Телефон", НСтр("ru = 'Телефон'"));
	
КонецПроцедуры

&НаКлиенте
Процедура ВладелецТелефонОчистка(Элемент, СтандартнаяОбработка)
	
	Модифицированность = Истина;
	ПредставлениеТелефонаОчистка(ЭтотОбъект, Элемент, СтандартнаяОбработка, "Телефон");
	
КонецПроцедуры

&НаКлиенте
Процедура ВладелецТелефонОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Модифицированность = Истина;
	ПредставлениеТелефонаОбработкаВыбора(ЭтотОбъект, Элемент, ВыбранноеЗначение, СтандартнаяОбработка, "Телефон");
	
КонецПроцедуры

&НаКлиенте
Процедура Ссылка1ПриИзменении(Элемент)

	ЗаполнитьРеквизитыОрганизации(ТипСсылкиСтрока, Ссылка);
	УправлениеВидимостью(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	СохранитьИзмененияИЗакрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	
	ЗадатьВопросПередЗакрытием();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗадатьВопросПередЗакрытием()
	
	Если Не Модифицированность Тогда
		Закрыть(Неопределено);
		Возврат;
	КонецЕсли;
	
	ПоказатьВопрос(Новый ОписаниеОповещения("ЗакрытиеПослеОтветаНаВопрос", ЭтотОбъект),
		НСтр("ru = 'Данные были изменены. Сохранить изменения?'"), РежимДиалогаВопрос.ДаНетОтмена);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытиеПослеОтветаНаВопрос(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		Модифицированность = Ложь;
		Закрыть(Неопределено);
	ИначеЕсли Ответ = КодВозвратаДиалога.Да Тогда
		СохранитьИзмененияИЗакрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьИзмененияИЗакрыть()
	
	ОчиститьСообщения();
	
	Если Не ПроверитьСведенияОФизическомЛице() Тогда
		Если Не Элементы.ВсеЭлементы.ТолькоПросмотр Тогда
			ПоказатьВопрос(Новый ОписаниеОповещения("СохранениеПослеОтветаНаВопрос", ЭтотОбъект),
				НСтр("ru = 'Есть ошибки. Все равно сохранить изменения?'"),
				РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
		КонецЕсли;
		Возврат;
	КонецЕсли;
	
	Если Не Модифицированность Тогда
		Закрыть(Неопределено);
		Возврат;
	КонецЕсли;
	
	СохранениеПослеОтветаНаВопрос(КодВозвратаДиалога.Да, Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура СохранениеПослеОтветаНаВопрос(Ответ, Контекст) Экспорт
	
	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ПодготовитьИзмененияНаСервере();
	
	Модифицированность = Ложь;
	Закрыть(СведенияОФизическомЛице);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ПриИзмененииВидаДокумента(Форма)
	
	Если Форма.ДокументВид = "" Тогда
		Форма.ДокументВид = "21";
	КонецЕсли;
	
	Элементы = Форма.Элементы;
	
	Если Форма.ДокументВид = "0" Тогда

		Форма.ДокументНомер = "";
		Форма.ДокументКемВыдан = "";
		Форма.ДокументДатаВыдачи = "";
		Форма.ДокументКодПодразделения = "";
		Форма.ДокументСрокДействия = "";
		
	ИначеЕсли Форма.ДокументВид = "21" Тогда
		Элементы.ДокументНомер.Заголовок = НСтр("ru = 'Серия и номер'");
		Элементы.ДокументНомер.Маска = "99 99 999999";
		Элементы.ДокументКодПодразделения.Видимость = Истина;
	Иначе
		Элементы.ДокументСрокДействия.Видимость = Форма.ДокументВид = "22";
		Элементы.ДокументНомер.Заголовок = НСтр("ru = 'Номер'");
		Элементы.ДокументНомер.Маска = "";
		Элементы.ДокументКодПодразделения.Видимость = Ложь;
		Форма.ДокументКодПодразделения = "";
	КонецЕсли;
	
	Если Форма.ДокументВид = 91 Тогда
		Форма.ДокументВид = "";
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ПриИзмененииГражданства(Форма)
	
	Форма.Элементы.Гражданство.Видимость = Не Форма.БезГражданства;
	Форма.Элементы.БезГражданства.Видимость = Не ЗначениеЗаполнено(Форма.Гражданство);
	
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеАдресаНачалоВыбора(Форма, Элемент, ДанныеВыбора, СтандартнаяОбработка, ИмяРеквизита, ЗаголовокФормы)
	
	Если Не ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.КонтактнаяИнформация") Тогда
		Возврат;
	КонецЕсли;
	
	МодульУправлениеКонтактнойИнформациейКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль(
		"УправлениеКонтактнойИнформациейКлиент");
	
	УстановитьНаименованиеКонтактнойИнформации(ВидКонтактнойИнформации, ЗаголовокФормы);
	ПараметрыФормы = МодульУправлениеКонтактнойИнформациейКлиент.ПараметрыФормыКонтактнойИнформации(
		ВидКонтактнойИнформации, ЭтотОбъект[ИмяРеквизита + "Значение"], ЭтотОбъект[ИмяРеквизита]);
	
	МодульУправлениеКонтактнойИнформациейКлиент.ОткрытьФормуКонтактнойИнформации(ПараметрыФормы, Элемент);
	
КонецПроцедуры

// Параметры:
//  ВидКИ - см. УправлениеКонтактнойИнформацией.ПараметрыВидаКонтактнойИнформации
//  ЗаголовокФормы - Строка
//
&НаКлиенте
Процедура УстановитьНаименованиеКонтактнойИнформации(ВидКИ, ЗаголовокФормы)
	ВидКИ.Наименование = ЗаголовокФормы;
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеАдресаОчистка(Форма, Элемент, СтандартнаяОбработка, ИмяРеквизита)
	
	Форма[ИмяРеквизита + "Значение"] = "";
	Форма[ИмяРеквизита] = "";
	
	РеквизитыПроверкиАдреса[ИмяРеквизита] = Истина;
	ПодключитьОбработчикОжидания("ПроверитьАдресОбработчикОжидания", 0.1, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеАдресаОбработкаВыбора(Форма, Элемент, ВыбранноеЗначение, СтандартнаяОбработка, ИмяРеквизита)
	
	СтандартнаяОбработка = Ложь;
	Если ТипЗнч(ВыбранноеЗначение) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	Форма[ИмяРеквизита + "Значение"] = ВыбранноеЗначение.КонтактнаяИнформация;
	Форма[ИмяРеквизита] = ВыбранноеЗначение.Представление;
	
	РеквизитыПроверкиАдреса[ИмяРеквизита] = Истина;
	ПодключитьОбработчикОжидания("ПроверитьАдресОбработчикОжидания", 0.1, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеТелефонаНачалоВыбора(Форма, Элемент, ДанныеВыбора, СтандартнаяОбработка, ИмяРеквизита, ЗаголовокФормы)
	
	Если Не ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.КонтактнаяИнформация") Тогда
		Возврат;
	КонецЕсли;
	
	МодульУправлениеКонтактнойИнформациейКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль(
		"УправлениеКонтактнойИнформациейКлиент");
	
	ПараметрыФормы = МодульУправлениеКонтактнойИнформациейКлиент.ПараметрыФормыКонтактнойИнформации(
		ВидКонтактнойИнформацииТелефон, ЭтотОбъект[ИмяРеквизита + "Значение"], ЭтотОбъект[ИмяРеквизита]);
	
	ПараметрыФормы.Вставить("Заголовок", ЗаголовокФормы);
	
	МодульУправлениеКонтактнойИнформациейКлиент.ОткрытьФормуКонтактнойИнформации(ПараметрыФормы, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеТелефонаОчистка(Форма, Элемент, СтандартнаяОбработка, ИмяРеквизита)
	
	Форма[ИмяРеквизита + "Значение"] = "";
	Форма[ИмяРеквизита] = "";
	
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеТелефонаОбработкаВыбора(Форма, Элемент, ВыбранноеЗначение, СтандартнаяОбработка, ИмяРеквизита)
	
	СтандартнаяОбработка = Ложь;
	Если ТипЗнч(ВыбранноеЗначение) <> Тип("Структура") Тогда
		// Данные не изменены.
		Возврат;
	КонецЕсли;
	
	Форма[ИмяРеквизита + "Значение"] = ВыбранноеЗначение.КонтактнаяИнформация;
	Форма[ИмяРеквизита] = ВыбранноеЗначение.Представление;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьАдресОбработчикОжидания()
	
	Для Каждого КлючИЗначение Из РеквизитыПроверкиАдреса Цикл
		
		Если КлючИЗначение.Значение Тогда
			ПроверитьАдрес(КлючИЗначение.Ключ);
			РеквизитыПроверкиАдреса[КлючИЗначение.Ключ] = Ложь;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьАдрес(ИмяРеквизита)

	Сообщение = МашиночитаемыеДоверенностиФНССлужебный.ПроверитьАдрес(ЭтотОбъект[ИмяРеквизита + "Значение"],
		СведенияОФизическомЛице.ЭтоФизическоеЛицо);
	
	Если Не ТолькоПросмотр И ЗначениеЗаполнено(Сообщение) Тогда
		Элементы[ИмяРеквизита + "Предупреждение"].Подсказка = Сообщение;
		Элементы[ИмяРеквизита + "Предупреждение"].Видимость = Истина;
	Иначе
		Элементы[ИмяРеквизита + "Предупреждение"].Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПодготовитьИзмененияНаСервере()
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.КонтактнаяИнформация") Тогда
		МодульУправлениеКонтактнойИнформацией = ОбщегоНазначения.ОбщийМодуль("УправлениеКонтактнойИнформацией");
		ЭлектроннаяПочтаЗначение = МодульУправлениеКонтактнойИнформацией.КонтактнаяИнформацияВJSON(
			ЭлектроннаяПочта, Перечисления["ТипыКонтактнойИнформации"].АдресЭлектроннойПочты);
	КонецЕсли;
		
	РеквизитыУчастникаДляХранения = МашиночитаемыеДоверенностиФНССлужебныйКлиентСервер.РеквизитыУчастникаДляХранения(ЭтотОбъект);
	ОбщегоНазначенияКлиентСервер.ДополнитьСтруктуру(СведенияОФизическомЛице, РеквизитыУчастникаДляХранения, Ложь);
	ЗаполнитьЗначенияСвойств(СведенияОФизическомЛице, ЭтотОбъект);
	
	Если Параметры.РедактированиеТаблицы Тогда
		СведенияОФизическомЛице.Вставить("Ссылка", Ссылка);
	КонецЕсли;
	
	Если ДокументВид = "00" Тогда
		СведенияОФизическомЛице.ДокументВид = "";
		СведенияОФизическомЛице.ДокументКемВыдан = "";
		СведенияОФизическомЛице.ДокументКодПодразделения = "";
		СведенияОФизическомЛице.ДокументНомер = "";
		СведенияОФизическомЛице.ДокументДатаВыдачи = Дата(1,1,1);
		СведенияОФизическомЛице.ДокументСрокДействия = Дата(1,1,1);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

&НаСервере
Функция ПроверитьСведенияОФизическомЛице()
	
	Возврат МашиночитаемыеДоверенностиФНССлужебный.ПроверитьСведенияОбОрганизации(ЭтотОбъект, СведенияОФизическомЛице);
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьСведенияОФизическомЛице(Форма, СведенияОФизическомЛице)
	
	Форма.АвтоЗаголовок = Ложь;
	Форма.Заголовок = НСтр("ru = 'Сведения о физическом лице'");
	
	СведенияОФизическомЛице = ?(ЭтоАдресВременногоХранилища(СведенияОФизическомЛице),
	ПолучитьИзВременногоХранилища(СведенияОФизическомЛице), СведенияОФизическомЛице);
	ЗаполнитьЗначенияСвойств(Форма, СведенияОФизическомЛице);
	Форма.СведенияОФизическомЛице = СведенияОФизическомЛице;
	
	Если Форма.СведенияОФизическомЛице.Пол = "Мужской" Тогда
		Форма.Пол = 1;
	ИначеЕсли Форма.СведенияОФизическомЛице.Пол = "Женский" Тогда
		Форма.Пол = 2;
	КонецЕсли;
	
	ПриИзмененииВидаДокумента(Форма);
	ПриИзмененииГражданства(Форма);
	
	Элементы = Форма.Элементы;
	ЭтоДолжностноеЛицо = Форма.СведенияОФизическомЛице.ЭтоДолжностноеЛицо;
	ЭтоИндивидуальныйПредприниматель = Форма.СведенияОФизическомЛице.ЭтоИндивидуальныйПредприниматель;
	ЭтоФизическоеЛицо = Не Форма.ЭтоДолжностноеЛицо И Не Форма.ЭтоИндивидуальныйПредприниматель;

	Если ЭтоДолжностноеЛицо = Неопределено Или Не ЭтоДолжностноеЛицо Тогда
		Форма.ДолжностьЛицаДоверителя = "";
	Иначе
		Форма.Заголовок = НСтр("ru='Сведения о должностном лице'");
	КонецЕсли;
	
	Если ЭтоИндивидуальныйПредприниматель = Истина Тогда
		Форма.Заголовок = НСтр("ru='Сведения об индивидуальном предпринимателе'");
		Форма.ИННФЛ = "";
	КонецЕсли;

	УправлениеВидимостью(Форма);
	
	Форма.Модифицированность = Ложь;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеВидимостью(Форма)
	
	СписокРеквизитов = МашиночитаемыеДоверенностиФНССлужебныйКлиентСервер.РеквизитыФизическогоЛицаСписок(Ложь,
		МашиночитаемыеДоверенностиФНССлужебныйКлиентСервер.ОпределитьВидУчастника(Форма));
		
	Если Не Форма.ПоказыватьПерсональныеДанные Тогда
		ПерсональныеДанные = МашиночитаемыеДоверенностиФНССлужебныйКлиентСервер.ПерсональныеДанные();	
	КонецЕсли;
	
	Для Каждого Элемент Из Форма.Элементы Цикл
		
		Если Элемент.Имя = "Ссылка1" Тогда
			Продолжить;
		КонецЕсли;
		
		Если Элемент.Вид <> ВидПоляФормы.ПолеВвода Тогда
			Продолжить;
		КонецЕсли;
		
		Реквизит = СписокРеквизитов.НайтиПоЗначению(Элемент.Имя);
		Если Реквизит <> Неопределено Тогда
			Если Не Форма.ПоказыватьПерсональныеДанные И ПерсональныеДанные.Найти(Элемент.Имя) <> Неопределено Тогда
				Форма.Элементы[Элемент.Имя].Видимость = Ложь;
			Иначе
				Форма.Элементы[Элемент.Имя].АвтоОтметкаНезаполненного = Не Реквизит.Пометка;
				Форма.Элементы[Элемент.Имя].Видимость = Истина;
			КонецЕсли;
		Иначе
			Форма.Элементы[Элемент.Имя].Видимость = Ложь;
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьРеквизитыОрганизации(ОрганизацияТипСтрока, ОрганизацияСсылка)
	
	Если ЗначениеЗаполнено(ОрганизацияСсылка) Тогда
		Реквизиты = МашиночитаемыеДоверенностиФНССлужебныйКлиентСервер.РеквизитыУчастника(
			ТипСсылкиСтрока, Ссылка);
		
		Реквизиты.Вставить("ТипСсылки", ТипСсылки);
		МашиночитаемыеДоверенностиФНССлужебный.ПриЗаполненииРеквизитовОрганизации(Реквизиты);
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, Реквизиты);
	КонецЕсли;
	
	Модифицированность = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокВидовДокументов()
	
	Элементы.ДокументВид.СписокВыбора.Очистить();
	Элементы.ДокументВид.СписокВыбора.Добавить("0", НСтр("ru = 'Не заполнять'"));
	
	Для Каждого ВидДокумента Из МашиночитаемыеДоверенностиФНССлужебный.ВидыДокументовУдостоверяющихЛичность() Цикл
		Элементы.ДокументВид.СписокВыбора.Добавить(ВидДокумента.Код, ВидДокумента.Наименование);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти