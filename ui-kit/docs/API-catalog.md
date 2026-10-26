# Каталог объявлений UI Kit

Генерируется `python3 ui-kit/tools/api_contract.py --write`. Не редактировать вручную.

Основной контракт и семантика: [API.md](API.md). Здесь перечислены собственные
объявления корневых QML-объектов и экспортируемые C++-объявления верхнего уровня.
Наследуемый Qt API, значения по умолчанию, вложенные объекты и детали поведения
не извлекаются. Наличие объявления не гарантирует работоспособность поведения.
Поля вспомогательных объектов и функции реализации не становятся рекомендуемым API.

## Sber.Core

### C++: clicktracker

Источник: `core/clicktracker.h`.

```cpp
Q_INVOKABLE void registerClick(QObject *element)
```

### C++: core

Источник: `core/core.h`.

```cpp
Q_PROPERTY(Settings *Settings READ GetSettings CONSTANT)
Q_PROPERTY(Notifier *Notifier READ GetNotifier CONSTANT)
Q_PROPERTY(ClickTracker *ClickTracker READ GetClickTracker CONSTANT)
```

### C++: notifier

Источник: `core/notifier.h`.

```cpp
Q_PROPERTY(QString text MEMBER text)
Q_PROPERTY(QString title MEMBER title)
Q_PROPERTY(QString iconName MEMBER iconName)
Q_PROPERTY(QString iconPath MEMBER iconPath)
Q_PROPERTY(QImage image MEMBER image)
Q_PROPERTY(bool closable MEMBER closable)
Q_PROPERTY(int timeout MEMBER timeout)
Q_INVOKABLE Notice createNotify() const
Q_INVOKABLE void sendNotify(const Notice &message) const
Q_INVOKABLE void sendSystemNotify(const Notice &message) const
Q_INVOKABLE void sendSystemNotify(const QString &title, const QString &message) const
```

### C++: settings

Источник: `core/settings.h`.

```cpp
enum ThemeModes { Light, Dark, System }
enum class HeaderButtons { Close = 1, Maximize = 2, Minimize = 4 }
Q_ENUM(ThemeModes)
Q_ENUM(HeaderButtons)
Q_PROPERTY(const QString ThemeName READ GetThemeName WRITE SetThemeName NOTIFY ThemeNameChanged)
Q_PROPERTY(const bool IsDarkTheme READ GetIsDarkTheme NOTIFY IsDarkThemeChanged)
Q_PROPERTY(const int LineHeight READ GetLineHeight WRITE SetLineHeight NOTIFY LineHeightChanged)
Q_INVOKABLE uint getThemeMode() const
Q_INVOKABLE void setThemeMode(const uint)
```

## Sber.Controls

### Accordion

Базовый тип: `Item`. Источник: `controls/Accordion.qml`.

```qml
default property alias data
property int contentPadding
property alias contentSpacing
property bool opened
property bool arrow
property bool hasBackground
property alias title
property alias titleFont
property alias titleColor
property int lineHeight
property int horizontalPadding
property Colorizer colorizer
```

### ApplicationHeader

Базовый тип: `Rectangle`. Источник: `controls/ApplicationHeader.qml`.

```qml
property var appWindow
readonly property int resizeBorderWidth
property int controls
readonly property int radiusValue
property int buttonsFocusPolicy
function maximizeWindow()
function setWindowMaximizeIcon(wVisibility, btn)
function getRadiusValue()
```

### ApplicationWindow

Базовый тип: `T.ApplicationWindow`. Источник: `controls/ApplicationWindow.qml`.

```qml
property int controls
property color backgroundColor
property int backgroundRadius
property int headerButtonsFocusPolicy
function getBackgroundRadius()
```

### ArrowRectangle

Базовый тип: `Item`. Источник: `controls/ArrowRectangle.qml`.

```qml
enum Edge { None = 0, Left = 1, Top = 2, Right = 4, Bottom = 16 }
enum Position { None = 0, Start = 65536, End = 131072 }
property int arrowSize
property int arrowPosition
property alias lineHeight
property alias radius
property bool inverse
property alias shadow
property color color
property BackgroundConfig backgroundConfig
```

### Attach

Базовый тип: `Item`. Источник: `controls/Attach.qml`.

```qml
property alias nameFilters
property alias currentFolder
property bool selectMultiple
property alias fileDialog
property int lineHeight
property alias text
property alias label
property alias labelText
property alias labelColor
property alias labelFont
property alias sublabel
property alias sublabelText
property alias sublabelColor
property alias sublabelFont
property alias caption
property alias captionText
property alias captionColor
property alias captionFont
property alias icon
property alias required
property int requiredPlacement
property alias type
property alias backgroundType
signal fileAdded(file: string)
```

### AutoComplite

Базовый тип: `TextField`. Источник: `controls/AutoComplite.qml`.

```qml
property var model
property string textRole
property string valueRole
property string captionRole
property bool tight
property int currentIndex
property Component loadComponent
```

### Avatar

Базовый тип: `T.Control`. Источник: `controls/Avatar.qml`.

```qml
property int lineHeight
property alias source
property int size
property bool inGroup
property int status
```

### AvatarGroup

Базовый тип: `RowLayout`. Источник: `controls/AvatarGroup.qml`.

```qml
property int lineHeight
function updateItems()
function updateCurrent()
```

### BackgroundConfig

Базовый тип: `QtObject`. Источник: `controls/BackgroundConfig.qml`.

```qml
property int lineHeight
property int type
property int backgroundType
property int status
property color defaultColor
property color hoverColor
property color activeColor
property int horizontalPadding
property int radius
```

### Badge

Базовый тип: `Rectangle`. Источник: `controls/Badge.qml`.

```qml
property alias text
property alias icon
property alias lineHeight
property alias type
property alias backgroundType
property alias status
property bool circle
property int horizontalPadding
property BackgroundConfig backgroundConfig
```

### BusyIndicator

Базовый тип: `T.BusyIndicator`. Источник: `controls/BusyIndicator.qml`.

```qml
property alias loadingPercent
property alias indicatorWidth
property color color
property int lineHeight
```

### Button

Базовый тип: `T.Button`. Источник: `controls/Button.qml`.

```qml
property alias loading
property alias loadingPercent
property alias status
property alias type
property alias backgroundType
property alias textItem
property alias iconItem
property int radius
property int cornersType
property int leftCornersType
property int rightCornersType
property int topLeftRadius
property int topRightRadius
property int bottomLeftRadius
property int bottomRightRadius
property int lineHeight
property BackgroundConfig backgroundConfig
property Colorizer colorizer
property string clickTrackerName
```

### ButtonRowGroup

Базовый тип: `Row`. Источник: `controls/ButtonRowGroup.qml`.

```qml
property int cornersType
```

### CalendarFunctions

Базовый тип: `QtObject`. Источник: `controls/CalendarFunctions.qml`.

```qml
function dateInRange(date, left, right)
function dateIsLess(left, right)
function dateIsEqual(left, right)
function monthInRange(date, left, right)
function monthIsLess(left, right)
function monthIsEqual(left, right)
function yearInRange(date, left, right)
function yearIsLess(left, right)
function yearIsEqual(left, right)
function min(left, right)
function max(left, right)
function isValid(date)
function upperFirst(str)
function getMonthName(month, locale)
function dateToText(date, locale)
function textToDate(text, locale)
function textToTime(timeAsString)
function timeIsEqual(left, right)
function isHourValid(value)
function isMinuteValid(value)
function isSecondsValid(value)
```

### CalendarView

Базовый тип: `Rectangle`. Источник: `controls/CalendarView.qml`.

```qml
enum SelectType { Date, Month, Year }
property int selectType
property alias lineHeight
property int spacing
property var locale
property var dateFrom
property var dateTo
property var dateMin
property var dateMax
property var currentDate
property int visibleYear
property int visibleMonth
property bool inSelect
property int padding
signal dateChanged(var dateFrom, var dateTo)
property bool doubled
property bool range
property bool headerVisible
property BackgroundConfig backgroundConfig
property int cellWidth
property int cellHeight
property Component dateViewLeft
property Component monthViewLeft
property Component yearViewLeft
property Component dateViewRight
property Component monthViewRight
property Component yearViewRight
function loadView()
function setDate(date, finish = false)
function setMonth(year, month)
function setYear(year)
function prevState()
function nextState()
```

### Carousel

Базовый тип: `Item`. Источник: `controls/Carousel.qml`.

```qml
default property alias data
property alias visibleCount
property alias currentIndex
property int lineHeight
property int itemWidth
property int itemHeight
property int spacing
property bool indicatorVisible
property bool buttonsVisible
function decrementCurrentIndex()
function incrementCurrentIndex()
```

### CheckBox

Базовый тип: `T.CheckBox`. Источник: `controls/CheckBox.qml`.

```qml
property string iconChecked
property string iconUnchecked
property string iconPartiallyChecked
property alias captionText
property int lineHeight
property alias fontColor
property alias indicatorSize
```

### CheckDelegate

Базовый тип: `T.CheckDelegate`. Источник: `controls/CheckDelegate.qml`.

```qml
property alias lineHeight
property alias captionText
property bool highlightCurrent
property bool tight
```

### Chip

Базовый тип: `Rectangle`. Источник: `controls/Chip.qml`.

```qml
property alias text
property string idx
property alias icon
property alias closable
property bool circle
property int lineHeight
property int spacing
property alias type
signal closed(string idx)
property int horizontalPadding
property BackgroundConfig backgroundConfig
property Colorizer colorizer
```

### ChipGroup

Базовый тип: `Item`. Источник: `controls/ChipGroup.qml`.

```qml
property list<Chip> chips
property int lineHeight
property bool closable
property bool circle
property int type
property int spacing
property bool oneLine
signal closed(string idx)
function add(text: string, idx = "", icon = "")
function remove(idx: string)
function removeByText(text: string)
function getCurrentChipsText()
function getCurrentChipsIds()
```

### Colorizer

Базовый тип: `Item`. Источник: `controls/Colorizer.qml`.

```qml
property color currentColor
property real borderWidth
property bool hovered
property bool activated
property bool selected
property color defaultColor
property color hoverColor
property color activeColor
```

### ComboBox

Базовый тип: `T.ComboBox`. Источник: `controls/ComboBox.qml`.

```qml
property alias lineHeight
property alias label
property alias labelText
property alias labelColor
property alias labelFont
property alias caption
property alias captionText
property alias captionColor
property alias captionFont
property alias placeholderText
property alias placeholderTextColor
property alias iconLeft
property alias iconRight
property alias required
required property alias requiredPlacement
property bool tight
property bool multiselect
property string captionRole
property string checkStateRole
```

### Counter

Базовый тип: `Badge`. Источник: `controls/Counter.qml`.

```qml
property int count
property int maxCount
```

### CursorDelegate

Базовый тип: `Rectangle`. Источник: `controls/CursorDelegate.qml`.

```qml
// Собственных объявлений нет.
```

### DashedBorder

Базовый тип: `Shape`. Источник: `controls/DashedBorder.qml`.

```qml
property alias lineWidth
property alias color
property int radius
property alias dashPattern
```

### DateEdit

Базовый тип: `TextField`. Источник: `controls/DateEdit.qml`.

```qml
property var date
property alias selectType
property alias currentDate
property alias visibleMonth
property alias visibleYear
property alias dateMin
property alias dateMax
property alias doubled
property var locale
```

### DateRangeEdit

Базовый тип: `Control`. Источник: `controls/DateRangeEdit.qml`.

```qml
property alias lineHeight
property alias label
property alias labelText
property alias labelColor
property alias labelFont
property alias caption
property alias captionText
property alias captionColor
property alias captionFont
property alias placeholderTextFrom
property alias placeholderTextColorFrom
property alias placeholderTextTo
property alias placeholderTextColorTo
property alias iconFromLeft
property alias iconFromRight
property alias iconToLeft
property alias iconToRight
property alias required
required property alias requiredPlacement
property alias status
property int delimiter
property alias textFrom
property alias textTo
property var dateFrom
property var dateTo
property alias selectType
property alias currentDate
property alias visibleMonth
property alias visibleYear
property alias dateMin
property alias dateMax
property alias doubled
property BackgroundConfig backgroundConfig
property Colorizer colorizer
```

### DateView

Базовый тип: `Item`. Источник: `controls/DateView.qml`.

```qml
property QtObject control
property bool incrementMonth
readonly property int month
readonly property int year
```

### DefaultOverlay

Базовый тип: `Rectangle`. Источник: `controls/DefaultOverlay.qml`.

```qml
// Собственных объявлений нет.
```

### DefaultTextMenu

Базовый тип: `Menu`. Источник: `controls/DefaultTextMenu.qml`.

```qml
function showContextMenu(x, y)
```

### Dialog

Базовый тип: `T.Dialog`. Источник: `controls/Dialog.qml`.

```qml
property alias closeButtonVisible
```

### DialogButtonBox

Базовый тип: `T.DialogButtonBox`. Источник: `controls/DialogButtonBox.qml`.

```qml
// Собственных объявлений нет.
```

### Divider

Базовый тип: `Rectangle`. Источник: `controls/Divider.qml`.

```qml
property bool vertical
```

### Drawer

Базовый тип: `T.Drawer`. Источник: `controls/Drawer.qml`.

```qml
property alias header
property alias closeButtonVisible
```

### DropZone

Базовый тип: `Item`. Источник: `controls/DropZone.qml`.

```qml
property alias nameFilters
property alias currentFolder
property bool selectMultiple
property alias fileDialog
property int lineHeight
property alias title
property alias caption
signal fileAdded(file: string)
```

### Editable

Базовый тип: `T.TextField`. Источник: `controls/Editable.qml`.

```qml
property alias lineHeight
property QtObject textConfig
function onMenuToggled(event)
function closeEvent(event)
```

### FocusItem

Базовый тип: `Rectangle`. Источник: `controls/FocusItem.qml`.

```qml
property QtObject target
property int margin
property int delta
```

### Icon

Базовый тип: `Item`. Источник: `controls/Icon.qml`.

```qml
property int lineHeight
property int size
property string name
property string source
property string imageProvider
property color color
```

### IconButton

Базовый тип: `Button`. Источник: `controls/IconButton.qml`.

```qml
// Собственных объявлений нет.
```

### IconLabel

Базовый тип: `Label`. Источник: `controls/IconLabel.qml`.

```qml
property bool iconOnRight
property int spacing
property alias icon
```

### Indicator

Базовый тип: `Rectangle`. Источник: `controls/Indicator.qml`.

```qml
property alias lineHeight
property alias type
property alias status
property BackgroundConfig backgroundConfig
```

### ItemDelegate

Базовый тип: `T.ItemDelegate`. Источник: `controls/ItemDelegate.qml`.

```qml
property alias lineHeight
property alias captionText
property bool highlightCurrent
property bool tight
```

### Label

Базовый тип: `T.Label`. Источник: `controls/Label.qml`.

```qml
property alias type
property alias backgroundType
property alias lineHeight
property alias bold
property alias secondary
property alias smaller
property alias status
property QtObject textConfig
```

### LinkButton

Базовый тип: `Button`. Источник: `controls/LinkButton.qml`.

```qml
// Собственных объявлений нет.
```

### Menu

Базовый тип: `T.Menu`. Источник: `controls/Menu.qml`.

```qml
property alias radius
```

### MenuItem

Базовый тип: `T.MenuItem`. Источник: `controls/MenuItem.qml`.

```qml
property alias lineHeight
property alias captionText
property int checkState
property bool highlight
property bool tight
```

### MenuSeparator

Базовый тип: `T.MenuSeparator`. Источник: `controls/MenuSeparator.qml`.

```qml
property int lineHeight
```

### MonthView

Базовый тип: `GridLayout`. Источник: `controls/MonthView.qml`.

```qml
property QtObject control
property int lineHeight
property bool incrementYear
readonly property int year
```

### Notification

Базовый тип: `Rectangle`. Источник: `controls/Notification.qml`.

```qml
property alias lineHeight
property int margin
property int spacing
property alias title
property alias text
property alias icon
property alias closable
property alias timeout
property BackgroundConfig backgroundConfig
```

### NumberInput

Базовый тип: `TextField`. Источник: `controls/NumberInput.qml`.

```qml
property real from
property real to
property int decimals
property double stepSize
property string prefixText
property string postfixText
property int notation
property var locale
signal valueChanged(real value)
function setValue(v)
function value()
function stepBy(steps)
function increase()
function decrease()
```

### PageIndicator

Базовый тип: `T.PageIndicator`. Источник: `controls/PageIndicator.qml`.

```qml
property int lineHeight
property int indicatorSize
property color color
property color activeColor
property int visibleCount
```

### Pagination

Базовый тип: `T.Control`. Источник: `controls/Pagination.qml`.

```qml
property int lineHeight
property int count
property int visibleCount
property int currentIndex
property int type
property bool goToVisible
function updatePagination()
```

### Popup

Базовый тип: `T.Popup`. Источник: `controls/Popup.qml`.

```qml
property alias arrowSize
property alias arrowPosition
property alias lineHeight
property alias radius
```

### ProgressBar

Базовый тип: `T.ProgressBar`. Источник: `controls/ProgressBar.qml`.

```qml
property bool circular
property bool warning
property bool error
property int indicatorWidth
property color color
property alias lineHeight
```

### RadioButton

Базовый тип: `T.RadioButton`. Источник: `controls/RadioButton.qml`.

```qml
property alias captionText
property int lineHeight
property alias fontColor
property alias indicatorSize
```

### RadioDelegate

Базовый тип: `T.RadioDelegate`. Источник: `controls/RadioDelegate.qml`.

```qml
property alias lineHeight
property alias captionText
property bool highlightCurrent
property bool tight
```

### Range

Базовый тип: `Control`. Источник: `controls/Range.qml`.

```qml
property alias prefixText
property alias postfixText
property alias label
property alias labelText
property alias labelColor
property alias labelFont
property alias caption
property alias captionText
property alias captionColor
property alias captionFont
property alias required
required property alias requiredPlacement
property alias status
property alias placeholderTextFrom
property alias placeholderTextColorFrom
property alias placeholderTextTo
property alias placeholderTextColorTo
property alias iconFromLeft
property alias iconFromRight
property alias iconToLeft
property alias iconToRight
property alias decimals
property alias from
property alias to
property alias inputMethodHints
property alias validator
readonly property alias text
property alias notation
property int delimiter
property int lineHeight
function valueFrom()
function setValueFrom(value)
signal valueFromChanged(real value)
function valueTo()
function setValueTo(value)
signal valueToChanged(real value)
property BackgroundConfig backgroundConfig
property Colorizer colorizer
```

### ScrollBar

Базовый тип: `T.ScrollBar`. Источник: `controls/ScrollBar.qml`.

```qml
property int handleSize
property alias backgroundColor
property alias handleColor
```

### ScrollView

Базовый тип: `T.ScrollView`. Источник: `controls/ScrollView.qml`.

```qml
// Собственных объявлений нет.
```

### ShadowBox

Базовый тип: `MultiEffect`. Источник: `controls/ShadowBox.qml`.

```qml
// Собственных объявлений нет.
```

### Slider

Базовый тип: `T.Slider`. Источник: `controls/Slider.qml`.

```qml
enum View { Default, Accient, Gradient }
signal valueEdited(real value)
signal editingFinished(real value)
property int view
property int labelPacement
property alias label
property alias labelText
property alias labelColor
property alias labelFont
property alias icon
property int rangeValuesPlacement
property alias showRangeValues
property alias rangeValuesFont
property alias rangeValuesColor
property int decimials
property int handleWidth
property int lineHeight
```

### SpinBox

Базовый тип: `Control`. Источник: `controls/SpinBox.qml`.

```qml
enum Type { Default, Segmented, Solid }
property int cornersType
property int type
property int editorType
property alias from
property alias to
property alias decimals
property alias stepSize
property alias prefixText
property alias postfixText
property bool editable
property alias inputMethodHints
property alias validator
readonly property alias text
property alias notation
property bool loading
property alias loadingPercent
readonly property alias up
readonly property alias down
property int lineHeight
function value()
function setValue(val)
signal valueChanged(real value)
```

### Step

Базовый тип: `MouseArea`. Источник: `controls/Step.qml`.

```qml
property alias title
property alias text
property alias icon
property int index
property bool checked
property int lineHeight
property var rightStep
function updateChecked()
```

### Steps

Базовый тип: `RowLayout`. Источник: `controls/Steps.qml`.

```qml
property int lineHeight
property int currentIndex
property bool bullet
property bool clickable
property bool linesVisible
function updateItems()
function next()
function prev()
```

### Switch

Базовый тип: `T.Switch`. Источник: `controls/Switch.qml`.

```qml
property alias captionText
property alias fontColor
property int lineHeight
property int indicatorHeight
property int indicatorWidth
```

### SwitchDelegate

Базовый тип: `T.SwitchDelegate`. Источник: `controls/SwitchDelegate.qml`.

```qml
property alias lineHeight
property alias captionText
property bool highlightCurrent
property bool tight
```

### TabBar

Базовый тип: `T.TabBar`. Источник: `controls/TabBar.qml`.

```qml
property int lineHeight
property bool arrowsVisible
property int arrowSize
property bool stretch
```

### TabButton

Базовый тип: `T.TabButton`. Источник: `controls/TabButton.qml`.

```qml
property alias rightText
property alias rightIcon
property TabBar parentBar
property int lineHeight
```

### TextArea

Базовый тип: `T.TextArea`. Источник: `controls/TextArea.qml`.

```qml
property alias status
property alias type
property alias label
property alias labelText
property alias labelColor
property alias labelFont
property alias caption
property alias captionText
property alias captionColor
property alias captionFont
property alias iconLeft
property alias iconRight
property alias required
property int requiredPlacement
property int textLimit
property int spacing
property int verticalSpacing
property int horizontalSpacing
property alias lineHeight
property alias radius
property alias border
property BackgroundConfig backgroundConfig
property Colorizer colorizer
property FocusItem focusItem
property Menu contextMenu
function onMenuToggled(event)
function closeEvent(event)
```

### TextAreaScroll

Базовый тип: `ScrollView`. Источник: `controls/TextAreaScroll.qml`.

```qml
property alias textArea
```

### TextConfig

Базовый тип: `QtObject`. Источник: `controls/TextConfig.qml`.

```qml
property int status
property int type
property int backgroundType
property int lineHeight
property bool bold
property bool secondary
property bool smaller
property font font
property color defaultColor
property color hoverColor
property color activeColor
```

### TextField

Базовый тип: `T.TextField`. Источник: `controls/TextField.qml`.

```qml
property alias status
property alias type
property alias label
property alias labelText
property alias labelColor
property alias labelFont
property alias caption
property alias captionText
property alias captionColor
property alias captionFont
property alias iconLeft
property alias iconRight
property alias required
property int requiredPlacement
property int textLimit
property int verticalSpacing
property int horizontalSpacing
property alias lineHeight
property alias radius
property alias border
property alias centerBackgroundColor
property BackgroundConfig backgroundConfig
property Colorizer colorizer
property FocusItem focusItem
property Menu contextMenu
function onMenuToggled(event)
function closeEvent(event)
```

### ThemeGradient

Базовый тип: `Gradient`. Источник: `controls/ThemeGradient.qml`.

```qml
property string source
property int angle
property QtObject stopComponent
function updateStops()
```

### TimeDelimiter

Базовый тип: `Label`. Источник: `controls/TimeDelimiter.qml`.

```qml
// Собственных объявлений нет.
```

### TimePart

Базовый тип: `Item`. Источник: `controls/TimePart.qml`.

```qml
property int lineHeight
property int timeData
property int maxValue
property bool isNeedDropDown
readonly property int iconsWidth
readonly property int iconsHeight
signal timePartDataChanged(int value)
function incTimePart()
function decTimePart()
```

### TimePicker

Базовый тип: `Item`. Источник: `controls/TimePicker.qml`.

```qml
property alias isNeedSeconds
property alias isNeedDropDown
property alias time
property string labelText
property var locale
property string iconName
```

### TimePickerView

Базовый тип: `Rectangle`. Источник: `controls/TimePickerView.qml`.

```qml
property var currentTime
property alias lineHeight
property var locale
property bool isNeedSeconds
property bool isNeedDropDown
property BackgroundConfig backgroundConfig
readonly property int padding
readonly property int cellWidth
readonly property int cellHeight
readonly property int delimiterWidth
```

### ToolTip

Базовый тип: `T.ToolTip`. Источник: `controls/ToolTip.qml`.

```qml
property alias arrowSize
property alias arrowPosition
property alias lineHeight
```

### YearView

Базовый тип: `GridLayout`. Источник: `controls/YearView.qml`.

```qml
property QtObject control
property int lineHeight
property bool incrementDecade
readonly property int startYear
readonly property int endYear
```

### C++: widget

Источник: `controls/widget.h`.

```cpp
enum Type { Default, Accient, Secondary, Black, White, TypeLast }
enum Background { Solid, Outline, Clear, BackgroundLast }
enum Status { None, Success, Warning, Error, StatusLast, Online = Success, Afk = Warning, Offline = Error, }
enum Corner { Flat, Square, Circle, CornerLast }
enum Placement { Inner, Outer, Left = Inner, Right = Outer, PlacementLast }
enum Delimiter { NoDelimiter, Arrow, Minus }
Q_ENUM_NS(Type)
Q_ENUM_NS(Background)
Q_ENUM_NS(Status)
Q_ENUM_NS(Corner)
Q_ENUM_NS(Placement)
Q_ENUM_NS(Delimiter)
```

## Sber.Theme

### C++: fonts

Источник: `theme/fonts.h`.

```cpp
Q_INVOKABLE QFont GetFont(const QString &tag) const
```

### C++: theme

Источник: `theme/theme.h`.

```cpp
Q_PROPERTY(FontsClass *Fonts READ GetFonts CONSTANT)
Q_PROPERTY(PaletteClass *Palette READ GetPalette NOTIFY ThemeChanged)
Q_PROPERTY(SizesClass *Sizes READ GetSizes NOTIFY ThemeChanged)
Q_INVOKABLE QStringList getAllImageNames() const
Q_INVOKABLE QVariantMap getAvaliableThemes() const
Q_INVOKABLE QList<QString> getAvaliableThemeNames() const
Q_INVOKABLE void setTheme(const QString &name)
Q_INVOKABLE void reloadTheme()
```

## Sber.Utils

### C++: app_screen

Источник: `utils/app_screen.h`.

```cpp
Q_INVOKABLE void create(QObject *appWindow)
```

### C++: appargs

Источник: `utils/appargs.h`.

```cpp
Q_INVOKABLE QStringList getKeys() const
Q_INVOKABLE bool hasKey(const QString &key) const
Q_INVOKABLE QVariantList args(const QString &key) const
Q_INVOKABLE QVariant arg(const QString &key) const
```

### C++: clipboard

Источник: `utils/clipboard.h`.

```cpp
Q_PROPERTY(QString text READ GetText WRITE SetText NOTIFY TextChanged)
```

### C++: file

Источник: `utils/file.h`.

```cpp
Q_INVOKABLE bool appendData(const QString &path, const QByteArray &data)
Q_INVOKABLE bool copyFile(const QString &source, const QString &dest)
Q_INVOKABLE bool exists(const QString &path)
Q_INVOKABLE bool isDir(const QString &path)
Q_INVOKABLE bool isFile(const QString &path)
Q_INVOKABLE QStringList listFiles(const QString &path, const QStringList &formats = QStringList())
Q_INVOKABLE QStringList listDirs(const QString &path)
Q_INVOKABLE QByteArray readFile(const QString &path)
Q_INVOKABLE bool removeFile(const QString &path)
Q_INVOKABLE bool removeDir(const QString &path)
Q_INVOKABLE bool writeFile(const QString &path, const QByteArray &data = QByteArray())
```

### C++: process

Источник: `utils/process.h`.

```cpp
Q_PROPERTY(QVariantList arguments READ arguments WRITE setArguments)
Q_PROPERTY(int exitCode READ exitCode NOTIFY finished)
Q_PROPERTY(int processId READ processId NOTIFY started)
Q_PROPERTY(QString program READ program WRITE setProgram)
Q_PROPERTY(QString workingDirectory READ workingDirectory WRITE setWorkingDirectory)
Q_INVOKABLE QVariantList arguments() const
Q_INVOKABLE int exitCode() const
Q_INVOKABLE void kill()
Q_INVOKABLE int processId() const
Q_INVOKABLE QString program() const
Q_INVOKABLE QByteArray readAllStandardError()
Q_INVOKABLE QByteArray readAllStandardOutput()
Q_INVOKABLE void setArguments(const QVariantList &args)
Q_INVOKABLE void setProgram(const QString &program)
Q_INVOKABLE void setWorkingDirectory(const QString &dir)
Q_INVOKABLE void start(const QString &program, const QVariantList &args)
Q_INVOKABLE void start()
Q_INVOKABLE void startDetached(const QString &program, const QVariantList &args)
Q_INVOKABLE void startDetached()
Q_INVOKABLE void terminate()
Q_INVOKABLE void waitForFinished(const int msecs = 30000)
Q_INVOKABLE void waitForStarted(const int msecs = 30000)
Q_INVOKABLE QString workingDirectory() const
Q_INVOKABLE void write(const QString &command)
Q_INVOKABLE void closeWriteChannel()
```

### C++: shell

Источник: `utils/shell.h`.

```cpp
Q_INVOKABLE QString run(const QString &command, const QStringList &args = QStringList()) const
```

### C++: types_provider

Источник: `utils/types_provider.h`.

```cpp
enum class MetaType { Void = QMetaType::Void, Bool = QMetaType::Bool, Int = QMetaType::Int, UInt = QMetaType::UInt, Double = QMetaType::Double, QChar = QMetaType::QChar, QString = QMetaType::QString, QByteArray = QMetaType::QByteArray, Nullptr = QMetaType::Nullptr, VoidStar = QMetaType::VoidStar, Long = QMetaType::Long, LongLong = QMetaType::LongLong, Short = QMetaType::Short, Char = QMetaType::Char, Char16 = QMetaType::Char16, Char32 = QMetaType::Char32, ULong = QMetaType::ULong, ULongLong = QMetaType::ULongLong, UShort = QMetaType::UShort, SChar = QMetaType::SChar, UChar = QMetaType::UChar, Float = QMetaType::Float, Float16 = QMetaType::Float16, QObjectStar = QMetaType::QObjectStar, QCursor = QMetaType::QCursor, QDate = QMetaType::QDate, QSize = QMetaType::QSize, QTime = QMetaType::QTime, QVariantList = QMetaType::QVariantList, QPolygon = QMetaType::QPolygon, QPolygonF = QMetaType::QPolygonF, QColor = QMetaType::QColor, QColorSpace = QMetaType::QColorSpace, QSizeF = QMetaType::QSizeF, QRectF = QMetaType::QRectF, QLine = QMetaType::QLine, QTextLength = QMetaType::QTextLength, QStringList = QMetaType::QStringList, QVariantMap = QMetaType::QVariantMap, QVariantHash = QMetaType::QVariantHash, QVariantPair = QMetaType::QVariantPair, QIcon = QMetaType::QIcon, QPen = QMetaType::QPen, QLineF = QMetaType::QLineF, QTextFormat = QMetaType::QTextFormat, QRect = QMetaType::QRect, QPoint = QMetaType::QPoint, QUrl = QMetaType::QUrl, QRegularExpression = QMetaType::QRegularExpression, QDateTime = QMetaType::QDateTime, QPointF = QMetaType::QPointF, QPalette = QMetaType::QPalette, QFont = QMetaType::QFont, QBrush = QMetaType::QBrush, QRegion = QMetaType::QRegion, QBitArray = QMetaType::QBitArray, QImage = QMetaType::QImage, QKeySequence = QMetaType::QKeySequence, QSizePolicy = QMetaType::QSizePolicy, QPixmap = QMetaType::QPixmap, QLocale = QMetaType::QLocale, QBitmap = QMetaType::QBitmap, QTransform = QMetaType::QTransform, QMatrix4x4 = QMetaType::QMatrix4x4, QVector2D = QMetaType::QVector2D, QVector3D = QMetaType::QVector3D, QVector4D = QMetaType::QVector4D, QQuaternion = QMetaType::QQuaternion, QEasingCurve = QMetaType::QEasingCurve, QJsonValue = QMetaType::QJsonValue, QJsonObject = QMetaType::QJsonObject, QJsonArray = QMetaType::QJsonArray, QJsonDocument = QMetaType::QJsonDocument, QCborValue = QMetaType::QCborValue, QCborArray = QMetaType::QCborArray, QCborMap = QMetaType::QCborMap, QCborSimpleType = QMetaType::QCborSimpleType, QModelIndex = QMetaType::QModelIndex, QPersistentModelIndex = QMetaType::QPersistentModelIndex, QUuid = QMetaType::QUuid, QByteArrayList = QMetaType::QByteArrayList, QVariant = QMetaType::QVariant, User = QMetaType::User, UnknownType = QMetaType::UnknownType }
Q_ENUM(MetaType)
```

## Sber.Widgets

### ThemeSettings

Базовый тип: `GridLayout`. Источник: `widgets/ThemeSettings.qml`.

```qml
property bool reloadVisible
property bool modeVisible
property bool heightVisible
```
