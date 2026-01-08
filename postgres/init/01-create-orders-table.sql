CREATE TABLE IF NOT EXISTS public.trn_customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

-- Вставляем 10 клиентов
INSERT INTO public.trn_customers (name)
SELECT 'Customer ' || g
FROM generate_series(1, 10) AS g;

CREATE TABLE IF NOT EXISTS public.trn_orders (
    order_id BIGINT PRIMARY KEY,
    customer_id INT,
    order_ts TIMESTAMP,
    total_amount NUMERIC(10,2)
);