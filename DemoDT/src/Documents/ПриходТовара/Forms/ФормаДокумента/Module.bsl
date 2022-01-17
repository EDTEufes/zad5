//////////////////////////////////////////////////////////////////////////////// 
// ПРОЦЕДУРЫ И ФУНКЦИИ
//

// Функция возвращает закупочную цену определенного товара на дату 
// 
// Параметры: 
//  Дата  – Дата – дата, на которую определяется цена. 
//  Товар – СправочникСсылка.Товары – товар, цена которого определяется. 
// 
// Возвращаемое значение: 
//  Число - Цена товара на определенную дату.
&НаСервереБезКонтекста
Функция ПолучитьЦенуТовара(Дата, Товар)

	ВидЦен = Справочники.ВидыЦен.Закупочная;
	ЦенаТовара = РегистрыСведений.ЦеныТоваров.ПолучитьПоследнее(
		Дата, Новый Структура("Товар, ВидЦен", Товар, ВидЦен));

	Возврат ЦенаТовара.Цена;

КонецФункции

// Функция возвращает ссылку на текущую строку в списке товаров 
// 
// Параметры: 
//  Нет. 
// 
// Возвращаемое значение: 
//  СправочникСсылка.Товары - Текущий товар в списке.
&НаКлиенте
Функция ПолучитьТекущуюСтрокуТовары()
	Возврат Элементы.Товары.ТекущиеДанные;
КонецФункции

// Функция возвращает товар по штрихкоду
&НаСервереБезКонтекста
Функция ПолучитьТоварПоШтрихкоду(Штрихкод)
	Возврат Справочники.Товары.НайтиПоРеквизиту("Штрихкод", Штрихкод);
КонецФункции


// Функция добавляет товар в накладную или увеличивает кол-во уже добавленного
&НаКлиенте
Функция ДобавитьТовар(Товар)

	Строки = Объект.Товары.НайтиСтроки(Новый Структура("Товар", Товар));

	Если Строки.Количество() > 0 Тогда

		Элемент = Строки[0];

	Иначе

		Элемент = Объект.Товары.Добавить();
		Элемент.Товар = Товар;
		Элемент.Цена = ПолучитьЦенуТовара(Объект.Дата, Товар);

	КонецЕсли;

	Элемент.Количество = Элемент.Количество + 1;
	Элемент.Сумма = Элемент.Количество * Элемент.Цена;

	Элементы.Товары.ТекущаяСтрока = Элемент.ПолучитьИдентификатор();
	Элементы.Товары.ТекущийЭлемент = Элементы.Товары.ПодчиненныеЭлементы.ТоварыКоличество;
	Элементы.Товары.ИзменитьСтроку();

КонецФункции

//////////////////////////////////////////////////////////////////////////////// 
// ОБРАБОТЧИКИ СОБЫТИЙ
//

&НаКлиенте
Процедура ТоварыТоварПриИзменении(Элемент)

	Стр = ПолучитьТекущуюСтрокуТовары();
	Стр.Цена = ПолучитьЦенуТовара(Объект.Дата, Стр.Товар);
	Стр.Сумма = Стр.Количество * Стр.Цена;

КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаПриИзменении(Элемент)
	
	// Задание №5.1
	Стр = ПолучитьТекущуюСтрокуТовары();
	Стр.Сумма = Стр.Количество * Стр.Цена;

КонецПроцедуры

&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(Элемент)

	// Задание №5.1  // еще какое-то изменение
	Стр = ПолучитьТекущуюСтрокуТовары();
	Стр.Сумма = Стр.Количество * Стр.Цена;

КонецПроцедуры

&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	
	Если Источник = "СканерШтрихкода" Тогда
		
		Если ВводДоступен() Тогда
			Товар = ПолучитьТоварПоШтрихкоду(Данные);
			Если НЕ Товар.Пустая() Тогда
				ДобавитьТовар(Товар);
			КонецЕсли
		КонецЕсли
			
	КонецЕсли

КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)

	ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
	УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);

КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Если Параметры.Ключ.Пустая() Тогда 
		
		ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
		УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);
		
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	ТорговоеОборудованиеВключено = Константы.РаботаСТорговымОборудованием.Получить();
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ТорговоеОборудованиеВключено Тогда
		
		РаботаСТорговымОборудованием.НачатьПодключениеСканераШтрихкодов();
		
	КонецЕсли;
		
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
	УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	ПараметрыОпций = Новый Структура("Организация", Объект.Организация);
	УстановитьПараметрыФункциональныхОпцийФормы(ПараметрыОпций);
	
КонецПроцедуры


