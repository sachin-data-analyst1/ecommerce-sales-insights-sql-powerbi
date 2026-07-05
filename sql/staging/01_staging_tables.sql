-- ============================================================
-- 01_staging_tables.sql
-- Purpose: isolate raw ingestion from cleaned/typed data so any
-- upstream schema drift only ever breaks this one layer.
-- ============================================================

DROP TABLE IF EXISTS stg_customers;
CREATE TABLE stg_customers AS
SELECT
  CAST(customer_id AS INTEGER)   AS customer_id,
  TRIM(customer_name)            AS customer_name,
  TRIM(gender)                   AS gender,
  TRIM(city)                     AS city,
  TRIM(state)                    AS state,
  DATE(signup_date)              AS signup_date
FROM raw_customers;

DROP TABLE IF EXISTS stg_orders;
CREATE TABLE stg_orders AS
SELECT
  CAST(order_id AS INTEGER)      AS order_id,
  CAST(customer_id AS INTEGER)   AS customer_id,
  DATE(order_date)               AS order_date,
  TRIM(order_status)             AS order_status,
  TRIM(payment_mode)             AS payment_mode
FROM raw_orders;

DROP TABLE IF EXISTS stg_products;
CREATE TABLE stg_products AS
SELECT
  CAST(product_id AS INTEGER)    AS product_id,
  TRIM(product_name)             AS product_name,
  TRIM(brand)                    AS brand,
  TRIM(category)                 AS category,
  TRIM(sub_category)             AS sub_category,
  CAST(price AS REAL)            AS price
FROM raw_products;

DROP TABLE IF EXISTS stg_order_items;
CREATE TABLE stg_order_items AS
SELECT
  CAST(order_item_id AS INTEGER) AS order_item_id,
  CAST(order_id AS INTEGER)      AS order_id,
  CAST(product_id AS INTEGER)    AS product_id,
  CAST(quantity AS INTEGER)      AS quantity,
  CAST(total_amount AS REAL)     AS total_amount
FROM raw_order_items;

CREATE INDEX idx_stg_orders_customer   ON stg_orders(customer_id);
CREATE INDEX idx_stg_order_items_order ON stg_order_items(order_id);
CREATE INDEX idx_stg_order_items_prod  ON stg_order_items(product_id);
