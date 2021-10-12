-- Assignment 2 | DAT701

use FinanceDB
go

exec sp_columns Country
exec sp_columns Product
exec sp_columns ProductCost
exec sp_columns Promotion
exec sp_columns Region
exec sp_columns SalesKPI
exec sp_columns SalesOrder
exec sp_columns SalesOrderLineItem
exec sp_columns SalesPerson
exec sp_columns SalesRegion
exec sp_columns Segment

drop database if exists staging_FinanceDW;
go

create database staging_FinanceDW;
go

drop database if exists production_FinanceDW;
go

create database production_FinanceDW;
go

use staging_FinanceDW;
go

-- DDL Making tables and indexes and checks

drop procedure if exists create_tables
go

create procedure create_tables
as
begin
    
drop table if exists dim_date;
drop table if exists dim_product;
drop table if exists dim_promotion;
drop table if exists dim_sales_location;
drop table if exists dim_sales_person;
drop table if exists fact_order;
drop table if exists fact_sales;
drop table if exists fact_aggregated_values;