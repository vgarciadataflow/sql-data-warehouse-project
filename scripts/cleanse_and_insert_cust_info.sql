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
    -Run these checks 



--Check for primary key duplicates and/or null values
--Expectation: No results

SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1 OR cst_id IS NULL;


-- Focuses on primary key : Removes duplicates by using a rank (row number) function and only keeping  
-- the most recent entry and also removes any null values. 

SELECT
*
FROM (
	SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t	WHERE flag_last = 1

-- Check for unwanted spaces 
-- Use separate queries for each column you want to check
-- Expectation: No results

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

--After checking each column, add the trim function to the needed columns

--Truncating and Inserting Table 

PRINT '>> Truncating Table: silver.crm_cust_info';
TRUNCATE TABLE silver.crm_cust_info;
PRINT '>> Inserting Data Into: silver.crm_cust_info';
INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	 ELSE 'n/a'
END cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	 ELSE 'n/a'
END cst_gndr,
cst_create_date
FROM (
	SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
)t	WHERE flag_last = 1

-- Data Standardization & Consistency
-- Went back to the code above and added the CASE statments to change the M/F
-- and M/S to acutal words

--This directly below was a column with low cardinality and checks to see the distinct values so 
--the appropriate values can be added to the case statements above
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info
