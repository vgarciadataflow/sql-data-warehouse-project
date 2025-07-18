SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 or LEN(sls_order_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END AS sls_order_dt,
CASE WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END AS sls_ship_dt,
CASE WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
	ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END AS sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details;

-- Checking for duplicates

SELECT
sls_cust_id,
COUNT(*)
FROM bronze.crm_sales_details
GROUP BY sls_cust_id
HAVING COUNT(*) >1 OR sls_cust_id IS NULL

-- Checking for unwanted spaces

SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Check for invalid dates : 

-- Checked for negatives but there were no results then checked for 0s and got results, so added the NULLIF above

SELECT 
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0

-- Checking to see if each date is 8 digits, got 2 results 
SELECT 
sls_order_dt
FROM bronze.crm_sales_details
WHERE LEN(sls_order_dt) != 8

--Since we had both 0s and results that were not 8 digits, we ended up adding a CASE statement to handle both

--Checking to make sure the shipping date comes after the order date. No results

SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_order_dt>sls_ship_dt OR sls_order_dt>sls_due_dt

--Checking to see if sales, quantity and price are positive numbers
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_sales<=0 OR sls_quantity <=0 OR sls_price <=0


--Checking to make sure the sales = quantity * price
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_sales != (sls_price * sls_quantity)

---Will clean the data (sales, quantity, price) using these 3 rules
---1. If Sales is negative, zero, or null, derive it using quantity and price
---2. If price is zero or null, calculate is using sales and quantity
---3. If price is negative, convert it to a positive value
