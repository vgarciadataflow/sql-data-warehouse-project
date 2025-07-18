SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, len(cid))
	ELSE cid
END AS cid,
CASE WHEN bdate > GETDATE() THEN NULL
    ELSE bdate
	END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12

--Identify out-of-range dates for the birthdate
--Report dates to determine how to handle 
--In this example, we will make them NULL

SELECT 
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

--Data Standardizatin and Consitency 
--Resulted in M,F, Male so we will fix with CASE
SELECT DISTINCT 
gen
FROM bronze.erp_cust_az12

--Insert into silver layer
	
TRUNCATE TABLE silver.erp_cust_az12;
PRINT '>> Inserting Data Into: silver.erp_cust_az12';

INSERT INTO silver.erp_cust_az12 (cid,bdate,gen)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, len(cid))
	ELSE cid
END AS cid,
CASE WHEN bdate > GETDATE() THEN NULL
    ELSE bdate
	END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12

--Conduct quality check on silver layer
