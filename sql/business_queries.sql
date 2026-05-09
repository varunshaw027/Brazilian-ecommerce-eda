-- =========================================
-- BRAZILIAN E-COMMERCE ANALYTICS SQL QUERIES
-- =========================================


-- =========================================
-- 1. Total Revenue
-- =========================================

SELECT 
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments;


-- =========================================
-- 2. Total Orders
-- =========================================

SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;


-- =========================================
-- 3. Average Order Value
-- =========================================

SELECT 
    ROUND(AVG(payment_value), 2) AS avg_order_value
FROM payments;


-- =========================================
-- 4. Top 10 States by Revenue
-- =========================================

SELECT 
    c.customer_state,
    ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;


-- =========================================
-- 5. Top 10 Customers by Spending
-- =========================================

SELECT 
    c.customer_unique_id,
    ROUND(SUM(p.payment_value), 2) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;


-- =========================================
-- 6. Payment Type Distribution
-- =========================================

SELECT 
    payment_type,
    COUNT(*) AS total_transactions
FROM payments
GROUP BY payment_type
ORDER BY total_transactions DESC;


-- =========================================
-- 7. Monthly Revenue Trend
-- =========================================

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(p.payment_value), 2) AS monthly_revenue
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;


-- =========================================
-- 8. Orders by Status
-- =========================================

SELECT 
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- =========================================
-- 9. Average Delivery Time
-- =========================================

SELECT 
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
    2) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


-- =========================================
-- 10. Late Deliveries
-- =========================================

SELECT 
    COUNT(*) AS late_deliveries
FROM orders
WHERE order_delivered_customer_date >
      order_estimated_delivery_date;


-- =========================================
-- 11. Percentage of Late Deliveries
-- =========================================

SELECT 
    ROUND(
        (
            SUM(
                CASE
                    WHEN order_delivered_customer_date >
                         order_estimated_delivery_date
                    THEN 1
                    ELSE 0
                END
            ) * 100.0
        ) / COUNT(*),
    2) AS late_delivery_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


-- =========================================
-- 12. Top Product Categories
-- =========================================

SELECT 
    p.product_category_name,
    COUNT(oi.product_id) AS total_products_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_products_sold DESC
LIMIT 10;


-- =========================================
-- 13. Highest Revenue Product Categories
-- =========================================

SELECT 
    pr.product_category_name,
    ROUND(SUM(pay.payment_value), 2) AS category_revenue
FROM products pr
JOIN order_items oi
    ON pr.product_id = oi.product_id
JOIN payments pay
    ON oi.order_id = pay.order_id
GROUP BY pr.product_category_name
ORDER BY category_revenue DESC
LIMIT 10;


-- =========================================
-- 14. Orders Per Customer
-- =========================================

SELECT 
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 10;


-- =========================================
-- 15. Repeat Customers
-- =========================================

SELECT 
    COUNT(*) AS repeat_customers
FROM (
    SELECT 
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
) AS repeat_data;


-- =========================================
-- 16. Average Freight Value
-- =========================================

SELECT 
    ROUND(AVG(freight_value), 2) AS avg_freight_value
FROM order_items;


-- =========================================
-- 17. Top States by Number of Orders
-- =========================================

SELECT 
    c.customer_state,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC
LIMIT 10;


-- =========================================
-- 18. Revenue by Payment Type
-- =========================================

SELECT 
    payment_type,
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments
GROUP BY payment_type
ORDER BY total_revenue DESC;


-- =========================================
-- 19. Seller Performance
-- =========================================

SELECT 
    seller_id,
    COUNT(order_id) AS total_orders
FROM order_items
GROUP BY seller_id
ORDER BY total_orders DESC
LIMIT 10;


-- =========================================
-- 20. Top Expensive Orders
-- =========================================

SELECT 
    order_id,
    ROUND(SUM(payment_value), 2) AS total_order_value
FROM payments
GROUP BY order_id
ORDER BY total_order_value DESC
LIMIT 10;
