/*
======================================================================
DDL Script: Create Gold View: fact_sales
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

--Because this is transactional data, it is a fact table.
--We are going to use the dimension's surrogate keys instead of IDs
--to easily connect facts with dimensions. So we replace the sls_prd_key and sls_cust_key
--with the surrogate keys product_number and customer_id that we created in the dimension tables as we join.
--Using the general principles, update column names using naming conventions
--Quality check the view using select*from gold.fact_sales f
--Foreign key integrity (dimensions) - check if all dimension tables can successfully join to the fact table

CREATE VIEW gold.fact_sales AS
SELECT 
	sls_ord_num AS order_number,
	pr.product_key,  --this was originally sls_prd_key before the join
	cu.customer_key,  --this was originally sls_cust_id before the join
	sls_order_dt AS order_date,
	sls_ship_dt AS shipping_date,
	sls_due_dt AS due_date,
	sls_sales AS sales_amount,
	sls_quantity AS quantity,
	sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr   
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id

--Foreign key integrity check:

--SELECT *
--FROM gold.fact_sales f
--LEFT JOIN gold.dim_customers c
--ON c.customer_key = f.customer_key
--WHERE c.customer_key IS NULL

--SELECT *
--FROM gold.fact_sales f
--LEFT JOIN gold.dim_products p
--ON p.product_key = f.product_key
--WHERE p.product_key IS NULL 

