-- Populate Dimensions

-- 1. Product from staging
INSERT INTO dim_products
SELECT 
    product_id,
    product_category_name,
    product_category_name_english,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    product_volume_cm3
FROM stg_products;

--2. Customer
INSERT INTO dim_customers
SELECT 
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
FROM stg_customers;

--3. Seller 
INSERT INTO dim_sellers
SELECT 
    seller_id,
    seller_city,
    seller_state
FROM stg_sellers;

--4. Date 
INSERT INTO dim_date (full_date, year, month, day, weekday)
SELECT DISTINCT 
    CAST(order_purchase_timestamp AS DATE),
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp),
    DAY(order_purchase_timestamp),
    DATENAME(WEEKDAY, order_purchase_timestamp)
FROM stg_orders;


-- Populate Facts
--1. fact order table
INSERT INTO fact_orders (
    order_id, customer_id, date_id,
    order_status, order_purchase_timestamp,
    order_approved_at, order_delivered_carrier_date,
    order_delivered_customer_date, order_estimated_delivery_date,
    delivery_time_days, delayed
)
SELECT 
    o.order_id,
    o.customer_id,
    d.date_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_time_days,
    CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END AS delayed
FROM stg_orders o
LEFT JOIN dim_date d ON CAST(o.order_purchase_timestamp AS DATE) = d.full_date;

--2.fact order items
INSERT INTO fact_order_items (
    order_id, order_item_id, product_id, seller_id,
    shipping_limit_date, price, freight_value
)
SELECT 
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM stg_order_items;

SELECT 
    i.*,
    o.order_purchase_timestamp AS order_date
FROM fact_order_items i
JOIN fact_orders o ON i.order_id = o.order_id;

--3. fact payments table
INSERT INTO fact_payments (
    order_id, payment_sequential, payment_type,
    payment_installments, payment_value
)
SELECT 
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM stg_payments;  

--4. fact reviews table
INSERT INTO fact_reviews (
    review_id, order_id, review_score,
    review_comment_title, review_comment_message,
    review_creation_date, review_answer_timestamp
)
SELECT 
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY review_id 
               ORDER BY review_answer_timestamp DESC
           ) AS rn
    FROM stg_reviews
) r
WHERE rn = 1; 
