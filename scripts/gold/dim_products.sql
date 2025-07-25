/*
======================================================================
DDL Script: Create Gold View: dim_products
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

--Started with master table prd_info and left joined px_cat
--Removed historical data (only if requested) with WHERE statement
--Left out prd_end_dt column from table because they were all going to show null
--Check quality of results - is product key unique?
--Using the general principles, update column names using naming conventions
--Check the quality of the view

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance AS maintenance,
	pn.prd_cost AS product_cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS product_start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL  --Filter out all historical data (no end date yet)
