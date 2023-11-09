// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/yard/
// ----------------------------------------------------------
//
// Реализация взаимодействия с сайтом 1С на основе обработки:
// https://infostart.ru/public/255881/
//
// ----------------------------------------------------------

#Использовать asserts

#Область ПеременныеМодуля

Перем Лог;                    // Объект      - объект записи лога приложения

Перем ИмяПользователя;        // Строка      - имя пользователя сервиса загрузки релизов
Перем ПарольПользователя;     // Строка      - пароль пользователя сервиса загрузки релизов
Перем ИдСеанса;               // Строка      - идентификатор сеанса сервиса загрузки релизов
Перем ВремяОжиданияОтвета;    // Число       - время ожидания ответа от внешнего ресурса (HTTP) в секундах

#КонецОбласти // ПеременныеМодуля

#Область ПрограммныйИнтерфейс

// Функция - возвращает время ожидания ответа от внешнего ресурса (HTTP) в секундах
// Если не установлено, то 20 сек
//
// Возвращаемое значение:
//   Число       - время ожидания ответа от внешнего ресурса в секундах
//
Функция ВремяОжиданияОтвета() Экспорт

	Если ЗначениеЗаполнено(ВремяОжиданияОтвета) Тогда
		Возврат ВремяОжиданияОтвета;
	КонецЕсли;

	Возврат 20;

КонецФункции // ВремяОжиданияОтвета()

// Процедура - устанавливает время ожидания ответа от внешнего ресурса (HTTP) в секундах
//
// Параметры:
//   НовоеЗначение    - Число    - время ожидания ответа от внешнего ресурса в секундах
//
Процедура УстановитьВремяОжиданияОтвета(Знач НовоеЗначение) Экспорт

	ВремяОжиданияОтвета = НовоеЗначение;

КонецПроцедуры // УстановитьВремяОжиданияОтвета()

// Функция - получает список версий приложения с сайта 1С
//
// Параметры:
//  Фильтр              - Строка            - регулярное выражение или массив регулярных выражений
//                        Массив из Строка    для поиска нужных приложений по имени
//  ФильтрВерсий        - Строка            - регулярное выражение или массив регулярных выражений
//                        Массив из Строка    для поиска нужных версий по номеру
//  НачальнаяДата       - Дата              - фильтр по начальной дате версии (включая)
//  КонечнаяДата        - Дата              - фильтр по последней дате версии (включая)
//  ПолучатьБетаВерсии  - Булево            - Истина - будут получены ознакомительные версии
//                                            Ложь - будут получены только релизные версии
//
// Возвращаемое значение:
//  Массив из Структура  - массив описаний ссылок для загрузки
//   * Имя                - Строка       - имя приложения
//   * Путь               - Строка       - относительный путь к странице приложения
//   * Идентификатор      - Строка       - идентификатор приложения
//   * Версия             - Строка       - номер версии приложения
//   * Дата               - Дата         - дата выпуска версии приложения
//   * БетаВерсии         - Булево       - Истина - это ознакомительная версия
//
Функция ПолучитьСписокПриложений(Знач Фильтр = Неопределено,
	                             Знач ФильтрВерсий = Неопределено,
	                             Знач НачальнаяДата = '00010101000000',
	                             Знач КонечнаяДата = '00010101000000',
	                             Знач ПолучатьБетаВерсии = Ложь) Экспорт

	СтраницаКонфигураций = ПолучитьСтраницуСайта(ПараметрыПриложения.СервисРелизов(),
	                                             ПараметрыПриложения.СтраницаСпискаРелизов());
	
	Служебный.ОчиститьТекстСтраницыHTML(СтраницаКонфигураций);

	СтрокиКонфигураций = Служебный.НайтиСовпаденияВТексте(СтраницаКонфигураций,
	                                                      ПараметрыПриложения.ШаблонПоискаСтрокКонфигураций());
	
	СписокКонфигураций = Новый Массив();

	Если СтрокиКонфигураций.Количество() = 0 Тогда
		Возврат СписокКонфигураций;
	КонецЕсли;

	Для Каждого ТекСтрокаКонфигурации Из СтрокиКонфигураций Цикл
		
		ТекстСтрокиКонфигурации = ТекСтрокаКонфигурации.Группы[0].Значение;

		НайденныеОписания = Служебный.НайтиСовпаденияВТексте(ТекстСтрокиКонфигурации,
		                                                     ПараметрыПриложения.ШаблонПоискаКонфигураций());

		Если НайденныеОписания.Количество() = 0
		 ИЛИ НайденныеОписания[0].Группы.Количество() < 3 Тогда
			Продолжить;
		КонецЕсли;

		НайденноеОписание = НайденныеОписания[0];

		ТекИмя = НайденноеОписание.Группы[2].Значение;

		Если НЕ СоответствуетФильтру(ТекИмя, Фильтр) Тогда
			Продолжить;
		КонецЕсли;

		ТекКонфигурация = Новый Структура("Имя, Путь, Версия, Дата, Идентификатор, БетаВерсии");
		ТекКонфигурация.Имя           = ТекИмя;
		ТекКонфигурация.Путь          = НайденноеОписание.Группы[1].Значение;
		ТекКонфигурация.Идентификатор = "";
		ТекКонфигурация.Версия        = "";
		ТекКонфигурация.Дата          = "";
		ТекКонфигурация.БетаВерсии    = Новый Массив();

		НайденныеОписания = Служебный.НайтиСовпаденияВТексте(ТекстСтрокиКонфигурации,
		                                                     ПараметрыПриложения.ШаблонПоискаКонфигурацийСВерсиями());

		Если ПолучатьБетаВерсии Тогда
			ТекКонфигурация.БетаВерсии = ПолучитьСписокБетаВерсий(ТекстСтрокиКонфигурации,
			                                                      ФильтрВерсий,
			                                                      НачальнаяДата,
			                                                      КонечнаяДата);
		КонецЕсли;

		Если (НайденныеОписания.Количество() = 0
		 ИЛИ НайденныеОписания[0].Группы.Количество() < 6)
		   И ТекКонфигурация.БетаВерсии.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;

		Если НайденныеОписания.Количество() > 0 Тогда
			НайденноеОписание = НайденныеОписания[0];
			ТекКонфигурация.Идентификатор = НайденноеОписание.Группы[3].Значение;
			ТекКонфигурация.Версия        = НайденноеОписание.Группы[4].Значение;
			ТекКонфигурация.Дата          = Служебный.ДатаИзСтроки(НайденноеОписание.Группы[5].Значение);
		ИначеЕсли ПолучатьБетаВерсии Тогда
			ТекКонфигурация.Идентификатор = ТекКонфигурация.БетаВерсии[0].Идентификатор;
			ТекКонфигурация.Версия        = ТекКонфигурация.БетаВерсии[0].Версия;
			ТекКонфигурация.Дата          = ТекКонфигурация.БетаВерсии[0].Дата;
		КонецЕсли;

		СписокКонфигураций.Добавить(ТекКонфигурация);
	КонецЦикла;
	
	Возврат СписокКонфигураций;
	
КонецФункции // ПолучитьСписокПриложений()

// Функция - получает список версий приложения с сайта 1С
//
// Параметры:
//  АдресРесурса        - Строка            - расположение страницы версий на сервере
//  Фильтр              - Строка            - регулярное выражение или массив регулярных выражений
//                        Массив из Строка    для поиска нужных версий по номеру
//  НачальнаяДата       - Дата              - фильтр по начальной дате версии (включая)
//  КонечнаяДата        - Дата              - фильтр по последней дате версии (включая)
//
// Возвращаемое значение:
//  Массив из Структура    - массив описаний ссылок для загрузки
//   * Версия                - Строка  - номер версии
//   * Дата                  - Дата    - дата версии
//   * Путь                  - Строка  - относительный путь к странице версии
//   * ВерсииДляОбновления   - Массив  - список версий для обновления
//   * Бета                  - Булево  - всегда Ложь - флаг ознакомительной версии
//
Функция ПолучитьВерсииПриложения(Знач АдресРесурса,
                                 Знач Фильтр = Неопределено,
                                 Знач НачальнаяДата = '00010101000000',
                                 Знач КонечнаяДата = '00010101000000') Экспорт
	
	СтраницаВерсий = ПолучитьСтраницуСайта(ПараметрыПриложения.СервисРелизов(), АдресРесурса);
	
	Совпадения = Служебный.НайтиСовпаденияВТексте(СтраницаВерсий, ПараметрыПриложения.ШаблонПоискаВерсий());

	СписокВерсий = Новый Массив();
	Если Совпадения.Количество() > 0 Тогда
		Для Каждого ТекСовпадение Из Совпадения Цикл
			Если ТекСовпадение.Группы.Количество() < 3 Тогда
				Продолжить;
			КонецЕсли;

			ТекНомерВерсии = ТекСовпадение.Группы[2].Значение;
			ТекДатаВерсии  = Служебный.ДатаИзСтроки(ТекСовпадение.Группы[4].Значение);

			Если НЕ СоответствуетФильтру(ТекНомерВерсии, Фильтр) Тогда
				Продолжить;
			КонецЕсли;

			ВерсияНеСоответствуетФильтруДат = ((ЗначениеЗаполнено(НачальнаяДата) И ТекДатаВерсии < НачальнаяДата)
				                           ИЛИ (ЗначениеЗаполнено(КонечнаяДата) И ТекДатаВерсии > КонечнаяДата));
			Если ВерсияНеСоответствуетФильтруДат Тогда
				Продолжить;
			КонецЕсли;

			ТекВерсия = Новый Структура("Версия, Дата, Путь, ВерсииДляОбновления, Бета");
			ТекВерсия.Версия              = ТекНомерВерсии;
			ТекВерсия.Дата                = ТекДатаВерсии;
			ТекВерсия.Путь                = ТекСовпадение.Группы[1].Значение;
			ТекВерсия.ВерсииДляОбновления = СтрРазделить(ТекСовпадение.Группы[6].Значение, ",", Ложь);
			ТекВерсия.Бета                = Ложь;

			Служебный.СортироватьВерсии(ТекВерсия.ВерсииДляОбновления, "Убыв");
			
			СписокВерсий.Добавить(ТекВерсия);
		КонецЦикла;
	КонецЕсли;
	
	СортироватьОписанияВерсийПоДате(СписокВерсий);

	Возврат СписокВерсий;
	
КонецФункции // ПолучитьВерсииПриложения()

// Функция - получает список ознакомительных версий приложения с сайта 1С
//
// Параметры:
//  СтрокаКонфигурации  - Строка            - текст строки описания приложения/конфигурации
//  Фильтр              - Строка            - регулярное выражение или массив регулярных выражений
//                        Массив из Строка    для поиска нужных версий по номеру
//  НачальнаяДата       - Дата              - фильтр по начальной дате версии (включая)
//  КонечнаяДата        - Дата              - фильтр по последней дате версии (включая)
//
// Возвращаемое значение:
//  Массив из Структура    - массив описаний ссылок для загрузки
//   * Версия                - Строка  - номер версии
//   * Дата                  - Дата    - дата версии
//   * Путь                  - Строка  - относительный путь к странице версии
//   * ВерсииДляОбновления   - Массив  - всегда пустой список версий для обновления
//   * Бета                  - Булево  - всегда Истина - флаг ознакомительной версии
//
Функция ПолучитьСписокБетаВерсий(СтрокаКонфигурации,
	                             Знач Фильтр = Неопределено,
	                             Знач НачальнаяДата = '00010101000000',
	                             Знач КонечнаяДата = '00010101000000') Экспорт
	
	КолонкиБетаВерсий = Служебный.НайтиСовпаденияВТексте(СтрокаКонфигурации,
	                                                     ПараметрыПриложения.ШаблонПоискаКолонокБетаВерсий());
	
	СписокБетаВерсий = Новый Массив();

	Если КолонкиБетаВерсий.Количество() = 0 Тогда
		Возврат СписокБетаВерсий;
	КонецЕсли;

	СсылкиБетаВерсий = Служебный.НайтиСовпаденияВТексте(КолонкиБетаВерсий[0].Группы[1].Значение,
	                                                    ПараметрыПриложения.ШаблонПоискаСсылокБетаВерсий());
	ДатыБетаВерсий = Служебный.НайтиСовпаденияВТексте(КолонкиБетаВерсий[0].Группы[2].Значение,
	                                                  ПараметрыПриложения.ШаблонПоискаДатБетаВерсий());

	Для й = 0 По СсылкиБетаВерсий.Количество() - 1 Цикл

		Если ДатыБетаВерсий.Количество() < й Тогда
			Прервать;
		КонецЕсли;

		ТекНомерВерсии = СсылкиБетаВерсий[й].Группы[3].Значение;
		ТекДатаВерсии  = Служебный.ДатаИзСтроки(ДатыБетаВерсий[й].Группы[1].Значение);

		Если НЕ СоответствуетФильтру(ТекНомерВерсии, Фильтр) Тогда
			Продолжить;
		КонецЕсли;

		ВерсияНеСоответствуетФильтруДат = ((ЗначениеЗаполнено(НачальнаяДата) И ТекДатаВерсии < НачальнаяДата)
		                               ИЛИ (ЗначениеЗаполнено(КонечнаяДата) И ТекДатаВерсии > КонечнаяДата));
		Если ВерсияНеСоответствуетФильтруДат Тогда
			Продолжить;
		КонецЕсли;

		ТекВерсия = Новый Структура("Идентификатор, Версия, Дата, Путь, ВерсииДляОбновления, Бета");
		ТекВерсия.Путь                = СсылкиБетаВерсий[й].Группы[1].Значение;
		ТекВерсия.Идентификатор       = СсылкиБетаВерсий[й].Группы[2].Значение;
		ТекВерсия.Версия              = ТекНомерВерсии;
		ТекВерсия.Дата                = ТекДатаВерсии;
		ТекВерсия.ВерсииДляОбновления = Новый Массив();
		ТекВерсия.Бета                = Истина;

		СписокБетаВерсий.Добавить(ТекВерсия);
	КонецЦикла;

	Служебный.СортироватьОписанияВерсийПоНомеру(СписокБетаВерсий);
	
	Возврат СписокБетаВерсий;

КонецФункции // ПолучитьСписокБетаВерсий()

// Функция - проверяет наличие ссылок для загрузки с сайта 1С
//
// Параметры:
//  АдресРесурса    - Строка            - расположение страницы загрузок на сервере
//  Фильтр          - Строка            - регулярное выражение или массив регулярных выражений
//                    Массив из Строка    для поиска ссылки на загрузку по заголовку
//
// Возвращаемое значение:
//  Булево          - Истина - есть ссылки, удовлетворяющие фильтру;
//                    Ложь - в противном случае
//
Функция ЕстьСсылкаДляЗагрузки(Знач АдресРесурса = "", Знач Фильтр = Неопределено) Экспорт

	СписокСсылок = ПолучитьСсылкиДляЗагрузки(АдресРесурса, Фильтр);

	Возврат (СписокСсылок.Количество() > 0);

КонецФункции // ЕстьСсылкаДляЗагрузки()

// Функция - получает список ссылок для загрузки с сайта 1С
//
// Параметры:
//  АдресРесурса    - Строка            - расположение страницы загрузок на сервере
//  Фильтр          - Строка            - регулярное выражение или массив регулярных выражений
//                    Массив из Строка    для поиска ссылки на загрузку по заголовку
//
// Возвращаемое значение:
//  Массив из Структура  - массив описаний ссылок для загрузки
//   * Имя                 - Строка - заголовок ссылки
//   * Путь                - Строка - относительный путь на сайте 1С
//   * ПутьДляЗагрузки     - Строка - путь для скачивания файла
//   * ИмяФайла            - Строка - имя загружаемого файла
//
Функция ПолучитьСсылкиДляЗагрузки(Знач АдресРесурса = "", Знач Фильтр = Неопределено) Экспорт
	
	СтраницаВерсии = ПолучитьСтраницуСайта(ПараметрыПриложения.СервисРелизов(), АдресРесурса);

	Совпадения = Служебный.НайтиСовпаденияВТексте(СтраницаВерсии,
	                                              ПараметрыПриложения.ШаблонПоискаАдресаСтраницыЗагрузки());

	СписокСсылок = Новый Массив();
	Если Совпадения.Количество() > 0 Тогда

		Для Каждого ТекСовпадение Из Совпадения Цикл

			Если ТекСовпадение.Группы.Количество() < 3 Тогда
				Продолжить;
			КонецЕсли;

			ТекИмя = ТекСовпадение.Группы[2].Значение;
			ТекСсылка = ТекСовпадение.Группы[1].Значение;
			ОписаниеФайла = ФайлИзАдреса(ТекСсылка);

			Если НЕ СоответствуетФильтру(ТекИмя, Фильтр) Тогда
				Продолжить;
			КонецЕсли;

			СтраницаЗагрузки = ПолучитьСтраницуСайта(ПараметрыПриложения.СервисРелизов(), ТекСсылка);
			
			СовпаденияДляЗагрузки = Служебный.НайтиСовпаденияВТексте(СтраницаЗагрузки,
			                                                         ПараметрыПриложения.ШаблонПоискаСсылкиДляЗагрузки());

			Если СовпаденияДляЗагрузки.Количество() = 0 Тогда
				Продолжить;
			КонецЕсли;

			ТекВерсия = Новый Структура("Имя, Путь, ПутьДляЗагрузки, ИмяФайла");
			ТекВерсия.Имя             = ТекИмя;
			ТекВерсия.Путь            = ТекСсылка;
			ТекВерсия.ПутьДляЗагрузки = СовпаденияДляЗагрузки[0].Группы[2].Значение;
			ТекВерсия.ИмяФайла        = ОписаниеФайла.Имя;
			СписокСсылок.Добавить(ТекВерсия);

		КонецЦикла;
	КонецЕсли;

	Возврат СписокСсылок;

КонецФункции // ПолучитьСсылкиДляЗагрузки()

// Процедура - загружает указанный файл с сайта 1С
//
// Параметры:
//  АдресИсточника             - Строка      - URI файла на сервере
//  ПутьКФайлуДляСохранения    - Строка      - путь к файлу для сохранения
//
Процедура ЗагрузитьФайл(АдресИсточника, Знач ПутьКФайлуДляСохранения) Экспорт

	СтруктураАдреса = СтруктураURI(АдресИсточника);
	
	Сервер = СтрШаблон("%1://%2", СтруктураАдреса.Схема, СтруктураАдреса.Хост);
	
	ИдСеансаЗагрузки = Авторизация(Сервер, ИмяПользователя, ПарольПользователя, СтруктураАдреса.ПутьНаСервере);

	Соединение = Новый HTTPСоединение(Сервер, , , , , ВремяОжиданияОтвета());
	Соединение.РазрешитьАвтоматическоеПеренаправление = Истина;

	Запрос = ЗапросКСайту(АдресИсточника);
	Запрос.Заголовки.Вставить("Cookie", ИдСеансаЗагрузки);

	Лог.Отладка("Загрузка файла: Начало загрузки файла по адресу ""%1""", АдресИсточника);

	Ответ = Соединение.Получить(Запрос, ПутьКФайлуДляСохранения);

	Лог.Отладка("Загрузка файла: Загружен файл ""%1""", ПутьКФайлуДляСохранения);

КонецПроцедуры // ЗагрузитьФайл()

// Функция - выполняет авторизацию на сайте 1С и возвращает идентификатор сеанса
//
// Параметры:
//  Сервер              - Строка      - адрес сервера
//  Имя                 - Строка      - имя пользователя
//  Пароль              - Строка      - пароль пользователя
//  АдресРесурса        - Строка      - расположение ресурса на сервере
//
// Возвращаемое значение:
//  Строка     - текст полученной страницы
//
Функция Авторизация(Знач Сервер, Знач Имя, Знач Пароль, Знач АдресРесурса = "") Экспорт
	
	ИмяПользователя = Имя;
	ПарольПользователя = Пароль;

	КодПереадресации = 302;
	КодОшибкиАвторизации = 401;

	СоединениеРегистрации = Новый HTTPСоединение(ПараметрыПриложения.СервисАвторизации(), , , , , ВремяОжиданияОтвета());
	СоединениеРегистрации.РазрешитьАвтоматическоеПеренаправление = Ложь;

	СоединениеЦелевое = Новый HTTPСоединение(Сервер, , , , , ВремяОжиданияОтвета());
	СоединениеЦелевое.РазрешитьАвтоматическоеПеренаправление = Ложь;
	
	// Запрос 1
	ЗапросПолучение = ЗапросКСайту();
	ЗапросПолучение.АдресРесурса = АдресРесурса;
	
	// Ответ 1 - переадресация на страницу регистрации
	ОтветПереадресация = СоединениеЦелевое.Получить(ЗапросПолучение);
	НовыйИдСеанса = ПолучитьЗначениеЗаголовка("set-cookie", ОтветПереадресация.Заголовки);
	НовыйИдСеанса = Сред(НовыйИдСеанса, Найти(НовыйИдСеанса, "SESSION="));
	НовыйИдСеанса = Лев(НовыйИдСеанса, Найти(НовыйИдСеанса, ";") - 1);

	Лог.Отладка("Авторизация: Получен ответ от ресурса ""%1%2"", переадресация -> ""%3""",
	            Сервер,
	            ЗапросПолучение.АдресРесурса,
	            ПолучитьЗначениеЗаголовка("location", ОтветПереадресация.Заголовки));
	
	// Запрос 2 - переходим на страницу регистрации
	ЗапросПолучение.АдресРесурса = СтрЗаменить(ПолучитьЗначениеЗаголовка("location", ОтветПереадресация.Заголовки),
	                                           ПараметрыПриложения.СервисАвторизации(),
	                                           "");
	
	// Ответ 2 - получение строки регистрации
	ОтветРегистрация = СоединениеРегистрации.Получить(ЗапросПолучение);
	ТелоОтвета = ОтветРегистрация.ПолучитьТелоКакСтроку();
	СтрокаРегистрации = ПолучитьСтрокуРегистрации(ТелоОтвета, ИмяПользователя, ПарольПользователя);

	Лог.Отладка("Авторизация: Получена строка регистрации от ресурса ""%1%2"": ""%3""",
	            ПараметрыПриложения.СервисАвторизации(),
	            ЗапросПолучение.АдресРесурса,
	            СтрокаРегистрации);
	
	// Запрос 3 - выполнение регистрации
	ЗапросОбработка = ЗапросКСайту(ПараметрыПриложения.СтраницаАвторизации());
	ЗапросОбработка.Заголовки.Вставить("Content-Type", "application/x-www-form-urlencoded");
	ЗапросОбработка.Заголовки.Вставить("Cookie", НовыйИдСеанса + "; i18next=ru-RU");
	ЗапросОбработка.УстановитьТелоИзСтроки(СтрокаРегистрации);

	// Ответ 3 - проверка успешности регистрации
	ОтветПроверка = СоединениеРегистрации.ОтправитьДляОбработки(ЗапросОбработка);
	
	СообщениеОбОшибке = "Код переадресации не соответствует ожидаемому!";

	Если ОтветПроверка.КодСостояния = КодОшибкиАвторизации Тогда
		СообщениеОбОшибке = СтрШаблон("Ошибка авторизации на сайте %1/%2 (пользователь: %3)",
		                              ПараметрыПриложения.СервисАвторизации(),
		                              ЗапросОбработка.АдресРесурса,
		                              Имя);
	КонецЕсли;

	Утверждения.ПроверитьРавенство(ОтветПроверка.КодСостояния,
	                               КодПереадресации,
	                               СообщениеОбОшибке);
	
	Лог.Отладка("Авторизация: Получен ответ от ресурса ""%1%2"", переадресация -> ""%3""",
	            ПараметрыПриложения.СервисАвторизации(),
	            ЗапросОбработка.АдресРесурса,
	            ПолучитьЗначениеЗаголовка("location", ОтветПроверка.Заголовки));
	
	// Запрос 4 - переход на целевую страницу
	ЗапросПолучение.АдресРесурса = СтрЗаменить(ПолучитьЗначениеЗаголовка("location", ОтветПроверка.Заголовки), Сервер, "");
	ЗапросПолучение.Заголовки.Вставить("Cookie", НовыйИдСеанса);
	
	СоединениеЦелевое.Получить(ЗапросПолучение);
	
	Лог.Отладка("Авторизация: Получен ответ от ресурса ""%1%2"", ID сеанса: ""%3""",
	            Сервер,
	            ЗапросПолучение.АдресРесурса,
	            НовыйИдСеанса);
	
	Возврат НовыйИдСеанса;
	
КонецФункции // Авторизация()

#КонецОбласти // ПрограммныйИнтерфейс

#Область РаботаСсайтом

// Функция - получает строку регистрации на основе данных страницы авторизации
//
// Параметры:
//  Текст            - Строка      - текст страницы авторизации
//  Имя              - Строка      - имя пользователя
//  Пароль           - Строка      - пароль пользователя
//
// Возвращаемое значение:
//  Строка     - строка регистрации на сайте
//
Функция ПолучитьСтрокуРегистрации(Знач Текст, Знач Имя, Знач Пароль)
	
	Совпадения = Служебный.НайтиСовпаденияВТексте(Текст, ПараметрыПриложения.ШаблонПоискаСтрокиРегистрации());

	Токен = "";
	Если Совпадения.Количество() > 0 Тогда
		Токен = Совпадения[0].Группы[1].Значение;
	КонецЕсли;

	Возврат СтрШаблон(ПараметрыПриложения.ШаблонСтрокиРегистрации(), Имя, Пароль, Токен);
	
КонецФункции // ПолучитьСтрокуРегистрации()

// Функция - получает страницу с сайта
//
// Параметры:
//  Сервер                          - Строка      - адрес сервера
//  АдресРесурса                    - Строка      - расположение ресурса на сервере
//  АвтоматическоеПеренаправление   - Булево      - Истина - будет выполняться автоматическое перенаправление
//                                                           при соответствующем ответе сервера
//                                                  Ложь - перенаправление выполняться не будет
//
// Возвращаемое значение:
//  Строка     - текст полученной страницы
//
Функция ПолучитьСтраницуСайта(Знач Сервер, Знач АдресРесурса, Знач АвтоматическоеПеренаправление = Ложь)
	
	Соединение = Новый HTTPСоединение(Сервер, , , , , ВремяОжиданияОтвета());
	Соединение.РазрешитьАвтоматическоеПеренаправление = АвтоматическоеПеренаправление;

	Запрос = ЗапросКСайту(АдресРесурса);
	Запрос.Заголовки.Вставить("Cookie", ИдСеанса);
	
	Ответ = Соединение.Получить(Запрос);

	Лог.Отладка("Получена страница сайта ""%1%2""", Сервер, АдресРесурса);

	Возврат Ответ.ПолучитьТелоКакСтроку();

КонецФункции // ПолучитьСтраницуСайта()

#КонецОбласти // РаботаСсайтом

#Область СлужебныеПроцедурыИФункции

// Функция - создает и возвращает HTTP-запрос со стандартными заголовками
//
// Параметры:
//  АдресРесурса       - Строка      - адрес ресурса на сайте
//
// Возвращаемое значение:
//  HTTPЗапрос         - HTTP-запрос со стандартными заголовками
//
Функция ЗапросКСайту(АдресРесурса = "")

	Запрос = Новый HTTPЗапрос;
	Запрос.Заголовки.Вставить("User-Agent", "oscript");
	Запрос.Заголовки.Вставить("Connection", "keep-alive");
	Запрос.АдресРесурса = АдресРесурса;

	Возврат Запрос;

КонецФункции // ЗапросКСайту()

// Функция - выделяет имя файла из полного адреса файла
//
// Параметры:
//  АдресФайла    - Строка            - полный адрес файла
//
// Возвращаемое значение:
//  Строка        - имя файла
//
Функция ФайлИзАдреса(Знач АдресФайла)

	ОписаниеФайла = Новый Структура("ПолноеИмя, ЧастиПути, Путь, Имя");
	ОписаниеФайла.ПолноеИмя = "";
	ОписаниеФайла.ЧастиПути = Новый Массив();
	ОписаниеФайла.Путь      = "";
	ОписаниеФайла.Имя       = "";

	Совпадения = Служебный.НайтиСовпаденияВТексте(АдресФайла, ПараметрыПриложения.ШаблонПоискаПутиКФайлуВАдресе());

	Если Совпадения.Количество() = 0 Тогда
		Возврат ОписаниеФайла;
	КонецЕсли;

	ОписаниеФайла.ПолноеИмя = Совпадения[0].Группы[1].Значение;
	ОписаниеФайла.ПолноеИмя = СтрЗаменить(ОписаниеФайла.ПолноеИмя, "%5c", "\");

	ОписаниеФайла.ЧастиПути = СтрРазделить(ОписаниеФайла.ПолноеИмя, "\");

	Для й = 0 По ОписаниеФайла.ЧастиПути.ВГраница() - 1 Цикл
		ОписаниеФайла.Путь = ОписаниеФайла.Путь
		                   + ?(ОписаниеФайла.Путь = "", "", "\")
		                   + ОписаниеФайла.ЧастиПути[й];
	КонецЦикла;

	ОписаниеФайла.Имя = ОписаниеФайла.ЧастиПути[ОписаниеФайла.ЧастиПути.ВГраница()];

	Возврат ОписаниеФайла;

КонецФункции // ФайлИзАдреса()

// Функция - проверяет соответствие строки указанному фильтру
//
// Параметры:
//  Значение      - Строка            - проверяемая строка
//  Фильтр        - Строка            - регулярное выражение или массив регулярных выражений
//                  Массив из Строка
//
// Возвращаемое значение:
//  Булево        - Истина - строка соответствует фильтру
//                  Ложь - в противном случае
//
Функция СоответствуетФильтру(Знач Значение, Знач Фильтр)

	Если Фильтр = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;

	МассивФильтров = Новый Массив();

	Если ТипЗнч(Фильтр) = Тип("Строка") Тогда
		МассивФильтров.Добавить(Фильтр);
	ИначеЕсли ТипЗнч(Фильтр) = Тип("Массив") И Фильтр.Количество() > 0 Тогда
		МассивФильтров = Фильтр;
	Иначе
		Возврат Истина;
	КонецЕсли;

	СоответствуетФильтру = Ложь;

	Для Каждого ТекФильтр Из МассивФильтров Цикл
		
		Если НЕ ТипЗнч(ТекФильтр) = Тип("Строка") Тогда
			Продолжить;
		КонецЕсли;

		Совпадения = Служебный.НайтиСовпаденияВТексте(Значение, ТекФильтр);
	
		Если Совпадения.Количество() > 0 Тогда
			СоответствуетФильтру = Истина;
			Прервать;
		КонецЕсли;

	КонецЦикла;

	Возврат СоответствуетФильтру;

КонецФункции // СоответствуетФильтру()

Функция ПолучитьЗначениеЗаголовка(Заголовок, ВсеЗаголовки)
	
	Для Каждого ТекЗаголовок Из ВсеЗаголовки Цикл
		Если НРег(ТекЗаголовок.Ключ) = НРег(Заголовок) Тогда
			Возврат ТекЗаголовок.Значение;
		КонецЕсли;
	КонецЦикла;
	
	Возврат "";
	
КонецФункции // ПолучитьЗначениеЗаголовка()

// Функция - разбирает строку URI на составные части и возвращает в виде структуры.
// На основе RFC 3986.
// утащено из https://its.1c.ru/db/metod8dev#content:5574:hdoc, также есть в БСП
//
// Параметры:
//  СтрокаURI - Строка - ссылка на ресурс в формате:
//                       <схема>://<логин>:<пароль>@<хост>:<порт>/<путь>?<параметры>#<якорь>.
//
// Возвращаемое значение:
//  Структура - составные части URI согласно формату:
//   * Схема         - Строка - схема из URI.
//   * Логин         - Строка - логин из URI.
//   * Пароль        - Строка - пароль из URI.
//   * ИмяСервера    - Строка - часть <хост>:<порт> из URI.
//   * Хост          - Строка - хост из URI.
//   * Порт          - Строка - порт из URI.
//   * ПутьНаСервере - Строка - часть <путь>?<параметры>#<якорь> из URI.
//
Функция СтруктураURI(Знач СтрокаURI) Экспорт
	
	СтрокаURI = СокрЛП(СтрокаURI);
	
	// схема
	Схема = "";
	Разделитель = "://";
	Позиция = Найти(СтрокаURI, Разделитель);
	Если Позиция > 0 Тогда
		Схема = НРег(Лев(СтрокаURI, Позиция - 1));
		СтрокаURI = Сред(СтрокаURI, Позиция + СтрДлина(Разделитель));
	КонецЕсли;

	// строка соединения и путь на сервере
	СтрокаСоединения = СтрокаURI;
	ПутьНаСервере = "";
	Позиция = Найти(СтрокаСоединения, "/");
	Если Позиция > 0 Тогда
		ПутьНаСервере = Сред(СтрокаСоединения, Позиция + 1);
		СтрокаСоединения = Лев(СтрокаСоединения, Позиция - 1);
	КонецЕсли;
		
	// информация пользователя и имя сервера
	СтрокаАвторизации = "";
	ИмяСервера = СтрокаСоединения;
	Позиция = Найти(СтрокаСоединения, "@");
	Если Позиция > 0 Тогда
		СтрокаАвторизации = Лев(СтрокаСоединения, Позиция - 1);
		ИмяСервера = Сред(СтрокаСоединения, Позиция + 1);
	КонецЕсли;
	
	// логин и пароль
	Логин = СтрокаАвторизации;
	Пароль = "";
	Позиция = Найти(СтрокаАвторизации, ":");
	Если Позиция > 0 Тогда
		Логин = Лев(СтрокаАвторизации, Позиция - 1);
		Пароль = Сред(СтрокаАвторизации, Позиция + 1);
	КонецЕсли;
	
	// хост и порт
	Хост = ИмяСервера;
	Порт = "";
	Позиция = Найти(ИмяСервера, ":");
	Если Позиция > 0 Тогда
		Хост = Лев(ИмяСервера, Позиция - 1);
		Порт = Сред(ИмяСервера, Позиция + 1);
	КонецЕсли;
	
	Результат = Новый Структура;
	Результат.Вставить("Схема", Схема);
	Результат.Вставить("Логин", Логин);
	Результат.Вставить("Пароль", Пароль);
	Результат.Вставить("ИмяСервера", ИмяСервера);
	Результат.Вставить("Хост", Хост);
	Результат.Вставить("Порт", ?(Порт <> "", Число(Порт), Неопределено));
	Результат.Вставить("ПутьНаСервере", ПутьНаСервере);
	
	Возврат Результат;
	
КонецФункции // СтруктураURI()

// Процедура - сортирует массив описаний версий по датам версий
//
// Параметры:
//	ОписанияВерсий         - Массив из Структура   - массив описаний версий для сортировки
//      * Версия               - Строка              - номер версии
//      * Дата                 - Дата                - дата версии
//      * Путь                 - Строка              - относительный путь к странице версии
//      * ВерсииДляОбновления  - Массив              - список версий для обновления
//	Порядок                - Строка                - принимает значение "ВОЗР" или "УБЫВ"
//
Процедура СортироватьОписанияВерсийПоДате(ОписанияВерсий, Порядок = "ВОЗР")

	ТабДляСортировки =  Новый ТаблицаЗначений();
	ТабДляСортировки.Колонки.Добавить("Дата");
	ТабДляСортировки.Колонки.Добавить("ОписаниеВерсии");

	Для Каждого ТекОписание Из ОписанияВерсий Цикл
		НоваяСтрока = ТабДляСортировки.Добавить();
		НоваяСтрока.Дата           = ТекОписание.Дата;
		НоваяСтрока.ОписаниеВерсии = ТекОписание;
	КонецЦикла;

	ТабДляСортировки.Сортировать(СокрЛП(СтрШаблон("Дата %1", Порядок)));

	ОписанияВерсий = ТабДляСортировки.ВыгрузитьКолонку("ОписаниеВерсии");

КонецПроцедуры // СортироватьОписанияВерсийПоДате()

#КонецОбласти // СлужебныеПроцедурыИФункции

#Область Инициализация

Процедура ПриСозданииОбъекта(Знач Имя, Знач Пароль)

	ИмяПользователя = Имя;
	ПарольПользователя = Пароль;

	Лог = ПараметрыПриложения.Лог();

	ИдСеанса = Авторизация(ПараметрыПриложения.СервисРелизов(),
	                       ИмяПользователя,
	                       ПарольПользователя,
	                       ПараметрыПриложения.СтраницаСпискаРелизов());

КонецПроцедуры // ПриСозданииОбъекта()

#КонецОбласти // Инициализация
