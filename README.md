# Обработка и анализ данных в Yandex Cloud: от загрузки до визуализации
## Часть 1. Анализ транзакционных данных с использованием Hive в кластере Yandex Data Proc.
### 1. Подготовка данных
Создаем кластер Yandex Data Processing. Файлы предварительно загружаем в Object Storage в бакет `study-backet` папку `data` в подпапки одноименные файлам:
- `transactions_v2.csv` - данные о транзакциях
- `logs_v2.txt` - логи транзакций

### 2. Запуск кластера 
### 3. Настройка DBeaver
#### 3.1. Подключение к Hive
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
Результат представлен в файле `req1.txt` папки `data`.
|currency|transaction_count|total_amount|avg_amount|
|--------|-----------------|------------|----------|
|RUB     |3                |11 000,5    |3 666,83  |
|USD     |2                |196,4       |98,2      |
|EUR     |2                |150,95      |75,48     |

#### 4.2. Анализ мошеннических транзакций
Сравниваем показатели нормальных и мошеннических операций.
```
SELECT 
    CASE 
        WHEN is_fraud = 1 THEN 'Мошенническая' 
        ELSE 'Нормальная' 
    END AS transaction_type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount,
    MAX(amount) AS max_amount,
    MIN(amount) AS min_amount
FROM transactions_v2
GROUP BY is_fraud
ORDER BY transaction_type;
```
Результат представлен в файле `req2.txt` папки `data`.
|transaction_type|transaction_count|total_amount|avg_amount|max_amount|min_amount|
|----------------|-----------------|------------|----------|----------|----------|
|Мошенническая   |3                |9 865,75    |3 288,58  |7500.00   |2300.00   |
|Нормальная      |4                |1 482,1     |370,53    |85.20     |1200.50   |
#### 4.3. Группировка по датам
Анализируем активность по дням.
```
SELECT 
    DATE(transaction_date) AS transaction_day,
    COUNT(*) AS daily_count,
    ROUND(SUM(amount), 2) AS daily_total,
    ROUND(AVG(amount), 2) AS daily_avg,
    COUNT(DISTINCT user_id) AS unique_users
FROM transactions_v2
GROUP BY DATE(transaction_date)
ORDER BY transaction_day;
```
Результат представлен в файле `req3.txt` папки `data`.
|transaction_day|daily_count|daily_total|daily_avg|unique_users|
|---------------|-----------|-----------|---------|------------|
|2023-01-15     |2          |7 650,5    |3 825,25 |2           |
|2023-01-16     |2          |2 385,2    |1 192,6  |2           |
|2023-01-17     |1          |45,9       |45,9     |1           |
|2023-01-18     |1          |1 200,5    |1 200,5  |1           |
|2023-01-19     |1          |65,75      |65,75    |1           |
#### 4.4. Анализ по временным интервалам
Выводим распределение транзакций по часам/дням/месяцам.
```
SELECT 
    HOUR(transaction_date) AS hour_of_day,
    DAY(transaction_date) AS day_of_month,
    MONTH(transaction_date) AS month,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS hourly_volume
FROM transactions_v2
GROUP BY 
    HOUR(transaction_date), 
    DAY(transaction_date), 
    MONTH(transaction_date)
ORDER BY 
    month, day_of_month, hour_of_day;
```
Результат представлен в файле `req4.txt` папки `data`.
|hour_of_day|day_of_month|month|transaction_count|hourly_volume|
|-----------|------------|-----|-----------------|-------------|
|10         |15          |1    |1                |150,5        |
|11         |15          |1    |1                |7 500        |
|9          |16          |1    |1                |85,2         |
|14         |16          |1    |1                |2 300        |
|16         |17          |1    |1                |45,9         |
|12         |18          |1    |1                |1 200,5      |
|8          |19          |1    |1                |65,75        |
#### 4.5. JOIN с логами (анализ транзакций)
Связываем транзакции с логами, анализируем категории.
```
SELECT 
    t.transaction_id,
    t.user_id,
    t.amount,
    t.currency,
    COUNT(l.log_id) AS log_count,
    COLLECT_LIST(DISTINCT l.category) AS log_categories,
    SUM(CASE WHEN l.category = 'security' THEN 1 ELSE 0 END) AS security_checks
FROM transactions_v2 t
LEFT JOIN logs_v2 l ON t.transaction_id = l.transaction_id
GROUP BY 
    t.transaction_id, 
    t.user_id, 
    t.amount, 
    t.currency
ORDER BY log_count DESC
LIMIT 10;
```
Результат представлен в файле `req5.txt` папки `data`.
|transaction_id|user_id|amount |currency|log_count|log_categories        |security_checks|
|--------------|-------|-------|--------|---------|----------------------|---------------|
|1             |101    |150.50 |USD     |2        |["payment","security"]|1              |
|4             |101    |2300.00|RUB     |2        |["payment","security"]|1              |
|2             |102    |7500.00|RUB     |2        |["payment","security"]|1              |
|3             |103    |85.20  |EUR     |1        |["payment"]           |0              |
|5             |104    |45.90  |USD     |0        |[]                    |0              |
|6             |105    |1200.50|RUB     |0        |[]                    |0              |
|7             |102    |65.75  |EUR     |0        |[]                    |0              |
#### 4.6. Топ категорий логов
```
SELECT 
    category,
    COUNT(*) AS category_count,
    COUNT(DISTINCT transaction_id) AS unique_transactions
FROM logs_v2
GROUP BY category
ORDER BY category_count DESC;
```
Результат представлен в файле `req6.txt` папки `data`.
|category|category_count|unique_transactions|
|--------|--------------|-------------------|
|payment |4             |4                  |
|security|3             |3                  |
### Визуализация
![dashboard](https://github.com/katrinnaya/SN_Palamarchuk/blob/hw_yandex_cloud/hive/photos/dashboard.jpg)
* Анализ мошенничества
* Распределение логов по категориям
* Динамика транзакций
## Часть 2. ClickHouse
### 1. Подготовка данных
Создаем кластер ClickHouse. Файлы предварительно загружаем в Object Storage в бакет `study-backet` папку `data`:
- `orders` - данные о заказах
- `order_items` - данные о товарах в заказах
### 2. Запуск кластера 
### 3. Подключение к ClickHouse через WebSQL под `admin`
#### 3.2. Создание таблиц в WebSQL
```
-- Таблица заказов
CREATE TABLE orders (
    order_id UInt32,
    user_id UInt32,
    order_date DateTime,
    total_amount Decimal(10, 2),
    payment_status String,
    delivery_address String
) ENGINE = MergeTree()
ORDER BY (order_date, order_id);
```
```
-- Таблица товаров в заказах
CREATE TABLE order_items (
    item_id UInt32,
    order_id UInt32,
    product_id UInt32,
    quantity UInt32,
    price Decimal(10, 2),
    discount Decimal(5, 2)
) ENGINE = MergeTree()
ORDER BY (order_id, item_id);
```
![connect_to_clickhouse](https://github.com/katrinnaya/SN_Palamarchuk/blob/hw_yandex_cloud/clickhouse/images/connect_to_clickhouse.png)
#### 3.3. Наполнение таблиц 
```
INSERT INTO orders
SELECT * FROM s3(
    'https://storage.yandexcloud.net/study-backet/data/orders.csv',
    'CSVWithNames'
);
```
```
INSERT INTO order_items
SELECT * FROM s3(
    'https://storage.yandexcloud.net/study-backet/data/order_items.csv',
    'CSVWithNames'
);
```
#### 3.4. Проверка загрузки данных
```
-- Проверка количества строк
SELECT count() FROM orders;
SELECT count() FROM order_items;
```
```
-- Просмотр первых 5 записей
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_items LIMIT 5;
```
### 4. Выполнение задания. SQL-запросы
#### 4.1. Анализ по статусам платежей
```
SELECT 
    payment_status,
    count() AS orders_count,
    sum(total_amount) AS total_amount_sum,
    round(avg(total_amount), 2) AS avg_order_amount
FROM orders
GROUP BY payment_status
ORDER BY total_amount_sum DESC;
```
Результат представлен в файле `req1.txt` папки `data`.
#### 4.2. Анализ товаров в заказах
```
SELECT 
    o.order_id,
    o.user_id,
    COUNT(i.item_id) AS items_count,
    SUM(i.price * i.quantity) AS items_total,
    ROUND(AVG(i.price), 2) AS avg_item_price
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
GROUP BY o.order_id, o.user_id
ORDER BY items_total DESC
LIMIT 10;
```
Результат представлен в файле `req2.txt` папки `data`.
#### 4.3. Статистика по датам
```
SELECT 
    toDate(order_date) AS order_day,
    COUNT(*) AS orders_count,
    SUM(total_amount) AS daily_total
FROM orders
GROUP BY order_day
ORDER BY order_day;
```
Результат представлен в файле `req3.txt` папки `data`.
#### 4.4. Топ пользователей
```
SELECT 
    user_id,
    COUNT(*) AS orders_count,
    SUM(total_amount) AS total_spent,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
GROUP BY user_id
ORDER BY total_spent DESC
LIMIT 5;
```
Результат представлен в файле `req4.txt` папки `data`.
#### 4.5. Популярные товары
```
SELECT 
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(quantity * price) AS total_revenue
FROM order_items
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 10;
```
Результат представлен в файле `req5.txt` папки `data`.
