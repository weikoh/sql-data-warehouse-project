/*
silver.crm_cust_info
*/
-- Check nulls or duplicates in Primary Key
-- Expectation: No Result
SELECT 
cst_id,
count(*)
FROM silver.crm_cust_info
GROUP BY cst_id
having COUNT(*)>1 or cst_id IS NULL;
-- Check unwanted spaces
select *
from silver.crm_cust_info
where cst_key != TRIM(cst_key)

-- Data Standardization and Consistency
select distinct cst_material_status
FROM silver.crm_cust_info

select distinct cst_gndr
from silver.crm_cust_info

select * from silver.crm_cust_info;

/*
silver.crm_prd_info
*/
select
prd_id,
count(*)
from silver.crm_prd_info
group by prd_id
having count(*)> 1 or prd_id IS NULL;
-- Check unwanted spaces
-- Expetation: No Results
select *
from silver.crm_prd_info
where prd_nm != TRIM(prd_nm);

select prd_cost from
silver.crm_prd_info
WHERE prd_cost < 0 or prd_cost is null;

select distinct prd_line
FROM silver.crm_prd_info;

select * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

select * from silver.crm_prd_info;

/*
silver.crm_sales_details
*/
 select * 
  From
  silver.crm_sales_details
  where 
  sls_order_dt > sls_ship_dt
  OR sls_order_dt > sls_due_dt
  ;
  -- sales = quantity * Price
  -- no negative, zeros, nulls allowed
select distinct 
sls_sales,
sls_quantity,
sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
order by sls_sales, sls_quantity, sls_price
;
select * FROM silver.crm_sales_details;

/*
silver.erp_cust_az12
*/
select distinct 
bdate
from silver.erp_cust_az12
where bdate	< '1924-01-01' or bdate > GETDATE();

select distinct 
gen
from silver.erp_cust_az12;

select *  
from silver.erp_cust_az12;

/*
silver.erp_loc_a101
*/
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
order by cntry;

SELECT * FROM silver.erp_loc_a101;
/*
silver.erp_px_cat_g1v2
*/
--- spaces?
select * from silver.erp_px_cat_g1v2
where cat != trim(cat);

select * from silver.erp_px_cat_g1v2
where subcat != trim(subcat);

select * from silver.erp_px_cat_g1v2
where maintance != trim(maintance);


--- Standardization and consistency?
select distinct maintance from silver.erp_px_cat_g1v2;
select distinct cat from silver.erp_px_cat_g1v2;
