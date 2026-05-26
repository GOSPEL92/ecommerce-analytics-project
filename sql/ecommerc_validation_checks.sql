---1. Validation  Checklist
-- Row Counts
-- Orders count
SELECT COUNT(*) FROM fact_orders;
SELECT COUNT(*) FROM stg_orders;

-- Order items count
SELECT COUNT(*) FROM fact_order_items;
SELECT COUNT(*) FROM stg_order_items;

-- Payments count
SELECT COUNT(*) FROM fact_payments;
SELECT COUNT(*) FROM stg_payments;

-- Reviews count
SELECT COUNT(*) FROM fact_reviews;
SELECT COUNT(*) FROM stg_reviews;

--2 Foreign Key Integrity

-- Orders linked to customers
SELECT COUNT(*) FROM fact_orders o
LEFT JOIN dim_customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Order items linked to products
SELECT COUNT(*) FROM fact_order_items oi
LEFT JOIN dim_products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Order items linked to sellers
SELECT COUNT(*) FROM fact_order_items oi
LEFT JOIN dim_sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

--Payment
SELECT COUNT(*) FROM fact_payments fp
LEFT JOIN fact_orders fo ON fp.order_id = fo.order_id
WHERE fo.order_id IS NULL;

--Reviews
SELECT COUNT(*) FROM fact_reviews fr
LEFT JOIN fact_orders fo ON fr.order_id = fo.order_id
WHERE fo.order_id IS NULL;

-- Business Sanity Checks
SELECT SUM(payment_value) AS total_payments FROM fact_payments;
SELECT SUM(price + freight_value) AS total_order_items FROM fact_order_items;

-- Notes:
-- Small differences (~1–3%) are expected due to:
--   • Freight charges handled differently
--   • Rounding and floating-point precision
--   • Partial payments / installments
--   • Real-world data quality issues (refunds, cancellations, adjustments)
-- Analysts usually accept differences under ~2–3% as normal unless investigating fraud.