select 
order_date, 
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by order_date
order by order_date;

select 
YEAR(order_date) as order_year, 
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by YEAR(order_date)
order by order_year;

select 
YEAR(order_date) as order_year, 
sum(sales_amount) as total_sales,
Count(Distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by YEAR(order_date)
order by order_year;

select 
MONTH(order_date) as order_year, 
sum(sales_amount) as total_sales,
Count(Distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by MONTH(order_date)
order by order_year;

select 
YEAR(order_date) as order_year, 
MONTH(order_date) as order_month, 
sum(sales_amount) as total_sales,
Count(Distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by YEAR(order_date), MONTH(order_date)
order by order_year, order_month;

select 
DATETRUNC(month, order_date) as order_date, 
sum(sales_amount) as total_sales,
Count(Distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by DATETRUNC(month, order_date)
order by order_date;

select 
DATETRUNC(year, order_date) as order_date, 
sum(sales_amount) as total_sales,
Count(Distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by DATETRUNC(year, order_date)
order by order_date;

select 
FORMAT(order_date, 'yyyy-MM') as order_date, -- NB! String output
sum(sales_amount) as total_sales,
Count(Distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by FORMAT(order_date, 'yyyy-MM')
order by order_date;

