# PLASMA-ALT-TAB: Восстановить переключение окон Alt+Tab в Plasma

- **Статус:** Готово
- **Обновлено:** 2026-10-27
- **Источник:** сообщение пользователя «plathmatheme не работает переключение окон по альт таб».
- **FT/UI:** существующее управление окнами; новый визуальный контракт не вводится.
- **Сценарии:** `03-01`, `03-04`.
- **Зависимости:** ATP-001; KWin/Wayland, KGlobalAccel.

## Границы и критерии

Восстановить штатный переключатель KWin в текущей сессии Plasma Smart Panel.
Sirca/Quickshell и пользовательские документы не менять.

- [x] Прочитать реальные назначения клавиш и состояние оболочек.
- [x] Восстановить Alt+Tab и Alt+Shift+Tab с сохранением прежних настроек.
- [x] Проверить активацию окна после отпускания Alt и показ списка при удержании.
- [x] Удалить временный наблюдатель, сохранить результат и ограничения.

## Результат и проверки

Постоянные назначения были правильными, но текущая регистрация сочетаний KWin
работала некорректно: до исправления при удержании Alt сетка не появлялась.
`reconfigure` не помог. Через `org.kde.KGlobalAccel.setForeignShortcut` для
`Walk Through Windows` и `Walk Through Windows (Reverse)` временно сняты,
затем повторно применены **прочитанные через shortcut** назначения. Это
восстановило показ переключателя. Первопричина рассинхронизации не установлена;
связь с прежним перехватом Sirca остаётся гипотезой.

Применённый код (`/usr/bin/python3`, модуль `dbus`, пользовательская сессия):

```python
import dbus
bus = dbus.SessionBus()
accel = dbus.Interface(bus.get_object('org.kde.kglobalaccel', '/kglobalaccel'),
                       'org.kde.KGlobalAccel')
for name in ['Walk Through Windows', 'Walk Through Windows (Reverse)']:
    action = dbus.Array(['kwin', name, 'KWin', name], signature='s')
    keys = accel.shortcut(action)
    accel.setForeignShortcut(action, dbus.Array([], signature='i'))
    accel.setForeignShortcut(action, keys)
```

Живая проверка: **Qt 6.11.2, KWin 6.7.4, Wayland**, светлая тема,
мониторы 2560×1440 и 1080×1920, DPR 1. Через XTest/Xwayland EIS отправлены
Alt+Tab и Alt+Shift+Tab с удержанием Alt; просмотрены снимки видимой сетки,
журнал временного KWin-наблюдателя подтвердил активацию окна при отпускании.
Фон и панель оставались видны. Наблюдатель `plasma-alt-tab-check` выгружен
(результат `true`). GUI-процессы не запускались в постоянном режиме.

Резервные копии и снимки:
[каталог диагностики](/home/ezhov/.local/state/sberos-shell/plasma-alt-tab/20261027/),
[Alt+Tab](/home/ezhov/.local/state/sberos-shell/plasma-alt-tab/20261027/held.png),
[Alt+Shift+Tab](/home/ezhov/.local/state/sberos-shell/plasma-alt-tab/20261027/reverse.png).
`kwinrc` и `kglobalshortcutsrc` после проверки побайтово совпадают с резервными
копиями: сохранены прежние назначения. Служба Plasma осталась active,
PID 107608, NRestarts=0; её перезапуск не требовался.

В журнале остаётся предупреждение о ненайденном `org.kde.breeze.desktop`:
KWin успешно использует штатный fallback `thumbnail_grid`, что подтверждено
снимком. Перезаход, физическая клавиатура, тёмная тема и Meta+Tab отдельно
не проверялись. Внешний вид компонентов Plasma не менялся; соответствие моку
и общая приёмка ATP-001 этой задачей не пересматриваются. Sirca/Quickshell,
UI Kit и refs не изменялись; сборка не нужна. `git diff --check` пройден.

## Следующий шаг

Работа по восстановлению текущей сессии завершена. Если проблема повторится
после запуска другой оболочки, отдельно воспроизвести передачу сочетаний KWin.
Ссылка на коммит доступна в истории этой карточки (`git log --follow`).
