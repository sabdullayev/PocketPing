# PocketPing — Журнал фичей и изменений (FEATURES_LOG.md)

> **Назначение документа:** Фиксация всех добавленных фичей, архитектурных этапов и изменений. Позволяет любому разработчику или ИИ быстро понять текущее состояние проекта: что уже работает, как это устроено и что предстоит сделать.

---

## Статус разработки (Roadmap)

- [x] **Этап 0:** Инициализация проекта, базовая Clean Architecture структура папок, архитектурная документация.
- [x] **Этап 1 (MVP):** 
  - Сетевое ядро `DioClient` (замер миллисекунд через `Stopwatch`, размер ответа в байтах/KB, авто-обход самоподписанных SSL-сертификатов для dev-серверов).
  - Умный **Request Builder** (HTTP-методы с цветными плашками, авто-парсинг Query-параметров, Headers, Bearer Auth, Body JSON/Raw со сниппетами и Beautify).
  - Киллер-фича: **cURL Parser** из буфера обмена в 1 тап (`CurlParser.parse`).
  - **Response Viewer** (панель метрик, подсветка синтаксиса JSON, Raw, заголовки, копирование тела ответа).
  - Фоновый сервис `JsonIsolateService.formatJson()` на базе `Isolate.run()`.
  - Unit-тесты и Smoke-тесты.
- [x] **Этап 2 (Хранение: Локальная база данных, История и Коллекции):**
  - Подключение локальной NoSQL базы данных **Hive** (`hive_flutter`).
  - **Автоматическая история запросов (`features/history`)**:
    - Сохранение каждого отправленного запроса с метриками (статус, ms, KB, время).
    - Экран `HistoryScreen` с живым поиском/фильтрацией по URL и HTTP-методу.
    - Быстрый переход: тап по любому запросу из истории мгновенно загружает его в конструктор.
    - Очистка истории и удаление отдельных записей.
  - **Коллекции и папки (`features/collections`)**:
    - Создание пользовательских папок (напр. «Auth API», «Shop Backend»).
    - Диалог быстрого сохранения `SaveToCollectionDialog` прямо из конструктора запросов.
    - Экран `CollectionsScreen` с раскрывающимися папками-аккордеонами и списком запросов.
    - Удаление папок и отдельных запросов.
  - **Главная навигация (`features/home`)**:
    - Нижняя панель навигации `MainNavigationShell` (Material 3) с вкладками `Ping`, `History`, `Collections`.
- [x] **Этап 3 (Киллер-фичи: Переменные окружения / Environments):**
  - Поддержка переменных окружения `{{base_url}}`, `{{token}}`, `{{user_id}}` и др.
  - Хранение в Hive (`environments_box`) с предзаполненными окружениями (`Development` и `Production`).
  - Юзкейс `SubstituteEnvVariablesUseCase` для автоматической замены переменных во всех слоях запроса (URL, Query, Headers, Bearer, Body) без модификации исходного шаблона в редакторе.
  - Компоненты UI: `EnvironmentSelectorWidget` (активный бейдж вверху экрана) и `EnvironmentsManagerDialog` (редактор окружений и переменных).
  - Unit-тесты подстановки переменных (`test/env_variables_test.dart`).
- [ ] **Этап 4 (Продвинутый уровень: JSON Tree & Health Check):** 
  - Интерактивное сворачиваемое дерево JSON (JSON Tree View) с копированием пути к полю (напр. `data.users[0].id`).
  - Фоновый Health Check серверов через `workmanager` + локальные пуш-уведомления при сбоях.

---

## Журнал изменений (Changelog)

### [2026-10-27] — Этап 3: Переменные окружения (Environments)
- **Статус:** Выполнено, протестировано (`flutter analyze` — 0 issues, `flutter test` — 6 passed).
- **Ключевые файлы:**
  - `lib/features/environments/` — сущности `EnvironmentEntity` и `EnvironmentVariable`, Hive-источник `EnvironmentsLocalDataSourceImpl`, юзкейсы `SubstituteEnvVariablesUseCase`, BLoC `EnvironmentsBloc`.
  - `lib/features/environments/presentation/widgets/` — `EnvironmentSelectorWidget` и `EnvironmentsManagerDialog`.
  - `lib/features/request_builder/presentation/bloc/request_builder_bloc.dart` — внедрение авто-подстановки переменных окружения перед сетевым вызовом.
  - `test/env_variables_test.dart` — тесты юзкейса замены переменных.

### [2026-10-27] — Этап 2: Локальная БД (Hive), История запросов, Коллекции и Главная навигация
- **Статус:** Выполнено, протестировано.
- Добавлена история запросов, коллекции, папки и нижняя панель навигации `MainNavigationShell`.

### [2026-10-27] — Этап 1: Сетевое ядро, Request Builder, cURL-импорт и Response Viewer
- **Статус:** Выполнено, протестировано.
- Реализованы: `DioClient`, `CurlParser`, `RequestBuilderBloc`, `MetricsBarWidget`, `ResponseBodyView`, `JsonIsolateService`.

### [2026-10-27] — Этап 0: Инициализация проекта и Clean Architecture структура
- **Статус:** Выполнено.
- Инициализирован проект Flutter, созданы папки Clean Architecture, написана документация `ARCHITECTURE.md` и `FEATURES_LOG.md`.
