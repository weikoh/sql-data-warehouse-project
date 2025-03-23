-- cumulative analysis
-- total sales per month
select
DATETRUNC(MONTH,order_date) AS order_year_month,
SUM(sales_amount)
from gold.fact_sales
where DATETRUNC(MONTH,order_date) is not null
GROUP BY DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(MONTH,order_date);
-- running total sales over time
-- with subquery
select 
order_year_month,
total_sales,
-- window function default unbounded preceding and current row
sum(total_sales) over (partition by order_year_month order by order_year_month) as running_total_sales
FROM
(
select
DATETRUNC(MONTH,order_date) AS order_year_month,
SUM(sales_amount) as total_sales
from gold.fact_sales
where DATETRUNC(MONTH,order_date) is not null
GROUP BY DATETRUNC(MONTH,order_date)
--ORDER BY DATETRUNC(MONTH,order_date)
) t
;
-- total and running sales by year
select 
order_year,
total_sales,
-- window function default unbounded preceding and current row
sum(total_sales) over (order by order_year) as running_total_sales
FROM
(
select
DATETRUNC(YEAR,order_date) AS order_year,
SUM(sales_amount) as total_sales
from gold.fact_sales
where DATETRUNC(YEAR,order_date) is not null
GROUP BY DATETRUNC(YEAR,order_date)
) t
;

select 
order_year,
total_sales,
-- window function default unbounded preceding and current row
sum(total_sales) over (order by order_year) as running_total_sales,
avg(avg_price) over (order by order_year) as moving_average_price
FROM
(
select
DATETRUNC(YEAR,order_date) AS order_year,
SUM(sales_amount) as total_sales,
AVG(price) as avg_price
from gold.fact_sales
where DATETRUNC(YEAR,order_date) is not null
GROUP BY DATETRUNC(YEAR,order_date)
) t
;
-- perfomance analysis
/* analyse the yearly perfomance of products by comparing their sales
to both the avarage sales peromance of the product and the previous years's sales
*/
select * from gold.fact_sales;