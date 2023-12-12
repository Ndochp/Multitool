﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Возникает при запуске приложения до открытия главного окна. 
// В процедуре-обработчике могут быть выполнены необходимые проверки и, при необходимости, установлен параметр отказа 
// от запуска приложения. Соответствует обработчику ПередНачаломРаботыСистемы.
//
// При работе в модели сервиса обработчик вызывается также:
// - при запуске сеанса администратора без установленных значений разделителей;
// - при входе администратора в область данных из сеанса без установленных значений разделителей.
// Для проверки режима запуска см. функцию ОбщегоНазначенияКлиент.ДоступноИспользованиеРазделенныхДанных.
//
// Параметры:
//  Параметры - Структура:
//   * Отказ         - Булево - возвращаемое значение. Если установить Истина, то работа программы будет прекращена.
//   * Перезапустить - Булево - возвращаемое значение. Если установить Истина, и параметр Отказ тоже установлен
//                              в Истина, то выполняется перезапуск программы.
// 
//   * ДополнительныеПараметрыКоманднойСтроки - Строка - возвращаемое значение. Имеет смысл, когда Отказ
//                              и Перезапустить установлены Истина.
//
//   * ИнтерактивнаяОбработка - ОписаниеОповещения - возвращаемое значение. Для открытия окна, блокирующего вход в
//                              программу, следует присвоить в этот параметр описание обработчика
//                              оповещения, который открывает окно. 
//
//   * ОбработкаПродолжения   - ОписаниеОповещения - если открывается окно, блокирующее вход в программу, то в обработке
//                              закрытия этого окна необходимо выполнить оповещение ОбработкаПродолжения. 
//
//   * Модули                 - Массив - ссылки на модули, в которых нужно вызвать эту же процедуру после возврата.
//                              Модули можно добавлять только в рамках вызова в процедуру переопределяемого модуля.
//                              Используется для упрощения реализации нескольких последовательных асинхронных вызовов
//                              в разные подсистемы. См. пример ИнтеграцияПодсистемБСПКлиент.ПередНачаломРаботыСистемы.
//
// Пример:
//  Следующий код открывает окно, блокирующее вход в программу.
//
//		Если ОткрытьОкноПриЗапуске Тогда
//			Параметры.ИнтерактивнаяОбработка = Новый ОписаниеОповещения("ОткрытьОкно", ЭтотОбъект);
//		КонецЕсли;
//
//	Процедура ОткрытьОкно(Параметры, ДополнительныеПараметры) Экспорт
//		// Показываем окно, по закрытию которого вызывается обработчик оповещения ОткрытьОкноЗавершение.
//		Оповещение = Новый ОписаниеОповещения("ОткрытьОкноЗавершение", ЭтотОбъект, Параметры);
//		Форма = ОткрытьФорму(... ,,, ... Оповещение);
//		Если Не Форма.Открыта() Тогда // Если ПриСозданииНаСервере Отказ установлен Истина.
//			ВыполнитьОбработкуОповещения(Параметры.ОбработкаПродолжения);
//		КонецЕсли;
//	КонецПроцедуры
//
//	Процедура ОткрытьОкноЗавершение(Результат, Параметры) Экспорт
//		...
//		ВыполнитьОбработкуОповещения(Параметры.ОбработкаПродолжения);
//		
//	КонецПроцедуры
//
Процедура ПередНачаломРаботыСистемы(Параметры) Экспорт
	
КонецПроцедуры

// Возникает при запуске приложения после открытия главного окна. 
// В процедуре-обработчике могут быть выполнены различные действия, необходимые при запуске программы, например, 
// открыты некоторые формы. Соответствует обработчику ПриНачалеРаботыСистемы.
//
// При работе в модели сервиса обработчик вызывается также:
// - при запуске сеанса администратора без установленных значений разделителей;
// - при входе администратора в область данных из сеанса без установленных значений разделителей.
// Для проверки режима запуска см. функцию ОбщегоНазначенияКлиент.ДоступноИспользованиеРазделенныхДанных.
//
// Параметры:
//  Параметры - Структура:
//   * Отказ         - Булево - возвращаемое значение. Если установить Истина, то работа программы будет прекращена.
//   * Перезапустить - Булево - возвращаемое значение. Если установить Истина и параметр Отказ тоже установлен
//                              в Истина, то выполняется перезапуск программы.
//
//   * ДополнительныеПараметрыКоманднойСтроки - Строка - возвращаемое значение. Имеет смысл
//                              когда Отказ и Перезапустить установлены Истина.
//
//   * ИнтерактивнаяОбработка - ОписаниеОповещения - возвращаемое значение. Для открытия окна, блокирующего вход
//                              в программу, следует присвоить в этот параметр описание обработчика оповещения,
//                              который открывает окно. См. пример в ПередНачаломРаботыСистемы.
//
//   * ОбработкаПродолжения   - ОписаниеОповещения - если открывается окно, блокирующее вход в программу, то в
//                              обработке закрытия этого окна необходимо выполнить оповещение ОбработкаПродолжения.
//                              
//   * Модули                 - Массив - ссылки на модули, в которых нужно вызвать эту же процедуру после возврата.
//                              Модули можно добавлять только в рамках вызова в процедуру переопределяемого модуля.
//                              Используется для упрощения реализации нескольких последовательных асинхронных вызовов
//                              в разные подсистемы. См. пример ИнтеграцияПодсистемБСПКлиент.ПередНачаломРаботыСистемы.
//
Процедура ПриНачалеРаботыСистемы(Параметры) Экспорт
	
	
	
	
	
КонецПроцедуры

// Вызывается для обработки собственных параметров запуска программы,
// передаваемых с помощью ключа командной строки /C, например: 
// 1cv8.exe /C РежимОтладки;ОткрытьИЗакрыть
//
// Параметры:
//  ПараметрыЗапуска  - Массив из Строка - строки, разделенные символом ";" в параметре запуска,
//                      которые переданы в конфигурацию с помощью ключа командной строки /C.
//  Отказ             - Булево - если установить Истина, то запуск будет прерван.
//
Процедура ПриОбработкеПараметровЗапуска(ПараметрыЗапуска, Отказ) Экспорт
	
КонецПроцедуры

// Выполняется при запуске приложения после завершения действий ПриНачалеРаботыСистемы.
// Используется для подключения обработчиков ожидания, которые не должны вызываться
// перед и при начале работы системы.
//
// Начальная страница (рабочий стол) в этот момент еще не открыта, поэтому запрещено открывать
// формы напрямую, а следует использовать для этих целей обработчик ожидания.
// Запрещено использовать это событие для интерактивного взаимодействия с пользователем
// (ПоказатьВопрос и аналогичные действия). Для этих целей следует размещать код в процедуре ПриНачалеРаботыСистемы.
//
Процедура ПослеНачалаРаботыСистемы() Экспорт
	
КонецПроцедуры

// Возникает перед завершением работы приложения до закрытия главного окна. 
// В процедуре-обработчике могут быть выполнены необходимые проверки и, при необходимости, может быть установлен 
// параметр отказа от выхода из программы. 
// Позволяет определить список предупреждений, выводимых пользователю перед завершением работы.
// В процессе завершения работы приложения запрещены серверные вызовы и  открытие окон. 
// Соответствует обработчику ПередЗавершениемРаботыСистемы.
//
// При работе в модели сервиса обработчик вызывается также:
// - при завершении сеанса администратора без установленных значений разделителей;
// - при выходе администратора из области данных в сеанса без установленных значений разделителей.
// Для проверки режима запуска см. функцию ОбщегоНазначенияКлиент.ДоступноИспользованиеРазделенныхДанных.
//
// Параметры:
//  Отказ          - Булево - если установить данному параметру значение Истина, то работа с программой не будет 
//                            завершена.
//  Предупреждения - Массив из см. СтандартныеПодсистемыКлиент.ПредупреждениеПриЗавершенииРаботы - 
//                            можно добавить сведения о внешнем виде предупреждения и дальнейших действиях.
//
Процедура ПередЗавершениемРаботыСистемы(Отказ, Предупреждения) Экспорт
	
КонецПроцедуры

// Позволяет переопределить заголовок приложения.
//
// Параметры:
//  ЗаголовокПриложения - Строка - текст заголовка приложения;
//  ПриЗапуске          - Булево - Истина, если вызывается при начале работы приложения.
//                                 В этом случае недопустимо вызывать те серверные функции конфигурации,
//                                 которые рассчитывают на то, что запуск уже полностью завершен. 
//                                 Например, вместо СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиента
//                                 следует вызывать СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске. 
//
// Пример:
//  Для того чтобы в начале заголовка приложения вывести название текущего проекта, следует определить параметр 
//  ТекущийПроект в процедуре ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиента и вписать код:
//
//	Если Не ОбщегоНазначенияКлиент.ДоступноИспользованиеРазделенныхДанных() Тогда
//		Возврат;
//	КонецЕсли;
//	ПараметрыКлиента = ?(ПриЗапуске, СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиентаПриЗапуске(),
//		СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиента());
//	Если ПараметрыКлиента.Свойство("ТекущийПроект")
//	   И ЗначениеЗаполнено(ПараметрыКлиента.ТекущийПроект) Тогда
//		ЗаголовокПриложения = Строка(ПараметрыКлиента.ТекущийПроект) + " / " + ЗаголовокПриложения;
//	КонецЕсли;
//
Процедура ПриУстановкеЗаголовкаКлиентскогоПриложения(ЗаголовокПриложения, ПриЗапуске) Экспорт
	
	
	
КонецПроцедуры

// Вызывается из глобального обработчика ожидания каждые 60 сек
// для возможности централизованно передать данные с клиента на сервер.
// Например, для передачи статистики о количестве открытых окон.
// Не рекомендуется делать собственные глобальные обработчики ожидания,
// чтобы минимизировать общее количество серверных вызовов.
//
// Не рекомендуется передавать данные каждые 60 сек, а делать это реже
// в зависимости от реальной необходимости (ориентироваться на один раз в 20 минут).
// Не рекомендуется передавать избыточно большой объем данных,
// так как это уменьшает отзывчивость клиентского приложения.
//
// Для отправки данных с клиента на сервер заполните параметр Параметры,
// который затем будет передан в процедуру
// ОбщегоНазначенияПереопределяемый.ПриПериодическомПолученииДанныхКлиентаНаСервере.
//
// Параметры:
//  Параметры - Соответствие из КлючИЗначение:
//    * Ключ     - Строка       - имя параметра, передаваемого на сервер.
//    * Значение - Произвольный - значение параметра, передаваемого на сервер.
//
// Пример:
//	МоментНачала = ТекущаяУниверсальнаяДатаВМиллисекундах();
//	Попытка
//		Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ЦентрМониторинга") Тогда
//			МодульЦентрМониторингаКлиентСлужебный = ОбщегоНазначенияКлиент.ОбщийМодуль("ЦентрМониторингаКлиентСлужебный");
//			МодульЦентрМониторингаКлиентСлужебный.ПередПериодическойОтправкойДанныхКлиентаНаСервер(Параметры);
//		КонецЕсли;
//	Исключение
//		СерверныеОповещенияКлиент.ОбработатьОшибку(ИнформацияОбОшибке());
//	КонецПопытки;
//	СерверныеОповещенияКлиент.ДобавитьПоказатель(МоментНачала,
//		"ЦентрМониторингаКлиентСлужебный.ПередПериодическойОтправкойДанныхКлиентаНаСервер");
//
Процедура ПередПериодическойОтправкойДанныхКлиентаНаСервер(Параметры) Экспорт
	
КонецПроцедуры

// Вызывается из глобального обработчика ожидания каждые 60 сек после возврата с сервера.
// Требуется, когда сервер возвращает результат для обработки на клиенте.
// Например, признак дальнейшей передачи статистики с клиента на сервер.
//
// Для получения результатов сервера на клиенте они должны быть заполнены
// в параметре Результаты в процедуре
// ОбщегоНазначенияПереопределяемый.ПриПериодическомПолученииДанныхКлиентаНаСервере.
//
// Параметры:
//  Результаты - Соответствие из КлючИЗначение:
//    * Ключ     - Строка       - имя параметра, возвращенного с сервера.
//    * Значение - Произвольный - значение параметра, возвращенного с сервера.
//
// Пример:
//	МоментНачала = ТекущаяУниверсальнаяДатаВМиллисекундах();
//	Попытка
//		Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ЦентрМониторинга") Тогда
//			МодульЦентрМониторингаКлиентСлужебный = ОбщегоНазначенияКлиент.ОбщийМодуль("ЦентрМониторингаКлиентСлужебный");
//			МодульЦентрМониторингаКлиентСлужебный.ПослеПериодическогоПолученияДанныхКлиентаНаСервере(Результаты);
//		КонецЕсли;
//	Исключение
//		СерверныеОповещенияКлиент.ОбработатьОшибку(ИнформацияОбОшибке());
//	КонецПопытки;
//	СерверныеОповещенияКлиент.ДобавитьПоказатель(МоментНачала,
//		"ЦентрМониторингаКлиентСлужебный.ПослеПериодическогоПолученияДанныхКлиентаНаСервере");
//
Процедура ПослеПериодическогоПолученияДанныхКлиентаНаСервере(Результаты) Экспорт
	
КонецПроцедуры

#КонецОбласти
