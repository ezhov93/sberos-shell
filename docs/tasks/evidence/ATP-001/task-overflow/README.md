# ATP-001: переполнение задач Plasma

27.10.2026, Qt 6.11.2 / Plasma 6.7.4, виртуальный KWin/Wayland,
1920×1080, DPR 1, Breeze Light. Сценарии `02-04`–`02-08`, `03-14`–`03-18`,
`03-22`, `09-24`; FT_APPLICATIONS_11–15, UI_APPLICATIONS_9–12.
Визуальный ориентир — HTML Smart Panel (`6e48fb5`, актуальные стили).

## Снимки

- До: [обычный ряд](before/normal.png), [заполненный ряд](before/compact.png),
  [переполнение с обрезкой](before/overflow.png).
- После: [обычный ряд](after/normal.png), [уменьшение до 32 px](after/compact.png),
  [12 видимых задач и +18](after/overflow.png), [сетка всех 30 задач](after/overflow-open.png).
- [Дочернее меню](after/child-menu.png), [первое закрытие возвращает сетку](after/child-dismiss.png),
  [второе закрытие сворачивает](after/collapse.png), [сокращение списка убирает переполнение](after/model-shrink.png).

Все кадры просмотрены. Снимки — `grabToImage` QML-содержимого, прозрачность
показана на чёрном фоне; они не подтверждают видимое размытие композитором.
Использованы реальные desktop entries из /usr/share/applications,
первые два закрепления — Dolphin и Konsole. Кнопка-счётчик сама не является задачей.
Контекстное меню вызвано инструментированием с индексом 15; его тестовая подпись
не проверяет название или реальные действия приложения.

## Проверки

```sh
QT_QPA_PLATFORM=offscreen QT_STYLE_OVERRIDE=Breeze QT_QUICK_CONTROLS_STYLE=Basic \
  timeout 20s /usr/lib/qt6/bin/qmltestrunner -input plasma-theme/tests/tst_taskoverflow.qml
QT_QPA_PLATFORM=offscreen timeout 15s /usr/lib/qt6/bin/qmltestrunner \
  -input plasma-theme/tests/tst_panellayout.qml
python3 plasma-theme/tests/capture-taskoverflow.py --source plasma-theme --output /tmp/sber-taskoverflow
python3 plasma-theme/tools/sync-smart-panel.py --check
bash plasma-theme/install.sh --dry-run
```

- 13 QML-проверок прошли: точные пороги вместимости, резерв счётчика/разделителя,
  обновление состава, Return/Space, стрелки, Shift+F10, Esc и прокрутка к последней строке.
- 6 проверок существующей геометрии панели прошли.
- 8 состояний KPackage прошли проверки из capture-taskoverflow.py;
  [геометрия после](after/geometry.json). Переходы popup вызваны функциями QML;
  это не проверка физического ввода и native-фокуса.
- qmllint изменённых компонентов — код 0 с предупреждениями динамических API
  и существующих неквалифицированных обращений AppButton. Sync-check — 177 ресурсов.
- Установщик в dry-run прошёл. CMake-сборки у этой QML/KPackage-копии нет.
- Тестовые группы процессов 117432 (до), 122704 (после) завершены;
  промежуточные 118191/120133 также завершены. Пользовательская установка не менялась.

Обычный sandbox блокирует инициализацию KDE-модулей в qmltestrunner; итоговые
тесты и виртуальный KWin выполнены с необходимым доступом вне sandbox.

## Ограничения и следующий шаг

Сетка использует отдельное окно над задачами. В HTML-моке весь остров
приложений расширяется вверх вместе с Launchpad; это расхождение остаётся открытым.
В исходной панели первые две иконки остаются 32 px, остальные переходят 40 → 32 px;
размеры ячеек — 48 → 40 px при целевой высоте острова 72 px.

Нужна ручная проверка запуска/активации/сворачивания реальных окон, preview,
native внешнего клика и возврата фокуса в пользовательском Wayland-сеансе.
При открытом дочернем элементе деактивация закрывает сначала его и запрашивает
активацию окна сетки; это требует отдельной проверки политики фокуса KWin.
Тёмная тема, масштабирование и другие мониторы не проверялись по границам ATP-001.
Sirca/Quickshell этой доработкой не менялись и повторно не проверялись.
