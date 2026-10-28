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
    - Нижняя панель навигации `MainNavigationShell` (Material 3) с вкладками `Ping`, `History`, `Collections`, `Monitor`.
- [x] **Этап 3 (Киллер-фичи: Переменные окружения / Environments):**
  - Поддержка переменных окружения `{{base_url}}`, `{{token}}`, `{{user_id}}` и др.
  - Хранение в Hive (`environments_box`) с предзаполненными окружениями (`Development` и `Production`).
  - Юзкейс `SubstituteEnvVariablesUseCase` для автоматической замены переменных во всех слоях запроса (URL, Query, Headers, Bearer, Body) без модификации исходного шаблона в редакторе.
  - Компоненты UI: `EnvironmentSelectorWidget` (активный бейдж вверху экрана) и `EnvironmentsManagerDialog` (редактор окружений и переменных).
  - Unit-тесты подстановки переменных (`test/env_variables_test.dart`).
- [x] **Этап 4 (Продвинутый уровень: JSON Tree & Health Check):** 
  - **Интерактивное сворачиваемое дерево JSON (`JsonTreeView`)**:
    - Раскрытие/сворачивание объектов `{}` и массивов `[]` со счетчиками элементов.
    - Цветовая дифференциация типов (String — зеленый, Number — оранжевый, Boolean — фиолетовый, Null — серый).
    - Долгое нажатие (Long-press) на любой узел открывает меню с копированием **значения** или **точного JSON-пути** (например `data.users[0].id`).
    - Обработка в отдельном фоновом потоке Dart через `Isolate.run()`.
  - **Фоновый Health Check монитор (`features/monitor`)**:
    - Добавление серверов для постоянного пинга с настройкой интервала (15, 30, 60 мин).
    - Ручной пинг любого сервера или всех сразу с замером времени и статус-кода.
    - Фоновый процесс Android/iOS через `workmanager` (`BackgroundPingService`).
    - Отправка громких локальных пуш-уведомлений через `flutter_local_notifications` (`NotificationService`), если сервер ответил ошибкой (не 200) или упал по таймауту.
    - Разрешения на работу с сетью, HTTP-трафиком (`usesCleartextTraffic`) и уведомлениями в `AndroidManifest.xml`.

---

## Журнал изменений (Changelog)

### [2026-10-28] — Этап 4: Интерактивное дерево JSON (JSON Tree) и Фоновый Health Check
- **Статус:** Выполнено, протестировано (`flutter analyze` — 0 issues, `flutter test` — 6 passed).
- **Ключевые файлы:**
  - `lib/features/response_viewer/presentation/widgets/json_tree_view.dart` — компонент интерактивного сворачиваемого дерева JSON с подсветкой типов и копированием пути / значения.
  - `lib/core/services/notification_service.dart` — сервис локальных пуш-уведомлений о падении серверов.
  - `lib/core/services/background_ping_service.dart` — фоновый планировщик задач Workmanager для фонового пинга.
  - `lib/features/monitor/` — модуль Health Check монитора (сущности, репозитории, BLoC, карточки серверов со статусами).
  - `android/app/src/main/AndroidManifest.xml` — разрешения INTERNET, POST_NOTIFICATIONS и `usesCleartextTraffic`.

### [2026-10-27] — Этап 3: Переменные окружения (Environments)
- **Статус:** Выполнено, протестировано.
- Сущности и юзкейсы `SubstituteEnvVariablesUseCase`, BLoC, переключатель `EnvironmentSelectorWidget` и диалог редактирования `EnvironmentsManagerDialog`.

### [2026-10-27] — Этап 2: Локальная БД (Hive), История запросов, Коллекции и Главная навигация
- **Статус:** Выполнено, протестировано.
- Реализованы история, коллекции, папки, `MainNavigationShell`.

### [2026-10-27] — Этап 1: Сетевое ядро, Request Builder, cURL-импорт и Response Viewer
- **Статус:** Выполнено, протестировано.
- Реализованы: `DioClient`, `CurlParser`, `RequestBuilderBloc`, `MetricsBarWidget`, `ResponseBodyView`, `JsonIsolateService`.

### [2026-10-27] — Этап 0: Инициализация проекта и Clean Architecture структура
- **Статус:** Выполнено.
- Инициализирован проект Flutter, Clean Architecture структура, `ARCHITECTURE.md` и `FEATURES_LOG.md`.
