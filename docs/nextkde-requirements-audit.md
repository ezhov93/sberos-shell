# Соответствие NextKDE требованиям SberOS DE

Дата: 22 октября 2026. Объект: `refs/NextKde`, `VERSION=0.1.1`, HEAD `2ca59a1fbe7cd8c4b9c0b9fd960edca6788425c5`. Рабочее дерево референса на момент чтения чистое.

## Вывод

NextKDE предоставляет более развитое разделение интерфейса и системных интеграций, чем Sirca: отдельные Quickshell, C++ platform daemon, Go data daemon и Settings, версионированные запросы/события, собственный desktop с файлами и тестовые контракты. Это полезный архитектурный референс, но не подтверждённая реализация целевой SberOS DE.

Прямые расхождения: Super+V открывает буфер; универсальный трей сохранён; ярлыки закрепляются за выходами вместо обязательного переноса на основной монитор; счётчик dock не синхронизируется с источником непрочитанных сообщений; диалоги завершения не соответствуют требованиям. Конфиденциальность при демонстрации, защита буфера после выхода, корпоративные login/search/profile/update и полный паритет доступности не подтверждены.

## Метод и ограничения

Применены [спецификация](README.md), [ограничения](rules/product.md), [270 сценариев](rules/README.md), [приёмка](rules/acceptance.md) и [ADR](adr/README.md). Прочитаны README, PROJECT_CONTEXT, CONTRIBUTING, Development и профильные документы референса; выводы проверены по указанным исходникам.

«Есть код» означает найденную реализацию, а не пройденную приёмку. «Внешняя интеграция» требует проверки поставляемой ОС и приложений; «не найдено» относится к исследованной базе. Это статический аудит по областям, не индивидуальный протокол прохождения всех 270 сценариев. Процент готовности не вычисляется.

По запросу пользователя сборка не выполнялась. Тесты, диагностика и графический запуск также не выполнялись: локальные правила NextKDE требуют VM/CI. Существующие `.build` и исторические результаты не использованы как доказательство работоспособности текущего HEAD. Изменён только этот отчёт вне дерева референса.

## Архитектурное соответствие

| Ограничение | Оценка и доказательство |
| --- | --- |
| Готовый композитор, Wayland | KWin/Plasma 6 Wayland и Quickshell. Соответствует направлениям ADR-0001/0002; XWayland и целевая аппаратура требуют испытаний. |
| Независимость от GNOME Shell | Ключевой UI собственный. Зависимость переносится на Quickshell, KDE, KWin Scripting, D-Bus и нативные плагины KWin. |
| Изоляция | [Архитектура](../refs/NextKde/docs/ProjectArchitecture.md): отдельные shell/platform/data/settings и ленивый AI-worker. Ошибка GUI Settings отделена от shell; ошибка platform может затронуть shell через `Requires=kos-platform.service`. |
| Восстановление | [kos-shell.service](../refs/NextKde/packaging/systemd/kos-shell.service.in): Restart=on-failure, KillMode=process, отключён file watcher установленного дерева. Приложения не должны завершаться при рестарте shell. JsonlClient переподключается, подписки восстанавливаются. Автоматический возврат панелей Plasma при повторных падениях в этом unit не задан. |
| Единый API, ADR-0003 | Есть [platform.v1](../refs/NextKde/shared/contracts/platform.v1.md): version/requestId/operation/payload, ошибки и события, ограниченные операции. Это существенная основа. MCP, агентные scopes, подтверждения опасных действий и аудит не найдены. |
| Защита интеграционного слоя | [PlatformServer](../refs/NextKde/platform/src/daemon/PlatformServer.cpp) задаёт сокету права владельца; операции валидируются. [Shortcuts.cpp](../refs/NextKde/platform/src/daemon/Shortcuts.cpp) ограничивает exec формой `qs ... ipc call`, запрещает shell-метасимволы. Это защита локального адаптера, не полноценная авторизация агента. |
| Общий UI Kit | Есть собственные `shared/qml/controls`, foundation, тема и i18n. Репозиторный SberOS `ui-kit/` не интегрирован. По PROJECT_CONTEXT внешний вид shell и standalone apps хранится раздельно и не синхронизируется автоматически. |
| Поэтапность | Разделены выбор исходников, установка и активация. Документированы VM/CI и матрица SDK KWin. Это процессы сопровождения, а не доказательство выполнения всех критичных сценариев. |

## Существенные расхождения и пробелы

### 1. Приватность уведомлений не связана с демонстрацией

**ID:** `05-18`, связи `08-05`, `08-06`; отдельно проверить `05-08`.

[NotificationPolicyService](../refs/NextKde/shell/desktop/modules/notifications/NotificationPolicyService.qml) содержит ручной `showPreview`, DND, banners и per-source blocking. [NotificationWindow](../refs/NextKde/shell/desktop/modules/notifications/NotificationWindow.qml) и история учитывают showPreview для текста, но автоматическая связь с активным screencast не найдена. Кроме того, `displayIconSource` продолжает выбирать `notification.image || appIcon` независимо от showPreview: скрытие текста не гарантирует скрытие чувствительного изображения. Нужны единая политика для баннеров/истории/изображений и реальные portal-тесты. Ручной DND не доказывает `05-18`.

### 2. Буфер хранится вне жизненного цикла сессии

**ID:** `06-18`, `06-19`.

[PlatformServer](../refs/NextKde/platform/src/daemon/PlatformServer.cpp) запускает `wl-paste --type text/image --watch cliphist store`. [Clipboard](../refs/NextKde/platform/src/daemon/PlatformServerClipboard.cpp) и [Pins](../refs/NextKde/platform/src/daemon/PlatformServerClipboardPins.cpp) работают с историей, превью и закреплёнными данными в state directory; pins переживают wipe. Принудительная очистка на logout и собственная согласованная классификация чувствительных данных не найдены. Сокет 0600 не исключает доступ процессов того же пользователя. Фильтрация секретов может зависеть от wl-clipboard/cliphist и MIME источника; без проверки этой цепочки нельзя объявлять её отсутствующей или достаточной.

### 3. Super+V вызывает другую функцию; ряд привычных путей не закреплён

**ID:** `05-17`, `09-15`, `02-09`, `02-14`, `10-40`.

[ShortcutsService](../refs/NextKde/shell/desktop/modules/shortcuts/ShortcutsService.qml) задаёт Meta+V для clipboard, Meta+Space для launcher, Meta+Shift+Space для quicksearch, Meta+Tab для overview. Это прямое расхождение `05-17`. В собственном наборе defaults не найдены Meta+1…9 для закреплённых приложений и Ctrl+Alt+Del для целевого power dialog. Сочетания KDE могут существовать отдельно, но их фактическое действие после takeover необходимо проверять; нельзя засчитать их по умолчанию.

### 4. Счётчик dock — счётчик уведомлений, не непрочитанных сообщений

**ID:** `05-12`, `05-13`; связан `05-03`.

[AppNotificationService](../refs/NextKde/shell/desktop/modules/common/AppNotificationService.qml) накапливает session-scoped notification events. [DockModelService](../refs/NextKde/shell/desktop/modules/dock/DockModelService.qml) вызывает clearForApp при активации окна/приложения. Открытие приложения не означает прочтение сообщений; чтение на другом устройстве также не обязано породить событие shell. Нужен источник авторитетного unread state поддерживаемых приложений и согласованная fallback-семантика. Наличие badge не закрывает минимум синхронизации.

### 5. История уведомлений теряет изображение и действия

**ID:** `05-02`, `05-03`, `05-19`.

[NotificationGroupService](../refs/NextKde/shell/desktop/modules/notifications/NotificationGroupService.qml) сохраняет в snapshot id/appName/desktopEntry/appIcon/summary/body/urgency/timestamp, но не image и action handles. [NotificationHistoryService](../refs/NextKde/shell/desktop/modules/notifications/NotificationHistoryService.qml) держит до 50 session-only записей. Действия поддерживаются живыми объектами баннеров; нельзя обещать их повторное выполнение из исторического снимка после уничтожения объекта. Для сохраняемой истории изображения `05-19` есть прямой пробел: appIcon не заменяет image уведомления.

### 6. Модель ярлыков отличается от «все на основном экране»

**ID:** `04-07`, `04-13`–`04-15`; частично `09-01`, `09-22`, `09-23`.

В отличие от Sirca, здесь есть полноценная основа desktop files: операции, размеры, интервалы и позиции. Но [desktop_placement.go](../refs/NextKde/services/data-service/desktop_placement.go) сохраняет Output каждого файла; смена defaultOutput не переносит существующих владельцев. [DesktopOutputs.mjs](../refs/NextKde/shell/desktop/modules/deskcenter/DesktopOutputs.mjs) оставляет файл на доступном назначенном выходе, а default применяет при недоступном владельце. Это осознанная модель нескольких рабочих столов, противоречащая требованию `04-13`/`04-14` о переносе всех ярлыков на основной. При hotplug есть fallback без удаления файлов, но сохранность доступного расположения надо испытать. Документация дополнительно предупреждает: при недостатке ёмкости сетки лишние элементы скрываются — файл сохранён, однако доступность ярлыка не гарантирована.

### 7. Завершение работы: неполный диалог и обход штатной оркестрации сохранения

**ID:** `10-33`–`10-42`, связанные `10-13`–`10-17`.

[SessionConfirmationDialog](../refs/NextKde/shell/desktop/modules/bar/controlcenter/SessionConfirmationDialog.qml) показывает Cancel и действие, но не Lock в том же диалоге и не минутный отсчёт reboot. Обновляющих вариантов выключения/перезагрузки не найдено. Cancel как отказ от действия предусмотрен.

[PlatformServerDesktop](../refs/NextKde/platform/src/daemon/PlatformServerDesktop.cpp) вызывает `systemctl reboot/poweroff`, а logout выполняет `systemctl --user --no-block stop graphical-session.target`. В этой цепочке нет явного обращения к KDE shutdown/session-save coordinator и собственного UI blocker/inhibitor с именем приложения и «Завершить принудительно». Системная политика может отказать операции, но это не доказывает `10-41`/`10-42` и передачу запросов сохранения редакторам. Нельзя просто обещать сохранность несохранённых документов. Требуется проектирование сессионного завершения и проверка Р7/браузеров/VS Code/GigaCode.

### 8. Lock — реальная блокировка, но неполный целевой интерфейс

**ID:** `10-22`–`10-32`, `09-08`, `09-24`.

[LockScreen](../refs/NextKde/apps/lockscreen/contents/lockscreen/LockScreen.qml) работает внутри kscreenlocker, не имитирует защиту overlay. Есть пароль/PAM, обработка повторных попыток, caps lock, медиа, виджеты и отдельный [SessionMenu](../refs/NextKde/apps/lockscreen/contents/lockscreen/SessionMenu.qml). Выключение/сон/reboot/logout делегируются SessionManagement: `10-28` имеет путь реализации и не должно считаться отсутствующим.

В меню есть `sessions.switchUser()` при canSwitchUser — это расходится с продуктовой границей «не входить другим пользователем на разблокировке». Полный выбор методов и последнее использованное средство аутентификации не представлены. Не найдены требуемые Wi-Fi, аппаратная яркость, громкость, авиарежим, батарея, диктор и размер текста до разблокировки. PAM может поддерживать дополнительные каналы, но это не равнозначно требуемому UI выбора. Pre-login остаётся отдельным компонентом.

### 9. Универсальный трей сохранён

**ID:** `03-24`, связанные `11-08`, `11-11`, `05-14`–`05-16`.

[SysTray](../refs/NextKde/shell/desktop/modules/bar/SysTray.qml) использует Quickshell.Services.SystemTray и общий StatusNotifierItem host. Перенос трея в dock, группировка и сворачивание коллекции не выполняют запрет универсального трея. Нужны проверенные альтернативы важным действиям приложений и отдельная точка корпоративных обновлений; просто удалить трей недостаточно.

### 10. Поиск и системные интеграции не образуют полный целевой набор

**ID:** `02-11`–`02-13`, `06-17`, `07-04`, `07-22`, `07-23`, `11-12`–`11-14`.

[QuickSearchWindow](../refs/NextKde/shell/desktop/modules/quicksearch/QuickSearchWindow.qml) фильтрует окна, каталог приложений и clipboard. Общий файловый/полнотекстовый и корпоративный поиск не найден. Это отличается от Sirca, где есть KRunner/Milou.

[NetworkService](../refs/NextKde/shell/desktop/modules/bar/NetworkService.qml) и platform network реализуют Wi-Fi, включая enterprise 802.1X, но собственные VPN list/connect/disconnect/error операции и видимая модель VPN не найдены. В [NetworkPanel](../refs/NextKde/shell/desktop/modules/bar/NetworkPanel.qml) есть запуск `kcm_networkmanagement`, поэтому путь через системные настройки возможен; его надо проверить на обязательном VPN. Enterprise Wi-Fi не следует путать с VPN.

Platform audio предоставляет per-stream sink-input control — полезно для `07-20`/`07-21`. Однако постоянная индикация использования микрофона в исследованном UI не найдена. Метрики data-service не заменяют полный GUI системного монитора и управление произвольными процессами.

## Карта покрытия 11 областей

| Область | Основа реализации | Незакрытые минимумы и зависимости |
| --- | --- | --- |
| 01. Вход, 35 | DesktopEnvironment, launcher/dock/status и сохранённое локальное состояние дают основу `01-03`–`01-05`. | Display manager/PAM, корпоративная сеть/сертификаты, подготовка/целостное появление desktop, миграция и синхронизация профиля (`01-01`, `01-02`, `01-07`–`01-35`) требуют отдельных компонентов. Lock не заменяет login. |
| 02. Поиск, 14 | Каталог приложений, pinned dock, запуск и активация окон (`02-02`, `02-04`–`02-08`). Overview делегирован штатному KWin effect. | Файловый/корпоративный поиск, порядок корпоративных результатов (`02-11`–`02-13`) не найдены. Номерные клавиши и Alt+F2 не закреплены собственными defaults; внешние регистрации проверить. Overview с поиском зависит от конфигурации KWin. |
| 03. Окна, 26 | WindowService, KWinBridge и window-bridge.js: снимки состояния, команды, группы, переключение, геометрия, thumbnails, overview/stage. | Фокус/модальность (`03-13`, `03-21`, `03-22`), четверти (`03-23`), жесты (`03-25`) требуют проверки KWin. Универсальный трей нарушает `03-24`. Overlay кнопок клиентских шапок в kos-bridge требует отдельного теста сохранности меню/поиска (`03-26`), его не следует переносить автоматически. |
| 04. Мониторы, 19 | ScreenLifecycle учитывает KScreen priority, hotplug/placeholder screens; DeskCenter создаёт поверхности по выходам; desktop имеет persisted placements. | Разрешение/scale/rotation/modes/config restore остаются KScreen/KWin и `kcm_kscreen`; `display.outputs.get` не является полным API конфигурации экранов. Модель ярлыков расходится с `04-13`/`04-14`; dock/бар работают на выбранном activeScreen, это не доказательство полной матрицы нескольких дисплеев. |
| 05. Уведомления, 19 | Собственный NotificationServer: действия, баннеры, DND, per-source blocking, группировка, session history; Calendar/PIM даёт основу событий. | При другом владельце Notifications собственный server неактивен — паритет истории требует проверки takeover. Конфликты badge/preview/image/history/Super+V описаны выше. Корпоративное обслуживание `05-14`–`05-16` не реализовано найденными механизмами. |
| 06. Файлы, 38 | DesktopFilesService, platform Files и data desktop: open/rename/copy/move/trash/Open-With/default MIME; история clipboard text/image. | Это desktop, не полноценный файловый менеджер. Сетевые/облачные каталоги, GTK/Qt/portal import/export, полнотекстовый поиск, печать/архивы/почта и полный набор контекстных операций надо обеспечить внешними компонентами и проверить. `06-19` требует политики и доработки. |
| 07. Устройства, 23 | Wi-Fi/Ethernet/802.1X, Bluetooth, выбор output и громкость/per-stream mixer, brightness/DDC, power profiles, keep-awake. | VPN доступен потенциально через KCM, собственный быстрый статус не найден. Capture indicator `07-23`, микрофон/камера, реальные hotplug/гарнитуры, восстановление после сна и разрешения требуют испытаний. |
| 08. Совместная работа, 13 | `screenshot.capture` запускает первый найденный mark-shot/markshot/flameshot/ksnip/spectacle/grimblast. | Наличие внешнего capture-tool не гарантирует равный набор area/window/fullscreen/annotations/save-as/autocopy (`08-03`, `08-07`–`08-11`). Некоторые fallback запущены только с region args. Запись экрана, portal permissions, прекращение трансляции и global shortcuts приложений — отдельная интеграция. |
| 09. Персонализация, 27 | Развитые shared controls, темы, размеры/позиции/интервалы ярлыков, настройки сочетаний. В части controls есть Accessible и Tab; не следует объявлять accessibility полностью отсутствующей. | Полный паритет диктора/pre-login/lock, Tab всех форм, OSK, курсоров, Ctrl+Shift (`09-08`, `09-16`, `09-17`, `09-24`, `09-26`, `09-27`) не подтверждён. В SessionConfirmationDialog кнопки — Rectangle/MouseArea без явного focus/keyboard path. Нет синхронизации SberOS профиля, фирменных тем и интеграции общего ui-kit. |
| 10. Сессия, 42 | Реальный kscreenlocker, запросы lock/sleep/logout/reboot/poweroff/switch-user, session confirmation, weather/media lock widgets. | Не покрыты точные диалоги `10-33`–`10-39`, блокирующие приложения, восстановление после обновления и protected-session controls. `10-18` — будущая возможность по требованиям. Медиа/погода на lock не равны корпоративному медиаскринсейверу `10-19`–`10-21`. |
| 11. Отказы, 14 | Разделённые процессы, reconnect/подписки, таймауты/ограниченные очереди API, systemd restart, window search/overview, metrics и GUI feedback ошибок. | Возврат потерянных окон и режимов (`11-01`–`11-03`), hung processes/full monitor (`11-05`, `11-12`–`11-14`), Polkit/portal (`11-09`), ошибки восстановления (`11-10`) требуют целевого состава DE. Удаление трея без альтернатив сломает `11-08`/`11-11`. |

## Приоритеты адаптации

1. Определить владельцев login/lock/session-save, portal/Polkit, update/profile/search, файлового менеджера и системного монитора; зафиксировать версии KDE/Qt и обязательные приложения/устройства.
2. Закрыть `05-18`/`06-19` и проверить protected session, прежде чем использовать реальные рабочие данные.
3. Исправить семантику badge, ярлыков, Super+V и завершения работы; сохранить доступ к действиям приложений при отказе от трея.
4. Развивать собственный API с агентными разрешениями/аудитом; не считать local inference/depth AI-worker реализацией MCP управления desktop.
5. Перепроверить сквозные пути из `rules/cross-scenario.md` в VM на точной версии; существующие тесты контрактов, desktop outputs, clipboard, notifications, shortcuts и lock — полезная база, но их прохождение в этом аудите не устанавливалось.

## Выбор концепции интеграции с оконным менеджером

Если UI и архитектура переписываются, целесообразно взять принцип отдельного адаптера из NextKDE, но базовые оконные операции строить на готовых моделях KDE, как Sirca. Это инженерная оценка по текущему коду, а не измеренная стоимость сопровождения.

Sirca использует `org.kde.taskmanager` TasksModel/VirtualDesktopInfo/ActivityInfo для списка, активации, close/minimize и PipeWire ScreencastingRequest для превью. У платформы остаётся ответственность за значительную часть идентификации и семантики окон. Недостаток Sirca — прямое использование моделей в UI и разрозненные KWin-скрипты для специальных операций; эту связность не стоит переносить.

NextKDE выносит интеграцию в platform service, но строит собственную оконную модель и долговременный [window-bridge.js](../refs/NextKde/kwin/window-bridge.js): события KWin порождают JSON snapshots, [KWinBridge.cpp](../refs/NextKde/platform/src/kwin/KWinBridge.cpp) принимает их по D-Bus, команды script забирает через TakeCommand каждые 50 мс. Это не полностью событийный командный канал. Есть debounce/coalescing, ограничения очередей, повторная подписка, отдельный захват thumbnails через ScreenShot2. Плюс — контролируемый API; цена — сопровождение собственной синхронизации, гонок, очередей, оконной идентичности и совместимости script API. Логика stage/park перемещает окна за пределы экранов ради живых превью и существенно расширяет количество состояний восстановления.

`kwin/kos-bridge` — несмотря на имя, не основной state/command bridge. Это C++ effect наложения оконных кнопок. Его, glass, context-menu input, stage animation и dock animation следует оценивать отдельно от жизненного цикла окон: нативные эффекты выполняются внутри композитора и увеличивают поверхность зависимости от KWin SDK.

Рекомендуемая граница: UI и MCP → собственный ограниченный Workspace API → адаптер KWin вне композитора → стандартные KDE/Wayland-механизмы; узкий постоянный KWin Script только для недоступных операций геометрии/компоновки. Не дублировать полную модель TasksModel и не писать нативный KWin plugin ради обычного activate/close/minimize. C++ effect нужен лишь там, где действительно необходим доступ к render pipeline. Перед выбором KDE API для C++ сервиса проверить его доступность, стабильность и упаковку на целевой версии: демонстрация TasksModel в QML не доказывает автоматически готовый публичный C++ ABI для нового daemon.

При минимизации собственных механизмов интеграции Sirca проще как референс стандартного оконного управления; NextKDE полезнее как референс процессной границы, контрактов, reconnect и тестирования. Форк всего NextKDE ради оконного управления перенесёт много механики, которая не нужна при новом UI и новой архитектуре.
