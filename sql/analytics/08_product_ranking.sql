-- ============================================================
-- 08_product_ranking.sql
-- Purpose: rank products/categories by revenue using window
-- functions, and quantify revenue concentration (Pareto check).
-- ============================================================

DROP VIEW IF EXISTS vw_product_ranking;
CREATE VIEW vw_product_ranking AS
SELECT
  product_id,
  MAX(product_name) AS product_name,
  MAX(category)      AS category,
  ROUND(SUM(total_amount), 2) AS revenue,
  RANK() OVER (ORDER BY SUM(total_amount) DESC) AS revenue_rank
FROM fact_orders
WHERE order_status = 'Delivered'
GROUP BY product_id;

DROP VIEW IF EXISTS vw_category_ranking;
CREATE VIEW vw_category_ranking AS
SELECT
  category,
  ROUND(SUM(total_amount), 2) AS revenue,
  ROUND(100.0 * SUM(total_amount) / SUM(SUM(total_amount)) OVER (), 2) AS pct_of_revenue,
  RANK() OVER (ORDER BY SUM(total_amount) DESC) AS revenue_rank
FROM fact_orders
WHERE order_status = 'Delivered'
GROUP BY category;

-- Pareto check: cumulative revenue share of top N products
DROP VIEW IF EXISTS vw_product_pareto;
CREATE VIEW vw_product_pareto AS
SELECT
  product_id,
  product_name,
  revenue,
  revenue_rank,
  ROUND(100.0 * SUM(revenue) OVER (ORDER BY revenue_rank) /
    SUM(revenue) OVER (), 2) AS cumulative_revenue_pct
FROM vw_product_ranking;
