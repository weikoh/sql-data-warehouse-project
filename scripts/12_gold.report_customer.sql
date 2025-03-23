/*
Customer Report
Purpose:
- This report consolidates key customer metrics and behaviors
Highlights:
1. Gathers essential fields such as names, ages, and transaction details.
2. Segments customers into categories (VIP, Regular, New) and age groups.
3. Aggregates customer-level metrics:
3.1 total orders
3.2 total sales
3.3 total quantity purchased
3.4 total products
3.5 lifespan (in months)
4. Calculates valuable KPIs:
4.1 recency (months since last order)
4.2 average order value
4.3 average monthly spend
*/

WITH base_query AS (
-- 1) Base Query: Retrieves core columns from tables
SELECT
fs.order_number,
fs.product_key,
fs.order_date,
fs.sales_amount,
fs.quantity,
dc.customer_key,
dc.customer_number,
concat(dc.first_name, ' ', dc.last_name) AS customer_name,
datediff(year, dc.birthdate, GETDATE()) age
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
WHERE fs.order_date IS NOT NULL
)
SELECT 
-- 2) total number of orders
    customer_key
   ,customer_number
   ,customer_name
   ,age
   ,count(DISTINCT order_number) AS total_orders
   ,sum(sales_amount) AS total_sales
   ,sum(quantity) AS total_quantity
   ,count(DISTINCT product_key) AS total_products
   ,max(order_date) AS last_order_date
   ,DATEDIFF(month, min(order_date), max(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key, customer_number, customer_name, age
;

-- 3) segmenting
create VIEW gold.report_customers AS
WITH base_query AS (
-- 1) Base Query: Retrieves core columns from tables
SELECT
fs.order_number,
fs.product_key,
fs.order_date,
fs.sales_amount,
fs.quantity,
dc.customer_key,
dc.customer_number,
concat(dc.first_name, ' ', dc.last_name) AS customer_name,
datediff(year, dc.birthdate, GETDATE()) age
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
ON fs.customer_key = dc.customer_key
WHERE fs.order_date IS NOT null)

, customer_aggregations AS (
-- 2) Customer aggregations: Summarizes key metrics at the customer level
SELECT 
    customer_key
   ,customer_number
   ,customer_name
   ,age
   ,count(DISTINCT order_number) AS total_orders
   ,sum(sales_amount) AS total_sales
   ,sum(quantity) AS total_quantity
   ,count(DISTINCT product_key) AS total_products
   ,max(order_date) AS last_order_date
   ,DATEDIFF(month, min(order_date), max(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key, customer_number, customer_name, age
)
SELECT customer_key
	  ,customer_number
	  ,customer_name
	  ,age
	  ,CASE WHEN age<20 THEN 'Under 20'
			WHEN age BETWEEN 20 and 29 then '20-29'
			WHEN age BETWEEN 30 AND 39 THEN '30-39'
			WHEN age BETWEEN 40 AND 49 THEN '40-49'
			ELSE '50 and above'
		END as age_group
	  ,CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
			WHEN lifespan < 12 THEN 'New'
	  END AS customer_segment
	  ,total_orders
	  ,total_sales
	  ,total_quantity
	  ,total_products
	  ,last_order_date
	  , datediff(month,last_order_date, GETDATE()) AS recency  
	  ,lifespan
	  ,
	  -- compute average order value
	  CASE WHEN total_sales = 0 THEN 0
		ELSE total_sales / total_orders 
	  END AS avg_order_value
	  ,
	  -- compute average monthly spend 
	  CASE WHEN  lifespan=0 THEN total_sales
	  ELSE total_sales/ lifespan
	  END AS avg_monthly_spend

FROM customer_aggregations
;

SELECT * FROM gold.report_customers rc;

-- example queries
SELECT 
rc.age_group,
count(rc.customer_number) AS total_customers,
sum(total_sales) as total_sales
FROM gold.report_customers rc
GROUP BY rc.age_group;

SELECT 
rc.customer_segment,
count(rc.customer_number) AS total_customers,
sum(total_sales) as total_sales
FROM gold.report_customers rc
GROUP BY rc.customer_segment;

