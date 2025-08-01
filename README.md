# Yet another release downloader (YARD)

Приложение oscript для загрузки и обработки релизов конфигураций 1С.

<a href="https://checkbsl.org"><img alt="Checked by Silver Bulleters SonarQube BSL plugin" src="https://web-files.do.bit-erp.ru/sonar/b_t.png" align="right" style="width:400px"/></a>

[![GitHub release](https://img.shields.io/github/release/ArKuznetsov/yard.svg?style=flat-square)](https://github.com/ArKuznetsov/yard/releases)
[![GitHub license](https://img.shields.io/github/license/ArKuznetsov/yard.svg?style=flat-square)](https://github.com/ArKuznetsov/yard/blob/develop/LICENSE)
[![GitHub Releases](https://img.shields.io/github/downloads/ArKuznetsov/yard/latest/total?style=flat-square)](https://github.comArKuznetsov/yard/releases)
[![GitHub All Releases](https://img.shields.io/github/downloads/ArKuznetsov/yard/total?style=flat-square)](https://github.com/ArKuznetsov/yard/releases)

[![Build Status](https://img.shields.io/github/workflow/status/ArKuznetsov/yard/%D0%9A%D0%BE%D0%BD%D1%82%D1%80%D0%BE%D0%BB%D1%8C%20%D0%BA%D0%B0%D1%87%D0%B5%D1%81%D1%82%D0%B2%D0%B0)](https://github.com/arkuznetsov/yard/actions/)
[![Quality Gate](https://open.checkbsl.org/api/project_badges/measure?project=yard&metric=alert_status)](https://open.checkbsl.org/dashboard/index/yard)
[![Coverage](https://open.checkbsl.org/api/project_badges/measure?project=yard&metric=coverage)](https://open.checkbsl.org/dashboard/index/yard)
[![Tech debt](https://open.checkbsl.org/api/project_badges/measure?project=yard&metric=sqale_index)](https://open.checkbsl.org/dashboard/index/yard)

Требуются следующие библиотеки и инструменты:

- [logos](https://github.com/oscript-library/logos)
- [asserts](https://github.com/oscript-library/asserts)
- [cli](https://github.com/oscript-library/cli)
- [v8runner](https://github.com/oscript-library/v8runner)
- [gitrunner](https://github.com/oscript-library/gitrunner)
- [semver](https://github.com/oscript-library/semver)
- [tempfiles](https://github.com/oscript-library/tempfiles)
- [fs](https://github.com/oscript-library/fs)
- [7-zip](http://www.7-zip.org/)

**Важно 1:** Архиватор 7-zip должен поддерживать распаковку rar-архивов. Для этого на linux нужно поставить пакет с поддержкой такого режима.
Например, на Ubuntu:

```shell
apt-get install p7zip-rar p7zip-full
```

**Важно 2:** Для конвертации в формат ЕДТ необходима установленная ЕДТ и ring

## Общие сведения

- выполняет загрузку приложений с [сайта релизов 1С](https://releases.1c.ru)

- для релизов конфигураций доступны следующие возможности:

  - загрузка указанных версий конфигурации
  - распаковка архива конфигурации (требуется 7-zip)
  - распаковка файлов шаблона конфигурации в указанный каталог (из формата EFD)
  - последовательная сборка CF-файлов конфигурации из CFU-файлов обновлений (требуется начальный CF)
  - Конвертация в формат ЕДТ (при необходимости)
  - последовательная выгрузка версий конфигурации в формате XML в указанный репозитарий GIT

- Реализованы 2 варианта работы:
  - запуск отдельных команд для каждого этапа обработки релизов конфигураций
  - экспериментальный пакетный режим с конвейерной обработкой данных (pipeline), т.е. каждая порция данных, полученная в текущей обработке передается в указанный(-ные) в настройках обработчик(-и) для последующей обработки
- настройки пакетного режима описываются в формате JSON (см. [Файл настроек](#jsonsettings))

## Команды

### **process** (p) - выполняет обработку данных настройкам из файла (.json)

- _--work-dir_ - путь к рабочему каталогу (по умолчанию: текущий каталог)
- _<Путь>_ - путь к файлу настроек (по умолчанию ./yardsettings.json)

Пользователя и пароль портала 1С можно передать с помощью переменных среды:

- `YARD_RELEASES_USER` - пользователь портала 1С;
- `YARD_RELEASES_PWD` - пароль пользователя портала 1С.

#### Пример

```bat
yard process --work-dir "c:\tmp" ".\examples\releases2templates.json"
```

см. [Файл настроек](#jsonsettings)

### **releases** (r) - работа с релизами с сайта 1С

- _--user_ - пользователь портала 1С
- _--pwd_ - пароль пользователя портала 1С

### **list** (l) - получение списка приложений и версий с портала 1С

- _--app-filter_ - фильтр приложений по имени (регулярное выражение)
- _--version-filter_ - фильтр версий по номеру (регулярное выражение)
- _--version-start-date_ - фильтр по начальной дате версии (формат: dd.MM.yyyy, включая дату)
- _--version-end-date_ - фильтр по последней дате версии (формат: dd.MM.yyyy, включая дату)
- _--output-file_ - путь к фалу (json) для сохранения списка приложений и версий

```bat
yard releases --user "user" --pwd "pwd" list --app-filter "Библиотека стандартных подсистем.*3\.1" --version-filter 3\.1.* --version-start-date "01.01.2019" --output-file ".\tmp\releases.json"
```

### **get** (g) - загрузка указанных версий, указанных приложений с портала 1С

- _--app-filter_ - фильтр приложений по имени (регулярное выражение)
- _--version-filter_ - фильтр версий по номеру (регулярное выражение)
- _--version-start-date_ - фильтр по начальной дате версии (формат: dd.MM.yyyy, включая дату)
- _--version-end-date_ - фильтр по последней дате версии (формат: dd.MM.yyyy, включая дату)
- _--distr-filter_ - фильтр заголовков ссылок на скачивание дистрибутива если не указан, то будет выполнена проверка наличия ссылки ""Полный дистрибутив"", затем ""Дистрибутив обновления""
- _--path_ - каталог для загрузки релизов 1С
- _--from-last-version_ - флаг загрузки версий с номером старше последней версии в каталоге для загрузки (проверяются файлы `description.json`)
- _--last-version-description_ - путь к файлу `description.json` с описанием последней загруженной версией
- _--download-existing_ - флаг принудительной загрузки ранее загруженных версий в каталоге для загрузки (проверяются файлы `description.json`)
- _--download-limit_ - ограничение количества загружаемых версий за 1 запуск
- _--download-only_ - только скачать дистрибутив с сайта и не выполнять дальнейшую обработку
- _--download-changelog_ - Скачать "Новое в версии" в файл changelog.htm
- _--extract_ - флаг распаковки загруженного архива
- _--extract-path_ - каталог для распаковки загруженного архива
- _--extract-dir_ - регулярное выражение, отбора каталогов в архиве EFD для распаковки
- _--extract-files_ - список файлов для распаковки из архива дистрибутива, разделенный "|"
- _--extract-existing_ - флаг принудительной распаковки ранее распакованных дистрибутивов версий в каталоге для распаковки (проверяются файлы `description.json`)
- _--version-delimiter_ - символ-разделитель частей версии дистрибутива в имени каталога распаковки шаблона (по умолчанию: ".")
- _--delete_ - флаг удаления загруженного архива после распаковки

```bat
yard releases --user "user" --pwd "pwd" get --app-filter "Библиотека стандартных подсистем.*3\.1" --version-filter 3\.1.* --version-start-date "01.01.2019" --path ".\tmp\distr" --extract --extract-path ".\tmp\tmplts"
```

### **extract** (e) - распаковка шаблона конфигурации 1С из EFD-файла дистрибутива конфигурации 1С

- _--path_ - путь к дистрибутиву конфигурации 1С
- _--extract-path_ - каталог для распаковки загруженного архива
- _--extract-dir_ - регулярное выражение, отбора каталогов в архиве EFD для распаковки
- _--extract-files_ - список файлов для распаковки из архива дистрибутива, разделенный "|"
- _--extract-existing_ - флаг принудительной распаковки ранее распакованных дистрибутивов в каталоге для распаковки (проверяются файлы `description.json`)
- _--version-delimiter_ - символ-разделитель частей версии дистрибутива в имени каталога распаковки шаблона (по умолчанию: ".")
- _--app-name_ - имя конфигурации 1С (если не указано, значение будет считано из файла 1cv8.mft дистрибутива)
- _--app-id_ - идентификатор конфигурации 1С (если не указано, значение будет считано из файла 1cv8.mft дистрибутива)
- _--app-version_ - версия конфигурации 1С (если не указано, значение будет считано из файла 1cv8.mft дистрибутива)

```bat
yard unpack --app-name "Библиотека стандартных подсистем, редакция 3.1" --app-id "SSL31" --app-version "3.1.2.332" --path ".\tmp\distr\SSL31\3.1.2.332" --extract-path ".\tmp\tmplts"
```

## **extract-all** (ea) - для всех дистрибутивов в каталоге выполняет распаковку шаблонов конфигураций 1С из EFD-файлов

- _--path_ - путь к каталогу содержащему дистрибутивы конфигурации для распаковки
- _--extract-path_ - каталог для распаковки шаблонов конфигурации
- _--extract-dir_ - регулярное выражение, отбора каталогов в архиве EFD для распаковки
- _--extract-files_ - список файлов для распаковки из архива дистрибутива, разделенный "|"
- _--extract-existing_ - флаг принудительной распаковки ранее распакованных дистрибутивов в каталоге для распаковки (проверяются файлы `description.json`)
- _--version-delimiter_ - символ-разделитель частей версии дистрибутива в имени каталога распаковки шаблона (по умолчанию: ".")

```bat
yard unpack --app-name "Библиотека стандартных подсистем, редакция 3.1" --app-id "SSL31" --app-version "3.1.2.332" --path ".\tmp\distr\SSL31\3.1.2.332" --extract-path ".\tmp\tmplts"
```

### **build-cf** (b) - выполняет обновление конфигурации (CF) файлом обновления (CFU) и помещает результат в новый файл CF

- _--cf-path_ - путь к файлу конфигурации (CF) предыдущей версии
- _--cfu-path_ - путь к файлу обновления (CFU) новой версии
- _--ibconnection_ - строка подключения к служебной базе 1С для выполнения обновления (если не указана, будет использована временная ИБ)

```bat
yard build-cf --cf-path ".\tmp\tmplts\1c\AccountingCorp\3_0_64_54\1cv8.cf" --cfu-path ".\tmp\tmplts\1c\AccountingCorp\3_0_66_53\1cv8.cfu" --ibconnection "/SMyServer\TMP_BASE"
```

### **build-all** (ba) - для всех файлов обновления (CFU) в каталоге ищет доступные для обновления файлы(CF) и выполняет обновление

- _--path_ - путь к каталогу содержащему версии конфигурации для формирования CF-файлов
- _--ibconnection_ - строка подключения к служебной базе 1С для выполнения обновления (если не указана, будет использована временная ИБ)

```bat
yard build-all --path ".\tmp\tmplts\1c\AccountingCorp" --ibconnection "/SMyServer\TMP_BASE"
```

### **upload-cf** (ucf) - выполняет выгрузку конфигурации 1С из файла конфигурации (CF) в репозитарий git

- _--cf-path_ - путь к файлу конфигурации (CF) для выгрузки
- _--export-tool_ - инструмент выгрузки конфигурации в файлы
  - designer (по умолчанию)
  - ibcmd
- _--git-path_ - путь к репозитарию git
- _--git-branch_ - имя ветки git в которую будет выполняться выгрузка (по умолчанию: base1c)
- _--git-author_ - имя автора коммита в git (по умолчанию: 1c)
- _--git-author-email_ - почта автора коммита в git (по умолчанию: 1c@1c.ru)
- _--git-commit-date_ - дата коммита в git в формате POSIX (формат: yyyy-MM-dd hh:mm:ss, по умолчанию: <ТекущаяУниверсальнаяДата>)
- _--git-commit-message_ - сообщение коммита в git
- _--ibconnection_ - строка подключения к служебной базе 1С для выгрузки в файлы
  - если не указана, будет использована временная ИБ
  - при использовании ibcmd может использоваться только файловая база
- _--object-list-file_ - путь к файлу со списком объектов конфигурации для выгрузки в репозиторий

```bat
yard upload-cf --cf-path ".\tmp\tmplts\SSL31\3.1.1.91\1cv8.cf" --git-path ".\tmp\repo\SSL31" --git-commit-message "Тест выгрузки БСП 3.1.1.91" --ibconnection "/SMyServer\TMP_BASE"
```

### **upload-all** (ua) - выполняет выгрузку всех версий конфигурации 1С в каталоге в репозитарий git

- _--path_ - путь к каталогу содержащему версии конфигурации для выгрузки в git
- _--cf-name - имя файла конфигурации (по умолчанию: 1cv8.cf)
- _--export-tool_ - инструмент выгрузки конфигурации в файлы
  - designer (по умолчанию)
  - ibcmd
- _--git-path_ - путь к репозитарию git
- _--git-author_ - имя автора коммита в git (по умолчанию: 1c)
- _--git-author-email_ - почта автора коммита в git (по умолчанию: 1c@1c.ru)
- _--ibconnection_ - строка подключения к служебной базе 1С для выгрузки в файлы
  - если не указана, будет использована временная ИБ
  - при использовании ibcmd может использоваться только файловая база
- _--object-list-file_ - путь к файлу со списком объектов конфигурации для выгрузки в репозиторий

```bat
yard upload-all --path ".\tmp\tmplts\SSL31\" --cfname "1cv8.cf" --git-path ".\tmp\repo\SSL31" --ibconnection "/SMyServer\TMP_BASE"
```

## Управляющие обработки

### МенеджерОбработкиДанных.os

Управляющая обработка-менеджер, читает настройки, запускает и управляет обработкой данных.

### yard.os

Обработка для интерактивного выполнения команд обработки релизов.

## <a id="api"></a> Стандартный программный интерфейс обработки

**Функция ОписаниеПараметров()** - возвращает структуру с описанием параметров обработки

**Функция МенеджерОбработкиДанных()** - возвращает ссылку на вызывающую/управляющую обработку - менеджер обработки данных

**Процедура УстановитьМенеджерОбработкиДанных(Знач НовыйМенеджерОбработкиДанных)** - устанавливает ссылку на вызывающую/управляющую обработку - менеджер обработки данных

**Функция Идентификатор()** - возвращает идентификатор обработки, установленный при инициализации в менеджере обработки данных

**Процедура УстановитьИдентификатор(Знач НовыйИдентификатор)** - устанавливает идентификатор обработки, вызывается при инициализации в менеджере обработки данных

**Функция ПараметрыОбработкиДанных()** - возвращает значения параметров обработки данных

**Процедура УстановитьПараметрыОбработкиДанных(Знач НовыеПараметры)** - устанавливает значения параметров обработки данных

**Функция ПараметрОбработкиДанных(Знач ИмяПараметра)** - возвращает значение указанного параметра обработки данных

**Процедура УстановитьПараметрОбработкиДанных(Знач ИмяПараметра, Знач Значение)** - устанавливает значение указанного параметра обработки

**Процедура УстановитьДанные(Знач ВходящиеДанные)** - устанавливает данные для обработки

**Процедура ОбработатьДанные()** - выполняет обработку данных

**Функция РезультатОбработки()** - возвращает результаты обработки данных

**Процедура ЗавершениеОбработкиДанных()** - выполняет действия при окончании обработки данных и оповещает обработку-менеджер о завершении обработки данных

## Обработчики данных

### СписокРелизов1С.os

Получает с сайта 1С список релизов и выводит в консоль или в указанный файл.

#### Параметры

- **ИмяПользователя** - Имя пользователя сайта релизов 1С
- **ПарольПользователя** - Пароль пользователя сайта релизов 1С
- **ВремяОжиданияОтвета** - Время ожидания ответа от внешнего ресурса (HTTP) в секундах
- **ФильтрПриложений** - Фильтр имен приложений
- **ФильтрВерсий** - Фильтр номеров версий
- **ФильтрВерсийНачинаяСДаты** - Фильтр по начальной дате версии (включая)
- **ФильтрВерсийДоДаты** - Фильтр по последней дате версии (включая)
- **ПутьКФайлуДляСохранения** - путь к фалу (json) для сохранения списка приложений и версий

### ЗагрузчикРелизов1С.os

Выполняет загрузку указанных приложений и версий с сайта 1С и, при необходимости, распаковывает файлы шаблона конфигурации 1С.

#### Параметры

- **ИмяПользователя** - Имя пользователя сайта релизов 1С
- **ПарольПользователя** - Пароль пользователя сайта релизов 1С
- **ВремяОжиданияОтвета** - Время ожидания ответа от внешнего ресурса (HTTP) в секундах
- **ФильтрПриложений** - Фильтр имен приложений
- **ФильтрВерсий** - Фильтр номеров версий
- **ФильтрВерсийНачинаяСДаты** - Фильтр по начальной дате версии (включая)
- **ФильтрВерсийДоДаты** - Фильтр по последней дате версии (включая)
- **ФильтрДистрибутива** - фильтр заголовков ссылок на скачивание дистрибутива если не указан, то будет выполнена проверка наличия ссылки "Полный дистрибутив", затем "Дистрибутив обновления"
- **СкачиватьНовоеВВерсии** - Истина - будут загружены "Новое в версии" с сайта в файл changelog.htm. По умолчанию: Ложь.
- **ПолучатьБетаВерсии** - Истина - будут получены ознакомительные версии
- **КаталогДляСохранения** - каталог для загрузки релизов 1С
- **НачатьСПоследнейВерсии** - Истина - будут загружены релизы с версией старше последней найденной в каталоге для загрузки (проверяются файлы description.json) Ложь - будут загружены все релизы с учетом других настроек
- **ОписаниеПоследнейВерсии** - путь к файлу description.json с описанием последней загруженной версии Ложь - будут загружены все релизы с учетом других настроек
- **ЗагружатьСуществующие** - Истина - будут загружены все найденные релизы независимо от существующих в каталоге для загрузки Ложь - будут загружены только отсутствующие в каталоге для загрузки релизы (проверяются файлы description.json)
- **ОграничениеКоличества** - ограничение количества загружаемых за 1 раз версий
- **ТолькоСкачать** - Истина - только скачать дистрибутив с сайта и не выполнять дальнейшую обработку
- **РаспаковыватьEFD** - Истина - если загруженный архив содержит упакованный шаблон конфигурации (содержит файл 1cv8.efd), то он будет распакован
- **КаталогДляРаспаковкиEFD** - каталог для распаковки шаблона конфигурации
- **КаталогВАрхивеДляРаспаковкиEFD** - регулярное выражение, отбора каталогов в архиве EFD для распаковки
- **ФайлыДляРаспаковкиEFD** - список файлов для распаковки из архива EFD дистрибутива конфигурации, если не указан, то распаковываются все файлы
- **РаспаковыватьСуществующие** - Истина - будут распакованы все найденные дистрибутивы независимо от существующих в каталоге для распаковки Ложь - будут распакованы только отсутствующие в каталоге для распаковки дистрибутивы (проверяются файлы description.json)
- **РаспаковыватьСуществующие** - символ-разделитель частей версии дистрибутива в имени каталога распаковки шаблона (по умолчанию: ".")
- **УдалитьПослеРаспаковкиEFD** - Истина - после распаковки загруженный архив будет удален

### РаспаковщикРелизов1С.os

Выполняет распаковку файлов шаблона конфигурации 1С из EFD-файла дистрибутива.

#### Параметры

- **Приложение_Имя** - имя конфигурации 1С (если не указано, значение будет считано из файла 1cv8.mft дистрибутива)
- **Приложение_Ид** - идентификатор конфигурации 1С (если не указано, значение будет считано из файла 1cv8.mft дистрибутива)
- **Приложение_Версия** - версия конфигурации 1С (если не указано, значение будет считано из файла 1cv8.mft дистрибутива)
- **ПутьКДистрибутиву** - путь к дистрибутиву конфигурации 1С
- **КаталогДляРаспаковкиEFD** - каталог для распаковки шаблона конфигурации
- **КаталогВАрхивеДляРаспаковкиEFD** - регулярное выражение, отбора каталогов в архиве EFD для распаковки
- **ФайлыДляРаспаковкиEFD** - список файлов для распаковки из архива EFD дистрибутива конфигурации, если не указан, то распаковываются все файлы
- **РаспаковыватьСуществующие** - Истина - будут распакованы все найденные дистрибутивы независимо от существующих в каталоге для распаковки Ложь - будут оаспакованы только отсутствующие в каталоге для распаковки дистрибутивы (проверяются файлы description.json)
- **РаспаковыватьСуществующие** - символ-разделитель частей версии дистрибутива в имени каталога распаковки шаблона (по умолчанию: ".")

### РаспаковщикКаталогаРелизов1С.os

Выполняет распаковку файлов шаблона конфигурации 1С из EFD-файла дистрибутива.

#### Параметры

- **Приложение_Имя** - имя конфигурации 1С (если не указано, значение будет считано из файла 1cv8.mft дистрибутива)
- **Приложение_Ид** - идентификатор конфигурации 1С (если не указано, значение будет считано из файла 1cv8.mft дистрибутива)
- **Приложение_Версия** - версия конфигурации 1С (если не указано, значение будет считано из файла 1cv8.mft дистрибутива)
- **ПутьКДистрибутиву** - путь к дистрибутиву конфигурации 1С
- **КаталогДляРаспаковкиEFD** - каталог для распаковки шаблона конфигурации
- **КаталогВАрхивеДляРаспаковкиEFD** - регулярное выражение, отбора каталогов в архиве EFD для распаковки
- **ФайлыДляРаспаковкиEFD** - список файлов для распаковки из архива EFD дистрибутива конфигурации, если не указан, то распаковываются все файлы
- **РаспаковыватьСуществующие** - Истина - будут распакованы все найденные дистрибутивы независимо от существующих в каталоге для распаковки Ложь - будут оаспакованы только отсутствующие в каталоге для распаковки дистрибутивы (проверяются файлы description.json)
- **РаспаковыватьСуществующие** - символ-разделитель частей версии дистрибутива в имени каталога распаковки шаблона (по умолчанию: ".")

### СборщикКонфигураций1С.os

Выполняет обновление конфигурации (CF) файлом обновления (CFU) и помещает результат в новый файл CF.

#### Параметры

- **ПутьККонфигурации** - путь к файлу конфигурации (CF) предыдущей версии
- **ПутьКОбновлению** - путь к файлу обновления (CFU) новой версии
- **База_СтрокаСоединения** - строка подключения к служебной базе 1С для выполнения обновления (если не указана, будет использована временная ИБ)

### СборщикКонфигураций1СВКаталоге.os

Для всех файлов обновления (CFU) в каталоге ищет доступные для обновления файлы(CF) и выполняет обновление.

#### Параметры

- **ПутьККаталогуКонфигураций** - путь к каталогу содержащему версии конфигурации для формирования CF-файлов
- **База_СтрокаСоединения** - строка подключения к служебной базе 1С для выполнения обновления (если не указана, будет использована временная ИБ)

### ВыгрузкаКонфигурацииВГит.os

Выполняет выгрузку конфигурации 1С из файла конфигурации (CF) в репозитарий git.

#### Параметры

- **ВерсияПлатформы** - маска версии платформы 1С (8.3, 8.3.6 и т.п.)
- **ПутьККонфигурации** - путь к файлу конфигурации (CF) для выгрузки
- **ИнструментВыгрузки** - инструмент выгрузки конфигурации в файлы
  - designer (по умолчанию)
  - ibcmd
- **РепозитарийГит** - путь к репозитарию git
- **ИмяВеткиГит** - имя ветки git в которую будет выполняться выгрузка (по умолчанию: base1c)
- **ИмяАвтора** - имя автора коммита в git (по умолчанию: 1c)
- **ПочтаАвтора** - почта автора коммита в git (по умолчанию: 1c@1c.ru)
- **ДатаКоммита** - дата коммита в git в формате POSIX
- **СообщениеКоммита** - сообщение коммита в git
- **База_СтрокаСоединения** - строка подключения к служебной базе 1С для выполнения обновления (если не указана, будет использована временная ИБ)
- **КонвертироватьВФорматЕДТ** - флаг конвертации в формат ЕДТ
- **СнятьСПоддержки** - снять конфигурацию с поддержки
- **ВерсияЕДТ** - версия среды 1С:Enterprise development tools для конвертации
- **ОтносительныйПуть** - Относительный путь внутри репозитории к исходникам проекта, по умолчанию (src/cf)
- **ПутьКСпискуОбъектов** - путь к файлу, содержащему список объектов конфигурации для выгрузки в репозиторий

### ВыгрузкаКаталогаКонфигурацииВГит.os

Выполняет выгрузку конфигурации 1С из файла конфигурации (CF) в репозитарий git.

#### Параметры

- **ВерсияПлатформы** - маска версии платформы 1С (8.3, 8.3.6 и т.п.)
- **ПутьККаталогуКонфигураций** - путь к каталогу содержащему версии конфигурации для выгрузки в git
- **ИмяФайлаКонфигурации** - имя файла конфигурации (по умолчанию: "1Cv8.cf")
- **ИнструментВыгрузки** - инструмент выгрузки конфигурации в файлы
  - designer (по умолчанию)
  - ibcmd
- **РепозитарийГит** - путь к репозитарию git
- **ИмяВеткиГит** - имя ветки git в которую будет выполняться выгрузка
- **ИмяАвтора** - имя автора коммита в git (по умолчанию: 1c)
- **ПочтаАвтора** - почта автора коммита в git (по умолчанию: 1c@1c.ru)
- **КонвертироватьВФорматЕДТ** - флаг конвертации в формат ЕДТ
- **ВерсияЕДТ** - версия среды 1С:Enterprise development tools для конвертации
- **СнятьСПоддержки** - снять конфигурацию с поддержки
- **ОтносительныйПуть** - Относительный путь внутри репозитории к исходникам проекта, по умолчанию (src/cf)
- **База_СтрокаСоединения** - строка подключения к служебной базе 1С для выполнения обновления (если не указана, будет использована временная ИБ)
- **КонвертироватьВФорматЕДТ** - флаг конвертации в формат ЕДТ
- **ОтносительныйПуть** - Относительный путь внутри репозитории к исходникам проекта, по умолчанию (src/cf)
- **ПутьКСпискуОбъектов** - путь к файлу, содержащему список объектов конфигурации для выгрузки в репозиторий

## <a id="jsonsettings"></a> Файл настроек (JSON)

### Структура файла настроек

Файл настроек описывает последовательность вызова обработчиков для обработки данных. обработчик = обработка 1С реализующая вышеуказанный [API](#api).

```txt
    |-> Описание обработчика
    |      |- ИдОбработчика     - строковый идентификатор обработчика (необязательный)
    |      |- ИмяОбработки      - имя класса обработчика
    |      |- ПутьКОбработке    - путь к oscript-файлу класса обработчика
    |      |- Параметры         - структура параметров обработки
    |      |      |- <просто параметр>                 - параметр простого типа
    |      |      |- <параметр из данных обработчика>  - параметр вычисляемый обработчиком
    |      |      |      |- ИдОбработчика              - идентификатор обработчика из которого будет получен параметр
    |      |      |      |- ФункцияПолученияЗначения   - имя функции получения значения параметра (по умолчанию: "ПолучитьРезультат")
    |      |- Обработчики      - массив обработчиков данных полученных на текущем уровне
    |             |- <Описание обработчика>*           - структура, аналогичная данной
    |____________________|
```

### Доступные подстановки

- **$settingsDir** - каталог файла настроек
- **$yardDir** - каталог запуска скрипта
- **$workDir** - указанный при запуске рабочий каталог (по умолчанию: каталог файла настроек)

### Пример файла настроек

Пример файла настроек чтения словарей журнала регистрации

```json
{
    // имя класса обработчика получения списка релизов
    "ИмяОбработки":"СписокРелизов1С",
    "Параметры":{
        "ИмяПользователя" : "user",
        "ПарольПользователя" : "password",
        "ВремяОжиданияОтвета" : 30,
        // Регулярки для фильтра приложений/конфигураций по имени
        "ФильтрПриложений" : ["Библиотека стандартных подсистем.*3\\.1"],
        // Регулярки для фильтра версий по номеру
        "ФильтрВерсий" : ["3\\.1\\.2.*"],
        "ФильтрВерсийНачинаяСДаты" : "2020-01-01T00:00:00",
    },
    "Обработчики":[
        {
            // имя класса обработчика загрузки релизов
            "ИмяОбработки":"ЗагрузчикРелизов1С",
            "ИдОбработчика":"ЗагрузчикБСП",
            "Параметры":{
                "ИмяПользователя" : "user",
                "ПарольПользователя" : "password",
                "КаталогДляСохранения" : "$workDir\\tmp\\distr",
                // флаг распаковки шаблона
                "РаспаковыватьEFD" : true,
                // путь распаковки шаблона конфигурации
                "КаталогДляРаспаковкиEFD" : "$workDir\\tmp\\tmplts"
            }
        }
    ]
}
```

Больше примеров расположены в каталоге [examples](./examples).
