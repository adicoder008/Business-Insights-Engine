-- -- 1. Monthly Revenue Trend
-- SELECT 
--     DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
--     SUM(p.payment_value) AS revenue
-- FROM orders o
-- JOIN payments p ON o.order_id = p.order_id
-- GROUP BY month
-- ORDER BY month;

-- -- 2. Top 10 Customers by Total Spending
-- SELECT 
--     c.customer_unique_id,
--     SUM(p.payment_value) AS total_spent
-- FROM customers c
-- JOIN orders o ON c.customer_id = o.customer_id
-- JOIN payments p ON o.order_id = p.order_id
-- GROUP BY c.customer_unique_id
-- ORDER BY total_spent DESC
-- LIMIT 10;


-- -- 3. Customer Segmentation
-- -- SELECT 
-- --     c.customer_unique_id,
-- --     SUM(p.payment_value) AS total_spent,
-- --     CASE 
-- --         WHEN SUM(p.payment_value) > 10000 THEN 'High Value'
-- --         WHEN SUM(p.payment_value) > 5000 THEN 'Medium Value'
-- --         ELSE 'Low Value'
-- --     END AS segment
-- -- FROM customers c
-- -- JOIN orders o ON c.customer_id = o.customer_id
-- -- JOIN payments p ON o.order_id = p.order_id
-- -- GROUP BY c.customer_unique_id;
-- WITH customer_metrics AS (
--     SELECT 
--         c.customer_unique_id,
--         MAX(o.order_purchase_timestamp) AS last_purchase_date,
--         COUNT(DISTINCT o.order_id) AS frequency,
--         SUM(p.payment_value) AS monetary
--     FROM customers c
--     JOIN orders o ON c.customer_id = o.customer_id
--     JOIN payments p ON o.order_id = p.order_id
--     GROUP BY c.customer_unique_id
-- ),

-- rfm_scores AS (
--     SELECT *,
--         NTILE(4) OVER (ORDER BY last_purchase_date DESC) AS recency_score,
--         NTILE(4) OVER (ORDER BY frequency DESC) AS frequency_score,
--         NTILE(4) OVER (ORDER BY monetary DESC) AS monetary_score
--     FROM customer_metrics
-- )

-- SELECT *,
--     CONCAT(recency_score, frequency_score, monetary_score) AS rfm_score,
--     CASE 
--         WHEN recency_score = 4 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Champions'
--         WHEN frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
--         WHEN recency_score = 4 AND frequency_score <= 2 THEN 'New Customers'
--         WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
--         ELSE 'Others'
--     END AS segment
-- FROM rfm_scores;


-- -- revenue contribution
-- WITH customer_revenue AS (
--     SELECT 
--         c.customer_unique_id,
--         SUM(p.payment_value) AS revenue
--     FROM customers c
--     JOIN orders o ON c.customer_id = o.customer_id
--     JOIN payments p ON o.order_id = p.order_id
--     GROUP BY c.customer_unique_id
-- )
-- SELECT 
--     SUM(revenue) AS total_revenue,
--     SUM(CASE WHEN revenue > 1000 THEN revenue END) AS high_value_revenue
-- FROM customer_revenue;

-- -- 4. Delivery Delay Analysis
-- -- SELECT 
-- --     COUNT(*) AS delayed_orders
-- -- FROM orders
-- -- WHERE order_delivered_customer_date > order_estimated_delivery_date;
-- SELECT 
--     AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)) AS avg_delay_days,
--     MAX(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)) AS max_delay
-- FROM orders
-- WHERE order_delivered_customer_date > order_estimated_delivery_date;


-- -- 5. Payment Method Analysis
-- SELECT 
--     payment_type,
--     COUNT(*) AS usage_count,
--     SUM(payment_value) AS total_value
-- FROM payments
-- GROUP BY payment_type;


-- -- 6. Customer Ranking (Window Function)
-- SELECT 
--     c.customer_unique_id,
--     SUM(p.payment_value) AS total_spent,
--     RANK() OVER (ORDER BY SUM(p.payment_value) DESC) AS rank_position
-- FROM customers c
-- JOIN orders o ON c.customer_id = o.customer_id
-- JOIN payments p ON o.order_id = p.order_id
-- GROUP BY c.customer_unique_id;


-- -- 7. Repeat Customers
-- SELECT 
--     customer_id,
--     COUNT(order_id) AS order_count
-- FROM orders
-- GROUP BY customer_id
-- HAVING order_count > 1;



-- =========================================
-- BUSINESS INSIGHTS PROJECT (FINAL VERSION)
-- =========================================

-- ========== 1. DATABASE SETUP ==========
CREATE DATABASE business_insights;
USE business_insights;

-- ========== 2. TABLE CREATION ==========
CREATE TABLE customers (
customer_id VARCHAR(50) PRIMARY KEY,
customer_unique_id VARCHAR(50),
customer_zip_code_prefix INT,
customer_city VARCHAR(100),
customer_state VARCHAR(10)
);

CREATE TABLE orders (
order_id VARCHAR(50) PRIMARY KEY,
customer_id VARCHAR(50),
order_status VARCHAR(50),
order_purchase_timestamp DATETIME,
order_approved_at DATETIME,
order_delivered_carrier_date DATETIME,
order_delivered_customer_date DATETIME,
order_estimated_delivery_date DATETIME,
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE products (
product_id VARCHAR(50) PRIMARY KEY,
product_category_name VARCHAR(100),
product_weight_g INT
);

CREATE TABLE order_items (
order_id VARCHAR(50),
order_item_id INT,
product_id VARCHAR(50),
seller_id VARCHAR(50),
shipping_limit_date DATETIME,
price DECIMAL(10,2),
freight_value DECIMAL(10,2),
PRIMARY KEY (order_id, order_item_id),
FOREIGN KEY (order_id) REFERENCES orders(order_id),
FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
order_id VARCHAR(50),
payment_sequential INT,
payment_type VARCHAR(50),
payment_installments INT,
payment_value DECIMAL(10,2),
PRIMARY KEY (order_id, payment_sequential),
FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ========== 3. INDEXING ==========
CREATE INDEX idx_customer ON orders(customer_id);
CREATE INDEX idx_order ON payments(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- -- ========== 4. DATA LOADING ==========
-- LOAD DATA INFILE 'data/customers_dataset.csv'
-- INTO TABLE customers
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- LOAD DATA INFILE 'data/orders_dataset.csv'
-- INTO TABLE orders
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- LOAD DATA INFILE 'data/order_items_dataset.csv'
-- INTO TABLE order_items
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- LOAD DATA INFILE 'data/products_dataset.csv'
-- INTO TABLE products
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- LOAD DATA INFILE 'data/payments_dataset.csv'
-- INTO TABLE payments
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- =========================================
-- ========== 5. ANALYTICS QUERIES =========
-- =========================================

-- Common CTE for clean revenue
WITH order_payments AS (
SELECT order_id, SUM(payment_value) AS total_payment
FROM payments
GROUP BY order_id
)

-- 1. Monthly Revenue Trend
SELECT
DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
SUM(op.total_payment) AS revenue
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY month
ORDER BY month;

-- 2. Top 10 Customers
WITH order_payments AS (
SELECT order_id, SUM(payment_value) AS total_payment
FROM payments GROUP BY order_id
)
SELECT
c.customer_unique_id,
SUM(op.total_payment) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;

-- 3. RFM Segmentation
WITH order_payments AS (
SELECT order_id, SUM(payment_value) AS total_payment
FROM payments GROUP BY order_id
),
customer_metrics AS (
SELECT
c.customer_unique_id,
MAX(o.order_purchase_timestamp) AS last_purchase_date,
COUNT(DISTINCT o.order_id) AS frequency,
SUM(op.total_payment) AS monetary
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY c.customer_unique_id
),
rfm_scores AS (
SELECT *,
NTILE(4) OVER (ORDER BY last_purchase_date DESC) AS recency_score,
NTILE(4) OVER (ORDER BY frequency DESC) AS frequency_score,
NTILE(4) OVER (ORDER BY monetary DESC) AS monetary_score
FROM customer_metrics
)
SELECT *,
CONCAT(recency_score, frequency_score, monetary_score) AS rfm_score,
CASE
WHEN recency_score = 4 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Champions'
WHEN frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
WHEN recency_score = 4 AND frequency_score <= 2 THEN 'New Customers'
WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
ELSE 'Others'
END AS segment
FROM rfm_scores;

-- 4. Revenue Contribution (Top 10%)
WITH order_payments AS (
SELECT order_id, SUM(payment_value) AS total_payment
FROM payments GROUP BY order_id
),
customer_revenue AS (
SELECT
c.customer_unique_id,
SUM(op.total_payment) AS revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY c.customer_unique_id
),
ranked AS (
SELECT *,
NTILE(10) OVER (ORDER BY revenue DESC) AS decile
FROM customer_revenue
)
SELECT
SUM(revenue) AS total_revenue,
SUM(CASE WHEN decile = 1 THEN revenue END) AS top_10_percent_revenue
FROM ranked;

-- 5. Delivery Delay Analysis
SELECT
AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)) AS avg_delay_days,
MAX(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)) AS max_delay
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;

-- 6. Payment Method Analysis
SELECT
payment_type,
COUNT(*) AS usage_count,
SUM(payment_value) AS total_value
FROM payments
GROUP BY payment_type;

-- 7. Customer Ranking
WITH order_payments AS (
SELECT order_id, SUM(payment_value) AS total_payment
FROM payments GROUP BY order_id
)
SELECT
c.customer_unique_id,
SUM(op.total_payment) AS total_spent,
RANK() OVER (ORDER BY SUM(op.total_payment) DESC) AS rank_position
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY c.customer_unique_id;

-- 8. Repeat Customers
SELECT
c.customer_unique_id,
COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING order_count > 1;

-- 9. Product Category Revenue
WITH order_payments AS (
SELECT order_id, SUM(payment_value) AS total_payment
FROM payments GROUP BY order_id
)
SELECT
p.product_category_name,
SUM(op.total_payment) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN order_payments op ON oi.order_id = op.order_id
GROUP BY p.product_category_name
ORDER BY revenue DESC;

-- 10. Customer Retention Summary
SELECT
COUNT(DISTINCT customer_unique_id) AS total_customers,
COUNT(DISTINCT CASE WHEN order_count > 1 THEN customer_unique_id END) AS repeat_customers
FROM (
SELECT
c.customer_unique_id,
COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
) t;

-- =========================================
-- END OF FILE (finally)
-- =========================================
