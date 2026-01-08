USE demo_db;

CREATE TABLE IF NOT EXISTS trn_payments (
    payment_id BIGINT PRIMARY KEY,
    order_id BIGINT,
    amount DECIMAL(10,2),
    paid_at TIMESTAMP
);