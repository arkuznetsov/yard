// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/yard/
// ----------------------------------------------------------

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт

	Команда.ДобавитьКоманду("list l", "список дистрибутивов на сайте 1С", Новый СписокРелизов1С());
	Команда.ДобавитьКоманду("get g" , "загрузка дистрибутивов с сайта 1С", Новый ЗагрузчикРелизов1С());

	Команда.Опция("u user", "", "имя пользователя")
	       .ТСтрока()
	       .ВОкружении("YARD_RELEASES_USER");

	Команда.Опция("p pwd password", "", "пароль пользователя")
	       .ТСтрока()
	       .ВОкружении("YARD_RELEASES_PWD");

	Команда.Опция("t timeout", 20, "время ожидания ответа от внешнего ресурса (HTTP) в секундах")
	       .ТЧисло()
	       .ВОкружении("YARD_RELEASES_TIMEOUT");

КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

КонецПроцедуры // ВыполнитьКоманду()
