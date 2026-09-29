# Серверные скрипты

Набор скриптов для администрирования Linux-серверов.

## 1. Установка

Для установки используется `install.sh`.

```bash
curl -fsSL \
    https://raw.githubusercontent.com/palma-yasen/server-scripts/main/install.sh \
    | bash
```

Установщик:

* создаёт каталог `/usr/local/bin/server-scripts/`;
* устанавливает серверные скрипты;
* назначает скриптам права `755`;
* создаёт файл `/etc/profile.d/server-scripts.sh`;
* добавляет `/usr/local/bin/server-scripts` в `PATH`.

## 2. Установленные скрипты

После установки скрипты находятся в:

```text
/usr/local/bin/server-scripts/
```

Состав устанавливаемых скриптов определяется текущей версией `install.sh`.

## 3. Структура репозитория

```text
server-scripts/
├── scripts/
│   ├── ...
│   └── ...
└── install.sh
```

В каталоге `scripts/` находятся серверные скрипты, доступные для установки.

## 4. Основной URL

Файлы скриптов доступны по адресу:

```text
https://raw.githubusercontent.com/palma-yasen/server-scripts/main/scripts
```

## 5. Проверка установки

Проверяем каталог со скриптами:

```bash
ls -lah /usr/local/bin/server-scripts/
```

Проверяем установленные скрипты:

```bash
ls -lah /usr/local/bin/server-scripts/*
```

## 6. Проверка PATH

После установки для текущей SSH-сессии можно применить настройки:

```bash
source /etc/profile.d/server-scripts.sh
```

Проверяем доступность установленных команд:

```bash
echo "$PATH"
```

Каталог должен присутствовать в `PATH`:

```text
/usr/local/bin/server-scripts
```

## 7. Обновление скриптов

Для повторной установки и обновления скриптов достаточно снова выполнить:

```bash
curl -fsSL \
    https://raw.githubusercontent.com/palma-yasen/server-scripts/main/install.sh \
    | bash
```

Установщик повторно скачает актуальные версии скриптов из репозитория.

## 8. Расположение установленных файлов

Скрипты:

```text
/usr/local/bin/server-scripts/
```

Файл настройки `PATH`:

```text
/etc/profile.d/server-scripts.sh
```
