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

На текущий момент устанавливаются:

```text
cg
s3-backup-rotate.sh
```

## 3. Структура репозитория

```text
server-scripts/
├── scripts/
│   ├── cg.sh
│   └── s3-backup-rotate.sh
└── install.sh
```

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

Проверяем установленные `.sh`-скрипты:

```bash
ls -lah /usr/local/bin/server-scripts/*.sh
```

Проверяем `cg`:

```bash
ls -lah /usr/local/bin/server-scripts/cg
```

## 6. Проверка PATH

После установки для текущей SSH-сессии можно применить настройки:

```bash
source /etc/profile.d/server-scripts.sh
```

Проверяем доступность `cg`:

```bash
which cg
```

Ожидаемый результат:

```text
/usr/local/bin/server-scripts/cg
```

## 7. Проверка `cg`

Запускаем:

```bash
cg
```

Должна появиться справка:

```text
Usage:
  cg new <component>
  cg status [component]
  cg pull [component]
  cg commit <component> "message"
  cg push [component]
```

## 8. Обновление скриптов

Для повторной установки и обновления скриптов достаточно снова выполнить:

```bash
curl -fsSL \
    https://raw.githubusercontent.com/palma-yasen/server-scripts/main/install.sh \
    | bash
```

Установщик повторно скачает актуальные версии скриптов из репозитория.

## 9. Расположение установленных файлов

```text
/usr/local/bin/server-scripts/
```

Файл настройки `PATH`:

```text
/etc/profile.d/server-scripts.sh
```
