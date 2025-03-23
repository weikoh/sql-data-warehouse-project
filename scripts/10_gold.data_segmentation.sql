-- Creating new categories by measures
-- Segment products into cost ranges
-- Count how many products fall into  each segment
-- 1. cost to measure (categories) CASE
-- 2. CTE 
WITH product_segments AS (
SELECT 
dp.product_key,
dp.product_name,
cost, 
CASE WHEN dp.cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 then '500-1000'
	ELSE 'Above 1000'
END cost_range
FROM gold.dim_products dp
)
SELECT
cost_range,
count(product_key) as total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products
;
---------------------------------------------------------
-- Group customers to three segments based on their behavior
-- VIP: 12+ months > 5000
-- Regular: 12+  months < 5000
-- New: lifespan <12 months
-- Total number of customers by each group

-- 1. total number of customers
-- 2. lifespan - first order to last order 
-- 3. lifespan
-- 4. cte for segmenting VIP, Regular, New

WITH customer_spending AS (
SELECT
dc.customer_key,
sum(fs.sales_amount) total_spending,
min(fs.order_date) first_order,
max(fs.order_date) last_order,
datediff(month, Min(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales fs
left JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key
)
SELECT
customer_key,
total_spending,
lifespan,
CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	WHEN lifespan < 12 THEN 'New'
END customer_segment
FROM customer_spending
;

-- 5. subquery goup by 
WITH customer_spending AS (
	SELECT
	dc.customer_key,
	sum(fs.sales_amount) total_spending,
	min(fs.order_date) first_order,
	max(fs.order_date) last_order,
	datediff(month, Min(order_date), MAX(order_date)) AS lifespan
	FROM gold.fact_sales fs
	left JOIN gold.dim_customers dc
	ON fs.customer_key = dc.customer_key
	GROUP BY dc.customer_key
)
SELECT 
customer_segment, 
count(customer_key) AS total_customers
FROM (
	SELECT
	customer_key,
	CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		WHEN lifespan < 12 THEN 'New'
	END customer_segment
	FROM customer_spending ) t
	WHERE t.customer_segment IS NOT null
GROUP BY customer_segment
ORDER BY total_customers desc
;

--- Alternative way
WITH customer_spending AS (
	SELECT
	dc.customer_key,
	--sum(fs.sales_amount) total_spending,
	--min(fs.order_date) first_order,
	--max(fs.order_date) last_order,
	--datediff(month, Min(order_date), MAX(order_date)) AS lifespan,
	CASE WHEN datediff(month, Min(order_date), MAX(order_date)) >= 12 AND sum(fs.sales_amount) > 5000 THEN 'VIP'
		WHEN datediff(month, Min(order_date), MAX(order_date)) >= 12 AND sum(fs.sales_amount) <= 5000 THEN 'Regular'
		WHEN datediff(month, Min(order_date), MAX(order_date)) < 12 THEN 'New'
	END customer_segment
	FROM gold.fact_sales fs
	left JOIN gold.dim_customers dc
	ON fs.customer_key = dc.customer_key
	GROUP BY dc.customer_key
)
SELECT 
customer_segment, 
count(customer_key) AS total_customers
FROM customer_spending
WHERE customer_segment IS NOT null
GROUP BY customer_segment
ORDER BY total_customers desc
;