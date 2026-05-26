-- Dimension Tables

-- Drop if exists
IF OBJECT_ID('dim_products', 'U') IS NOT NULL
    DROP TABLE dim_products;

-- Create dimension table
CREATE TABLE dim_products (
    product_id NVARCHAR(50) PRIMARY KEY,
    product_category_name NVARCHAR(100),
    product_category_name_english NVARCHAR(100),
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT,
    product_volume_cm3 FLOAT
);
--2. Customers
IF OBJECT_ID('dim_customers', 'U') IS NOT NULL
    DROP TABLE dim_customers;

CREATE TABLE dim_customers (
    customer_id NVARCHAR(50) PRIMARY KEY,
    customer_unique_id NVARCHAR(50),
    customer_city NVARCHAR(100),
    customer_state NVARCHAR(10)
);
-- 3. Sellers
IF OBJECT_ID('dim_sellers', 'U') IS NOT NULL
    DROP TABLE dim_sellers;

CREATE TABLE dim_sellers (
    seller_id NVARCHAR(50) PRIMARY KEY,
    seller_city NVARCHAR(100),
    seller_state NVARCHAR(10)
);

--4. Date
IF OBJECT_ID('dim_date', 'U') IS NOT NULL
    DROP TABLE dim_date;

CREATE TABLE dim_date (
    date_id INT IDENTITY(1,1) PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    day INT,
    weekday NVARCHAR(20)
);


-- Fact Tables
--1. fact_orders

-- Drop if exists
IF OBJECT_ID('fact_orders', 'U') IS NOT NULL
    DROP TABLE fact_orders;

CREATE TABLE fact_orders (
    order_id NVARCHAR(50) PRIMARY KEY,
    customer_id NVARCHAR(50),
    date_id INT,
    order_status NVARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    delivery_time_days INT,
    delayed BIT,
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

--2. fact_order_items
-- Drop if exists
IF OBJECT_ID('fact_order_items', 'U') IS NOT NULL
    DROP TABLE fact_order_items;

-- Create fact table
CREATE TABLE fact_order_items (
    order_id NVARCHAR(50),
    order_item_id INT,
    product_id NVARCHAR(50),
    seller_id NVARCHAR(50),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES fact_orders(order_id),
    FOREIGN KEY (product_id) REFERENCES dim_products(product_id),
    FOREIGN KEY (seller_id) REFERENCES dim_sellers(seller_id)
);

-- 4 fact_payments

-- Drop if exists
IF OBJECT_ID('fact_payments', 'U') IS NOT NULL
    DROP TABLE fact_payments;

-- Create fact table
CREATE TABLE fact_payments (
    order_id NVARCHAR(50),
    payment_sequential INT,
    payment_type NVARCHAR(20),
    payment_installments INT,
    payment_value FLOAT,
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES fact_orders(order_id)
);

--5 fact_reviews 
-- Drop if exists
IF OBJECT_ID('fact_reviews', 'U') IS NOT NULL
    DROP TABLE fact_reviews;

-- Create fact table
CREATE TABLE fact_reviews (
    review_id NVARCHAR(50) PRIMARY KEY,
    order_id NVARCHAR(50),
    review_score INT,
    review_comment_title NVARCHAR(MAX),
    review_comment_message NVARCHAR(MAX),
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
    FOREIGN KEY (order_id) REFERENCES fact_orders(order_id)
);


-- Indexes for performance
CREATE INDEX idx_fact_orders_customer ON fact_orders(customer_id);
CREATE INDEX idx_fact_order_items_product ON fact_order_items(product_id);
CREATE INDEX idx_fact_order_items_seller ON fact_order_items(seller_id);
