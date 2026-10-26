# Витрина компонентов UI Kit

Интерактивный пример использует `Sber.Controls`, `Sber.Theme` и `Sber.Widgets`.
Справа расположен список компонентов с интерактивными примерами; поле поиска
фильтрует его. Каждый пункт боковой панели служит вкладкой и переключает рабочую
область на соответствующий пример. Список включает 22 компонента, с которыми
можно взаимодействовать; статичные элементы и служебные типы в нём не показаны.
Светлая/тёмная тема переключается в шапке.

Витрина демонстрационная: она не изменяет настройки рабочего стола и не требует
подключения к оболочке.

## Визуальная проверка

Снимки до и после изменения сохранены для обеих тем в
[`screenshots/2026-10-22/`](screenshots/2026-10-22/). После сняты на Qt 6.11.2,
Linux, `offscreen` с программным рендерером. Они подтверждают загрузку и
раскладку верхней части страницы; проверка интерактивности мышью в Wayland не
проводилась. Qt сообщает об отсутствующем системном переводе и об отсутствующей
иконке `Settings`; эти ресурсы не мешают запуску витрины.

Промежуточные снимки с цветами Smart Panel сохранены как
[`mock-colors-light.png`](screenshots/2026-10-26/mock-colors-light.png) и
[`mock-colors-dark.png`](screenshots/2026-10-26/mock-colors-dark.png). По просьбе
пользователя палитра возвращена к исходной; актуальные снимки —
[`original-palette-light.png`](screenshots/2026-10-26/original-palette-light.png)
и [`original-palette-dark.png`](screenshots/2026-10-26/original-palette-dark.png).
Обе пары сняты на Qt 6.11.2, Linux, `offscreen` с программным рендерером. На кадрах
показан образец кнопок и верхняя часть витрины. `QT_STYLE_OVERRIDE` сброшен;
предупреждения о переводе и свойстве `data` у Accordion остались. Остальные
элементы UI Kit и Wayland-ввод этими снимками не охвачены.

Снимки до и после фильтрации списка на компоненты с интерактивными образцами
находятся в [`screenshots/2026-10-22/interactive-filter/`](screenshots/2026-10-22/interactive-filter/).

Из корня рабочей области:

```sh
cmake -S ui-kit -B ui-kit/_build -DBUILD_WITH_CTEST=OFF
cmake --build ui-kit/_build -j 4
./ui-kit/_build/examples/gallery/sber-components-gallery
```

Галерея включена по умолчанию (`BUILD_EXAMPLES=ON`). Тема и иконки загружаются
из `ui-kit/resources`, QML-плагины — из `_build/qml`; установки в систему
и ручных символических ссылок не требуется.

Скриншоты без дисплея:

```sh
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
    ./ui-kit/_build/examples/gallery/sber-components-gallery \
    --screenshot "$PWD/ui-kit/_build/gallery-light.png"
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
    ./ui-kit/_build/examples/gallery/sber-components-gallery --dark \
    --screenshot "$PWD/ui-kit/_build/gallery-dark.png"
```

`--dark` также можно использовать при обычном запуске. При ошибке загрузки QML,
отсутствии файлов темы или ошибке сохранения изображения программа возвращает 1.

Qt подбирает замену для отсутствующих фирменных шрифтов. Сообщение
`Translation file not found` связано с поиском перевода в системном QML-каталоге
в `Core::setTranslation()` и не мешает запуску локального примера.
