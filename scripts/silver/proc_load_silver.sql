/*
Stored Procedure: Load Silver Layer (Bronze -> Silver)
Usage: 
EXEC silver.load_silver;
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY 
		SET @batch_end_time = GETDATE();
		PRINT 'Loading silver';
		PRINT 'Loading CRM';
		SET @start_time = GETDATE();
		PRINT 'Truncating silver.crm_cust_info';
		TRUNCATE table silver.crm_cust_info;
		PRINT 'Inserting silver.crm_cust_info';
		insert into silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gndr,
		cst_create_date)

		select
		cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname,
		trim(cst_lastname) as cst_lastname,
		CASE WHEN upper(trim(cst_material_status)) = 'S' THEN 'Single'
			WHEN upper(trim(cst_material_status)) = 'M' THEN 'Married'
			ELSE 'n/a'
		END cst_material_status,
		CASE WHEN upper(trim(cst_gndr)) = 'F' THEN 'Female'
			WHEN upper(trim(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'n/a'
		END cst_gndr,
		cst_create_date
		from(
		select
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_cust_info
		where cst_id is not null
		)t where flag_last = 1;
		SET @end_time = GETDATE();
		PRINT 'Load Duration ' + cast(datediff(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		TRUNCATE table silver.crm_prd_info;
		INSERT INTO silver.crm_prd_info (
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
		  SELECT prd_id,
			replace(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
			prd_nm,
			isnull(prd_cost, 0) as prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,
			CAST(prd_start_dt AS DATE) as prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER (PARTITION by prd_key order by prd_start_dt)-1 AS DATE) as prd_end_dt
		  FROM bronze.crm_prd_info;
		truncate table silver.crm_sales_details;
		INSERT INTO silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case when sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
				ELSE cast(cast(sls_order_dt as varchar) AS DATE)
			end AS sls_order_dt,
			case when sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
				ELSE cast(cast(sls_ship_dt as varchar) AS DATE)
			end AS sls_ship_dt,	
			case when sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
				ELSE cast(cast(sls_due_dt as varchar) AS DATE)
			end AS sls_due_dt,
			case when sls_sales is null or sls_sales <=0 OR sls_sales != sls_quantity * abs(sls_price)
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END sls_sales,
			sls_quantity,
			case when sls_price IS NULL or sls_price <=0
				THEN sls_sales / NULLIF(sls_quantity,0)
				ELSE sls_price
			END as sls_price
		FROM bronze.crm_sales_details;
		truncate table silver.erp_cust_az12;
		insert into silver.erp_cust_az12 (cid, bdate, gen)
		select
		 CASE when cid LIKE 'NAS%' THEN SUBSTRING (cid, 4,LEN(cid))
			ELSE
			cid
		 END as cid,
		 CASE WHEN bdate > GETDATE() THEN NULL
		 ELSE
		 bdate
		 END bdate,
		CASE WHEN UPPER(trim(GEN))  IN ('F', 'FEMALE') THEN 'Female'
			 WHEN UPPER(trim(GEN))  IN ('M', 'MALE') THEN 'Male'
			 ELSE
			 'n/a'
		END gen
		from bronze.erp_cust_az12;
		truncate table silver.erp_loc_a101;
		INSERT INTO silver.erp_loc_a101
		(
		cid,
		cntry) 
		select 
		REPLACE(cid,'-', '') cid,
		CASE WHEN trim(cntry) = 'DE' THEN 'Germany'
			 WHEN trim(cntry) = 'US' OR trim(cntry) = 'USA' THEN 'United States'
			 when trim(cntry) = '' or cntry is NULL THEN 'n/a'
			 ELSE TRIM(cntry)
		END cntry
		from bronze.erp_loc_a101;
		truncate table silver.erp_px_cat_g1v2;
		INSERT INTO silver.erp_px_cat_g1v2
		(
		id, cat, subcat, maintance
		)
		select 
		id,
		cat,
		subcat,
		maintance
		from bronze.erp_px_cat_g1v2;

		SET @batch_end_time = GETDATE();
		PRINT 'Total Load Duration ' + cast(datediff(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		PRINT '=========================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error message' + ERROR_MESSAGE();
		PRINT 'Error number' + cast (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error state' + cast (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================';
	END CATCH
END
