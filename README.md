# Обработка и анализ данных в Yandex Cloud: от загрузки до визуализации
## Часть 1. Анализ транзакционных данных с использованием Hive в кластере Yandex Data Proc.
### 1. Подготовка данных
Создаем кластер Yandex Data Processing. Файлы предварительно загружаем в Object Storage в бакет study-backet папку data в подпапки одноименными файлам:
- `transactions_v2.csv` - данные о транзакциях
- `logs_v2.txt` - логи транзакций

### 2. Запуск кластера 
### 3. Настройка DBeaver
#### 3.1. Подлкючение к Hive
*	Тип: `Apache Hive`
*	Хост: `публичный-IP-мастер-ноды`
*	Метод авторизации: `Публичный ключ`
#### 3.2. Создание таблиц в DBeaver
```
-- Таблица транзакций
CREATE EXTERNAL TABLE transactions_v2 (
  transaction_id INT,
  user_id INT,
  amount DOUBLE,
  currency STRING,
  transaction_date TIMESTAMP,
  is_fraud INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3a://study-backet/data/transactions_v2/'
TBLPROPERTIES ("skip.header.line.count"="1");

-- Таблица логов
CREATE EXTERNAL TABLE logs_v2 (
  log_id INT,
  transaction_id INT,
  category STRING,
  log_message STRING,
  log_timestamp TIMESTAMP
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3a://study-backet/data/logs_v2/'
TBLPROPERTIES ("skip.header.line.count"="1");
```
![backet_yandex](https://github.com/katrinnaya/SN_Palamarchuk/blob/hw_yandex_cloud/hive/photos/screen1.png)

#### 3.3. Проверка загрузки данных
```
-- Проверка транзакций 
SELECT * FROM transactions_v2 LIMIT 10;
```
```
-- Проверка логов 
SELECT * FROM logs_v2 LIMIT 10;
-- Проверка количества
SELECT COUNT(*) AS total_transactions FROM transactions_v2;
SELECT COUNT(*) AS total_logs FROM logs_v2;
```
### 4. Выполнение задания. SQL-запросы
#### 4.1. Фильтрация валют
Считаем количество, сумму и средний размер транзакций для указанных валют.
```
SELECT 
    currency,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount
FROM transactions_v2
WHERE currency IN ('USD', 'EUR', 'RUB') -- Фильтр по валютам
GROUP BY currency
ORDER BY total_amount DESC;
```
Результат представлен в 

