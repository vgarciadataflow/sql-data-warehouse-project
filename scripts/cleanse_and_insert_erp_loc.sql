SELECT
REPLACE(cid, '-', '') cid,
CASE WHEN UPPER(TRIM(cntry)) IN ('USA', 'UNITED STATES', 'US') THEN 'United States'
	 WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
	 WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101

--Check to see if join columns will need to be transformed
--The '-' on cid will need to be removed

--Use this AFTER you have put the REPLACE function in to see if it worked
--This will show you if anything in this cid in this table is not in the cst_key in the cust_info table
--If you get any results, that would mess up a join, so you should expect no results

SELECT
REPLACE(cid, '-', '') cid,
cntry
FROM bronze.erp_loc_a101 WHERE REPLACE(cid, '-', '') NOT IN
(SELECT cst_key FROM silver.crm_cust_info)


--Data Standardization and Consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101

--Insert into silver layer

INSERT INTO silver.erp_loc_a101
(cid, cntry)
SELECT
REPLACE(cid, '-', '') cid,
CASE WHEN UPPER(TRIM(cntry)) IN ('USA', 'UNITED STATES', 'US') THEN 'United States'
	 WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
	 WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101


--Conduct quality check on silver layer
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
