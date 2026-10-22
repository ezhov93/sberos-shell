# Галерея компонентов

Пример использует `Sber.Controls` и `Sber.Theme`: кнопки, поле ввода,
слайдер, прогресс и переключение светлой/тёмной темы. Кнопка приветствия
читает введённое имя, сброс возвращает форму в исходное состояние.
Поведение оболочки и её сценарии не затрагиваются.

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
