# ATP-001: проверка QML-аудита

Дата: 27.10.2026. Скриншоты проверки опубликованы только для светлой темы по
уточнению пользователя. Окружение: Plasma 6.7.4, Qt 6.11.2, Wayland, экран
2560×1440, DPR 1.

После устранения повторного `Component.onCompleted` в `LogicController.qml`
файловый поиск загружается. Установленные версии 30 затронутых QML-файлов
совпали с рабочей копией; `plasma-plasmashell.service` active/running,
`NRestarts=0`. В журнале после исправления не повторилась ошибка загрузки
`sberos.filesearch`.

Команда `python3 plasma-theme/tests/run-panel-sizing.py --source plasma-theme --output <каталог> --themes light`
сняла 10 кадров светлой темы и прошла проверки геометрии:
апплеты остаются в пределах панели и центрированы по вертикали, а ширина
`smarttasks` меняется при добавлении и удалении задач. В процессе проверки
исправлены два неверных ожидания теста: равенство высоты applet контейнера полной
толщине панели и изменение ширины полноэкранной панели вместо ширины `smarttasks`.

Команда `python3 plasma-theme/tests/capture-smart-panel.py --source plasma-theme --output <каталог> --states panel sber power search notifications quick calendar launcher`
сняла все восемь состояний: панель, меню Сбера, меню
питания, поиск, уведомления, быстрые настройки, календарь и Launchpad. Эти кадры
получены из временного профиля с отдельной D-Bus-сессией. В ней недоступны службы
KWin, `kglobalaccel` и Night Light, поэтому снимки подтверждают загрузку и
отрисовку QML, но не проверяют управление окнами, системные действия,
фокусировку popup или работу реальных уведомлений.

Кадры:

- `panel-72-light.png` — панель толщиной 72 px.
- `panel-light.png` — панель в состоянии по умолчанию.
- `sber-menu-light.png`, `power-menu-light.png` — меню Сбера и питания.
- `search-light.png`, `notifications-light.png` — поиск и уведомления.
- `quick-settings-light.png`, `calendar-light.png` — быстрые настройки и календарь.
- `launcher-light.png` — Launchpad.
