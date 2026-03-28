-- 1. Monthly Revenue Trend
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    SUM(p.payment_value) AS revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

-- 2. Top 10 Customers by Total Spending
SELECT 
    c.customer_unique_id,
    SUM(p.payment_value) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;


-- 3. Customer Segmentation
SELECT 
    c.customer_unique_id,
    SUM(p.payment_value) AS total_spent,
    CASE 
        WHEN SUM(p.payment_value) > 10000 THEN 'High Value'
        WHEN SUM(p.payment_value) > 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS segment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id;


-- 4. Delivery Delay Analysis
SELECT 
    COUNT(*) AS delayed_orders
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;


-- 5. Payment Method Analysis
SELECT 
    payment_type,
    COUNT(*) AS usage_count,
    SUM(payment_value) AS total_value
FROM payments
GROUP BY payment_type;


-- 6. Customer Ranking (Window Function)
SELECT 
    c.customer_unique_id,
    SUM(p.payment_value) AS total_spent,
    RANK() OVER (ORDER BY SUM(p.payment_value) DESC) AS rank_position
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id;


-- 7. Repeat Customers
SELECT 
    customer_id,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_id
HAVING order_count > 1;