-- Which categories contribute the most overall sales?
-- 1. sales by category
-- 2. CTE + window function SUM, float
-- 3. percentage
WITH category_sales AS (
SELECT
dp.category,
sum(fs.sales_amount) AS total_sales
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
ON fs.product_key = dp.product_key
GROUP BY dp.category
)
SELECT 
category,
total_sales,
sum(total_sales) OVER () AS overall_sales,
concat(round((cast(total_sales AS FLOAT) / sum(total_sales) OVER ())*100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;