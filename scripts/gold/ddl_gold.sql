/*
Create Gold Views
*/
--------------------------------- gold.dim_customers
CREATE VIEW gold.dim_customers AS
select  
	ROW_NUMBER() over (order by cst_id) AS customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	la.cntry as country,
	ci.cst_material_status as marital_status,
	CASE WHEN ci.cst_gndr	!= 'n/a' THEN ci.cst_gndr -- CRM is the master for gender info
		ELSE COALESCE(ca.gen,'n/a')
	END as gender,
	ca.bdate as birthdate,
	ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
ON	ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
ON	ci.cst_key = la.cid;

--------------------------------- gold.dim_products
create view gold.dim_products AS
select
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, prd_key) AS product_key,
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	pc.cat as category,
	pc.subcat as subcategory,
	pc.maintance  as maintenance,
	pn.prd_cost as cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date
FROM silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
where prd_end_dt IS NULL;
------------------------------- gold.fact_sales
create view gold.fact_sales AS
select
sd.sls_ord_num AS order_number,
pr.product_key, -- warehouse product key
cu.customer_key, -- warehouse customer key
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
FROM silver.crm_sales_details sd
left join gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
left join gold.dim_customers cu;
ON sd.sls_cust_id = cu.customer_id;
