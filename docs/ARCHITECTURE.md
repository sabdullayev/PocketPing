# PocketPing — Архитектурная документация (ARCHITECTURE.md)

> **Назначение документа:** Быстрый ввод в проект для разработчиков и ИИ-ассистентов. Описывает структуру, используемый стек, принципы разделения ответственности и правила расширения кодовой базы.

---

## 1. О проекте PocketPing

**PocketPing** — карманный мобильный Postman и сетевой сканер/монитор.
- **Цель:** Быстрое тестирование HTTP/REST API с мобильного устройства без необходимости открывать ноутбук.
- **Ключевые фичи:** 
  1. Умный конструктор запросов (Query-параметры, Headers, Bearer Auth, Body JSON / Form-Data).
  2. Импорт cURL из буфера в один тап (RegEx парсер).
  3. Просмотр ответа и метрик (статус, ms через Stopwatch, KB, Json Tree View через `Isolate.run()`).
  4. Коллекции и переменные окружения (`{{base_url}}`, `{{token}}`, Dev/Prod режимы).
  5. Фоновый Health Check серверов с локальными пуш-уведомлениями при падении.

---

## 2. Стек технологий

| Направление | Инструмент / Пакет | Роль в проекте |
| :--- | :--- | :--- |
| **Фреймворк** | Flutter (Dart 3.x) | Кроссплатформенная мобильная разработка |
| **Архитектура** | Clean Architecture (Feature-First) | Разделение бизнес-логики, данных и UI |
| **Стейт-менеджмент** | `flutter_bloc` | Предсказуемый однонаправленный поток состояний |
| **DI (Service Locator)** | `get_it` | Инъекция зависимостей без жесткой связности |
| **Сетевой клиент** | `dio` | HTTP-запросы, интерцепторы, замер таймингов, обход SSL |
| **Локальная БД** | `hive_ce` / `hive` | Хранение истории запросов, коллекций и переменных |
| **Многопоточность** | `Isolate.run()` | Тяжелый парсинг и форматирование больших JSON ответов |
| **Фоновые задачи** | `workmanager` + `flutter_local_notifications` | Фоновый пинг серверов и алерты |
| **Синтаксис / UI** | `flutter_highlight` | Подсветка JSON/XML в ответе сервера |

---

## 3. Архитектурный подход: Feature-First Clean Architecture

Проект разбит на независимые фичи в директории `lib/features/` и общее ядро в `lib/core/`.
Каждая фича строго следует 3 слоям Clean Architecture:

```
feature_name/
├── data/           # Слой данных (внешний мир: API, база данных, парсинг DTO)
│   ├── datasources/# Источники данных (Local/Remote)
│   ├── models/     # DTO / модели (маппинг JSON <-> Entity)
│   └── repositories/# Реализация репозиториев из Domain слоя
├── domain/         # Слой бизнес-логики (чистый Dart, без Flutter и внешних библиотек)
│   ├── entities/   # Чистые бизнес-сущности
│   ├── repositories/# Абстрактные интерфейсы репозиториев (контракты)
│   └── usecases/   # Сценарии использования (Single Responsibility)
└── presentation/   # Слой отображения (UI и управление состоянием)
    ├── bloc/       # BLoC / Cubit (Events, States, Bloc)
    ├── screens/    # Экранные виджеты (страницы)
    └── widgets/    # Локальные переиспользуемые UI-компоненты
```

### Правило направления зависимостей:
`Presentation` ➔ зависит от ➔ `Domain`  
`Data` ➔ зависит от ➔ `Domain`  
`Domain` ➔ **НИ ОТ КОГО НЕ ЗАВИСИТ** (содержит только чистую логику приложения).

---

## 4. Структура директорий проекта

```
PocketPing/
├── docs/
│   ├── ARCHITECTURE.md            # Данный архитектурный документ
│   └── FEATURES_LOG.md            # Лог реализованных фичей и изменений
├── lib/
│   ├── app.dart                   # Корневой MaterialApp, MultiBlocProvider, темы
│   ├── main.dart                  # Точка входа, инициализация DI и Hive
│   ├── core/                      # Общий код для всех фичей
│   │   ├── constants/             # Цвета, размеры, строковые константы
│   │   ├── di/                    # Регистрация зависимостей в GetIt
│   │   ├── errors/                # Failure и Exception классы
│   │   ├── network/               # Конфигурация Dio, интерцепторы, SSL bypass
│   │   ├── services/              # Сервисы уведомлений, изоляты, буфер обмена
│   │   ├── theme/                 # Стили, темная/светлая тема
│   │   └── utils/                 # cURL парсер, форматтеры, валидаторы
│   └── features/                  # Модули приложения
│       ├── home/                  # Главная навигация (MainNavigationShell)
│       ├── request_builder/       # Конструктор HTTP-запросов и импорт cURL
│       ├── response_viewer/       # Просмотр ответа, метрик, дерево JSON
│       ├── collections/           # Папки, коллекции сохраненных запросов (Hive)
│       ├── environments/          # Переменные ({{base_url}}) и переключение Dev/Prod
│       ├── history/               # История отправленных запросов (Hive)
│       └── monitor/               # Фоновый пинг серверов (Health Check)
```

---

## 5. Поток данных (Data Flow)

1. **User Action:** Пользователь вводит URL или нажимает «Отправить».
2. **UI -> BLoC:** Виджет шлет событие (напр. `SendHttpRequestEvent`) в `RequestBuilderBloc`.
3. **BLoC -> UseCase:** BLoC заменяет переменные окружения через `SubstituteEnvVariablesUseCase` и вызывает `ExecuteRequestUseCase`.
4. **UseCase -> Repository:** `ExecuteRequestUseCase` вызывает `RequestRepository.execute(request)`.
5. **Repository -> Network/DataSource:** `RequestRepositoryImpl` использует `DioClient` с замером времени через `Stopwatch`.
6. **Data -> Isolate:** Сырой JSON ответ парсится через `Isolate.run()` без блокировки UI.
7. **State Update:** BLoC эмитит `RequestSuccessState` с сущностью `ResponseEntity`.
8. **UI Render:** `ResponseViewerScreen` отрисовывает статус, тайминг, размер и раскрывающееся дерево JSON.

---

## 6. Памятка для нового разработчика / ИИ

1. **Не смешивать слои:** Логику запросов не писать в виджетах; виджеты общаются только через BLoC.
2. **Изоляция тяжелых задач:** Любой парсинг ответов больше 50KB выносить в `Isolate.run()`.
3. **Регистрация в DI:** Новые BLoC, UseCase, Repository регистрировать в `lib/core/di/injection_container.dart`.
4. **Обновление логов:** При добавлении или изменении фичи обязательно делать краткую запись в `docs/FEATURES_LOG.md`.
