/*
======================================
  Create Database and Schemas
======================================
Script Purpose:
  This script creates a new database named 'Datawarehouse'. It also sets up three schemas within the database: 'bronze', 'silver', and 'gold'.  
*/

USE master;
GO
CREATE DataWarehouse;
GO
USE DataWarehouse;
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
