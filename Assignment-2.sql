-- DAT602 | Assignment 2
-- Data Warehouse

exec sp_columns Country;
exec sp_columns Product;
exec sp_columns ProductCost;
exec sp_columns Promotion;
exec sp_columns Region;
exec sp_columns SalesKPI;
exec sp_columns SalesOrder;
exec sp_columns SalesOrderLineItem;
exec sp_columns SalesPerson;
exec sp_columns SalesRegion;
exec sp_columns Segment;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

create database staging_FinanceDW;
go

create database production_FinanceDW;
go

use production_FinanceDW;
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
        PromotionYear int
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
        DaysOfSickLeave int
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
        TotalAnnualKPI float,
        AnnualSalesPrice float,
        AnnualPerformance float,
        TotalMonthlylKPI float,
        MonthlySalesPrice float,
        MonthlyPerformance float
    );

    -- exec sp_helpindex 'FactSalePerformance';

    drop index if exists idx_fsp_group on FactSalePerformance;

    create nonclustered index idx_fsp_group
        on FactSalePerformance
            (SalesPersonID, RegionID);

    create table FactSaleOrder
    (
        DateKey int not null foreign key references DimDate([dateKey]),
        SalesOrderID bigint,
        RegionID smallint,
        SalesPersonID smallint,
        ProductID tinyint,
        UnitsSold smallint,
        SalePrice float,
        TotalSalesPrice float,
        TotalCost float,
        GrossProfit float,
        TotalRRP float,
        TotalItems int,
        PromotionRate int,
        Margin float,
        PercentageDiscount float
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

drop procedure if exists create_partitions
go

create procedure create_partitions
as
begin

    drop partition scheme DateScheme;
    drop partition function Key_Date;
    drop index if exists idx_Fact_SO_Date on FactSaleOrder;
    drop index if exists idx_Fact_SP_Date on FactSalePerformance;

    -- Partition on datekey split into 4 five year intervals
    create partition function Key_Date (int)
        as range right for values ('20000101', '20050101', '20100101', '20150101');

    create partition scheme DateScheme
        as partition Key_Date ALL TO ([primary]);

    -- Create Partition on FactSalePerformance
    create clustered index idx_Fact_SP_Date on FactSalePerformance(DateKey)
      with (statistics_norecompute = off, ignore_dup_key = off,
            allow_row_locks = on, allow_page_locks = on)
      on DateScheme(DateKey);

    -- Create Partition on FactSaleOrder
    create clustered index idx_Fact_SO_Date on FactSaleOrder(DateKey)
      with (statistics_norecompute = off, ignore_dup_key = off,
            allow_row_locks = on, allow_page_locks = on)
      on DateScheme(DateKey)
end;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Execute create partitions procedure

exec create_partitions;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

exec sp_helpindex 'FactSalePerformance';
go

exec sp_helpindex 'FactSaleOrder';
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

-- Inserting into tables

-- https://docs.oracle.com/database/121/DWHSG/transform.htm#DWHSG8313

drop procedure if exists insert_into;
go

create procedure insert_into
as
begin

    -- DimDate
    -- https://gist.github.com/sfrechette/0be7716d98d8aa107e64

    declare @DateCalendarStart  datetime,
            @DateCalendarEnd    datetime,
            @FiscalCounter      datetime,
            @FiscalMonthOffset  int;
 
    set @DateCalendarStart = '2000-01-01';
    set @DateCalendarEnd = '2030-12-31';
 
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
    insert into production_FinanceDW.dbo.DimProduct
        (
            ProductID,    
            ProductName,
            PromotionYear
        )
    select
        p.ProductID,
        ProductName,
        PromotionYear
    from FinanceDB.dbo.Product p
        inner join FinanceDB.dbo.Promotion pm on p.ProductID = pm.ProductID;

    -- DimSalesLocation
    insert into production_FinanceDW.dbo.DimSalesLocation
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
    insert into production_FinanceDW.dbo.DimSalesPerson
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

    -- Fact_SalePerformance
    with fsp_1(SalesYear, SalesPersonID, RegionID, CountryName, SegmentName, TotalYearlyKPI, TotalMonthlyKPI) as  
        (
        select
            SalesYear,
            sp.SalesPersonID,
            r.RegionID,
            CountryName,
            SegmentName,
            sum(KPI) as TotalYearlyKPI,
            sum(KPI) / 12 as TotalMonthlyKPI
        from FinanceDB.dbo.SalesPerson sp
            inner join FinanceDB.dbo.SalesKPI sk on sp.SalesPersonID = sk.SalesPersonID
            inner join FinanceDB.dbo.SalesRegion sr on sp.SalesPersonID = sr.SalesPersonID
            inner join FinanceDB.dbo.Region r on sr.RegionID = r.RegionID
            inner join FinanceDB.dbo.Segment s on r.SegmentID = s.SegmentID
            inner join FinanceDB.dbo.Country c on r.CountryID = c.CountryID
        group by
            SalesYear,
            sp.SalesPersonID,
            r.RegionID,
            CountryName,
            SegmentName
        ),
        fsp_2(SalesYear, CountryName, SegmentName, TotalSalesPrice) as  
        (
        select
            year(SalesOrderDate) as SalesYear,
            CountryName,
            SegmentName,
            sum(SalePrice) as TotalSalesPrice
        from FinanceDB.dbo.SalesRegion sr
            inner join FinanceDB.dbo.Region r on sr.RegionID = r.RegionID
            inner join FinanceDB.dbo.Segment s on r.SegmentID = s.SegmentID
            inner join FinanceDB.dbo.Country c on r.CountryID = c.CountryID
            inner join FinanceDB.dbo.SalesOrder so on sr.SalesRegionID = so.SalesRegionID
            inner join FinanceDB.dbo.SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
        group by
            year(SalesOrderDate),
            CountryName,
            SegmentName
        ),
        fsp_3 (
                SalesDate,
                SalesYear,
                SalesMonth,
                CountryName,
                SegmentName,
                TotalMonthlyPrice
                ) as
        (
        select distinct
            concat(year(SalesOrderDate), RIGHT('0' + CONVERT(VARCHAR(2), Month( SalesOrderDate )), 2), '01') as SalesDate,
            year(SalesOrderDate) as SalesYear,
            month(SalesOrderDate) as SalesMonth,
            CountryName,
            SegmentName,
            sum(SalePrice) as TotalMonthlyPrice
        from FinanceDB.dbo.SalesOrder so
            inner join FinanceDB.dbo.SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
            inner join FinanceDB.dbo.SalesRegion sr on so.SalesRegionID = sr.SalesRegionID
            inner join FinanceDB.dbo.Region r on sr.RegionID = r.RegionID
            inner join FinanceDB.dbo.Segment s on r.SegmentID = s.SegmentID
            inner join FinanceDB.dbo.Country c on r.CountryID = c.CountryID
        group by
            concat(year(SalesOrderDate), RIGHT('0' + CONVERT(VARCHAR(2), Month( SalesOrderDate )), 2), '01'),
            year(SalesOrderDate),
            month(SalesOrderDate),
            CountryName,
            SegmentName
        )
        insert into production_FinanceDW.dbo.FactSalePerformance
            select
                SalesDate,
                fsp_1.SalesPersonID,
                fsp_1.RegionID,
                TotalYearlyKPI,
                TotalSalesPrice,
                round(sum((TotalSalesPrice / TotalYearlyKPI) * 100), 2) as AnnualPerformance,
                TotalMonthlyKPI,
                TotalMonthlyPrice,
                round(sum((TotalMonthlyPrice / TotalMonthlyKPI) * 100), 2) as AnnualPerformance
            from fsp_1
                inner join fsp_2 on fsp_1.SalesYear = fsp_2.SalesYear
                    and fsp_1.CountryName = fsp_2.CountryName
                    and fsp_1.SegmentName = fsp_2.SegmentName
                inner join fsp_3 on fsp_1.SalesYear = fsp_3.SalesYear
                    and fsp_1.CountryName = fsp_3.CountryName
                    and fsp_1.SegmentName = fsp_3.SegmentName
            group by
                SalesDate,
                fsp_1.SalesPersonID,
                fsp_1.RegionID,
                TotalYearlyKPI,
                TotalSalesPrice,
                TotalMonthlyKPI,
                TotalMonthlyPrice
            order by
                fsp_3.SalesDate;
        
    -- Fact_SaleOrder
    with fso_1(
            SaleYear,
            RegionID,
            SalesPersonID,
            ProductID,
            SalesOrderID,
            UnitsSold,
            SalePrice
            ) as
        (
        select distinct
            convert(int, convert(varchar(8), SalesOrderDate, 112)) as SaleYear,
            sr.RegionID,
            so.SalesPersonID,
            li.ProductID,
            so.SalesOrderID,
            li.UnitsSold,
            li.SalePrice
        from FinanceDB.dbo.SalesOrderLineItem li
            inner join FinanceDB.dbo.SalesOrder so on li.SalesOrderID = so.SalesOrderID
            inner join FinanceDB.dbo.SalesRegion sr on so.SalesRegionID = sr.SalesRegionID
        ),
        fso_2(
            SaleYear,
            RegionID,
            SalesPersonID,
            ProductID,
            SalesOrderID,
            TotalSalesPrice,
            TotalCost,
            TotalRRP,
            TotalItems,
            GrossProfit,
            PromotionRate,
            Margin,
            PercentageDiscount
            ) as
        (
        select
            convert(int, convert(varchar(8), SalesOrderDate, 112)) as SaleYear,
            sr.RegionID,
            sr.SalesPersonID,
            pc.ProductID,
            so.SalesOrderID,
            sum(li.SalePrice * li.UnitsSold) as TotalSalesPrice,
            sum(pc.ManufacturingPrice * li.UnitsSold) as TotalCost,
            sum(pc.RRP * li.UnitsSold) as TotalRRP,
            sum(li.UnitsSold) as TotalItems,
            sum((li.SalePrice - pc.ManufacturingPrice) * li.UnitsSold) as GrossProfit,
            sum(case when li.PromotionID = 0 then 0.0 else 1.0 end) / count(*) as PromotionRate,
            round(case
                when sum(SalePrice) = 0 then 0
                else sum(SalePrice - (pc.ManufacturingPrice * li.UnitsSold)) / sum(SalePrice)
                end, 2) as Margin,
            round(sum((pc.RRP * li.UnitsSold) - SalePrice) / sum(pc.RRP * li.UnitsSold), 2) as PercentageDiscount
        from FinanceDB.dbo.ProductCost pc
            inner join FinanceDB.dbo.SalesOrderLineItem li on pc.ProductID = li.ProductID
            inner join FinanceDB.dbo.SalesOrder so on li.SalesOrderID = so.SalesOrderID
            inner join FinanceDB.dbo.SalesRegion sr on so.SalesRegionID = sr.SalesRegionID
        group by
            convert(int, convert(varchar(8), SalesOrderDate, 112)),
            sr.RegionID,
            sr.SalesPersonID,
            pc.ProductID,
            so.SalesOrderID
        )
       insert into production_FinanceDW.dbo.FactSaleOrder
            select
                fso_1.SaleYear,
                fso_1.SalesOrderID,
                fso_1.RegionID,
                fso_1.SalesPersonID,
                fso_1.ProductID,
                fso_1.UnitsSold,
                fso_1.SalePrice,
                fso_2.TotalSalesPrice,
                fso_2.TotalCost,
                fso_2.GrossProfit,
                fso_2.TotalRRP,
                fso_2.TotalItems,
                fso_2.PromotionRate,
                fso_2.Margin,
                fso_2.PercentageDiscount
            from fso_1
                inner join fso_2 on fso_1.SaleYear = fso_2.SaleYear
                    and fso_1.RegionID = fso_2.RegionID
                    and fso_1.SalesPersonID = fso_2.SalesPersonID
                    and fso_1.ProductID = fso_2.ProductID
                    and fso_1.SalesOrderID = fso_2.SalesOrderID
            order by
                fso_1.SaleYear,
                fso_1.RegionID,
                fso_1.SalesPersonID,
                fso_1.ProductID,
                fso_1.SalesOrderID;

end;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Execute Insert Into procedure

exec insert_into;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

select * from FactSalePerformance;
go

select * from FactSaleOrder;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Alternative DimDate based on dates in FinanceDB

drop table if exists DimDate_AltVersion;
go

create table DimDate_AltVersion
(
    [Date_Key] datetime primary key,
    [Day] int not null,
    [Month] int not null,
    [Year] int not null
);
go

drop view if exists DateView_AltVersion;
go

create view DateView_AltVersion as
    with dd_av(NewDate) as
        (
            select SalesOrderDate from FinanceDB.dbo.SalesOrder
            union
            select convert(datetime, convert(varchar(10), SalesYear)) from FinanceDB.dbo.SalesKPI
            union
            select convert(datetime, convert(varchar(10), PromotionYear)) from FinanceDB.dbo.Promotion
        )
    select distinct
        NewDate as [Date_Key],
        day(NewDate) as [Day],
        month(NewDate) as [Month],
        year(NewDate) as [Year]
    from dd_av
    where
        NewDate is not null;
go

select * from DateView_AltVersion
    order by [Date_Key] desc;
go

merge into DimDate_AltVersion as Target
using DateView_AltVersion  as Source
on Target.[Date_Key] = Source.[Date_Key]
when matched then
    update set
        Target.[Date_Key] = Source.[Date_Key],
        Target.[Day] = Source.[Day],
        Target.[Month] = Source.[Month],
        Target.[Year] = Source.[Year]
when not matched then
    insert ([Date_Key], [Day], [Month], [Year])
    values (Source.[Date_Key], Source.[Day], Source.[Month], Source.[Year]);
go

select * from DateView_AltVersion;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Upsert & Merge Testing with DimProduct

    merge into production_FinanceDW.dbo.DimProduct as Target
    using FinanceDB.dbo.Product as Source
       on Target.ProductID = Source.ProductID
    when matched then
       update set
           Target.ProductName = Source.ProductName
    when not matched then
       insert (   
                   ProductName
               )
       values (
                   Source.ProductName
               );
    go

    select * from DimProduct;
    go

    -- Test merge procedure
    update FinanceDB.dbo.Product
    set ProductName = 'Carretera'
    where ProductName = 'Carretera_v2';
    go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Views for fact tables

-- Fact_SalePerformance
drop view fact_sp;
go

create view fact_sp as
    with fsp_1(SalesYear, SalesPersonID, RegionID, CountryName, SegmentName, TotalYearlyKPI, TotalMonthlyKPI) as  
        (
        select
            SalesYear,
            sp.SalesPersonID,
            r.RegionID,
            CountryName,
            SegmentName,
            sum(KPI) as TotalYearlyKPI,
            sum(KPI) / 12 as TotalMonthlyKPI
        from FinanceDB.dbo.SalesPerson sp
            inner join FinanceDB.dbo.SalesKPI sk on sp.SalesPersonID = sk.SalesPersonID
            inner join FinanceDB.dbo.SalesRegion sr on sp.SalesPersonID = sr.SalesPersonID
            inner join FinanceDB.dbo.Region r on sr.RegionID = r.RegionID
            inner join FinanceDB.dbo.Segment s on r.SegmentID = s.SegmentID
            inner join FinanceDB.dbo.Country c on r.CountryID = c.CountryID
        group by
            SalesYear,
            sp.SalesPersonID,
            r.RegionID,
            CountryName,
            SegmentName
        ),
        fsp_2(SalesYear, CountryName, SegmentName, TotalSalesPrice) as  
        (
        select
            year(SalesOrderDate) as SalesYear,
            CountryName,
            SegmentName,
            sum(SalePrice) as TotalSalesPrice
        from FinanceDB.dbo.SalesRegion sr
            inner join FinanceDB.dbo.Region r on sr.RegionID = r.RegionID
            inner join FinanceDB.dbo.Segment s on r.SegmentID = s.SegmentID
            inner join FinanceDB.dbo.Country c on r.CountryID = c.CountryID
            inner join FinanceDB.dbo.SalesOrder so on sr.SalesRegionID = so.SalesRegionID
            inner join FinanceDB.dbo.SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
        group by
            year(SalesOrderDate),
            CountryName,
            SegmentName
        ),
        fsp_3 (
                SalesDate,
                SalesYear,
                SalesMonth,
                CountryName,
                SegmentName,
                TotalMonthlyPrice
                ) as
        (
        select distinct
            concat(year(SalesOrderDate), RIGHT('0' + CONVERT(VARCHAR(2), Month( SalesOrderDate )), 2), '01') as SalesDate,
            year(SalesOrderDate) as SalesYear,
            month(SalesOrderDate) as SalesMonth,
            CountryName,
            SegmentName,
            sum(SalePrice) as TotalMonthlyPrice
        from FinanceDB.dbo.SalesOrder so
            inner join FinanceDB.dbo.SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
            inner join FinanceDB.dbo.SalesRegion sr on so.SalesRegionID = sr.SalesRegionID
            inner join FinanceDB.dbo.Region r on sr.RegionID = r.RegionID
            inner join FinanceDB.dbo.Segment s on r.SegmentID = s.SegmentID
            inner join FinanceDB.dbo.Country c on r.CountryID = c.CountryID
        group by
            concat(year(SalesOrderDate), RIGHT('0' + CONVERT(VARCHAR(2), Month( SalesOrderDate )), 2), '01'),
            year(SalesOrderDate),
            month(SalesOrderDate),
            CountryName,
            SegmentName
        )
    select
        SalesDate,
        fsp_1.SalesPersonID,
        fsp_1.RegionID,
        TotalYearlyKPI,
        TotalSalesPrice,
        round(sum((TotalSalesPrice / TotalYearlyKPI) * 100), 2) as AnnualPerformance,
        TotalMonthlyKPI,
        TotalMonthlyPrice,
        round(sum((TotalMonthlyPrice / TotalMonthlyKPI) * 100), 2) as MonthlylPerformance
    from fsp_1
        inner join fsp_2 on fsp_1.SalesYear = fsp_2.SalesYear
            and fsp_1.CountryName = fsp_2.CountryName
            and fsp_1.SegmentName = fsp_2.SegmentName
        inner join fsp_3 on fsp_1.SalesYear = fsp_3.SalesYear
            and fsp_1.CountryName = fsp_3.CountryName
            and fsp_1.SegmentName = fsp_3.SegmentName
    group by
        SalesDate,
        fsp_1.SalesPersonID,
        fsp_1.RegionID,
        TotalYearlyKPI,
        TotalSalesPrice,
        TotalMonthlyKPI,
        TotalMonthlyPrice;
go

-- Fact_SaleOrder
drop view fact_so;
go

create view fact_so as
    with fso_1(
            SaleYear,
            RegionID,
            SalesPersonID,
            ProductID,
            SalesOrderID,
            UnitsSold,
            SalePrice
            ) as
        (
        select distinct
            convert(int, convert(varchar(8), SalesOrderDate, 112)) as SaleYear,
            sr.RegionID,
            so.SalesPersonID,
            li.ProductID,
            so.SalesOrderID,
            li.UnitsSold,
            li.SalePrice
        from FinanceDB.dbo.SalesOrderLineItem li
            inner join FinanceDB.dbo.SalesOrder so on li.SalesOrderID = so.SalesOrderID
            inner join FinanceDB.dbo.SalesRegion sr on so.SalesRegionID = sr.SalesRegionID
        ),
        fso_2(
            SaleYear,
            RegionID,
            SalesPersonID,
            ProductID,
            SalesOrderID,
            TotalSalesPrice,
            TotalCost,
            TotalRRP,
            TotalItems,
            GrossProfit,
            PromotionRate,
            Margin,
            PercentageDiscount
            ) as
        (
        select
            convert(int, convert(varchar(8), SalesOrderDate, 112)) as SaleYear,
            sr.RegionID,
            sr.SalesPersonID,
            pc.ProductID,
            so.SalesOrderID,
            sum(li.SalePrice * li.UnitsSold) as TotalSalesPrice,
            sum(pc.ManufacturingPrice * li.UnitsSold) as TotalCost,
            sum(pc.RRP * li.UnitsSold) as TotalRRP,
            sum(li.UnitsSold) as TotalItems,
            sum((li.SalePrice - pc.ManufacturingPrice) * li.UnitsSold) as GrossProfit,
            sum(case when li.PromotionID = 0 then 0.0 else 1.0 end) / count(*) as PromotionRate,
            round(case
                when sum(SalePrice) = 0 then 0
                else sum(SalePrice - (pc.ManufacturingPrice * li.UnitsSold)) / sum(SalePrice)
                end, 2) as Margin,
            round(sum((pc.RRP * li.UnitsSold) - SalePrice) / sum(pc.RRP * li.UnitsSold), 2) as PercentageDiscount
        from FinanceDB.dbo.ProductCost pc
            inner join FinanceDB.dbo.SalesOrderLineItem li on pc.ProductID = li.ProductID
            inner join FinanceDB.dbo.SalesOrder so on li.SalesOrderID = so.SalesOrderID
            inner join FinanceDB.dbo.SalesRegion sr on so.SalesRegionID = sr.SalesRegionID
        group by
            convert(int, convert(varchar(8), SalesOrderDate, 112)),
            sr.RegionID,
            sr.SalesPersonID,
            pc.ProductID,
            so.SalesOrderID
        )
        select
            fso_1.SaleYear,
            fso_1.SalesOrderID,
            fso_1.RegionID,
            fso_1.SalesPersonID,
            fso_1.ProductID,
            fso_1.UnitsSold,
            fso_1.SalePrice,
            fso_2.TotalSalesPrice,
            fso_2.TotalCost,
            fso_2.GrossProfit,
            fso_2.TotalRRP,
            fso_2.TotalItems,
            fso_2.PromotionRate,
            fso_2.Margin,
            fso_2.PercentageDiscount
        from fso_1
            inner join fso_2 on fso_1.SaleYear = fso_2.SaleYear
                and fso_1.RegionID = fso_2.RegionID
                and fso_1.SalesPersonID = fso_2.SalesPersonID
                and fso_1.ProductID = fso_2.ProductID
                and fso_1.SalesOrderID = fso_2.SalesOrderID;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Merge tables

drop procedure if exists table_merge;
go

create procedure table_merge
as
begin

    -- DimProduct
    with dp_cte (ProductID, ProductName, PromotionYear) as
    (
        select
            p.ProductID,
            p.ProductName,
            pm.PromotionYear
        from FinanceDB.dbo.Product p
            inner join FinanceDB.dbo.Promotion pm on p.ProductID = pm.ProductID
    )
    merge into production_FinanceDW.dbo.DimProduct as Target
    using dp_cte as Source
        on Target.ProductID = Source.ProductID
            and Target.ProductName = Source.ProductName
            and Target.PromotionYear = Source.PromotionYear
    when matched then
        update set
            Target.ProductName = Source.ProductName,
            Target.PromotionYear = Source.PromotionYear
    when not matched then
        insert (   
                    ProductName,
                    PromotionYear
                )
        values (
                    Source.ProductName,
                    Source.PromotionYear
                );

    -- DimSalesLocation
    with dsl_cte (
                    RegionID,
                    CountryID,
                    SegmentID,
                    CountryName,
                    SegmentName
                ) as
    (
        select
            RegionID,
            c.CountryID,
            s.SegmentID,
            CountryName,
            SegmentName
        from FinanceDB.dbo.Region r  
            inner join FinanceDB.dbo.Country c on r.CountryID = c.CountryID
            inner join FinanceDB.dbo.Segment s on r.SegmentID = s.SegmentID
    )
    merge into production_FinanceDW.dbo.DimSalesLocation as Target
    using dsl_cte as Source
        on Target.RegionID = Source.RegionID
            and Target.CountryID = Source.CountryID
            and Target.SegmentID = Source.SegmentID
    when matched then
        update set
            Target.CountryID = Source.CountryID,
            Target.SegmentID = Source.SegmentID,
            Target.CountryName = Source.CountryName,
            Target.SegmentName = Source.SegmentName
    when not matched then
        insert (   
                    CountryID,
                    SegmentID,
                    CountryName,
                    SegmentName
                )
        values (
                    Source.CountryID,
                    Source.SegmentID,
                    Source.CountryName,
                    Source.SegmentName
                );
        
    -- DimSalesPerson
    with dsp_cte (            
                    SalesPersonID,
                    FirstName,
                    LastName,
                    Gender,
                    HireDate,
                    DayOfBirth,
                    DaysOfLeave,
                    DaysOfSickLeave
                  ) as
    (
        select
            SalesPersonID,
            FirstName,
            LastName,
            Gender,
            HireDate,
            DayOfBirth,
            DaysOfLeave,
            DaysOfSickLeave
        from FinanceDB.dbo.SalesPerson
    )
    merge into production_FinanceDW.dbo.DimSalesPerson as Target
    using dsp_cte as Source
        on Target.SalesPersonID = Source.SalesPersonID
    when matched then
        update set
            Target.FirstName = Source.FirstName,
            Target.LastName = Source.LastName,
            Target.Gender = Source.Gender,
            Target.HireDate = Source.HireDate,
            Target.DayOfBirth = Source.DayOfBirth,
            Target.DaysOfLeave = Source.DaysOfLeave,
            Target.DaysOfSickLeave = Source.DaysOfSickLeave
    when not matched then
        insert (   
                    FirstName,
                    LastName,
                    Gender,
                    HireDate,
                    DayOfBirth,
                    DaysOfLeave,
                    DaysOfSickLeave
                )
        values (
                    Source.FirstName,
                    Source.LastName,
                    Source.Gender,
                    Source.HireDate,
                    Source.DayOfBirth,
                    Source.DaysOfLeave,
                    Source.DaysOfSickLeave
                );

    -- Fact_SalePerformance
    merge into production_FinanceDW.dbo.FactSalePerformance as Target
    using fact_sp as Source
        on Target.DateKey = Source.SalesDate
            and Target.SalesPersonID = Source.SalesPersonID
            and Target.RegionID = Source.RegionID
    when matched then
        update set
            Target.TotalAnnualKPI = Source.TotalYearlyKPI,
            Target.AnnualSalesPrice = Source.TotalSalesPrice,
            Target.AnnualPerformance = Source.AnnualPerformance,
            Target.TotalMonthlylKPI = Source.TotalMonthlyKPI,
            Target.MonthlySalesPrice = Source.TotalMonthlyPrice,
            Target.MonthlyPerformance = Source.MonthlylPerformance
    when not matched then
        insert (   
                    TotalAnnualKPI,
                    AnnualSalesPrice,
                    AnnualPerformance,
                    TotalMonthlylKPI,
                    MonthlySalesPrice,
                    MonthlyPerformance
                )
        values (
                    Source.TotalYearlyKPI,
                    Source.TotalSalesPrice,
                    Source.AnnualPerformance,
                    Source.TotalMonthlyKPI,
                    Source.TotalMonthlyPrice,
                    Source.MonthlylPerformance
                );

    -- Fact_SaleOrder
    merge into production_FinanceDW.dbo.FactSaleOrder as Target
    using fact_so as Source
        on Target.DateKey = Source.SaleYear
            and Target.RegionID = Source.RegionID
            and Target.SalesPersonID = Source.SalesPersonID
            and Target.ProductID = Source.ProductID
            and Target.SalesOrderID = Source.SalesOrderID
            and Target.UnitsSold = Source.UnitsSold
            and Target.SalePrice = Source.SalePrice
    when matched then
        update set
            Target.TotalSalesPrice = Source.TotalSalesPrice,
            Target.TotalCost = Source.TotalCost,
            Target.TotalRRP = Source.TotalRRP,
            Target.TotalItems = Source.TotalItems,
            Target.GrossProfit = Source.GrossProfit,
            Target.PromotionRate = Source.PromotionRate,
            Target.Margin = Source.Margin,
            Target.PercentageDiscount = Source.PercentageDiscount
    when not matched then
        insert (   
                    TotalSalesPrice,
                    TotalCost,
                    GrossProfit,
                    TotalRRP,
                    TotalItems,
                    PromotionRate,
                    Margin,
                    PercentageDiscount
                )
        values (
                    Source.TotalSalesPrice,
                    Source.TotalCost,
                    Source.GrossProfit,
                    Source.TotalRRP,
                    Source.TotalItems,
                    Source.PromotionRate,
                    Source.Margin,
                    Source.PercentageDiscount
                );

end;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Execute Merge Into procedure

exec table_merge;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Create User Login and assign permissions for Data Warehouse Developer to read only access FinanceDB

use FinanceDB;

create login data_Warehouse_Developer with password = 'P@ssword1';

create user data_Warehouse_Developer for login data_Warehouse_Developer;

grant select on FinanceDB.dbo.Country to data_Warehouse_Developer;
grant select on FinanceDB.dbo.Product to data_Warehouse_Developer;
grant select on FinanceDB.dbo.ProductCost to data_Warehouse_Developer;
grant select on FinanceDB.dbo.Promotion to data_Warehouse_Developer;
grant select on FinanceDB.dbo.Region to data_Warehouse_Developer;
grant select on FinanceDB.dbo.SalesKPI to data_Warehouse_Developer;
grant select on FinanceDB.dbo.SalesOrder to data_Warehouse_Developer;
grant select on FinanceDB.dbo.SalesOrderLineItem to data_Warehouse_Developer;
grant select on FinanceDB.dbo.SalesPerson to data_Warehouse_Developer;
grant select on FinanceDB.dbo.SalesRegion to data_Warehouse_Developer;
grant select on FinanceDB.dbo.Segment to data_Warehouse_Developer;

-- Create User Login and assign permissions for Data Analyst Manager to read only access FinanceDW from PowerBI

use production_FinanceDW;

create login data_Analyst_Manager with password = 'P@ssword1';

create user data_Analyst_Manager for login data_Analyst_Manager;

grant select on DimDate to data_Analyst_Manager;
grant select on DimProduct to data_Analyst_Manager;
grant select on DimSalesLocation to data_Analyst_Manager;
grant select on DimSalesPerson to data_Analyst_Manager;
grant select on FactSaleOrder to data_Analyst_Manager;
grant select on FactSalePerformance to data_Analyst_Manager;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Reporting Views

-- Reporting View 1 | Total Yearly KPI by Sales Rep, Country, & Segment

drop view Sales_Performance;
go

create view Sales_Performance as
    select distinct
        YearCalendar,
        concat(FirstName, ' ', LastName) as SalesRepresentative,
        CountryName,
        SegmentName,
        TotalAnnualKPI,
        AnnualSalesPrice,
        AnnualPerformance
    from FactSalePerformance fsp
        inner join DimDate dd on fsp.DateKey = dd.DateKey
        inner join DimSalesPerson sp on fsp.SalesPersonID = sp.SalesPersonID
        inner join DimSalesLocation sl on fsp.RegionID = sl.RegionID;
go

select * from Sales_Performance
order by
    YearCalendar,
    SalesRepresentative desc,
    CountryName desc,
    SegmentName desc;

-- Indexing for View 1

exec sp_helpindex FactSalePerformance;
go

drop index if exists ix_fsp_view1 on FactSalePerformance;
go

create nonclustered index ix_fsp_view1
    on FactSalePerformance
        (DateKey asc, SalesPersonID, RegionID) include (AnnualSalesPrice, AnnualPerformance)
    with (data_compression = row);
go

-- Reporting View 2 | Yearly Sales Orders by Sales Representative

drop view Sales_Orders;
go

create view Sales_Orders as
    select
        year(FullDate) as Year,
        MonthNameOfYear,
        MonthNumberOfYear,
        YearCalendar,
        SalesOrderID,
        concat(FirstName, ' ', LastName) as SalesRepresentative,
        TotalSalesPrice,
        TotalCost,
        GrossProfit,
        TotalRRP,
        TotalItems,
        Margin,
        PercentageDiscount
    from FactSaleOrder fso
        inner join DimDate dd on fso.DateKey = dd.DateKey
        inner join DimSalesPerson sp on fso.SalesPersonID = sp.SalesPersonID
        inner join DimSalesLocation sl on fso.RegionID = sl.RegionID;

go

select * from Sales_Orders
order by
    Year,
    SalesOrderID,
    SalesRepresentative;

    -- Indexing for View 2

exec sp_helpindex FactSaleOrder;
go

drop index if exists ix_fso_view2 on FactSaleOrder;
go

create nonclustered index ix_fso_view2
    on FactSaleOrder
        (DateKey, SalesOrderID) -- include (TotalSalesPrice, TotalCost, TotalRRP)
    with (data_compression = row);
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Execute stored procedure | Schedule overnight

drop procedure if exists Run_Merge;
go

create procedure Run_Merge as
begin
    set nocount on;
    --  For executing the stored procedure at 11:00 P.M
    declare @delayTime nvarchar(50)
    set @delayTime = '23:00'

    while 1 = 1
    begin
        waitfor time @delayTime
        begin
            --Name for the stored proceduce you want to call on regular bases
            execute [production_FinanceDW].[dbo].[table_merge];
        end
    end
end;
go

sp_procoption   @ProcName = 'Run_Merge',
                @OptionName = 'startup',
                @OptionValue = 'on'