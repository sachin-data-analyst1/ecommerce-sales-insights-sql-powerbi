-- ============================================================
-- 02_validation_checks.sql
-- Purpose: prove data trustworthiness before a single dashboard
-- number is calculated. Run each check and record the result
-- in the "Data Quality Findings" table in the README.
-- ============================================================

-- CHECK 1: order_items with no matching product (orphaned FK)
SELECT COUNT(*) AS orphaned_order_items_no_product
FROM stg_order_items oi
LEFT JOIN stg_products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- CHECK 2: order_items with no matching order (orphaned FK)
SELECT COUNT(*) AS orphaned_order_items_no_order
FROM stg_order_items oi
LEFT JOIN stg_orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- CHECK 3: orders with no matching customer (orphaned FK)
SELECT COUNT(*) AS orphaned_orders_no_customer
FROM stg_orders o
LEFT JOIN stg_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- CHECK 4: duplicate primary keys
SELECT 'customers' AS table_name, COUNT(*) AS duplicate_ids
FROM (SELECT customer_id FROM stg_customers GROUP BY customer_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'orders', COUNT(*)
FROM (SELECT order_id FROM stg_orders GROUP BY order_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'products', COUNT(*)
FROM (SELECT product_id FROM stg_products GROUP BY product_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'order_items', COUNT(*)
FROM (SELECT order_item_id FROM stg_order_items GROUP BY order_item_id HAVING COUNT(*) > 1);

-- CHECK 5: null audit on critical columns
SELECT
  SUM(CASE WHEN order_date   IS NULL THEN 1 ELSE 0 END) AS null_order_date,
  SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_order_status,
  SUM(CASE WHEN customer_id  IS NULL THEN 1 ELSE 0 END) AS null_customer_id
FROM stg_orders;

-- CHECK 6: logical impossibility - order placed before customer signed up
SELECT COUNT(*) AS orders_before_signup
FROM stg_orders o
JOIN stg_customers c ON o.customer_id = c.customer_id
WHERE o.order_date < c.signup_date;

-- CHECK 7: order_status domain check (should only ever be 3 values)
SELECT order_status, COUNT(*) AS row_count
FROM stg_orders
GROUP BY order_status;

-- CHECK 8: negative or zero quantity/amount sanity check
SELECT COUNT(*) AS bad_order_items
FROM stg_order_items
WHERE quantity <= 0 OR total_amount <= 0;

-- CHECK 9: orders with ZERO line items (silently dropped by an
-- INNER JOIN into fact_orders -- this is the check that actually
-- matters most here, since it changes which orders show up in
-- every downstream revenue number)
SELECT COUNT(*) AS orders_with_no_line_items
FROM stg_orders o
LEFT JOIN stg_order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;
