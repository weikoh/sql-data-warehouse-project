/*
=============================
Create Database and Schemas
=============================
Script Purpose:
  Creates new database and drops old if already exists: 'DataWarehouse'
  Creates three chemas: bronze, silver, gold
WARNING:
  It will delete old database!
*/
use master;
CREATE DATABASE DataWarehouse;
USE DataWarehouse;

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
