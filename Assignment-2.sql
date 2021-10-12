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

create table dim_date (
    [DateKey] int identity primary key, 
    [Date] DATETIME,
    [FullDateUK] CHAR(10), -- Date in dd-MM-yyyy format
    [FullDateUSA] CHAR(10),-- Date in MM-dd-yyyy format
    [DayOfMonth] VARCHAR(2), -- Field will hold day number of Month
    [DaySuffix] VARCHAR(4), -- Apply suffix as 1st, 2nd ,3rd etc
    [DayName] VARCHAR(9), -- Contains name of the day, Sunday, Monday 
    [DayOfWeekUSA] CHAR(1),-- First Day Sunday=1 and Saturday=7
    [DayOfWeekUK] CHAR(1),-- First Day Monday=1 and Sunday=7
    [DayOfWeekInMonth] VARCHAR(2), --1st Monday or 2nd Monday in Month
    [DayOfWeekInYear] VARCHAR(2),
    [DayOfQuarter] VARCHAR(3),
    [DayOfYear] VARCHAR(3),
    [WeekOfMonth] VARCHAR(1),-- Week Number of Month 
    [WeekOfQuarter] VARCHAR(2), --Week Number of the Quarter
    [WeekOfYear] VARCHAR(2),--Week Number of the Year
    [Month] VARCHAR(2), --Number of the Month 1 to 12
    [MonthName] VARCHAR(9),--January, February etc
    [MonthOfQuarter] VARCHAR(2),-- Month Number belongs to Quarter
    [Quarter] CHAR(1),
    [QuarterName] VARCHAR(9),--First,Second..
    [Year] CHAR(4),-- Year value of Date stored in Row
    [YearName] CHAR(7), --CY 2012,CY 2013
    [MonthYear] CHAR(10), --Jan-2013,Feb-2013
    [MMYYYY] CHAR(6),
    [FirstDayOfMonth] DATE,
    [LastDayOfMonth] DATE,
    [FirstDayOfQuarter] DATE,
    [LastDayOfQuarter] DATE,
    [FirstDayOfYear] DATE,
    [LastDayOfYear] DATE,
    [IsHolidayUSA] BIT,-- Flag 1=National Holiday, 0-No National Holiday
    [IsWeekday] BIT,-- 0=Week End ,1=Week Day
    [HolidayUSA] VARCHAR(50),--Name of Holiday in US
    [IsHolidayUK] BIT Null,-- Flag 1=National Holiday, 0-No National Holiday
    [HolidayUK] VARCHAR(50) Null --Name of Holiday in UK
);

go 