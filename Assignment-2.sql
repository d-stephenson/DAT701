-- DAT602 | Assignment 2
-- Data Warehouse

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

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

create database staging_FinanceDW;
go

create database production_FinanceDW;
go

use staging_FinanceDW;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Create tables procedure

drop procedure if exists create_tables
go

create procedure create_tables
as
begin
      
    drop table if exists FactSalePerformance;
    drop table if exists FactSaleOrder;
    drop table if exists DimDate;
    drop table if exists DimProduct;
    drop table if exists DimSalesLocation;
    drop table if exists DimSalesPerson;
    
    create table DimDate
    (
        DateKey                 int not null,
        FullDate                date not null,
        DayNumberOfWeek         tinyint not null,
        DayNameOfWeek           nvarchar(10) not null,
        WeekDayType             nvarchar(7) not null,
        DayNumberOfMonth        tinyint not null,
        DayNumberOfYear         smallint not null,
        WeekNumberOfYear        tinyint not null,
        MonthNameOfYear         nvarchar(10) not null,
        MonthNumberOfYear       tinyint not null,
        QuarterNumberCalendar   tinyint not null,
        QuarterNameCalendar     nchar(2) not null,
        SemesterNumberCalendar  tinyint not null,
        SemesterNameCalendar    nvarchar(15) not null,
        YearCalendar            smallint not null,
        MonthNumberFiscal       tinyint not null,
        QuarterNumberFiscal     tinyint not null,
        QuarterNameFiscal       nchar(2) not null,
        SemesterNumberFiscal    tinyint not null,
        SemesterNameFiscal      nvarchar(15) not null,
        YearFiscal              smallint not null
 
        constraint PK_DimDate primary key clustered  
        (
            DateKey asc
        )
    )
    
    create table DimProduct
    (
        ProductID tinyint primary key,
        ProductName varchar(24),
        PromotionYear int,
        Discount float,
        ManufacturingPrice float, 
        RRP float

    );

    create table DimSalesLocation
    (
        RegionID smallint primary key,
        CountryID tinyint,
        SegmentID tinyint,
        CountryName varchar(56),
        SegmentName varchar(48)
    );

    create table DimSalesPerson
    (
        SalesPersonID smallint primary key,
        FirstName varchar(64),
        LastName varchar(64),
        Gender varchar(20),
        HireDate date,
        DayOfBirth date,
        DaysOfLeave int,
        DaysOfSickLeave int,
        SalesYear int,
        KPI float
    );

    create table FactSalePerformance
    (
        [dateKey] int not null foreign key references DimDate([dateKey]),
        salespersonKey int foreign key references DimSalesPerson(salespersonKey),
        saleslocationKey int foreign key references DimSalesLocation(saleslocationKey),
        SalesYear int,
        KPI float
    );

    create table FactSaleOrder
    (
        [dateKey] int not null foreign key references DimDate([dateKey]),
        salespersonKey int foreign key references DimSalesPerson(salespersonKey),
        productKey int foreign key references DimProduct(productKey),
        promotionKey int foreign key references DimPromotion(promotionKey),
        saleslocationKey int foreign key references DimSalesLocation(saleslocationKey),
        SalesOrderID bigint,
        SalesOrderLineItemID bigint,
        SalesOrderLineNumber varchar(10),
        UnitsSold smallint,
        SalePrice float,
        ManufacturingPrice float,
        RRP float,
        Discount float
    );

end;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Execute create tables procedure

exec create_tables;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- DML Inserting into tables

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Insert into DimDate table
-- https://gist.github.com/sfrechette/0be7716d98d8aa107e64

declare @DateCalendarStart  datetime,
        @DateCalendarEnd    datetime,
        @FiscalCounter      datetime,
        @FiscalMonthOffset  int;
 
set @DateCalendarStart = '2005-01-01';
set @DateCalendarEnd = '2021-12-31';
 
-- Set this to the number of months to add or extract to the current date to get the beginning
-- of the Fiscal Year. Example: If the Fiscal Year begins July 1, assign the value of 6
-- to the @FiscalMonthOffset variable. Negative values are also allowed, thus if your
-- 2012 Fiscal Year begins in July of 2011, assign a value of -6.

set @FiscalMonthOffset = 0;
 
with DateDimension  
as
(
    select  @DateCalendarStart as DateCalendarValue,
            dateadd(m, @FiscalMonthOffset, @DateCalendarStart) as FiscalCounter
                 
    union all
     
    select  DateCalendarValue + 1,
            dateadd(m, @FiscalMonthOffset, (DateCalendarValue + 1)) as FiscalCounter
    from    DateDimension
    where   DateCalendarValue + 1 < = @DateCalendarEnd
)
 
insert into dbo.DimDate (DateKey, FullDate, DayNumberOfWeek, DayNameOfWeek, WeekDayType,
                        DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear, MonthNameOfYear,
                        MonthNumberOfYear, QuarterNumberCalendar, QuarterNameCalendar, SemesterNumberCalendar,
                        SemesterNameCalendar, YearCalendar, MonthNumberFiscal, QuarterNumberFiscal,
                        QuarterNameFiscal, SemesterNumberFiscal, SemesterNameFiscal, YearFiscal)
 
select  cast(convert(varchar(25), DateCalendarValue, 112) as int) as 'DateKey',
        cast(DateCalendarValue as date) as 'FullDate',
        datepart(weekday, DateCalendarValue) as 'DayNumberOfWeek',
        datename(weekday, DateCalendarValue) as 'DayNameOfWeek',
        case datename(dw, DateCalendarValue)
            when 'Saturday' then 'Weekend'
            when 'Sunday' then 'Weekend'
        else 'Weekday'
        end as 'WeekDayType',
        datepart(day, DateCalendarValue) as'DayNumberOfMonth',
        datepart(dayofyear, DateCalendarValue) as 'DayNumberOfYear',
        datepart(week, DateCalendarValue) as 'WeekNumberOfYear',
        datename(month, DateCalendarValue) as 'MonthNameOfYear',
        datepart(month, DateCalendarValue) as 'MonthNumberOfYear',
        datepart(quarter, DateCalendarValue) as 'QuarterNumberCalendar',
        'Q' + cast(datepart(quarter, DateCalendarValue) as nvarchar) as 'QuarterNameCalendar',
        case
            when datepart(month, DateCalendarValue) <= 6 then 1
            when datepart(month, DateCalendarValue) > 6 then 2
        end as 'SemesterNumberCalendar',
        case
            when datepart(month, DateCalendarValue) < = 6 then 'First Semester'
            when datepart(month, DateCalendarValue) > 6 then 'Second Semester'
        end as 'SemesterNameCalendar',
        datepart(year, DateCalendarValue) as 'YearCalendar',
        datepart(month, FiscalCounter) as 'MonthNumberFiscal',
        datepart(quarter, FiscalCounter) as 'QuarterNumberFiscal',
        'Q' + cast(datepart(quarter, FiscalCounter) as nvarchar) as 'QuarterNameFiscal',  
        case
            when datepart(month, FiscalCounter) < = 6 then 1
            when datepart(month, FiscalCounter) > 6 then 2
        end as 'SemesterNumberFiscal',  
        case
            when datepart(month, FiscalCounter) < = 6 then 'First Semester'
            when  datepart(month, FiscalCounter) > 6 then 'Second Semester'
        end as 'SemesterNameFiscal',            
        datepart(year, FiscalCounter) as 'YearFiscal'
from    DateDimension
order by
        DateCalendarValue
option (maxrecursion 0);
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Insert Into dimension tables procedure
-- https://docs.oracle.com/database/121/DWHSG/transform.htm#DWHSG8313

drop procedure if exists dim_insert_into;
go

create procedure dim_insert_into
as
begin

    -- from DimProduct
    insert into staging_FinanceDW.dbo.DimProduct
        (
            ProductID,    
            ProductName
        )
    select
        ProductID,
        ProductName
    from FinanceDB.dbo.Product;

    -- DimPromotion
    insert into staging_FinanceDW.dbo.DimPromotion
        (
            PromotionID,
            PromotionYear
        )
    select  
        PromotionID,
        PromotionYear
    from FinanceDB.dbo.Promotion;

    -- DimSalesLocation
    insert into staging_FinanceDW.dbo.DimSalesLocation
        (
            SalesRegionID,
            r.RegionID,
            CountryName,
            SegmentName
        )
    select
        SalesRegionID,
        r.RegionID,
        CountryName,
        SegmentName
    from FinanceDB.dbo.Country c
        inner join FinanceDB.dbo.Region r on c.CountryID = r.CountryID
        inner join FinanceDB.dbo.SalesRegion sr on r.RegionID = sr.RegionID
        inner join FinanceDB.dbo.Segment s on r.SegmentID = s.SegmentID;

    -- DimSalesPerson
    insert into staging_FinanceDW.dbo.DimSalesPerson
        (
            SalesPersonID,
            FirstName,
            LastName,
            Gender,
            HireDate,
            DayOfBirth,
            DaysOfLeave,
            DaysOfSickLeave
        )
    select
        SalesPersonID,
        FirstName,
        LastName,
        Gender,
        HireDate,
        DayOfBirth,
        DaysOfLeave,
        DaysOfSickLeave
    from FinanceDB.dbo.SalesPerson;

end;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Execute dim Insert Into procedure

exec dim_insert_into;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Insert Into fact tables procedure

--drop table if exists #FactOrder;
--go

--select * into #FactOrder from staging_FinanceDW.dbo.FactOrder where 1 = 0;
--go

--select * from #FactOrder;
--go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
drop procedure if exists fact_insert_into;
go

create procedure fact_insert_into
as
begin

    -- Fact_SalesRepPerformance
    insert into FactSalesRepPerformance
        (
            [dateKey],
            salespersonKey,
            saleslocationKey,
            SalesYear,
            KPI
        )
    select
        [dateKey],
        salespersonKey,
        saleslocationKey,
        SalesYear,
        KPI
    from
        staging_FinanceDW.dbo.DimDate dd
        inner join FinanceDB.dbo.SalesKPI sk on left(dd.[datekey], 4) = sk.SalesYear
        inner join staging_FinanceDW.dbo.DimSalesPerson dsp on sk.SalesPersonID = dsp.SalesPersonID
        inner join FinanceDB.dbo.SalesRegion sr on sk.SalesPersonID = sr.SalesPersonID
        inner join staging_FinanceDW.dbo.DimSalesLocation dsl on sr.SalesRegionID = dsl.SalesRegionID
    order by
        [dateKey],
        salespersonKey,
        saleslocationKey;

    -- Fact_SalesOrder
    insert into FactSalesOrder
        (
            [dateKey],
            salespersonKey,
            saleslocationKey,
            productKey,
            promotionKey,
            SalesOrderID,
            SalesOrderLineItemID,
            SalesOrderLineNumber,
            UnitsSold,
            SalePrice,
            ManufacturingPrice,
            RRP,
            Discount
        )
    select
        [dateKey],
        salespersonKey,
        saleslocationKey,
        productKey,
        promotionKey,
        so.SalesOrderID,
        SalesOrderLineItemID,
        SalesOrderLineNumber,
        UnitsSold,
        SalePrice,
        ManufacturingPrice,
        RRP,
        Discount
    from
        FinanceDB.dbo.SalesOrder so
        inner join staging_FinanceDW.dbo.DimDate dd on convert(int, convert(varchar(8), so.SalesOrderDate, 112)) = dd.[datekey]
        inner join staging_FinanceDW.dbo.DimSalesPerson dsp on so.SalesPersonID = dsp.SalesPersonID
        inner join staging_FinanceDW.dbo.DimSalesLocation dsl on so.SalesRegionID = dsl.SalesRegionID
        inner join FinanceDB.dbo.SalesOrderLineItem sli on so.SalesOrderID = sli.SalesOrderID
        inner join FinanceDB.dbo.Promotion pm on sli.PromotionID = pm.PromotionID
        inner join FinanceDB.dbo.Product p on pm.ProductID = p.ProductID
        inner join FinanceDB.dbo.ProductCost pc on p.ProductID = pc.ProductID
        inner join staging_FinanceDW.dbo.DimProduct dp on dp.ProductID = p.ProductID
        inner join staging_FinanceDW.dbo.DimPromotion dm on pm.PromotionID = dm.PromotionID
    order by
        [dateKey],
        salespersonKey,
        saleslocationKey,
        productKey;

    -- Fact_Calculatioms
    -- insert into FactCalculations
    --     (
    --         [dateKey],
    --         salespersonKey,
    --         saleslocationKey,
    --         productKey,
    --         promotionKey,
    --         TotalSale    
    --     )
    -- select
    --     [dateKey],
    --     salespersonKey,
    --     saleslocationKey,
    --     productKey,
    --     promotionKey,
    --     TotalSale
    -- from
    --     FinanceDB.dbo.SalesOrder so
    --     inner join staging_FinanceDW.dbo.DimDate dd on convert(int, convert(varchar(8), so.SalesOrderDate, 112)) = [dd.datekey]
    --     inner join staging_FinanceDW.dbo.DimSalesPerson dsp on so.SalesPersonID = dsp.SalesPersonID
    --     inner join staging_FinanceDW.dbo.DimSalesLocation dsl on so.SalesRegionID = dsl.SalesRegionID
    --     inner join SalesOrderLineItem sli on so.SalesOrderID = sli.SalesOrderID
    --     inner join FinanceDB.dbo.Promotiom pm on sli.PromotionID = pm.PromotionID
    --     inner join FinanceDB.dbo.Product p on pm.ProductID = p.ProductID
    --     inner join FinanceDB.dbo.ProductCost pc on p.ProductID = pc.ProductID
    --     inner join staging_FinanceDW.dbo.DimProduct dp on dp.ProductID = p.ProductID
    --     inner join staging_FinanceDW.dbo.DimPromotion dm on dp.PromotionID = p.PromotionID
    -- order by
    --     [dateKey],
    --     salespersonKey,
    --     saleslocationKey,
    --     productKey;

end;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Execute fact Insert Into procedure

exec fact_insert_into;
go  

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>