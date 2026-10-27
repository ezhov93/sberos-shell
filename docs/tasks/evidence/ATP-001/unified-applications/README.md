# ATP-001: один апплет Launchpad и задач

27.10.2026. Решение пользователя и [ADR-0012](../../../../adr/0012-unified-plasma-applications.md).
FT_SMART_PANEL_LAUNCHPAD_1–6, FT_SMART_PANEL_APPLICATIONS_7/11–15,
UI_SMART_PANEL_APPLICATIONS_9–12; сценарии `03-01`, `03-14`–`03-18`, `03-22`,
`09-02`, `09-24`.

## Результат

Один PlasmoidItem/KPackage с ID `io.gitgud.wackyideas.smarttasks` владеет
Launchpad, задачами и общим фоном. Отдельный Drawer удалён из рабочей копии;
сохранены лицензия GPL-2.0-or-later и заголовки авторства перенесённых компонентов.
Шаблон убирает прежний applet Drawer из существующей панели, сохраняя Task Manager.
Установщик обновляет объединённый пакет, затем сохраняет и удаляет прежний
пользовательский пакет Drawer. Установка основной панели здесь не выполнялась.

## Снимки и измерения

Qt 6.11.2 / Plasma 6.7.4, отдельный KWin/Wayland 1920×1080, DPR 1,
Breeze Light и Breeze Dark. До — исходники `c3ecdd4`; после — текущая доработка.
Визуальная цель — Smart Panel из текущего репозитория, базовый мок `6e48fb5`.

| Состояние | Светлая тема | Тёмная тема |
| --- | --- | --- |
| До, ряд | [снимок](before/light/normal.png) | [снимок](before/dark/normal.png) |
| После, ряд | [снимок](after/light/normal.png) | [снимок](after/dark/normal.png) |
| До, +N | [снимок](before/light/overflow.png) | [снимок](before/dark/overflow.png) |
| После, +N | [снимок](after/light/overflow.png) | [снимок](after/dark/overflow.png) |
| Сетка | [снимок](after/light/overflow-open.png) | [снимок](after/dark/overflow-open.png) |
| Launchpad | [снимок](after/light/launchpad.png) | [снимок](after/dark/launchpad.png) |
| Поиск | [снимок](after/light/search.png) | [снимок](after/dark/search.png) |

Ряд до/после, сетка и Launchpad/поиск просмотрены. Снимки — QML grabToImage,
не композиция KWin. Геометрия панели 1920×88 в (0,992), Оська центрирована;
суммарная ширина острова и вместимость +N в обеих темах сохранены. Кнопка
занимает 48 px плюс промежуток 8 px внутри апплета; значок остался 32 px.
30 закреплений дают 12 видимых задач и +18. Launchpad 1920×1080 показывает
27 реальных приложений, запрос `konsole` оставляет одну карточку.

Светлая тема проверена с сохранённой раскладкой из прогона «до»: applet ID 5
и все 30 закреплений сохранены, Drawer удалён. Тёмная — с новым профилем.
[startup light](after/light/startup.json), [startup dark](after/dark/startup.json),
[геометрия light](after/light/geometry.json), [геометрия dark](after/dark/geometry.json).

## Проверки

```sh
node plasma-theme/tests/test-panel-screens.js
node --check plasma-theme/layout-templates/sberos.taskbar/contents/layout.js
QT_QPA_PLATFORM=offscreen QT_STYLE_OVERRIDE=Breeze QT_QUICK_CONTROLS_STYLE=Basic \
  timeout 25s /usr/lib/qt6/bin/qmltestrunner -input plasma-theme/tests/tst_applications.qml
# Те же env и timeout: tst_taskoverflow.qml, tst_panellayout.qml.
qmllint plasma-theme/plasmoids/sberos.smarttasks/contents/ui/*.qml \
  plasma-theme/plasmoids/sberos.panel/contents/ui/main.qml
python3 plasma-theme/tests/capture-taskoverflow.py --source plasma-theme \
  --output /tmp/sber-applications-check --theme dark --applications
# Светлая тема: --theme light --restore-config <профиль-до>/config/plasma-io.gitgud.wackyideas.desktop-appletsrc;
# рядом с appletsrc должен находиться plasmashellrc с высотой панели.
python3 plasma-theme/tools/sync-smart-panel.py --check
bash -n plasma-theme/install.sh
bash plasma-theme/install.sh --dry-run
git diff --check
```

Прошли 6 QML-проверок объединённого компонента, 13 проверок задач/+N,
6 геометрии панели; Node проверяет создание/повтор/экраны и удаление старой кнопки
без замены задач. 14 состояний runtime прошли в каждой теме: ряд, сжатие, +N,
сетка, меню, закрытие дочернего элемента, сворачивание, сокращение модели,
Launchpad, поиск, закрытие Launchpad, повтор +N, переход в Launchpad и закрытие
другим popup. Действия runtime вызваны из QML, а не физическим вводом.
qmllint — код 0 с предупреждениями динамических/неквалифицированных API;
sync-check — 175 ресурсов; shell syntax, dry-run и diff-check прошли.
CMake-сборки у этой QML/KPackage-копии нет.

Qt Test и KWin выполнены с необходимым доступом вне sandbox; первая попытка
Qt Test внутри sandbox остановлена после зависания и не считается проверкой.
Промежуточные ошибки сценария тестирования (видимость TestCase, восстановление
plasmashellrc и разбор секций KConfig) исправлены; итоговые прогоны прошли.
Итоговые группы процессов 34588/34711 остановлены, остальные запущенные в этой
задаче тестовые группы также завершены. Основной сервис не перезапускался.

## Границы приёмки

Геометрия компактного острова сохранена. +N всё ещё открывает отдельную сетку
над панелью; анимация единого растущего острова по моку остаётся следующим шагом.
Физический ввод/внешний клик, возврат фокуса из fullscreen, реальные действия
окон/preview, blur композитора, масштабирование и несколько мониторов этим
прогоном не подтверждены. Sirca/Quickshell не менялись, их соответствие не
переоценивалось. ATP-001 остаётся «В работе».

API удаления старого applet проверен по
[официальному Plasma scripting API](https://develop.kde.org/docs/plasma/scripting/api/).
Коммит доработки: `git log --grep='объедини Launchpad и задачи'`.
