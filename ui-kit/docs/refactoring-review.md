# Первичный разбор рефакторинга UI Kit

Дата: 2026-10-22. Связанная задача: [UIKIT-001](../../docs/tasks/UIKIT-001.md).
Это выборочное статическое ревью 5 QML-файлов (690 строк) и 8 C++-файлов
(692 строки), а также анализ CMake и существующих тестов. Остальные компоненты,
сгенерированное дерево токенов и графическое поведение полностью не проверены.
Исходники не изменялись. Форматные замечания не являются приоритетом перед дефектами поведения.

## Архитектурные предложения

1. Сначала исправить дефекты поведения ниже и закрепить контракт тестами TEST-001.
2. Сборка: target-based зависимости вместо `libSberCorePlugin.so` и link_directories;
   единая версия (корень 1.7.2, Controls жёстко 1.4.0), требования Qt и опции;
   отдельный публичный C++ API от заголовков реализации. Не обещать переносимость
   на другие платформы без отдельной проверки.
3. Ресурсы: UI Kit устанавливает их в share/SberComponents. Реализован поиск через
   SBER_COMPONENTS_DATA_DIR, исходный каталог и стандартные data paths. Проверить
   запуск установленного пакета без исходников в отдельном временном prefix.
4. Состояния: уменьшить повторение ветвлений в BackgroundConfig/TextConfig;
   единый внутренний механизм цветов, фокуса и disabled, сохранив семантические
   токены. Colorizer выбирает состояние selected, которого нет в states:
   отдельно определить требуемую семантику перед изменением.
5. API: добавлять правильно написанные имена рядом с decimials/labelPacement/
   Accient/AutoComplite/getAvaliable*, с совместимыми alias/обёртками и примерами
   миграции. Не удалять существующие имена одним массовым переименованием.
6. Границы: Core — настройки и общие сервисы приложения; Theme — токены/ресурсы;
   Controls — компоненты; Widgets — составные элементы; Utils — утилиты с явным
   контрактом ошибок. Системную логику оболочки сюда не переносить. Разделять
   модули дальше только при выявленной зависимости, а не ради количества слоёв.
7. Галерея: сделать матрицу состояний и размеров, обе темы, клавиатуру, длинный
   текст и локализацию воспроизводимыми примерами для регрессий.

## Проверки

- `python3 ui-kit/tools/api_contract.py --check`: прошло.
- `timeout 40s ctest --test-dir ui-kit/_build --output-on-failure`: 2/2 прошло
  (test_plugin_load, test_slider_input), существующая сборка, без пересборки.
- Python-линтеры обоих навыков и системный qmllint выполнены; результаты ниже.
- Динамическое воспроизведение найденных дефектов, сборка с нуля, установка,
  визуальные проверки и Wayland в этом разборе не выполнялись.

## QML Code Review Report

**Scope**: files: `controls/TextField.qml`, `controls/ComboBox.qml`, `controls/Colorizer.qml`, `controls/Button.qml`, `controls/BackgroundConfig.qml`

**Files reviewed**: 5

**Issues found**: 174 (172 from lint, 2 from deep analysis)

**Agents**: 0 (inline)

**qmllint**: ran (/usr/lib/qt6/bin/qmllint)

### Lint findings

Замечания линтеров — кандидаты на разбор, их число не равно числу подтверждённых дефектов.

| Rule | Count | Locations | Mitigation |
|---|---|---|---|
| BND-1 | 1 | `ComboBox.qml:161` | property var -- use a typed property (int, string, etc.) for qmlsc compilation and type safety |
| BND-2 | 1 | `TextField.qml:176` | Imperative '=' on 'control.status' destroys its binding -- use Qt.binding() to restore, or verify this is intentional |
| IMP-3 | 3 | `Button.qml:2  ComboBox.qml:2  TextField.qml:3` | import QtQuick.Controls without style qualifier -- use Controls.Basic (or specific style) when customizing contentItem/background/indicator/handle |
| JS-1 | 3 | `ComboBox.qml:87,88,99` | Use let/const instead of var -- var has function scope and hoisting bugs |
| JS-2 | 70 | `BackgroundConfig.qml:15,16,17,18,19,20,21,22,24,25,26,27,28,29,30,31,36,37,38,39,40,41,42,43,45,46,47,48,49,50,51,52,57,58,59,60,61,62,63,64,66,67,68,69,70,71,72,73  Button.qml:72,98,99,100,102,105,106,110,111,115,116,120,121  ComboBox.qml:89,156,181,184  TextField.qml:88,121,136,154,193` | Loose equality (==/!=) -- use strict equality (===/!==) |
| ORD-1 | 7 | `Button.qml:57,96  ComboBox.qml:44,129,135,150  TextField.qml:97` | id appears after property assignment |
| ORD-1 | 4 | `Button.qml:41,46  TextField.qml:58,62` | id appears after property declaration |
| ORD-1 | 1 | `ComboBox.qml:144` | property assignment appears after attached property |
| ORD-1 | 3 | `Button.qml:54  ComboBox.qml:33  TextField.qml:20` | property declaration appears after property assignment |
| PRF-1 | 1 | `Button.qml:98` | Rectangle with 'transparent' color -- use Item instead, or toggle visible on the Rectangle (creates geometry node even when transparent) |
| PRF-3 | 2 | `ComboBox.qml:75,139` | clip: true disables scene graph batching -- verify this is needed (acceptable on ListView) |
| QL:Quick.property-changes-parsed | 1 | `Colorizer.qml:31` | Property "borderWidth" is custom-parsed in PropertyChanges. You should phrase this binding as "colorizer.borderWidth: 1.5" |
| QL:Quick.property-changes-parsed | 2 | `Colorizer.qml:39,47` | Property "borderWidth" is custom-parsed in PropertyChanges. You should phrase this binding as "colorizer.borderWidth: 2" |
| QL:Quick.property-changes-parsed | 1 | `Colorizer.qml:46` | Property "currentColor" is custom-parsed in PropertyChanges. You should phrase this binding as "colorizer.currentColor: activeColor" |
| QL:Quick.property-changes-parsed | 1 | `Colorizer.qml:30` | Property "currentColor" is custom-parsed in PropertyChanges. You should phrase this binding as "colorizer.currentColor: defaultColor" |
| QL:Quick.property-changes-parsed | 1 | `Colorizer.qml:38` | Property "currentColor" is custom-parsed in PropertyChanges. You should phrase this binding as "colorizer.currentColor: hoverColor" |
| QL:Quick.property-changes-parsed | 3 | `Colorizer.qml:29,37,45` | You should remove any bindings on the "target" property and avoid custom-parsed bindings in PropertyChanges. |
| QL:missing-property | 1 | `Button.qml:90` | Member "activeColor" not found on type "QObject" |
| QL:missing-property | 2 | `Button.qml:86  TextField.qml:18` | Member "defaultColor" not found on type "QObject" |
| QL:missing-property | 1 | `TextField.qml:17` | Member "font" not found on type "QObject" |
| QL:missing-property | 1 | `Button.qml:88` | Member "hoverColor" not found on type "QObject" |
| QL:missing-property | 1 | `ComboBox.qml:132` | Member "radius" not found on type "QQuickItem" |
| QL:missing-property | 1 | `TextField.qml:194` | Member "showContextMenu" not found on type "Menu" |
| QL:signal-handler-parameters | 1 | `TextField.qml:174` | Signal handler for "onTextChanged" has more formal parameters than the signal it handles. |
| QL:unqualified | 35 | `ComboBox.qml:46,69,88,89,91,93,105,106,152,153,154,156,158,159,160,161,162,163,164,166,167,168,169,171,172,173,174,175,179,180,181,182,184,185,187` | Unqualified access |
| QL:unused-imports | 6 | `Button.qml:8  Colorizer.qml:3  ComboBox.qml:3  TextField.qml:2,4,8` | Unused import |
| STA-1 | 3 | `Colorizer.qml:29,37,45` | PropertyChanges uses target: -- in Qt 6 use id.property: value syntax |
| STY-1 | 5 | `BackgroundConfig.qml:8  Button.qml:11  Colorizer.qml:7  ComboBox.qml:10  TextField.qml:12` | Top-level component should have id: root (enables qualified lookup, future-proofs for QML 3) |
| STY-3 | 8 | `TextField.qml:72,78,89,110,118,128,155,164` | 3 anchors.* properties using dot notation -- use group notation: anchors { ... } |
| STY-3 | 1 | `TextField.qml:98` | 4 anchors.* properties using dot notation -- use group notation: anchors { ... } |
| STY-3 | 1 | `BackgroundConfig.qml:23` | 6 Theme.* properties using dot notation -- use group notation: Theme { ... } |

### Deep analysis findings

#### [D-001] Escape подтверждает ввод
- **File**: `controls/TextField.qml:209`
- **Category**: Logic & Wiring
- **Confidence**: 100/100
- **Finding**: Escape вызывает тот же accepted(), что Return/Enter; потребитель может сохранить значение при попытке отмены.
- **Trace**: Keys.onEscapePressed → closeEvent → control.accepted(). Поведение прямо отражено в API.md.
- **Mitigation**: Развести подтверждение и отмену; сначала определить совместимость и тесты, обновить контракт и потребителей.

#### [D-002] Многовыбор ComboBox смешивает контракты моделей
- **File**: `controls/ComboBox.qml:88`
- **Category**: Logic & Wiring
- **Confidence**: 95/100
- **Finding**: update() использует model.count и data(index(), числовые роли 0/2), а удаление чипа — rowCount() и setProperty(); заявленные captionRole/checkStateRole не образуют единого контракта. Обычный ListModel не предоставляет этот смешанный интерфейс.
- **Trace**: chipsGroup.update():88–106 и delegate:158–185; дополнительно проверки Array.isArray(control.modelData) обращаются к необъявленному свойству control, а не к модели делегата.
- **Mitigation**: Выбрать поддерживаемые типы моделей и один адаптер доступа по ролям; выбор хранить отдельно либо изменять модель через документированный контракт. Проверить ListModel, JS-массив и C++-модель отдельно.

### Investigation targets (human verification needed)

Нет дополнительных целей расследования в выбранном объёме.

### Summary

| Category | Lint | Deep | Investigate | Total |
|---|---|---|---|---|
| Static checks / QML | 172 | 2 | 0 | 174 |
| **Total** | **172** | **2** | **0** | **174** |

Findings below confidence 60 are suppressed.

## Qt Code Review Report

**Scope**: files: `core/settings.cpp`, `core/settings.h`, `theme/theme.cpp`, `theme/theme.h`, `utils/process.cpp`, `utils/process.h`, `utils/file.cpp`, `utils/file.h`

**Files reviewed**: 8

**Issues found**: 14 (11 from lint, 3 from deep analysis)

**Agents**: 0 (inline)

**Framework mode**: off

### Lint findings

Замечания линтеров — кандидаты на разбор, их число не равно числу подтверждённых дефектов.

| Rule | Count | Locations | Mitigation |
|---|---|---|---|
| API-5 | 2 | `theme/theme.h:36,37` | get-prefix on getter — Qt reserves get for user interaction/decomposition |
| DEP-1 | 2 | `theme/theme.h:57,58` | QScopedPointer — use std::unique_ptr (const unique_ptr for scoped) |
| ENM-2 | 1 | `core/settings.h:13` | Unscoped enum without explicit underlying type — add type to prevent BiC |
| PAT-7 | 3 | `theme/theme.cpp:53  theme/theme.h:26,56` | QMap usage — verify copying is needed; std::map saves ~1.7KiB text |
| PAT-9 | 3 | `theme/theme.cpp:89,90  theme/theme.h:38` | QList<QString> — use QStringList (idiomatic Qt, convenience methods) |

### Deep analysis findings

#### [D-001] Запись файла сообщает успех без проверки записи
- **File**: `utils/file.cpp:76`
- **Category**: Error Handling & Validation
- **Confidence**: 100/100
- **Finding**: writeFile() и appendData() возвращают true после успешного open(), игнорируя результат write(); ошибка записи не доходит до потребителя.
- **Trace**: appendData():15–19, writeFile():73–79.
- **Mitigation**: Проверять количество записанных байтов и завершение записи; документировать диагностику ошибок. Для замены целого файла рассмотреть атомарное сохранение.

#### [D-002] Перезагрузка темы не обрабатывает отсутствие или повреждение ресурсов
- **File**: `theme/theme.cpp:67`
- **Category**: Error Handling & Validation
- **Confidence**: 100/100
- **Finding**: LoadThemes() оставляет пустую карту при отсутствии файла; последующий reloadTheme()/setTheme() вызывает firstKey() без проверки. SetThemeByFilename() заменяет палитру даже при пустом результате UploadTheme().
- **Trace**: LoadThemes → AvaliableThemes; reloadTheme → ReloadTheme → SetTheme; SetThemeByFilename → UploadTheme, который возвращает пустой объект при ошибке.
- **Mitigation**: Валидировать набор ресурсов и секции до применения, сохранять предыдущую рабочую палитру, предоставлять fallback и диагностируемую ошибку.

#### [D-003] Process скрывает ошибки запуска и результат ожидания
- **File**: `utils/process.cpp:90`
- **Category**: Error Handling & Validation
- **Confidence**: 100/100
- **Finding**: startDetached(), waitForStarted() и waitForFinished() отбрасывают результат; у обёртки нет передачи errorOccurred/errorString. Потребитель QML не может надёжно отличить ошибку запуска и таймаут через этот API.
- **Trace**: process.cpp:22–27,90–103 и публичные методы/сигналы process.h.
- **Mitigation**: Добавить документированные ошибки и результаты операций, предпочитать асинхронный путь для UI; сохранить совместимость старых вызовов.

### Investigation targets (human verification needed)

Нет дополнительных целей расследования в выбранном объёме.

### Summary

| Category | Lint | Deep | Investigate | Total |
|---|---|---|---|---|
| Static checks | 11 | 0 | 0 | 11 |
| Error Handling & Validation | 0 | 3 | 0 | 3 |
| **Total** | **11** | **3** | **0** | **14** |

Findings below confidence 60 are suppressed.
