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
    
    -- DimDate
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
    
    -- DimProduct
    create table DimProduct
    (
        ProductID tinyint,
        ProductName varchar(24),
        PromotionYear int,
        Discount float,
        ManufacturingPrice float,
        RRP float
    );

    -- exec sp_helpindex 'DimProduct';

    drop index if exists idx_product on DimProduct;

    create clustered index idx_product
        on DimProduct
            (ProductID);

    -- DimSalesLocation
    create table DimSalesLocation
    (
        RegionID smallint,
        CountryID tinyint,
        SegmentID tinyint,
        CountryName varchar(56),
        SegmentName varchar(48)
    );

    -- exec sp_helpindex 'DimSalesLocation';

    drop index if exists idx_saleslocation on DimSalesLocation;

    create clustered index idx_saleslocation
        on DimSalesLocation
            (RegionID);

    -- DimSalesPerson
    create table DimSalesPerson
    (
        SalesPersonID smallint,
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

    -- exec sp_helpindex 'DimSalesPerson';

    drop index if exists idx_salesperson on DimSalesPerson;

    create clustered index idx_salesperson
        on DimSalesPerson
            (SalesPersonID);

    drop index if exists idx_salespersonname on DimSalesPerson;

    create nonclustered index idx_salespersonname
        on DimSalesPerson
            (FirstName, LastName);

    -- FactSalesPerformance
    create table FactSalePerformance
    (
        DateKey int not null foreign key references DimDate([dateKey]),
        SalesPersonID smallint,
        RegionID smallint,
        TotalYearSales_byRegion float,
        TotalYearKPI float,
        TotalYearSalesKPI_byRegion float,
        YearPerformance int,
        MonthPerformance int,
        SP_RankPerformance int,
        TotalYearProductSales_byRegion_bySP float,
        TotalTearPromotion_byRegion_bySP float
    );

    -- exec sp_helpindex 'FactSalePerformance';

    drop index if exists idx_fsp_group on FactSalePerformance;

    create nonclustered index idx_fsp_group
        on FactSalePerformance
            (SalesPersonID, RegionID);

    create table FactSaleOrder
    (
        DateKey int not null foreign key references DimDate([dateKey]),
        SalesPersonID smallint,
        RegionID smallint,
        ProductID tinyint,
        SalesOrderID bigint,
        UnitsSold smallint,
        SalePrice float,
        GrossProfit float,
        PromotionRate int,
        TotalMonthSales float,
        PercentageDiscount int,
        Margin float,
        TotalSalesPrice_byOrder_SP_Month float,
        TotalCost_byOrder_SP_Month float,
        TotalRRP_byOrder_SP_Month float,
        UniqueItems_byOrder_SP_Month int,
        TotalItems_byOrder_SP_Month int
    );

    -- exec sp_helpindex 'FactSaleOrder';

    drop index if exists idx_fsp_group on FactSaleOrder;

    create nonclustered index idx_fso_group
        on FactSaleOrder
            (SalesPersonID, RegionID, ProductID);

end;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Execute create tables procedure

exec create_tables;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Create partitions

-- Partition on datekey split into 4 five year intervals
drop partition scheme SalesPerformanceScheme;
drop partition function SP_Date;

create partition function SP_Date (int)
    as range right for values ('20010101', '20060101', '20110101', '20160101');
go

create partition scheme SalesPerformanceScheme
    as partition SP_Date ALL TO ([primary]);
go

-- Create Partition on SalesOrderID
drop index if exists idx_Fact_SP_Date on FactSalePerformance;
go

create clustered index idx_Fact_SP_Date on FactSalePerformance(DateKey)
  with (statistics_norecompute = off, ignore_dup_key = off,
        allow_row_locks = on, allow_page_locks = on)
  on SalesPerformanceScheme(DateKey);
go

-- Partition on datekey split into4 five year intervals
drop partition scheme SalesOrderScheme;
drop partition function SO_Date;

create partition function SO_Date (int)
    as range right for values ('20010101', '20060101', '20110101', '20160101');
go

create partition scheme SalesOrderScheme
    as partition SO_Date ALL TO ([primary]);
go

-- Create Partition on SalesOrderID
drop index if exists idx_Fact_SO_Date on FactSaleOrder;
go

create clustered index idx_Fact_SO_Date on FactSaleOrder(DateKey)
  with (statistics_norecompute = off, ignore_dup_key = off,
        allow_row_locks = on, allow_page_locks = on)
  on SalesOrderScheme(DateKey);
go

-- View Partitions
select
    ps.name,
    pf.name,
    boundary_id,
    value
from sys.partition_schemes ps
    inner join sys.partition_functions pf ON pf.function_id=ps.function_id
    inner join sys.partition_range_values prf ON pf.function_id=prf.function_id;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Create Recovery Model

-- View recovery model
select
    name,
    recovery_model_desc  
from
    sys.databases  
where name = 'model';  
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- DML Inserting into tables

-- Insert Into dimension tables procedure
-- https://docs.oracle.com/database/121/DWHSG/transform.htm#DWHSG8313

drop procedure if exists dim_insert_into;
go

create procedure dim_insert_into
as
begin

    -- DimDate
    -- https://gist.github.com/sfrechette/0be7716d98d8aa107e64

    declare @DateCalendarStart  datetime,
            @DateCalendarEnd    datetime,
            @FiscalCounter      datetime,
            @FiscalMonthOffset  int;
 
    set @DateCalendarStart = '2000-01-01';
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

    -- DimProduct
    insert into staging_FinanceDW.dbo.DimProduct
        (
            ProductID,    
            ProductName,
            PromotionYear,
            Discount,
            ManufacturingPrice,
            RRP
        )
    select
        p.ProductID,
        ProductName,
        PromotionYear,
        Discount,
        ManufacturingPrice,
        RRP
    from FinanceDB.dbo.ProductCost pc
        inner join FinanceDB.dbo.Product p on pc.ProductID = p.ProductID
        inner join FinanceDB.dbo.Promotion pm on p.ProductID = pm.ProductID;

    -- DimSalesLocation
    insert into staging_FinanceDW.dbo.DimSalesLocation
        (
            RegionID,
            CountryID,
            SegmentID,
            CountryName,
            SegmentName
        )
    select
        RegionID,
        c.CountryID,
        s.SegmentID,
        CountryName,
        SegmentName
    from FinanceDB.dbo.Region r  
        inner join FinanceDB.dbo.Country c on r.CountryID = c.CountryID
        inner join FinanceDB.dbo.Segment s on r.SegmentID = s.SegmentID;
        
    -- DimSalesPerson
    insert into staging_FinanceDW.dbo.DimSalesPerson
        (
            SalesPersonID,
            FullName, 
            FirstName,
            LastName,
            Gender,
            HireDate,
            DayOfBirth,
            DaysOfLeave,
            DaysOfSickLeave,
            SalesYear,
            KPI
        )
    select
        sp.SalesPersonID,
        concat(FirstName, ' ', LastName),
        FirstName,
        LastName,
        Gender,
        HireDate,
        DayOfBirth,
        DaysOfLeave,
        DaysOfSickLeave,
        SalesYear,
        KPI
    from FinanceDB.dbo.SalesPerson sp
        inner join FinanceDB.dbo.SalesKPI sk on sp.SalesPersonID = sk.SalesPersonID;

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
    insert into FactSalePerformance
        (
            dateKey,
            salesperson_key,
            RegionID,
            TotalYearSales_byRegion,
            TotalYearSalesKPI_byRegion,
            YearPerformance
        )
    select
        convert(int, convert(varchar(8), SalesOrderDate, 112)),
        sr.SalesPersonID,
        r.RegionID,
        sum(KPI),
        round(sum((SalePrice / KPI) * 100), 2)
    from FinanceDB.dbo.SalesOrderLineItem li
        inner join FinanceDB.dbo.SalesOrder so on li.SalesOrderID = so.SalesOrderID
        inner join FinanceDB.dbo.SalesRegion sr on so.SalesRegionID = sr.SalesRegionID
        inner join FinanceDB.dbo.Region r on sr.RegionID = r.RegionID
        inner join FinanceDB.dbo.Country c on r.CountryID = c.CountryID
        inner join FinanceDB.dbo.ProductCost pc on c.CountryID = pc.CountryID
        inner join FinanceDB.dbo.SalesPerson sp on sr.SalesPersonID = sp.SalesPersonID
        inner join FinanceDB.dbo.SalesKPI sk on sp.SalesPersonID = sk.SalesPersonID
    group by
        convert(int, convert(varchar(8), SalesOrderDate, 112)),
        sr.SalesPersonID,
        r.RegionID
    order by
        convert(int, convert(varchar(8), SalesOrderDate, 112)),
        SalesPersonID,        
        RegionID;
        
    -- Fact_SalesOrder
    insert into FactSalesOrder
        (
            [dateKey],
            SalesPersonID,
            RegionID,
            ProductID,
            SalesOrderID,
            UnitsSold,
            SalePrice,
            GrossProfit,         round(sum(SalePrice - ManufacturingPrice), 2),
            TotalYearProductSales,
            TotalYearPromotionSales,
            PromotionRate,
            TotalMonthSales
        )
    -- select
    --     [dateKey],
    --     salespersonKey,
    --     saleslocationKey,
    --     productKey,
    --     promotionKey,
    --     so.SalesOrderID,
    --     SalesOrderLineItemID,
    --     SalesOrderLineNumber,
    --     UnitsSold,
    --     SalePrice,
    --     ManufacturingPrice,
    --     RRP,
    --     Discount
    -- from
    --     FinanceDB.dbo.SalesOrder so
    --     inner join staging_FinanceDW.dbo.DimDate dd on convert(int, convert(varchar(8), so.SalesOrderDate, 112)) = dd.[datekey]
    --     inner join staging_FinanceDW.dbo.DimSalesPerson dsp on so.SalesPersonID = dsp.SalesPersonID
    --     inner join staging_FinanceDW.dbo.DimSalesLocation dsl on so.SalesRegionID = dsl.SalesRegionID
    --     inner join FinanceDB.dbo.SalesOrderLineItem sli on so.SalesOrderID = sli.SalesOrderID
    --     inner join FinanceDB.dbo.Promotion pm on sli.PromotionID = pm.PromotionID
    --     inner join FinanceDB.dbo.Product p on pm.ProductID = p.ProductID
    --     inner join FinanceDB.dbo.ProductCost pc on p.ProductID = pc.ProductID
    --     inner join staging_FinanceDW.dbo.DimProduct dp on dp.ProductID = p.ProductID
    --     inner join staging_FinanceDW.dbo.DimPromotion dm on pm.PromotionID = dm.PromotionID
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




