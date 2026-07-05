-- ============================================================
-- 04_fact_orders.sql
-- Purpose: grain = one row per order line item. Joins out to
-- dim_customer, dim_product, dim_date. This is the single
-- source every analytics view and every Power BI visual
-- should read from.
-- ============================================================

DROP TABLE IF EXISTS fact_orders;
CREATE TABLE fact_orders AS
SELECT
  oi.order_item_id,
  o.order_id,
  o.customer_id,
  oi.product_id,
  o.order_date,
  o.order_status,
  o.payment_mode,
  oi.quantity,
  oi.total_amount,
  p.product_name,
  p.category,
  p.sub_category,
  p.brand,
  c.city,
  c.state
FROM stg_order_items oi
JOIN stg_orders   o ON oi.order_id   = o.order_id
JOIN stg_products p ON oi.product_id = p.product_id
JOIN stg_customers c ON o.customer_id = c.customer_id;

CREATE INDEX idx_fact_orders_customer ON fact_orders(customer_id);
CREATE INDEX idx_fact_orders_status   ON fact_orders(order_status);
CREATE INDEX idx_fact_orders_date     ON fact_orders(order_date);
