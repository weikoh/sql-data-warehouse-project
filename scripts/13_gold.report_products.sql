/*
Product Report
===
Purpose:
This report consolidates key product metrics and behaviors.
Highlights:
1. Gathers essential fields such as product name, category, subcategory, and cost.
2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
3. Aggregates product-level metrics:
3.1 total orders
3.2 total sales
3.3 total quantity sold
3.4 total customers (unique)
3.5 lifespan (in months)
4. Calculates valuable KPIs:
4.1 recency (months since last sale)
4.2 average order revenue (AOR)
4.3 average monthly revenue
*/
-- Steps
-- 1) Explore data
SELECT * FROM gold.fact_sales fs;
SELECT * FROM gold.dim_products dp;
SELECT * FROM gold.dim_customers dc;

CREATE VIEW gold.report_products AS
-- 2) Get essential fields
WITH base_query AS (
SELECT 
	fs.order_number,
	fs.order_date,
	fs.customer_key,
	fs.sales_amount,
	fs.quantity,
	dp.product_key,
	dp.product_name,
	dp.category,
	dp.subcategory,
	dp.cost
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
WHERE fs.order_date IS NOT NULL
),
-- 3) Summarize key metrics at the product level
product_aggregation AS (
SELECT
	product_key, 
	product_name,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT order_number) AS total_orders,
	sum(sales_amount) AS total_sales,
	sum(quantity) AS total_quantity,
	count(DISTINCT customer_key) AS total_customers,
	datediff(month, min(order_date), max(order_date)) AS lifespan,
	max(order_date) AS last_sale_date,
	round(avg(cast(sales_amount AS FLOAT) / NULLIF(quantity,0)),1) AS avg_selling_price
FROM base_query
GROUP BY
	product_key, 
	product_name,
	category,
	subcategory,
	cost
)
-- 4) Final query
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	datediff(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average order revenue
	CASE
		WHEN total_sales = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,
	-- Average monthly revenue
	CASE WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue
FROM product_aggregation
;
SELECT * FROM gold.report_products rp;