-- dimensions and measures 
SELECT DISTINCT
category -- dimension
FROM gold.dim_products dp;

SELECT DISTINCT
sales_amount -- measure: is numeric, and makes sense to aggregate
FROM gold.fact_sales fs;

SELECT DISTINCT
dp.product_name -- dimension
FROM gold.dim_products dp;

SELECT DISTINCT
quantity -- measure: is numeric, and makes sense to aggregate
FROM gold.fact_sales fs;

SELECT DISTINCT
birthdate -- dimension
FROM gold.dim_customers dc;

SELECT DISTINCT
datediff(year, birthdate, GETDATE()) as Age  -- measure: is numeric, and makes sense to aggregate
FROM gold.dim_customers dc;

SELECT DISTINCT
avg(datediff(year, birthdate, GETDATE())) as Avg_age  
FROM gold.dim_customers dc;

SELECT DISTINCT
dc.customer_id -- dimension: numeric but makes no sense to aggregation
FROM gold.dim_customers dc

-- Explore All Objects in the DATABASE 
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Explore All Columns in the Database 
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'
;

