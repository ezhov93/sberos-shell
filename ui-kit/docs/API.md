# API-контракт SberOS UI Kit

Редакция контракта: **2**, 2026-10-22. Статус: принят как основной справочник для потребителей UI Kit. Описывает текущий API исходного снимка, а не завершённую интеграцию с оболочкой. Версия `version.txt` — **1.7.2**; `Sber.Controls` отдельно объявляет **1.4.0**. Редакция документа не является версией бинарного ABI.

## Как пользоваться контрактом

1. При разработке интерфейсов оболочки и приложений сначала читать этот документ, затем искать нужный тип в [каталоге объявлений](API-catalog.md), токен — в [каталоге токенов](API-tokens.md).
2. Не перечитывать исходники UI Kit для обычного использования описанного API. Существующие базовые свойства Qt перечислены ниже; собственные расширения перечислены в каталоге.
3. Если нужное поведение не описано, есть ошибка выполнения или проверка актуальности не проходит, читать только относящуюся к вопросу реализацию и дополнять контракт в той же задаче. Отсутствующее API не выдумывать.
4. При изменении самой библиотеки читать её реализацию по необходимости. Контракт не заменяет отладку, сборку и визуальную проверку.

Документ описывает рекомендуемый способ использования. Автоматические каталоги содержат и вспомогательные экспортируемые типы; они не означают обещания стабильности всех внутренних объектов и функций. Проверенная по исходникам сигнатура не означает проверенное на устройстве поведение.

## Подключение и среда

```qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtControls
import Sber.Controls as Sber
import Sber.Core
import Sber.Theme
// import Sber.Widgets as SberWidgets // при необходимости
// import Sber.Utils as SberUtils     // при необходимости
```

Импорты Sber использовать без явной версии, как в текущей галерее. Псевдоним `Sber` исключает коллизии с типами Qt; `Core` и `Theme` — singleton-объекты, `Settings` и `Sber.Widget` дают перечисления. `Core.Settings` — объект настроек, его не создают через `Settings {}`.

| Модуль | Назначение |
| --- | --- |
| `Sber.Controls` | Элементы управления, формы, окна, меню, служебные визуальные типы |
| `Sber.Core` | Настройки UI Kit, уведомления, регистрация кликов |
| `Sber.Theme` | Палитра, размеры, шрифты, имена иконок |
| `Sber.Widgets` | Составной экран `ThemeSettings` |
| `Sber.Utils` | Утилиты, включая доступ к процессам, файлам, D-Bus и буферу обмена |

Утилиты не являются API рабочего пространства SberOS и не предоставляют модель разрешений. Конфигурация оболочки, вызовы сервисов и предметная логика остаются в потребителе.

Текущий проверочный стек галереи: Qt **6.11.2**, Linux, `offscreen`, программный рендеринг. Минимальная версия Qt для всего API не подтверждена: некоторые компоненты используют отдельные радиусы углов Rectangle. Требование Qt 6.6 в Sirca не доказывает совместимость с UI Kit.

Для хоста нужен `QApplication` и `QQmlApplicationEngine`, как в галерее. До загрузки QML добавить каталог `<сборка-ui-kit>/qml` через `engine.addImportPath(...)`. Доступность плагинов, их разделяемых библиотек и ресурсов требуется и при запуске установленного приложения. Оболочка собирается отдельно: её CMake-параметр `SBER_QML_IMPORT_PATH` указывает на этот каталог (по умолчанию `ui-kit/_build/qml`); путь добавляется во все QML-движки оболочки, включая проверки. Исходный проект UI Kit использует `CMAKE_SOURCE_DIR`, поэтому поддержку `add_subdirectory` не предполагать.

```sh
cmake -S ui-kit -B ui-kit/_build -DBUILD_WITH_CTEST=OFF
cmake --build ui-kit/_build -j 4
./ui-kit/_build/examples/gallery/sber-components-gallery
```

`THEME_RESOURCES_PATH` задаётся при сборке библиотеки и по умолчанию указывает на `ui-kit/resources`. Нужны `theme/sdds_os.json`, `theme/sizes_os.json`, `theme/font_styles.json`, связанные палитры и `icons/`. Один `addImportPath` не переопределяет путь ресурсов. Фирменные шрифты устанавливаются отдельно; возможна подстановка Qt.

## Тема, размеры и шрифты

| API | Тип / смысл |
| --- | --- |
| `Core.Settings.ThemeName` | `string`, чтение/запись имени темы; для смены использовать `Theme.setTheme(name)` |
| `Core.Settings.IsDarkTheme` | `bool`, только чтение эффективного тёмного режима |
| `Core.Settings.LineHeight` | `int`, чтение/запись базового размера контролов; это не высота строки текста |
| `Core.Settings.getThemeMode()` | Возвращает числовое значение режима |
| `Core.Settings.setThemeMode(mode)` | Принимает `Settings.Light`, `Settings.Dark`, `Settings.System` |
| `Theme.Palette` | Дерево цветов текущей темы, только чтение |
| `Theme.Sizes` | Дерево размеров, только чтение |
| `Theme.Fonts` | Именованные `font`, только чтение |
| `Theme.getAvaliableThemeNames()` | Список имён тем; написание `Avaliable` является частью API |
| `Theme.getAvaliableThemes()` | Отображение имён тем в имена файлов |
| `Theme.setTheme(name)` | Выбирает тему; неизвестное имя при наличии тем заменяется первой доступной |
| `Theme.reloadTheme()` | Перечитывает выбранную тему |
| `Theme.getAllImageNames()` | Список имён иконок для `Sber.Icon.name` |

`Theme.ThemeChanged` сообщает об обновлении темы; `Core.Settings` имеет `ThemeNameChanged`, `IsDarkThemeChanged`, `LineHeightChanged`. Palette и Sizes могут заменяться: связывать свойства напрямую с `Theme.Palette...`, не хранить вложенный объект палитры навсегда.

Инициализация после загрузки темы:

```qml
Component.onCompleted: {
    Core.Settings.LineHeight = Theme.Sizes.LineHeight.S
    Core.Settings.setThemeMode(Settings.Light)
}
```

Для оболочки режим должен поступать из её конфигурации; приведённый пример задаёт светлый режим только для отдельного приложения. Настройки UI Kit сохраняются через собственный `QSettings`, привязанный к имени приложения. Они не заменяют `sirca-shell/config.json` и не переключают автоматически темы KDE/GTK.

| Токен | Назначение |
| --- | --- |
| `Theme.Palette.Background.Default.Primary` | Основной фон |
| `Theme.Palette.Background.Default.Secondary` | Дополнительный фон |
| `Theme.Palette.Text.Default.Primary` | Основной текст |
| `Theme.Palette.Text.Default.Secondary` | Подписи и пояснения |
| `Theme.Palette.Surface.Default.Accent` | Акцентная поверхность |
| `Theme.Palette.Surface.Default.AccentHover` / `AccentActive` | Состояния акцента |
| `Theme.Palette.Surface.Default.Negative` | Ошибка |
| `Theme.Palette.Outline.Default.SolidSecondaryHover` | Контур |
| `Theme.Sizes.LineHeight.Xxs / Xs / S / M / L` | В текущих ресурсах: 24 / 32 / 40 / 48 / 56 |
| `Theme.Sizes.BorderRadius.Xxs / Xs / S / M / L / Xl / Xxl` | В текущих ресурсах: 4 / 6 / 8 / 12 / 16 / 20 / 40 |
| `Theme.Fonts.BodyS`, `BodySB`, `BodyM`, `BodyMB` | Основной текст, обычный и полужирный |
| `Theme.Fonts.HeaderH4`, `HeaderH4B` | Заголовки |

Числа описывают текущие ресурсы; в интерфейсе ссылаться на токены. Полные пути и типы — в [каталоге токенов](API-tokens.md). Цвета `Default` следуют теме; фиксированные варианты `Light`/`Dark`/`OnLight`/`OnDark` использовать только при соответствующем фоне.

## Перечисления оформления

| Свойство / группа | Значения |
| --- | --- |
| `type` / `Widget.Type` | `Sber.Widget.Default`, `Accient`, `Secondary`, `Black`, `White` |
| `backgroundType` / `Widget.Background` | `Sber.Widget.Solid`, `Outline`, `Clear` |
| `status` / `Widget.Status` | `Sber.Widget.None`, `Success`, `Warning`, `Error`; псевдонимы `Online`, `Afk`, `Offline` |
| Углы / `Widget.Corner` | `Sber.Widget.Flat`, `Square`, `Circle` |
| Размещение / `Widget.Placement` | `Sber.Widget.Inner`, `Outer`; `Left = Inner`, `Right = Outer` |

`Accient` — фактическое написание, `Accent` в этом перечислении отсутствует. Суффиксы `Last` — служебные границы, их не использовать. Не каждый компонент имеет все эти свойства; сверять его запись в каталоге.

## Основные компоненты для форм

Свойства Qt ниже унаследованы от соответствующего базового типа. Дополнения UI Kit перечислены отдельно. На все визуальные элементы распространяются `visible`, `enabled` и геометрия Item; `Layout.*` использовать только в Qt Quick Layouts, не смешивать с anchors на тех же осях. Размеры по умолчанию вычисляются через `implicitWidth/implicitHeight`; длинным подписям задавать доступную ширину и перенос.

| Компонент | База Qt / основной API | Дополнения UI Kit |
| --- | --- | --- |
| `Sber.Button` | `T.Button`: `text`, `icon.name/source`, `enabled`, `checkable`, `checked`; `clicked()`, `toggled()` | `type`, `status`, `backgroundType`, `lineHeight`, `loading`, `loadingPercent`, `radius`, `cornersType` |
| `Sber.IconButton` | Наследует `Sber.Button`, те же свойства и сигналы | Квадратный размер по `lineHeight`, нулевые отступы |
| `Sber.Label` | `T.Label`: `text`, `font`, `color`, `wrapMode`, `elide` | `lineHeight`, `bold`, `secondary`, `smaller`, `type`, `backgroundType`, `status` |
| `Sber.Switch` | `T.Switch`: `text`, `checked`, `toggled()` | `captionText`, `fontColor`, `lineHeight`, `indicatorHeight/Width` |
| `Sber.CheckBox` | `T.CheckBox`: `text`, `checked`, `checkState`, `tristate`, `toggled()` | `captionText`, `lineHeight`, `fontColor`, `indicatorSize`, имена иконок состояний |
| `Sber.RadioButton` | `T.RadioButton`: `text`, `checked`, `toggled()` | Дополнения см. в каталоге |
| `Sber.TextField` | `T.TextField`: `text`, `placeholderText`, `readOnly`, `validator`; `textEdited()`, `accepted()` | `labelText`, `captionText`, `status`, `type`, `lineHeight`, `required`, `textLimit`, `iconLeft/Right` |
| `Sber.ComboBox` | `T.ComboBox`: `model`, `currentIndex`, `currentValue`, `activated(index)` | `labelText`, `captionText`, `placeholderText`, `lineHeight`, `tight`, `multiselect`; роли ниже |
| `Sber.Slider` | `T.Slider`: `from`, `to`, `stepSize`, `value` | `labelText`, `showRangeValues`, `rangeValuesPlacement`, `view`, `decimials`, `labelPacement`, `handleWidth`, `lineHeight` |
| `Sber.ProgressBar` | `T.ProgressBar`: `from`, `to`, `value`, `indeterminate` | `circular`, `warning`, `error`, `color`, `lineHeight`; по умолчанию диапазон **0…100** |
| `Sber.Chip` | `Rectangle`, не AbstractButton | `text`, `idx: string`, `icon`, `closable`, `circle`, `type`, `lineHeight`; `closed(string idx)` |
| `Sber.Icon` | `Item` | `name: string`, `source: string`, `size: int`, `color: color`, `imageProvider: string` |

### События и привязки

У кнопок и переключателей использовать события действий пользователя. `onCheckedChanged` и `onTextChanged` вызываются и при обновлении модели; не сохранять конфигурацию без защиты от обратной записи. Сигнал `toggled()` у Sber.Switch не передаёт аргумент: читать `checked`.

```qml
Sber.Switch {
    text: qsTr("Уведомления")
    checked: settingsModel.notificationsEnabled
    onToggled: settingsModel.setNotificationsEnabled(checked)
}
Sber.Button {
    text: qsTr("Сбросить")
    type: Sber.Widget.Secondary
    onClicked: settingsModel.reset()
}
```

`settingsModel` здесь — объект потребителя с указанными свойством и методами; он не входит в UI Kit.

### Поля ввода и выбор

`TextField.textLimit` показывает счётчик и выставляет `status = Widget.Error` при превышении; ввод не обрезает. Признак `required` показывает индикатор обязательности и сам по себе не валидирует значение. В текущей реализации Return, Enter **и Escape** вызывают `accepted()` и снимают фокус. Не считать Escape отменой ввода без отдельной обработки и проверки.

`ComboBox` по умолчанию: `textRole = "text"`, `valueRole = "value"`, `captionRole = "caption"`, `checkStateRole = "checkState"`, `currentIndex = -1`, `multiselect = false`. Для обычного выбора использовать `ListModel` с ролями `text` и `value`. Для многовыбора поддержаны `ListModel` и массив объектов с ролями, указанными выше; `checkState` хранит `Qt.Checked` или `Qt.Unchecked`. Другие реализации модели требуют отдельной проверки.

`Range.setValueFrom(value)` и `Range.setValueTo(value)` задают значения полей начала и конца независимо.

### Слайдер: пользовательское изменение и завершение

Точные имена: **`decimials`**, **`labelPacement`**, `Sber.Slider.View.Accient` (значение enum View). Шаг называется `stepSize`. Это другой API, чем Sirca GlassSlider: сигналов `committed` и `moved(value)` нет.

В редакции 2 добавлены события:

| Событие | Контракт |
| --- | --- |
| `valueEdited(real value)` | Пользователь изменил значение указателем или клавиатурой; программное присваивание `value` не испускает событие |
| `editingFinished(real value)` | Завершено перетаскивание (отпускание или отмена захвата), либо выполнен шаг клавиатурой; передаётся итоговое значение |
| `moved()` | Стандартное событие Slider без аргументов; теперь испускается и внутренней MouseArea |

Внутренняя MouseArea ограничивает значение диапазоном и округляет к `stepSize` относительно `from`; `stepSize <= 0` означает непрерывное изменение. Во время перетаскивания `pressed = true`. При завершении указателем `editingFinished` испускается до сброса `pressed`, чтобы потребитель сохранил итоговое значение до восстановления привязки. Для клавиатуры событие завершения приходит на каждом изменившем значение шаге. Программные изменения не сохранять через `onValueChanged`.

Путь указателя прямо присваивает `value`; для повторного обновления из модели применять Binding, отключённый на время перетаскивания:

```qml
Sber.Slider {
    id: slider
    from: 0; to: 100; stepSize: 1
    Binding { target: slider; property: "value"; value: settingsModel.level; when: !slider.pressed }
    onValueEdited: v => settingsModel.previewLevel(v)
    onEditingFinished: v => settingsModel.commitLevel(v)
}
```

`settingsModel` — модель потребителя; при завершении она должна принимать последнее значение до восстановления Binding. Оболочка использует такой подход в Settings.qml и сбрасывает очередь записей при смене страницы, скрытии и закрытии окна. Проверки диапазона, шага, событий, клавиатуры и внешнего обновления выполняются в `ui-kit/tests/tst_slider.qml` и тестах настроек оболочки на Qt 6.11.2/offscreen. Сенсорный ввод, другие версии Qt и доступность в Wayland ещё не подтверждены.

### Метки и иконки

`Chip` сообщает `closed(idx)` при нажатии на область удаления; стандартного `clicked()` и состояния `checked` у него нет. Для выбора режима использовать `Button { checkable: true }` либо RadioButton, для метки — Chip.

`Icon.name` берётся из `Theme.getAllImageNames()` и имеет приоритет над `source`; это имена библиотеки, а не автоматически имена KDE. Для файловой/ресурсной иконки использовать `source`. Поставщик по умолчанию — `"Default"`, устанавливается при инициализации Theme в QML-движке.

## Окна, прокрутка и составные элементы

`Sber.ApplicationWindow` наследует `T.ApplicationWindow`: обычные `title`, `width`, `height`, `minimumWidth/Height`, `visible`, `header`, `footer`, `background`. Дополнения: `controls` (маска `Settings.Close | Settings.Maximize | Settings.Minimize`), `backgroundColor`, `backgroundRadius`, `headerButtonsFocusPolicy`. По умолчанию окно видимо. Собственная шапка создаётся при `Qt.CustomizeWindowHint`, если `header` не задан; автоматически используется Core.Notifier для встроенных уведомлений.

Можно использовать `QtControls.ApplicationWindow` с Sber-компонентами, как в галерее. Для миграции окна оболочки выбор декорации и окна проверять в Wayland; UI Kit не заменяет управление окнами KWin.

`ScrollView`, `ScrollBar`, `TabBar`, `TabButton`, `Menu`, `MenuItem`, `Popup`, `Dialog`, `DialogButtonBox`, `TextArea` и остальные экспортируемые компоненты описаны в [каталоге](API-catalog.md) с базовым типом и собственными членами. Для неописанной здесь семантики сложного компонента сначала дополнить контракт. Внутренние `backgroundConfig`, `colorizer`, `textItem` и прочие alias-объекты не использовать как обязательную основу прикладного интерфейса; предпочитать свойства верхнего уровня.

## Уведомления и утилиты

`Core.Notifier.createNotify()` возвращает Notice с полями `title`, `text`, `iconName`, `iconPath`, `image`, `closable`, `timeout`. `sendNotify(notice)` испускает `newNotify(notice)` для интерфейса приложения; `sendSystemNotify(notice)` и `sendSystemNotify(title, message)` предназначены для системного уведомления. Не путать их с конфигурацией или сервером уведомлений оболочки.

Сигнатуры Core, Theme и Utils перечислены в каталоге. Каталог C++ показывает Q_PROPERTY/Q_INVOKABLE и enum из заголовков; имена разделов соответствуют файлам, не обязательно именам создаваемых QML-типов. Это справочник деклараций, не общий контракт безопасности или завершения операций с процессами/файлами. Такие операции проверять и описывать отдельно перед первым использованием.

## Совместимость и обновление

Потребитель использует документированные свойства, сигналы, enum и токены. Не зависеть от внутренних id, порядка дочерних элементов, путей к исходным QML или конкретного устройства background/contentItem. Случайно экспортируемые детали не становятся стабильным API.

При изменении API в одной задаче:

1. Обновить этот документ: сигнатуры, значения по умолчанию, события, ограничения и пример миграции при несовместимом изменении.
2. Увеличить редакцию контракта при изменении его смысла. Изменения версии библиотеки согласовывать отдельно; скрипт её не повышает.
3. Выполнить `python3 ui-kit/tools/api_contract.py --write`, проверить изменения каталогов и отпечатка источников.
4. Выполнить `python3 ui-kit/tools/api_contract.py --check`, сборку и применимые проверки поведения/интерфейса.

Проверка без Qt:

```sh
python3 ui-kit/tools/api_contract.py --check
```

Она сравнивает каталоги и SHA-256 отпечатки QML/C++ модулей, CMake, версии и JSON темы. Изменение реализации тоже требует просмотра контракта, даже если сигнатуры прежние. Проверка не обнаруживает смысловые ошибки документа и не заменяет запуск Qt. Каталоги — статическое извлечение объявлений, а не полноценный QML/C++ парсер. SVG, шрифты и окружение выполнения отпечатком не покрыты; имена иконок запрашивать через Theme.

При миграции настроек действуют [ADR-0006](../../docs/adr/0006-settings-ui-kit.md) и [правила настроек](../../docs/rules/settings-ui-kit.md), включая сценарии `09-01`, `09-02`, `09-19`, `09-21`, `09-24`. Выполнение этих сценариев данным документом не подтверждается.
