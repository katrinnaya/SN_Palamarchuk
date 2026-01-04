# Итоговая домашняя работа Trino + PostgreSQL + MySQL + Iceberg + Визуализация
## Общая архитектура
* `PostgreSQL` — источник данных 1;
* `MySQL` — источник данных 2;
* `Trino` — координатор, который подключится к обеим СУБД как к каталогам; 
* `Локальный файловый путь` — хранилище для Iceberg;
* `Jupyter Notebook` — клиент для выполнения всех шагов.
## Шаги выполнения
* Уровень 1: Подключения
* Уровень 2: Агрегация данных
* Уровень 3: Визуализация
* Уровень 4: Сохранение в Iceberg

## Реализация
### Шаг 1. Установка Python-зависимостей
```zsh
pip3 install jupyter pandas matplotlib seaborn trino
```
### Шаг 2. Запуск Docker-контейнеров
```zsh
docker-compose up -d
```
### Шаг 3. Проверка работы Trino
* UI: `http://localhost:8080`
* Терминал: `docker-compose ps`
### Шаг 4. Запуск Jupyter Notebook
см. файл `final_homework.ipynb`
### Шаг 5. Остановка контейнера
```zsh
docker-compose down
```
