/*
Quality checks for Gold Layer
*/
------------------------------------ gold.dim_customers
-- duplicate cst_id?
select cst_id, count(*) FROM
(
select  
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_material_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,
	ca.gen,
	la.cntry
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
ON	ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
ON	ci.cst_key = la.cid
) t
GROUP BY cst_id
HAVING COUNT(*)>1
;

--------------------------------- gold.dim_products
-- uniqueness?
select prd_key, COUNT(*) FROM(
select
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintance  ---> maintenance
FROM silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
where prd_end_dt IS NULL
)t GROUP BY prd_key
HAVING COUNT(*) > 1;

----------------------------------- gold.fact_sales
-- Foreign Key Integrity (Dimensions)
select * from gold.fact_sales f
left join gold.dim_customers c
ON c.customer_key = f.customer_key
where c.customer_key IS NULL
;
select * from gold.fact_sales f
left join gold.dim_customers c
ON c.customer_key = f.customer_key
left join gold.dim_products p 
ON p.product_key = f.product_key
where c.customer_key IS NULL
