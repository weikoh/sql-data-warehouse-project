/*
* Analyze the yearly performance of products by comparing their sales to both 
the average sales performance of the product and the previous year's sales.
*/
SELECT 
    --fs.order_date
    datetrunc(YEAR,fs.order_date) AS order_date
    ,dp.product_name
    ,sum(fs.sales_amount) AS total_sales
	,avg(fs.sales_amount) AS avg_sales
FROM gold.fact_sales fs 
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
WHERE fs.order_date is not NULL
GROUP BY  datetrunc(YEAR,fs.order_date), dp.product_name
ORDER BY  datetrunc(YEAR,fs.order_date),sum(fs.sales_amount) DESC;

-- 1. year, pdoduct, sales sum for each year
-- 2. + avg sales of all sales by year
-- 3. + difference from average product sales by year
-- 4. case: above avg, avg, below avg.
-- 5. compare with previous year.
-- 6. case increase, decrease
WITH yearly_product_sales AS(
 SELECT 
 year(fs.order_date) AS order_year,
 dp.product_name,
 sum(fs.sales_amount) AS current_sales
 FROM gold.fact_sales fs
 left JOIN gold.dim_products dp
 ON fs.product_key = dp.product_key
 WHERE fs.order_date is NOT NULL
 GROUP BY year(fs.order_date), dp.product_name
)
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) as avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_sales,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above average'
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below average'
	ELSE 'Average'
END avg_change,
-- Year-over-year analysis
LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
CASE WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	ELSE 'No change'
END py_change
FROM yearly_product_sales
ORDER by product_name, order_year
;