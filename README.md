[English documentation](https://github-com.translate.goog/endportal0292/CoreXY-Music-Converter?_x_tr_sl=ru&_x_tr_tl=en)  

# CoreXY-Music-Converter
Program for converting musical gcode to coreXY mechanics
- Преобразование музыкального gcode для механики CoreXY
- Программа позволяет сыграть gcode-музыку на механике CoreXY
- Выключение моторов после окончания воспроизведения
- Пауза перед и после музыки
- gcode для Klipper и Marlin

**АВТОР НЕ НЕСЁТ ОТВЕТСТВЕННОСТЬ ЗА ВОЗМОЖНЫЕ ПОВРЕЖДЕНИЯ 3Д ПРИНТЕРА!!!**

## Содержание
- [Установка](#install)
- [Инструкция](#manual)
  - [Принцип работы](#working)
  - [Конвертер midi в gcode](#converter)
  - [Импорт файла](#import)
  - [Настройки](#settings)
  - [Конвертирование](#convert)
  - [Отправка на принтер](#print)
- [Проблемы и их решения](#troubleshooting)
- [Версии](#versions)
- [Баги и предложения](#callbackping)


<a id="install"></a>
## Установка
- Программа доступна в виде приложения для Windows(32, 64-bit). Для работы нужна Java актуальной версии(приложения проверялись на Java Version 8 Update 441)
- Также в [архиве](https://github.com/endportal0292/CoreXY-Music-Converter/archive/refs/heads/main.zip) есть исходный код написанный на Processing 3.5.4(Java)


<a id="manual"></a>
## Инструкция
<a id="working"></a>
### Принцип работы
![programm](doc/programm.jpg)
- Программа преобразует gcode из [конвертера](https://www.ultimatesolver.com/en/midi2gcode) в gcode для CoreXY механики без потери звука
- Принцип работы программы:
  - Загрузка файла с сайта конвертера(определенный синтаксис + расширение .nc, .gcode, .txt)
  - Настройка параметров gcode'а(тип прошивки, ускорение, отключение моторов, пауза перед и после музыки)
  - Конвертирование
  - Экспорт gcode'а(копирование, сохранение как файл .gcode)
  - Отправка на ЧПУ с CoreXY механикой
- Алгоритм конечного gcode'а:
  - Автопарковка(G28)
  - Переход к абсолютным координатам(G90)
  - Единицы измерения - миллиметры(G21)
  - Ускорение 500мм/с^2
  - Движение в начальную точку по оси Z со скоростью 600мм/мин
  - Движение в начальную точку по осям X и Y со скоростью 7800мм/мин
  - Установка заданного ускорения
  - Пауза, если включена(G4)
  - Воспроизведение мелодии
  - Пауза, если включена(G4)
  - Выключение моторов(M84)


<a id="converter"></a>
### Конвертер midi в gcode
Как сделать из midi gcode для этой программы?
- Зайти на [сайт](https://www.ultimatesolver.com/en/midi2gcode)
![site1](doc/site1.jpg)
- Выбрать midi файл, нажать **Analyze file**
![site2](doc/site2.jpg)
- Необходимо внести информацию о принтере
  - Единицы измерения - мм, не трогать
  - Название осей тоже не трогать
  - Количество осей: для программы выставить 2 или 3(чем больше, тем лучше будет звучать музыка). Для 1 оси данная программа не нужна
  - Каналы: рекомендуется оставить все включёнными. Если принтер издаёт непонятные звуки(музыка не похожа на оригинал), то необходимо выключить некоторые каналы, которые не несут большой роли в мелодии
  - Шагов на миллиметр: ввести количество шагов на миллиметр для каждой оси. Эту информацию мжно найти в прошивке принтера(Marlin), либо в cfg файле(Klipper)
  - Рабочая зона в миллиметрах: область, в которой будут перемещаться оси принтера. Для оси Z минимальное значение ограничить примерно 10мм, чтобы сопло не царапало стол при движении
![site3](doc/site3.jpg)
- Здесь можно выключить паузы между отдельными звуками - **Disable breaks**. Некоторая музыка может звучать лучше
- Согласиться с тем, что мы используем генератор gcode'а на свой риск
- Нажать **Create G-Code**
![site4](doc/site4.jpg)
- После генерации можно послушать, как примерно будет звучать музыка на принтере - **Listen to music**
- Кнопка **Save file** скачает gcode в файле расширения .nc
- Ниже прописан gcode в виде текста
- Ещё ниже можно вернуться к настройкам, чтобы поменять их, если Вас не устроило звучание - **Change settings**
- В самом низу страницы можно вернуться к выбору midi файла - **Select new MIDI file**

Gcode файл с музыкой готов, но он будет корректно работать, если у ЧПУ(принтера) каждой осью управляет отдельный мотор(механики H-BOT, PRUSA, ULTIMAKER и им подобные). Но для CoreXY, CoreXYZ, MAKERBOT и других придётся пользоваться конвертером из одной механики в другую. **Данная программа конвертирует только в CoreXY!**


<a id="import"></a>
### Импорт файла
- Программа поддерживает файлы из конвертера версии 2.7.4
- На вход принимаются файлы расширения nc, gcode, nc
- Синтаксис должен быть на у канвертера выше. В начале файла параметры принтера; перед началом основного gcode'а находятся команды G21, G90, G94, G00/G01; в конце команда M02
- Если файл не соответсвует требованиям, будет показана ошибка файла


<a id="settings"></a>
### Настройки
- Настройки влияют на конечный gcode
- При изменении любой настройки надо будет заново конвертировать gcode
- После 5 секунд бездействия(отсутствия изменения настроек) данные будут автоматически сохранены, а внизу по центру будет показана надпись "Сохранение"
- Всего 4 настройки:
  - [Тип прошивки](#firmware)
  - [Ускорение](#accel)
  - [Выключение моторов(M84)](#motors84)
  - [Пауза перед и после воспроизведения(G4)](#pause4)


<a id="firmware"></a>
#### Тип прошивки
![firmwarejpg](doc/firmware.jpg)
- Тип прошивки(Marlin или Klipper) определяет синтаксис конечного gcode'а
- Синтаксис некоторых команд Klipper'а и Marlin'а отличается
- Значение по умолчанию - Klipper


<a id="accel"></a>
#### Ускорение
![acceljpg](doc/accel.jpg)
- Ускорение влияет на качество звука
- Если выставить слишком низкое значение, моторы будут слишком медленно разгоняться. Частота и громкость будут плавно нарастать и убывать
- Если выставить слишком большое значение, принтер может начать издавать щёлкающие звуки(из-за слишком быстрого разгона или из-за пропуска шагов моторами). Также частоты звуков могут немного изменяться из-за работы алгоритма INPUT SHAPING(асли он есть)
- Рекомендуемое значение - 2000-4000мм/с^2
- Значение по умолчанию - 4000мм/с^2


<a id="motors84"></a>
#### Выключение моторов(M84)
![m84](doc/m84.jpg)
- Выключение моторов после окончания воспроизведения влияет на нагрев моторов
- Если выключать моторы, то они и драйвера смогут охладиться на небольшую температуру
- Рекомендуемое значение - вкл.
- Значение по умолчанию - вкл.


<a id="pause4"></a>
#### Пауза перед и после воспроизведения(G4)
![g4](doc/g4.jpg)
- Пауза перед и после воспроизведения уменьшает шум от моторов
- В начале моторы вращаются, передвигая оси в начальные координаты, и издают звук
- В конце, если моторы выключаются(M84), они издают щелчок
- Пауза отделяет звук подготовки к воспроизведению от самой музыки
- Рекомендуемое значение - 1000-10000мс
- Значение по умолчанию - 5000мс


<a id="convert"></a>
### Конвертирование
- После выбора файла и настроек слева внизу появится кнопка **Конвертировать**
![convertjpg](doc/convert.jpg)
- После нажатия все кнопки станут неактивными и начнётся конвертирование
- На кнопке будет показан процент завершённости процесса
- После окончания все кнопки станут активными, в том числе кнопки **Копировать** и **Сохранить**(справа вверху), которые раньше были недоступны
![savecopy](doc/savecopy.jpg)
  - Кнопка **Копировать** скопирует конечный gcode в буфер обмена
  - Кнопка **Сохранить** экспортирует gcode в виде .gcode файла в путь *папка программы*\out\. К названию прибавится " - CoreXY - " и тип прошивки(Marlin/Klipper)


<a id="print"></a>
### Отправка на принтер
- Воспроизвести музыку можно 2 способами:
  - Закинуть .gcode файл на печать
  - Вставить gcode в консоль принтера


<a id="troubleshooting"></a>
## Проблемы и их решения
- [Оси двигаются, а звука нет](#mute)
- [Частота звука выше/ниже, чем ожидалось](#freq)


<a id="mute"></a>
### Оси двигаются, а звука нет
- Gcode воспроизводится, оси двигаются, а звука нет. Такое может быть, если моторы находятся в "тихом" режиме
- Моторы работают в режиме StealthChop, либо включена интерполяция, либо всё вместе
  - Режим работы драйверов настраивается, если драйвера подключены по uart. Надо вместо режима StealthChop поставить SpreadCycle. Изменить можно в коде прошивки/cfg файле(зависит от типа прошивки)
  - Интерполяция настраивется также, как и режим работы(StealthChop/SpreadCycle). Интерполяцию необходимо отключить


<a id="freq"></a>
### Частота звука выше/ниже, чем ожидалось
- Скорее всего Вы неправильно указали количество шагов на миллиметр на сайте конвертера
  - За данный параметр отвечают шкивы на моторах, моторы(шаги на оборот), редуктор(если есть) между мотором и шкивом/валом
  - Шагов_на_мм **=** (шагов_на_оборот **x** микрошаг) **/** мм_на_оборот **x** соотношение_редуктора(если есть)
  - Рекомендуемый микрошаг для мотора 200 шагов_на_оборот и 40 мм_на_оборот - 16 микрошагов на шаг


<a id="versions"></a>
## Версии
- v1.0

<a id="callbackping"></a>
## Баги и предложения
Предложить идею/сообщить о баге - писать на электронку [endportal0292@gmail.com](mailto:endportal0292@gmail.com)
