/*
===================================================================
Quality Checks
===================================================================
Script Purpose:
   This script performs various quality checks for data consistency, 
   accuracy, and standardization across the 'silver' schema. It includes
   checks for:
    -Null or duplicate primary keys.
    -Unwanted spaces in string fields.
    -Data standardization and consistency.
    -Invalid date ranges and orders.
    -Data consistency between related fields.

Usage Notes:
    -Run these checks after loading data into Silver layer
    -Investigate and resolve any discrepancies found during the checks.
===================================================================
*/

-- Cleansed version of crm_prd_info table:

SELECT
prd_id,
prd_key,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, --Extract category ID
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,   --Extract product key, used the LEN function because the length of the string varied
prd_nm,
ISNULL(prd_cost,0) AS prd_cost,
CASE
	WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Roads'
	WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
	WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
	ELSE 'n/a'
END AS prd_line,
CAST (prd_start_dt AS DATE) AS prd_start_dt,
CAST(
    DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt))
    AS DATE
  ) AS prd_end_dt   -- Calculates end date as one day before the next start date
FROM bronze.crm_prd_info;

-- Was checking how primary keys from tables were related to see how to perform split 
SELECT *
FROM bronze.crm_sales_details;

SELECT *
FROM bronze.erp_px_cat_g1v2;

--Checked for duplicates in null in prd_info table
SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

--Checked for unwanted spaces
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

--Check for nulls or negatives for cost
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL;

--Check for invalid date orders - end is before start date
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

IF OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
	prd_id		INT,
	cat_id		NVARCHAR(50),
	prd_key		NVARCHAR(50),
	prd_nm		NVARCHAR(50),
	prd_cost	INT,
	prd_line	NVARCHAR(50),
	prd_start_dt	DATE,
	prd_end_dt	DATE,
	dwh_create_date	DATETIME2	DEFAULT	GETDATE()
);

--Inserting the cleansed bronze prod_info table into the silver schema under silver.crm_prd_info

TRUNCATE TABLE silver.crm_prd_info;
PRINT '>> Inserting Data Into: silver.crm_prd_info';
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
SELECT
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
prd_nm,
ISNULL(prd_cost,0) AS prd_cost,
CASE
	WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Roads'
	WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
	WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
	ELSE 'n/a'
END AS prd_line,
CAST (prd_start_dt AS DATE) AS prd_start_dt,
CAST(
    DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt))
    AS DATE
  ) AS prd_end_dt
FROM bronze.crm_prd_info
