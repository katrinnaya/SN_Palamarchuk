# Развёртывание S3-совместимого хранилища MinIO, подключение к нему из JupyterHub и базовые операции записи/чтения данных
## Шаги выполнения
### 1. Запуск MinIO через Docker Compose
```docker-compose up -d```
### 1.1. Проверка доступности
* UI: http://localhost:9001
* Логин: `minioadmin`
* Пароль: `minioadmin123`
### 2. Работа в JupyterHub
См. файл `hw_minio.ipynb`
#### Имена объектов:
* CSV: `students/students_data.csv`
* Parquet: `students/students_data.parquet`
