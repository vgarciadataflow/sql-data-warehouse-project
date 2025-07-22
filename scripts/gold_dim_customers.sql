/*
======================================================================
DDL Script: Create Gold View: dim_customers
======================================================================
Script Purpose:
 This script creates views for the Gold layer in the data warehouse.
 The Gold layer represents the final dimension and fact tables (Star
 Schema).

 Each view performs transformations and combines data from the Silver
 layer to produce a clean, enriched, and business-ready dataset.

Usage:
  -These views can be queried directly for analytics and reporting.
======================================================================
*/

--Start from the master table, (cust_info in this case) then use left joins so no data gets left out
--If you use an inner join and the second table didn't have data on all the customers, you would lose data.
--As you keep joining, use a query from below to check for duplicates
--See data integration step below
--Using the general principles, update column names using naming conventions
--Generate a surrogate key, in this case we used a rank function (row number) to do this.
--Create the object (view)
--Check the quality of the view

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr  --CRM is the Master for gender info
		ELSE COALESCE(ca.gen, 'n/a')
		END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON	ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid


--Use this query after joining to see if the joins caused any duplicates

--SELECT cst_id, COUNT(*)
--FROM 
--(
	--SELECT
		--ci.cst_id,
		--ci.cst_key,
		--ci.cst_firstname,
		--ci.cst_lastname,
		--ci.cst_marital_status,
		--ci.cst_gndr,
		--ci.cst_create_date,
		--ca.bdate,
		--la.cntry
	--FROM silver.crm_cust_info ci
	--LEFT JOIN silver.erp_cust_az12 ca
	--ON	ci.cst_key = ca.cid
	--LEFT JOIN silver.erp_loc_a101 la
	--ON ci.cst_key = la.cid
--)t
--GROUP BY cst_id 
--HAVING COUNT(*) >1


--Data integration: Two tables had the gender column, use this query to 
--see what is going on with the columns in these two tables.
--Go to the experts within the company to see which column contains the
--most accurate info. Here it is the data coming from the CRM. 
--We will include a CASE statement that will pull data from the crm table first
--but if a value is n/a then it will pull from the second table.
--The coalesce function makes the null a 'n/a'
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr  --CRM is the Master for gender info
		ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON	ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1,2


--Check quality of the view

SELECT * FROM gold.dim_customers

SELECT DISTINCT gender FROM gold.dim_customers
