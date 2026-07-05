-- ============================================================
-- 09_kpi_summary_and_refresh.sql
-- Purpose: single source-of-truth KPI view for the README/
-- executive dashboard, plus a documented rebuild order.
-- SQLite has no stored procedures, so the "procedure" here is
-- expressed as an ordered script — on Postgres/MySQL this
-- logic would instead live in a CALL-able stored procedure
-- (see the commented Postgres version below).
-- ============================================================

DROP VIEW IF EXISTS vw_kpi_summary;
CREATE VIEW vw_kpi_summary AS
SELECT
  COUNT(DISTINCT order_id)                                          AS total_orders,
  COUNT(DISTINCT customer_id)                                       AS total_customers,
  ROUND(SUM(total_amount), 2)                                       AS total_revenue,
  ROUND(SUM(CASE WHEN order_status = 'Delivered' THEN total_amount ELSE 0 END), 2) AS net_revenue,
  ROUND(SUM(CASE WHEN order_status IN ('Cancelled','Returned') THEN total_amount ELSE 0 END), 2) AS revenue_lost,
  ROUND(100.0 * SUM(CASE WHEN order_status IN ('Cancelled','Returned') THEN total_amount ELSE 0 END)
    / SUM(total_amount), 2)                                         AS revenue_leakage_pct,
  ROUND(SUM(total_amount) * 1.0 / COUNT(DISTINCT order_id), 2)      AS avg_order_value
FROM fact_orders;

-- Repeat vs new customer revenue split
DROP VIEW IF EXISTS vw_repeat_vs_new_revenue;
CREATE VIEW vw_repeat_vs_new_revenue AS
WITH order_counts AS (
  SELECT customer_id, COUNT(DISTINCT order_id) AS orders
  FROM fact_orders
  WHERE order_status = 'Delivered'
  GROUP BY customer_id
),
customer_type AS (
  SELECT customer_id, CASE WHEN orders > 1 THEN 'Repeat' ELSE 'New' END AS customer_type
  FROM order_counts
)
SELECT
  ct.customer_type,
  COUNT(DISTINCT ct.customer_id)             AS customers,
  ROUND(SUM(f.total_amount), 2)              AS revenue,
  ROUND(100.0 * SUM(f.total_amount) / SUM(SUM(f.total_amount)) OVER (), 2) AS pct_of_revenue
FROM customer_type ct
JOIN fact_orders f ON ct.customer_id = f.customer_id AND f.order_status = 'Delivered'
GROUP BY ct.customer_type;

-- ------------------------------------------------------------
-- Rebuild order (run in this sequence any time raw data refreshes):
--   1. sql/staging/01_staging_tables.sql
--   2. sql/data_quality/02_validation_checks.sql   (inspect output before continuing)
--   3. sql/dimensions/03_dim_tables.sql
--   4. sql/facts/04_fact_orders.sql
--   5. sql/analytics/05_rfm_segmentation.sql
--   6. sql/analytics/06_cohort_retention.sql
--   7. sql/analytics/07_revenue_leakage.sql
--   8. sql/analytics/08_product_ranking.sql
--   9. sql/procedures/09_kpi_summary_and_refresh.sql
-- ------------------------------------------------------------

-- Postgres equivalent, for reference (not runnable in SQLite):
-- CREATE OR REPLACE PROCEDURE refresh_fact_orders()
-- LANGUAGE plpgsql AS $$
-- BEGIN
--   TRUNCATE fact_orders;
--   INSERT INTO fact_orders
--   SELECT oi.order_item_id, o.order_id, o.customer_id, oi.product_id,
--          o.order_date, o.order_status, o.payment_mode, oi.quantity,
--          oi.total_amount, p.category, p.sub_category, p.brand, c.city, c.state
--   FROM stg_order_items oi
--   JOIN stg_orders o ON oi.order_id = o.order_id
--   JOIN stg_products p ON oi.product_id = p.product_id
--   JOIN stg_customers c ON o.customer_id = c.customer_id;
-- END;
-- $$;
