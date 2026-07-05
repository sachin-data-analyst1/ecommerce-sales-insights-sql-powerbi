-- ============================================================
-- 03_dim_tables.sql
-- Purpose: conformed dimensions for the star schema.
-- ============================================================

DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer AS
SELECT
  customer_id,
  customer_name,
  gender,
  city,
  state,
  signup_date
FROM stg_customers;

DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product AS
SELECT
  product_id,
  product_name,
  brand,
  category,
  sub_category,
  price
FROM stg_products;

DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date AS
SELECT DISTINCT
  order_date                                   AS date,
  CAST(STRFTIME('%Y', order_date) AS INTEGER)  AS year,
  CAST(STRFTIME('%m', order_date) AS INTEGER)  AS month,
  CASE CAST(STRFTIME('%m', order_date) AS INTEGER)
    WHEN 1 THEN 'January' WHEN 2 THEN 'February' WHEN 3 THEN 'March'
    WHEN 4 THEN 'April' WHEN 5 THEN 'May' WHEN 6 THEN 'June'
    WHEN 7 THEN 'July' WHEN 8 THEN 'August' WHEN 9 THEN 'September'
    WHEN 10 THEN 'October' WHEN 11 THEN 'November' WHEN 12 THEN 'December'
  END                                           AS month_name,
  ((CAST(STRFTIME('%m', order_date) AS INTEGER) - 1) / 3) + 1 AS quarter
FROM stg_orders;

CREATE UNIQUE INDEX idx_dim_customer_id ON dim_customer(customer_id);
CREATE UNIQUE INDEX idx_dim_product_id  ON dim_product(product_id);
CREATE UNIQUE INDEX idx_dim_date_date   ON dim_date(date);
