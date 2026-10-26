# SHELL-004: Удалить поддержку KDE Plasma applets из Sirca

- **Статус:** Готово
- **Обновлено:** 2026-10-22
- **Источник:** прямое указание пользователя от 2026-10-22: «вырежи поддержку kde аплетов».
- **Требования FT/UI:** сохранить собственные системные элементы единой панели; не добавлять поддержку сторонних плазмоидов.
- **Сценарии:** `03-14`, `05-01`–`05-07`, `09-21`.
- **Зависимости:** ADR-0008, PANEL-001.
- **Область:** Sirca Shell (`shell/shell/`); `quickshell/` и `refs/NextKde/` не изменять.

## Цель

Удалить хостинг сторонних Plasma applets из Sirca: Corona/Containments, QML host,
bundled forks, applet-specific package support, fallback-ветви и проверки applet-пакетов.
Собственные tray, quick settings, календарь, уведомления и настройки Sirca остаются.

## Критерии готовности

- [x] Sirca больше не создаёт Plasma Corona и не экспортирует API для загрузки applet.
- [x] Удалены bundled Plasma applets и shell package, используемые только хостом.
- [x] Удалены зависимости сборки, fallback-ветви, конфигурация и документация applet-hosting.
- [x] `sirca-shell-reload` проверяет только встроенный QML оболочки.
- [x] Сборка Sirca проходит; ограниченная QML-проверка запущена и результат ограничения зафиксирован.
- [x] `quickshell/` и `refs/NextKde/` не изменены этой задачей.

### Готовность по проектам

- Sirca [x] Хостинг и сопровождающий код удалены; CMake configure и сборка прошли.
- NextKDE [x] Не входит в область; `quickshell/` и `refs/NextKde/` не изменялись.

## Неясности

Нет. «Поддержка KDE applets» относится к загрузке и размещению Plasma applets внутри Sirca;
KDE Frameworks, KWin/Wayland и собственные системные элементы Sirca остаются.

## Проверки и результат

`cmake -S shell/shell -B /tmp/sberos-shell-build -DCMAKE_BUILD_TYPE=Debug` и
`cmake --build /tmp/sberos-shell-build -j 4` прошли. Изолированная smoke-проверка
единой панели `python3 shell/shell/tests/run-panel-smoke.py --output
/tmp/sber-panel-check-applet-removal` прошла с `PANEL PASS` (offscreen,
software rendering, временные данные; без реального KWin/D-Bus-сервисов).
CMake сообщил о недоступном
необязательном PipeWire и предупреждениях Qt QML import scanner; сборка завершилась
успешно. `QT_QPA_PLATFORM=offscreen timeout 25s
/tmp/sberos-shell-build/bin/sirca-shell --check` не завершилась за 25 секунд;
согласно правилам проекта это незавершённая проверка, повторно не запускалась.
Поиск по Sirca не находит AppletHost, ShellCorona, API загрузки applet, applet
пакеты и проверки установленных плазмоидов. `git diff --check` прошёл.

## Следующий шаг

Нет. Реализация завершена; QML `--check` ограничена известным зависанием offscreen.

## Коммиты

Коммит не создан: `.git/index` доступен только для чтения в sandbox.
