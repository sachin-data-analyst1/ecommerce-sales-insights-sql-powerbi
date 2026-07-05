-- ============================================================
-- 06_cohort_retention.sql
-- Purpose: group customers into monthly signup cohorts and
-- measure what % of each cohort placed an order in each
-- subsequent month. Business question: are we getting better
-- or worse at retaining customers over time?
-- ============================================================

DROP VIEW IF EXISTS vw_cohort_base;
CREATE VIEW vw_cohort_base AS
SELECT
  c.customer_id,
  STRFTIME('%Y-%m', c.signup_date) AS cohort_month,
  STRFTIME('%Y-%m', o.order_date)  AS order_month
FROM dim_customer c
JOIN fact_orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered';

DROP VIEW IF EXISTS vw_cohort_index;
CREATE VIEW vw_cohort_index AS
SELECT
  cohort_month,
  order_month,
  -- month index: 0 = signup month, 1 = one month after signup, etc.
  (CAST(STRFTIME('%Y', order_month || '-01') AS INTEGER) * 12 + CAST(STRFTIME('%m', order_month || '-01') AS INTEGER))
  - (CAST(STRFTIME('%Y', cohort_month || '-01') AS INTEGER) * 12 + CAST(STRFTIME('%m', cohort_month || '-01') AS INTEGER))
    AS month_index,
  COUNT(DISTINCT customer_id) AS active_customers
FROM vw_cohort_base
GROUP BY cohort_month, order_month;

DROP VIEW IF EXISTS vw_cohort_size;
CREATE VIEW vw_cohort_size AS
SELECT
  STRFTIME('%Y-%m', signup_date) AS cohort_month,
  COUNT(DISTINCT customer_id) AS cohort_size
FROM dim_customer
GROUP BY cohort_month;

DROP VIEW IF EXISTS vw_cohort_retention;
CREATE VIEW vw_cohort_retention AS
SELECT
  ci.cohort_month,
  ci.month_index,
  ci.active_customers,
  cs.cohort_size,
  ROUND(100.0 * ci.active_customers / cs.cohort_size, 2) AS retention_pct
FROM vw_cohort_index ci
JOIN vw_cohort_size cs ON ci.cohort_month = cs.cohort_month
WHERE ci.month_index >= 0
ORDER BY ci.cohort_month, ci.month_index;
