## Библиотека компонентов для SberOS

Пакет: sberos-qml-components

------------

#### Документация:

https://confluence.sberbank.ru/display/SBOS/SberOS+Components

------------

#### Сборка:

Для сборки кода лучше использовать clang, например:

```
export CXX=/usr/bin/clang++

cmake -S . -B _build

cmake --build _build -j

cmake --install _build
```

------------

#### Пути установки:
  
/usr/includes/SberComponents - хедеры
  
/usr/lib/x86_64-linux-gnu/qt6/qml - библиотеки и qml файлы
  
/usr/lib/x86_64-linux-gnu/Sber{name}Plugin - модули cmake

------------

#### Пример:

[Галерея компонентов](examples/gallery/README.md) — локальная сборка и запуск
без установки в систему, с темой и иконками из соседних репозиториев.
