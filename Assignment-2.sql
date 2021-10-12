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
    
drop table if exists Dimdate;
drop table if exists DimProduct;
drop table if exists DimPromotion;
drop table if exists DimSalesLocation;
drop table if exists DiSalesPerson;
drop table if exists FactOrder;
drop table if exists FactSales;
drop table if exists FactAggregatedValues;

-- https://www.codeproject.com/Articles/647950/Create-and-Populate-date-Dimension-for-Data-Wareho

create table Dimdate (
    [dateKey] int identity primary key, 
    [date] datetime,
    [FulldateUK] char(10), -- date in dd-MM-yyyy format
    [FulldateUSA] char(10),-- date in MM-dd-yyyy format
    [DayOfMonth] varchar(2), -- Field will hold day number of Month
    [DaySuffix] varchar(4), -- Apply suffix as 1st, 2nd ,3rd etc
    [DayName] varchar(9), -- Contains name of the day, Sunday, Monday 
    [DayOfWeekUSA] char(1),-- First Day Sunday=1 and Saturday=7
    [DayOfWeekUK] char(1),-- First Day Monday=1 and Sunday=7
    [DayOfWeekInMonth] varchar(2), --1st Monday or 2nd Monday in Month
    [DayOfWeekInYear] varchar(2),
    [DayOfQuarter] varchar(3),
    [DayOfYear] varchar(3),
    [WeekOfMonth] varchar(1),-- Week Number of Month 
    [WeekOfQuarter] varchar(2), --Week Number of the Quarter
    [WeekOfYear] varchar(2),--Week Number of the Year
    [Month] varchar(2), --Number of the Month 1 to 12
    [MonthName] varchar(9),--January, February etc
    [MonthOfQuarter] varchar(2),-- Month Number belongs to Quarter
    [Quarter] char(1),
    [QuarterName] varchar(9),--First,Second..
    [Year] char(4),-- Year value of date stored in Row
    [YearName] char(7), --CY 2012,CY 2013
    [MonthYear] char(10), --Jan-2013,Feb-2013
    [MMYYYY] char(6),
    [FirstDayOfMonth] date,
    [LastDayOfMonth] date,
    [FirstDayOfQuarter] date,
    [LastDayOfQuarter] date,
    [FirstDayOfYear] date,
    [LastDayOfYear] date,
    [IsHolidayUSA] bit,-- Flag 1=National Holiday, 0-No National Holiday
    [IsWeekday] bit,-- 0=Week End ,1=Week Day
    [HolidayUSA] varchar(50),--Name of Holiday in US
    [IsHolidayUK] bit null,-- Flag 1=National Holiday, 0-No National Holiday
    [HolidayUK] varchar(50) null --Name of Holiday in UK
);
go 