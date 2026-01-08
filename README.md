# Итоговая домашняя работа Trino + PostgreSQL + MySQL + Iceberg + Визуализация
## Общая архитектура
* `PostgreSQL` — источник данных 1;
* `MySQL` — источник данных 2;
* `Trino` — координатор, который подключится к обеим СУБД как к каталогам; 
* `MinIO` — хранилище для Iceberg;
* `Jupyter Notebook` — клиент для выполнения всех шагов.
## Шаги выполнения
* Уровень 1: Подключения
* Уровень 2: Агрегация данных
* Уровень 3: Визуализация
* Уровень 4: Сохранение в Iceberg

## Реализация
### Шаг 1. Создание окружения
```zsh
python3 -m venv .venv
```
```zsh
source .venv/bin/activate
```
### Шаг 2. Установка Python-зависимостей
```zsh
pip install psycopg2-binary mysql-connector-python trino pandas matplotlib
```
### Шаг 3. Запуск Docker-контейнеров
```zsh
docker-compose up -d
```
### Шаг 4. Проверка работы Trino
* UI: `http://localhost:8080`
* Терминал: `docker-compose ps`
### Шаг 5. Запуск Jupyter Notebook
см. файл [final_homework.ipynb](final_homework.ipynb)
### Шаг 6. Остановка контейнера
```zsh
docker-compose down
```
