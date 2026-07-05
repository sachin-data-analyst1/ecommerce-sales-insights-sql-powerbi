-- ============================================================
-- 05_rfm_segmentation.sql
-- Purpose: score every customer on Recency, Frequency, Monetary
-- value using window functions, then bucket into segments.
-- Business question: which customers are most valuable, and
-- which are showing early churn risk?
-- ============================================================

DROP VIEW IF EXISTS vw_customer_rfm_base;
CREATE VIEW vw_customer_rfm_base AS
SELECT
  customer_id,
  MAX(order_date)                    AS last_order_date,
  COUNT(DISTINCT order_id)           AS frequency,
  SUM(total_amount)                  AS monetary,
  JULIANDAY((SELECT MAX(order_date) FROM fact_orders)) - JULIANDAY(MAX(order_date)) AS recency_days
FROM fact_orders
WHERE order_status = 'Delivered'
GROUP BY customer_id;

DROP VIEW IF EXISTS vw_customer_rfm_scored;
CREATE VIEW vw_customer_rfm_scored AS
SELECT
  customer_id,
  recency_days,
  frequency,
  monetary,
  -- 5 = best (most recent / most frequent / highest spend), 1 = worst
  NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
  NTILE(5) OVER (ORDER BY frequency ASC)     AS f_score,
  NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score
FROM vw_customer_rfm_base;

DROP VIEW IF EXISTS vw_customer_rfm_segment;
CREATE VIEW vw_customer_rfm_segment AS
SELECT
  *,
  CASE
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
    WHEN r_score >= 3 AND f_score >= 3                  THEN 'Loyal Customers'
    WHEN r_score >= 4 AND f_score <= 2                  THEN 'New / Promising'
    WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
    WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2  THEN 'Lost'
    ELSE 'Needs Attention'
  END AS rfm_segment
FROM vw_customer_rfm_scored;
