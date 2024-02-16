﻿// Шаблон (заготовка для копирования) разделов для общих модулей:
//Раздел «Программный интерфейс» содержит экспортные процедуры и функции, предназначенные для использования другими объектами конфигурации или другими программами (например, через внешнее соединение).
//Раздел «Служебный программный интерфейс»  предназначен для модулей, которые являются частью некоторой функциональной подсистемы. В нем должны быть размещены экспортные процедуры и функции, которые допустимо вызывать только из других функциональных подсистем этой же библиотеки.
//Раздел «Служебные процедуры и функции» содержит процедуры и функции, составляющие внутреннюю реализацию общего модуля. В тех случаях, когда общий модуль является частью некоторой функциональной подсистемы, включающей в себя несколько объектов метаданных, в этом разделе также могут быть размещены служебные экспортные процедуры и функции, предназначенные только для вызова из других объектов данной подсистемы.

////////////////////////////////////////////////////////////////////////////////
// <Заголовок модуля> 
// -<Описание модуля>
//
// Например:
// Клиентские процедуры и функции общего назначения:
// - для работы со списками в формах;
// - для работы с журналом регистрации;
// - для обработки действий пользователя в процессе редактирования
//   многострочного текста, например комментария в документах;
// - прочее.
//
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс // Public
#Область СозданиеНовыхЗадач
// Нужно стараться использовать информацию из отборов и мест вызова
// В первую очередь беремся за текущую строку и тянем данные из нее
// Если текущая строка это группировка, то родителя стоит поискать из отборов, а реквизиты собирать из группировок (срочность, место, и тд)


Процедура СоздатьРебенка(ПараметрКоманды, ПараметрыВыполненияКоманды) Экспорт
	ЗначенияЗаполнения = Новый Структура();
	ЗначенияЗаполнения.Вставить("ПараметрКоманды", ПараметрКоманды);
	ЗначенияЗаполнения.Вставить("Родитель", ПараметрыВыполненияКоманды.Источник.ТекущаяЗадача);
	//ЗначенияЗаполнения.Вставить("",);
	
	ПараметрыФормы = Новый Структура("ЗначенияЗаполнения", ЗначенияЗаполнения);
	
	ОткрытьФорму("Справочник.Задачи.ФормаОбъекта", ПараметрыФормы, ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно, ПараметрыВыполненияКоманды.НавигационнаяСсылка);
КонецПроцедуры

Процедура СоздатьСоседа(ПараметрКоманды, ПараметрыВыполненияКоманды) Экспорт
	ЗначенияЗаполнения = Новый Структура();
	ЗначенияЗаполнения.Вставить("ПараметрКоманды", ПараметрКоманды);
	ЗначенияЗаполнения.Вставить("Родитель", ПараметрыВыполненияКоманды.Источник.ТекущаяЗадача.Родитель);
	//ЗначенияЗаполнения.Вставить("",);
	
	ПараметрыФормы = Новый Структура("ЗначенияЗаполнения", ЗначенияЗаполнения);
	
	ОткрытьФорму("Справочник.Задачи.ФормаОбъекта", ПараметрыФормы, ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно, ПараметрыВыполненияКоманды.НавигационнаяСсылка);
КонецПроцедуры
#КонецОбласти // СозданиеНовыхЗадач
#КонецОбласти // ПрограммныйИнтерфейс

