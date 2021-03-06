&НаСервере
Функция ПолучитьЗаказы() Экспорт
	АдресOMS = Константы.АдресOMS.Получить();
	HTTPСоединение = Новый HTTPСоединение(АдресOMS,8080,,,,,,Ложь);
	запросGet = Новый HTTPЗапрос("/api/info/listorders"); 	
	запросGet.Заголовки.Вставить("Content-type", "application/json");
	Попытка
		Ответ = HTTPСоединение.Получить(запросGet);
		Если Ответ.КодСостояния=200 Тогда  
			ТелоОтвета = Ответ.ПолучитьТелоКакСтроку();
			ЧтениеJson=Новый ЧтениеJSON;
			ЧтениеJson.УстановитьСтроку(ТелоОтвета);
			ДанныеGETЗапроса=ПрочитатьJSON(ЧтениеJSON);		
		Иначе 
			ДанныеGETЗапроса=Новый ТаблицаЗначений;
			ЗаписьЖурналаРегистрации("OMS",
			УровеньЖурналаРегистрации.Ошибка, , ,
			"Получение заказов не успешно");
		КонецЕсли;		
	Исключение 
		ЗаписьЖурналаРегистрации("OMS",
		УровеньЖурналаРегистрации.Ошибка, , ,
		"Во время получение заказов произошла ошибка" + Символы.ПС +
		ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())); 
	КонецПопытки; 
	
	Возврат	ДанныеGETЗапроса;
КонецФункции

&НаСервере
Функция ПолучитьСоставЗаказа(НомерЗаказа) Экспорт
	АдресOMS = Константы.АдресOMS.Получить();
	HTTPСоединение = Новый HTTPСоединение(АдресOMS,8080,,,,,,Ложь);
	запросGet = Новый HTTPЗапрос("/api/info/ordersdata/"+НомерЗаказа);
	запросGet.Заголовки.Вставить("Content-type", "application/json");
	Попытка
		Ответ = HTTPСоединение.Получить(запросGet);
		Если Ответ.КодСостояния=200 Тогда  
			ТелоОтвета = Ответ.ПолучитьТелоКакСтроку();
			ЧтениеJson=Новый ЧтениеJSON;
			ЧтениеJson.УстановитьСтроку(ТелоОтвета);
			ДанныеGETЗапроса=ПрочитатьJSON(ЧтениеJSON);		
		Иначе 
			ДанныеGETЗапроса=Новый ТаблицаЗначений;
			ЗаписьЖурналаРегистрации("OMS",
			УровеньЖурналаРегистрации.Ошибка, , ,
			"Ошибка при получении состава заказа");
		КонецЕсли;		
	Исключение 
		ЗаписьЖурналаРегистрации("OMS",
		УровеньЖурналаРегистрации.Ошибка, , ,
		"Сервер недоступен"); 
	КонецПопытки; 
	Возврат	ДанныеGETЗапроса;
	
КонецФункции

&НаСервере
Процедура ОтправитьДанныеЗаказов(ТЗДанные=Неопределено) Экспорт
	АдресOMS = Константы.АдресOMS.Получить();
	Для Каждого Заказ Из ТЗДанные Цикл
		Если Заказ.Обновить = Ложь Тогда
			Продолжить;
		КонецЕсли; 
		Заказ.Обновить = Ложь;
		HTTPСоединение = Новый HTTPСоединение(АдресOMS,8080,,,,,,Ложь);
		запросPOST = Новый HTTPЗапрос("/api/info/updatestatus/"+Заказ.НомерЗаказа);  		
		запросPOST.Заголовки.Вставить("Content-type", "application/json");
		ЗаписьJSON = Новый ЗаписьJSON;  
		тПараметрыJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Нет, " ", Истина);  
		ЗаписьJSON.УстановитьСтроку(тПараметрыJSON); 	
		тДанные = Новый Структура;
		тДанные.Вставить("status", 2); 
		ЗаписатьJSON(ЗаписьJSON, тДанные);
		СтрокаJS = ЗаписьJSON.Закрыть();
		запросPOST.УстановитьТелоИзСтроки(СтрокаJS);
		Попытка
			HTTPОтвет = HTTPСоединение.ВызватьHTTPМетод("PUT",запросPOST);
			Если HTTPОтвет.КодСостояния<>200 Тогда  
				ЗаписьЖурналаРегистрации("OMS",
				УровеньЖурналаРегистрации.Ошибка, , ,
				"Ошибка при обновлении статуса заказа");
			КонецЕсли;
		Исключение 
			ЗаписьЖурналаРегистрации("OMS",
			УровеньЖурналаРегистрации.Ошибка, , ,
			"Сервер недоступен");
		КонецПопытки; 
	КонецЦикла;
КонецПроцедуры



