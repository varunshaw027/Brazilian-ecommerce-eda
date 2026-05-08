
SELECT COUNT(*) AS total_orders
FROM orders;


SELECT
 ROUND(SUM(payment_value),2) AS total_revenue
 FROM dbo.payments;


SELECT
 COUNT(*) AS total_orders
 FROM dbo.orders;

 SELECT
 ROUND(AVG(payment_value),2) AS avg_order_value
 FROM dbo.payments;

SELECT
payment_type,
COUNT(*) AS total_transaction,
ROUND(SUM(payment_value),2) AS total_revenue
FROM dbo.payments
GROUP BY payment_type
ORDER BY total_revenue DESC;

SELECT
  YEAR(o.order_purchase_timestamp) AS order_year,
  MONTH(o.order_purchase_timestamp) AS oder_month,

  ROUND(SUM(p.payment_value),2) AS monthly_revenue

  FROM dbo.orders o
  
  JOIN dbo.payments p
      ON o.order_id = p.order_id

 GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)

 ORDER BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp);


SELECT TOP 10

o.customer_id,

ROUND(SUM(p.payment_value),2) AS total_spent

FROM dbo.orders o

JOIN dbo.payments p
 ON o.order_id = p.order_id

 GROUP BY o.customer_id

 ORDER BY total_spent DESC;


 SELECT

    pr.product_category_name,

    ROUND(SUM(py.payment_value),2) AS total_revenue

FROM dbo.orders o

JOIN dbo.payments py
    ON o.order_id = py.order_id

JOIN dbo.order_items oi
    ON o.order_id = oi.order_id

JOIN dbo.products pr
    ON oi.product_id = pr.product_id

GROUP BY pr.product_category_name

ORDER BY total_revenue DESC;


SELECT

 DATEPART(HOUR, order_purchase_timestamp) AS order_hour,

 COUNT(*) AS total_orders

 FROM dbo.orders

 GROUP BY DATEPART(HOUR, order_purchase_timestamp)

 ORDER BY total_orders DESC;


 SELECT

    CASE
        WHEN DATENAME(WEEKDAY, order_purchase_timestamp)
            IN ('Saturday','Sunday')
        THEN 'Weekend'

        ELSE 'Weekday'
    END AS order_type,

    COUNT(*) AS total_orders

FROM dbo.orders

GROUP BY
    CASE
        WHEN DATENAME(WEEKDAY, order_purchase_timestamp)
            IN ('Saturday','Sunday')
        THEN 'Weekend'

        ELSE 'Weekday'
    END;


    SELECT TOP 20

    o.customer_id,

    ROUND(SUM(p.payment_value),2) AS total_spent,

    RANK() OVER(
        ORDER BY SUM(p.payment_value) DESC
    ) AS customer_rank

FROM dbo.orders o

JOIN dbo.payments p
    ON o.order_id = p.order_id

GROUP BY o.customer_id;


WITH monthly_sales AS (

    SELECT

        YEAR(o.order_purchase_timestamp) AS order_year,

        MONTH(o.order_purchase_timestamp) AS order_month,

        ROUND(SUM(p.payment_value),2) AS revenue

    FROM dbo.orders o

    JOIN dbo.payments p
        ON o.order_id = p.order_id

    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)

)

SELECT TOP 5 *

FROM monthly_sales

ORDER BY revenue DESC;


WITH monthly_sales AS (

    SELECT

        YEAR(o.order_purchase_timestamp) AS order_year,

        MONTH(o.order_purchase_timestamp) AS order_month,

        ROUND(SUM(p.payment_value),2) AS monthly_revenue

    FROM dbo.orders o

    JOIN dbo.payments p
        ON o.order_id = p.order_id

    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)

)

SELECT

    order_year,
    order_month,
    monthly_revenue,

    SUM(monthly_revenue)
    OVER(
        ORDER BY order_year, order_month
    ) AS cumulative_revenue

FROM monthly_sales;


WITH customer_spending AS (

    SELECT

        o.customer_id,

        ROUND(SUM(p.payment_value),2) AS total_spent

    FROM dbo.orders o

    JOIN dbo.payments p
        ON o.order_id = p.order_id

    GROUP BY o.customer_id

)

SELECT

    customer_id,
    total_spent,

    CASE

        WHEN total_spent >= 5000
            THEN 'High Value Customer'

        WHEN total_spent >= 1000
            THEN 'Medium Value Customer'

        ELSE 'Low Value Customer'

    END AS customer_segment

FROM customer_spending

ORDER BY total_spent DESC;

-- PAYMENT METHOD ANALYSIS --

SELECT

    payment_type,

    COUNT(*) AS total_transactions,

    ROUND(SUM(payment_value),2) AS total_revenue,

    ROUND(AVG(payment_value),2) AS avg_transaction_value

FROM dbo.payments

GROUP BY payment_type

ORDER BY total_revenue DESC;

-- LATE DELIVERY DETECTION --

SELECT

    COUNT(*) AS late_deliveries

FROM dbo.orders

WHERE order_delivered_customer_date
    > order_estimated_delivery_date;

-- ON-TIME VS LATE DELIVERY --

SELECT

    CASE

        WHEN order_delivered_customer_date
            > order_estimated_delivery_date

            THEN 'Late Delivery'

        ELSE 'On Time'

    END AS delivery_status,

    COUNT(*) AS total_orders

FROM dbo.orders

WHERE order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL

GROUP BY

    CASE

        WHEN order_delivered_customer_date
            > order_estimated_delivery_date

            THEN 'Late Delivery'

        ELSE 'On Time'

    END;

    -- AVERAGE DELIVERY DELAY DAYS --

    SELECT

    ROUND(
        AVG(
            DATEDIFF(
                DAY,
                order_estimated_delivery_date,
                order_delivered_customer_date
            )
        ),2
    ) AS avg_delay_days

FROM dbo.orders

WHERE order_delivered_customer_date
    > order_estimated_delivery_date;

    -- MONTHLY DELIVERY DELAY ANALYSIS --

    SELECT

    YEAR(order_purchase_timestamp) AS order_year,

    MONTH(order_purchase_timestamp) AS order_month,

    COUNT(*) AS late_orders,

    ROUND(
        AVG(
            DATEDIFF(
                DAY,
                order_estimated_delivery_date,
                order_delivered_customer_date
            )
        ),2
    ) AS avg_delay_days

FROM dbo.orders

WHERE order_delivered_customer_date
    > order_estimated_delivery_date

GROUP BY

    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)

ORDER BY avg_delay_days DESC;