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

create database staging_FinanceDW;
go

create database production_FinanceDW;
go

use staging_FinanceDW;
go

drop procedure if exists create_tables
go

create procedure create_tables
as
begin
        
    drop table if exists Dimdate;
    drop table if exists DimProduct;
    drop table if exists DimPromotion;
    drop table if exists DimSalesLocation;
    drop table if exists DimSalesPerson;
    drop table if exists FactOrder;
    drop table if exists FactSales;
    drop table if exists FactAggregatedValues;

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
        productKey tinyint identity primary key,
        ProductName varchar(24)
    );

    create table DimPromotion
    (
        promotionKey smallint identity primary key,
        PromotionYear int
    );

    create table DimSalesLocation
    (
        saleslocationKey smallint identity primary key,
        CountryName varchar(56),
        SegmentName varchar(48)
    );

    create table DimSalesPerson
    (
        salespersonKey smallint identity primary key,
        FirstName varchar(64),
        LastName varchar(64),
        Gender varchar(20),
        HireDate date,
        DateOfBirth date,
        DateOfLeave date,
        DateOfSickLeave date
    );

    create table FactOrder
    (
        factorderKey int identity primary key,
        salespersonKey smallint foreign key references DimSalesPerson(salespersonKey),
        KPI float(15),
        saleslocationKey smallint foreign key references DimSalesLocation(saleslocationKey),
        promotionKey smallint foreign key references DimPromotion(promotionKey),
        productKey tinyint foreign key references DimProduct(productKey),
        [dateKey] int not null foreign key references DimDate([dateKey]),
        SalesOrderNumber varchar(48)
    );

    create table FactSales
    (
        factsalesKey int identity primary key,
        [dateKey] int not null foreign key references DimDate([dateKey]),
        productKey tinyint foreign key references DimProduct(productKey),
        promotionKey smallint foreign key references DimPromotion(promotionKey),
        saleslocationKey smallint foreign key references DimSalesLocation(saleslocationKey),
        SalesOrderLineNumber varchar(10),
        UnitsSold smallint,
        SalePrice float(8),
        ManufacturingPrice float(8),
        RRP float(8),
        Discount float(15)
    );

    create table FactAggregatedValues
    (
        factaggregatedvaluesKey int identity primary key,
        [dateKey] int not null foreign key references DimDate([dateKey]),
        productKey tinyint foreign key references DimProduct(productKey),
        promotionKey smallint foreign key references DimPromotion(promotionKey),
        saleslocationKey smallint foreign key references DimSalesLocation(saleslocationKey),
        salespersonKey smallint foreign key references DimSalesPerson(salespersonKey),
        TotalSale float(8),
        GrossProfit float(8),
        TotalYearlyKPI float(15),
        AnnualPerformance float(15),
        SalesRepRank int,
        GrossProfitRank int,
        TotalProductSales int,
        TotalPromotionalSales int,
        PromotionRate int,
        TotalItems int,
        Margin int,
        PercentageDiscount int,
        TotalRRP float(8),
        UniqueItems int
    );
end;
go

exec create_tables;
go

-- DML Inserting into tables

-- Dim Date 
-- https://gist.github.com/sfrechette/0be7716d98d8aa107e64

declare @DateCalendarStart  datetime,
        @DateCalendarEnd    datetime,
        @FiscalCounter      datetime,
        @FiscalMonthOffset  int;
 
set @DateCalendarStart = '2005-01-01';
set @DateCalendarEnd = '2015-12-31';
 
-- Set this to the number of months to add or extract to the current date to get the beginning
-- of the Fiscal Year. Example: If the Fiscal Year begins July 1, assign the value of 6
-- to the @FiscalMonthOffset variable. Negative values are also allowed, thus if your
-- 2012 Fiscal Year begins in July of 2011, assign a value of -6.
set @FiscalMonthOffset = 6;
 
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

-- Insert Into Procedure

-- https://docs.oracle.com/database/121/DWHSG/transform.htm#DWHSG8313

create procedure insert_into
as
begin

    -- DimProduct
    insert into staging_FinanceDW.dbo.DimProduct
        (
            ProductID,    
            ProductName
        )
    select 
        productKey,
        ProductName
    from FinanceDB.dbo.Product;

    -- DimPromotion
    insert into staging_FinanceDW.dbo.DimPromotion
        (
            promotionKey,
            PromotionYear
        )
    select  
        PromotionID, 
        PromotionYear
    from FinanceDB.dbo.Promotion;

    -- DimSalesLocation
    insert into staging_FinanceDW.dbo.DimSalesLocation
        (
            saleslocationKey,
            CountryName,
            SegmentName
        )
    select 
        RegionID,
        CountryName,
        SegmentName
    from FinanceDB.dbo.Country c
        inner join FinanceDB.dbo.Region r on c.CountryID = r.CountryID
        inner join FinanceDB.dbo.Segment s on r.SegmentID = s.SegmentID;

    -- DimSalesPerson
    insert into staging_FinanceDW.dbo.DimSalesPerson
        (
            salespersonKey,
            FirstName,
            LastName,
            Gender,
            HireDate,
            DateOfBirth,
            DateOfLeave,
            DateOfSickLeave
        )
    select 
        SalesPersondID,
        FirstName,
        LastName,
        Gender,
        HireDate,
        DateOfBirth,
        DateOfLeave,
        DateOfSickLeave
    from FinanceDB.dbo.SalesPerson;

    -- FactOrders
    insert into staging_FinanceDW.dbo.FactOrder
        (
            salespersonKey,
            KPI,
            saleslocationKey,
            promotionKey,
            productKey,
            [dateKey],
            SalesOrderNumber
        )
    select
        fo1.SalesPersonID,
        KPI,
        RegionID,
        PromotionID,
        ProductID,
        SalesOrderDate,
        SalesOrderNumber
    from
        (
            select
                sp.SalesPersonID,
                KPI,
                SalesYear
            from SalesPerson sp
                inner join SalesKPI sk on sp.SalesPersonID = sk.SalesPersonID
        ) fo1
        inner join
        (
            select
                sp.SalesPersonID,
                RegionID,
                PromotionID,
                ProductID,
                convert(varchar(10), SalesOrderDate, 111) as SalesOrderDate,
                SalesOrderNumber
            from SalesPerson sp
                inner join SalesRegion sr on sp.SalesPersonID = sr.SalesPersonID
                inner join SalesOrder so on sp.SalesPersonID = so.SalesPersonID
                inner join SalesOrderLineItem sli on so.SalesOrderID = sli.SalesOrderID
        ) fo2
    on fo1.SalesPersonID = fo2.SalesPersonID
        and SalesYear = year(SalesOrderDate)
    order by
        SalesOrderDate desc,
        fo1.SalesPersonID,
        RegionID,
        ProductID;

    -- FactSales 
    insert into staging_FinanceDW.dbo.FactSales
        (
            factsalesKey,
            [dateKey],
            productKey,
            promotionKey,
            saleslocationKey,
            SalesOrderLineNumber,
            UnitsSold,
            SalePrice,
            ManufacturingPrice,
            RRP,
            Discount
        )
    select
        fo1.SalesPersonID,
        KPI,
        RegionID,
        PromotionID,
        ProductID,
        SalesOrderDate,
        SalesOrderNumber
    from
        (
            select
                sp.SalesPersonID,
                KPI,
                SalesYear
            from SalesPerson sp
                inner join SalesKPI sk on sp.SalesPersonID = sk.SalesPersonID
        ) fo1
        inner join
        (
            select
                sp.SalesPersonID,
                RegionID,
                PromotionID,
                ProductID,
                convert(varchar(10), SalesOrderDate, 111) as SalesOrderDate,
                SalesOrderNumber
            from SalesPerson sp
                inner join SalesRegion sr on sp.SalesPersonID = sr.SalesPersonID
                inner join SalesOrder so on sp.SalesPersonID = so.SalesPersonID
                inner join SalesOrderLineItem sli on so.SalesOrderID = sli.SalesOrderID
        ) fo2
    on fo1.SalesPersonID = fo2.SalesPersonID
        and SalesYear = year(SalesOrderDate)
    order by
        SalesOrderDate desc,
        fo1.SalesPersonID,
        RegionID,
        ProductID;      



end;
go

exec insert_into;
go

