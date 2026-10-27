# ATP-001: раскрытие всего острова +N

27.10.2026. Подтверждение пользователя после объединения апплетов `5955f49`;
[ADR-0012](../../../../adr/0012-unified-plasma-applications.md).
FT_SMART_PANEL_APPLICATIONS_11–15, UI_SMART_PANEL_APPLICATIONS_9–12;
сценарии `03-01`, `03-14`–`03-18`, `03-22`, `09-02`, `09-24`.

## Реализация

Native fullRepresentation перекрывает исходный остров, как в исследованном приёме
Dynamic Island. `ApplicationsExpansion.qml` анимирует одну поверхность из ряда
620×72 в сетку 504×168; Launchpad занимает первую ячейку. Нижний край остаётся
в y=1072, левый — в x=96. Компактный ряд отключён и прозрачен только на время
подмены. Containment исключает его из маски панели: остаются три других острова,
после закрытия снова четыре. Раскладка и высота панели при этом не меняются.

Окно имеет запас под обе формы; его прозрачная часть исключена из native маски.
Python создаёт SVG с 65 префиксами один раз на геометрию и сохраняет в XDG cache.
На кадрах меняется только префикс, без записи файлов и запуска процессов.
Дочерние меню/preview добавляются к маске. Длительности — Kirigami.Units,
18 ms передача между компактной поверхностью и её копией. Esc/явное закрытие
обращают анимацию; native деактивация или исчезновение переполнения могут
закрыть окно сразу. Это визуальная подмена отдельным окном, без патча PanelView.

Для возврата фокуса включается штатный AcceptingInputStatus панели. Затем
`ApplicationsStrip` восстанавливает +N внутри собственного FocusScope после
штатного перенаправления фокуса CompactApplet. Переключение в следующий popup
освобождает режим ввода. Собственная рамка кнопок используется вместо дополнительной
штатной подсветки панели. Проверены активная PanelView и activeFocus самой +N,
не только сохранённый индекс задачи. Штатный механизм ввода сверялся с
[PanelView 6.7.4](https://github.com/KDE/plasma-workspace/blob/v6.7.4/shell/panelview.cpp).

## Снимки до и после

Qt 6.11.2 / Plasma 6.7.4, private KWin/Wayland 1920×1080, DPR 1,
Breeze Light/Dark. До — `5955f49`, после — текущая доработка; визуальная цель —
Smart Panel в репозитории (базовый мок `6e48fb5`). Для сравнения закреплён
одинаковый набор 30 установленных desktop entries через `--launchers-file`.

| Состояние | Светлая тема | Тёмная тема |
| --- | --- | --- |
| До, ряд | [снимок](before/light/normal.png) | [снимок](before/dark/normal.png) |
| До, отдельная сетка | [снимок](before/light/overflow-open.png) | [снимок](before/dark/overflow-open.png) |
| После, ряд | [снимок](after/light/normal.png) | [снимок](after/dark/normal.png) |
| После, общий остров | [снимок](after/light/overflow-open.png) | [снимок](after/dark/overflow-open.png) |
| Дочернее меню | [снимок](after/light/child-menu.png) | [снимок](after/dark/child-menu.png) |
| Закрытие и фокус | [снимок](after/light/collapse.png) | [снимок](after/dark/collapse.png) |

Ряд, раскрытие, меню, закрытие и промежуточные кадры просмотрены.
Это QML grabToImage, а не композиция экрана KWin; видимый blur за поверхностью
и порядок отрисовки поверх fullscreen такими снимками не подтверждаются.
Размер прозрачного host — 620×168, нарисованной раскрытой поверхности — 504×168.

## Native измерения

В отдельном прогоне открыты настоящее развёрнутое окно и fullscreen-клиент.
KWin script независимо записывает frameGeometry. В обоих темах все 14 состояний
сохраняют PanelView `(0,992) 1920×88`, доступную область `1920×992`, развёрнутый
клиент `1920×992`, fullscreen `1920×1080`. Native прогоны содержат ещё две задачи
клиентов; число в +N поэтому +20 вместо +18 в сравнительных снимках.

В светлой теме записано 18 промежуточных отсчётов, в тёмной — 19. Каждый сохраняет
нижний край y=1072 и x=96; компактный ряд в этот момент прозрачен. После закрытия
он видим, +N имеет activeFocus и PanelView активна. Native records хранят последние
геометрии объектов, включая закрытые окна; это не перечень живых окон.

- [Светлая: геометрия](native/light/geometry.json), [движение](native/light/motion.json), [KWin](native/light/native.json).
- [Тёмная: геометрия](native/dark/geometry.json), [движение](native/dark/motion.json), [KWin](native/dark/native.json).
- Промежуточные PNG сохранены рядом с motion.json в каждой теме.

## Проверки и воспроизведение

```sh
QT_QPA_PLATFORM=offscreen QT_STYLE_OVERRIDE=Breeze QT_QUICK_CONTROLS_STYLE=Basic \
  timeout 25s /usr/lib/qt6/bin/qmltestrunner -input plasma-theme/tests/tst_applicationsreveal.qml
# Те же env/timeout: tst_applications.qml, tst_taskoverflow.qml; геометрия — tst_panellayout.qml.
python3 plasma-theme/tests/capture-taskoverflow.py --source plasma-theme \
  --output /tmp/sber-reveal-check --theme dark --applications --native-geometry
# Сравнительные снимки: без --native-geometry, с фиксированным набором
# --launchers-file docs/tasks/evidence/ATP-001/unified-applications/after/light/startup.json
c++ -std=c++17 -fPIC plasma-theme/tests/check-reveal-mask.cpp \
  -o /tmp/sber-check-reveal-mask -I/usr/include/KF6/KSvg $(pkg-config --cflags --libs Qt6Gui) -lKF6Svg
# Генератор принимает JSON sizes=[hostW,hostH,compactW,compactH,gridW,gridH], child=[x,y,w,h] или [].
XDG_CACHE_HOME=/tmp/sber-reveal-mask-check python3 \
  plasma-theme/plasmoids/sberos.smarttasks/contents/code/reveal-mask.py \
  '{"sizes":[620,168,620,72,504,168],"child":[]}'
# Путь из JSON-вывода передать в QT_QPA_PLATFORM=offscreen timeout 10s /tmp/sber-check-reveal-mask <SVG>.
# Для child=[256,0,248,400] / hostH=400: добавить последний аргумент child.
python3 plasma-theme/tools/sync-smart-panel.py --check
node plasma-theme/tests/test-panel-screens.js
qmllint plasma-theme/plasmoids/sberos.smarttasks/contents/ui/*.qml \
  plasma-theme/plasmoids/sberos.panel/contents/ui/main.qml \
  plasma-theme/shells/sberos.desktop/contents/views/Panel.qml
bash plasma-theme/install.sh --dry-run
git diff --check
```

Прошли 4 QML-проверки движения/обратного хода, 7 объединённого компонента,
14 задач/сетки; 6 существующих проверок компоновки прошли на этапе объединения.
KSvg QRegion: все 65 кадров проверены на размеры, нижний край, скругления и
прозрачный запас; отдельно проверено объединение с дочерним меню без заливки
промежутков. Runtime — 14 состояний в каждой теме с native клиентами;
дополнительно сравнительные прогоны с фиксированным составом задач.
qmllint — код 0 с предупреждениями динамических API; sync-check 175 ресурсов,
Node, Python syntax, dry-run и diff-check прошли. CMake-сборки KPackage нет.

Qt Test/KSvg/KWin выполнялись с необходимым доступом вне sandbox. Маска внутри
sandbox завершилась таймаутом и не считается проверкой. В промежуточных прогонах
выявлены и исправлены обработка Backtab, возврат фокуса в CompactApplet и учёт
двух реальных клиентских задач. Неуспешные прогоны не используются как приёмка.
Тестовые группы процессов завершены. Основная пользовательская панель и сервис
не обновлялись и не перезапускались.

Физический Esc/внешний клик, реальные действия и кадры preview окон, другие
масштабы/мониторы, native blur и композиция над fullscreen требуют живой приёмки.
Геометрия общей поверхности и наличие Launchpad в сетке соответствуют композиции
мока; полная визуальная приёмка ATP-001 остаётся открытой. Sirca/Quickshell не менялись.
Коммит: `git log --grep='раскрывай единый остров приложений'`.
