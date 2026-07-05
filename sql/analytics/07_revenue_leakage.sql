-- ============================================================
-- 07_revenue_leakage.sql
-- Purpose: quantify how much revenue is lost to cancellations
-- and returns, and break it down by payment mode / city /
-- category so the loss is actionable, not just a headline %.
-- ============================================================

DROP VIEW IF EXISTS vw_revenue_leakage_status;
CREATE VIEW vw_revenue_leakage_status AS
SELECT
  order_status,
  COUNT(DISTINCT order_id)                                              AS order_count,
  ROUND(SUM(total_amount), 2)                                           AS revenue,
  ROUND(100.0 * SUM(total_amount) / SUM(SUM(total_amount)) OVER (), 2)  AS pct_of_total_revenue
FROM fact_orders
GROUP BY order_status;

DROP VIEW IF EXISTS vw_leakage_by_payment_mode;
CREATE VIEW vw_leakage_by_payment_mode AS
-- NOTE: fact_orders grain = one row per order LINE ITEM (~2.31 items/order
-- on average). Counting must therefore use COUNT(DISTINCT order_id) scoped
-- by status, not SUM(CASE WHEN ... THEN 1 ELSE 0 END), or orders with
-- multiple line items get double/triple-counted in the numerator while the
-- denominator (COUNT(DISTINCT order_id)) still counts them once. The
-- previous version of this view had exactly that bug, which inflated every
-- rate below by ~2.3x and changed the ranking across payment modes.
SELECT
  payment_mode,
  COUNT(DISTINCT order_id) AS total_orders,
  COUNT(DISTINCT CASE WHEN order_status = 'Cancelled' THEN order_id END) AS cancelled_orders,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN order_status = 'Cancelled' THEN order_id END)
    / COUNT(DISTINCT order_id), 2) AS cancellation_rate_pct,
  COUNT(DISTINCT CASE WHEN order_status = 'Returned' THEN order_id END) AS returned_orders,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN order_status = 'Returned' THEN order_id END)
    / COUNT(DISTINCT order_id), 2) AS return_rate_pct
FROM fact_orders
GROUP BY payment_mode
ORDER BY cancellation_rate_pct DESC;

DROP VIEW IF EXISTS vw_leakage_by_city;
CREATE VIEW vw_leakage_by_city AS
SELECT
  city,
  COUNT(DISTINCT order_id) AS total_orders,
  ROUND(SUM(CASE WHEN order_status IN ('Cancelled','Returned') THEN total_amount ELSE 0 END), 2) AS revenue_lost,
  ROUND(SUM(total_amount), 2) AS total_revenue,
  ROUND(100.0 * SUM(CASE WHEN order_status IN ('Cancelled','Returned') THEN total_amount ELSE 0 END)
    / SUM(total_amount), 2) AS leakage_pct
FROM fact_orders
GROUP BY city
ORDER BY leakage_pct DESC;
