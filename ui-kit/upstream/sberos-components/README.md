## Метапакет для дизайн системы SberOS

Пакет: sberos-components

------------
#### Инициализация сабмодулей: 

```git submodule update --init --recursive```

По умолчанию, сабмодули указывают на привязанный к ним коммит, чтобы переключить их все на ветку по умолчанию используйте:

```git submodule foreach -q --recursive 'branch="$(git config -f $toplevel/.gitmodules submodule.$name.branch)"; git switch ${branch}'```

Если хотите переключить на определенную ветку:

```git submodule foreach -q --recursive 'git switch upstream/develop'```

------------
#### Документация

https://confluence.sberbank.ru/display/SBOS/SberOS+Components

------------
#### Демо приложение:
Пакет: sberos-components-demo

репозиторий - ```../sberos-qml-components-demo.git```


### Список подрепозиториев: 
#### sberos-theme

Пакет: sberos-theme

Репозиторий с данными темы: цветами, json-конфигом светлой и темной тем, json-конфигом размеров.

Путь установки: /usr/share/SberComponents/theme

------------

#### sberos-app-icons

Пакет: sberos-app-icons

Репозиторий с иконками для приложений.

Путь установки: /usr/share/SberComponents/icons

------------

#### sberos-qml-components

Пакет: sberos-qml-components

Репозиторий с ядром приложения и темы, qml-компонентами, qml-виджетами.

Путь установки: /usr/share/SberComponents/theme


