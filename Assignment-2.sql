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
        SalesMonth int,
        RegionID smallint,
        SalesPersonID smallint,
        TotalAnnualKPI float,
        TotalMonthlylKPI float,
        AnnualSalesPrice float,
        AnnualPerformance float,
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
        RegionID smallint,
        SalesPersonID smallint,
        ProductID tinyint,
        SalesOrderID bigint,
        UnitsSold smallint,
        SalePrice float,
        TotalSalesPrice float,
        TotalCost float,
        TotalRRP float,
        TotalItems int,
        GrossProfit float,
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

-- Partition on datekey split into 4 five year intervals
drop partition scheme DateScheme;
drop partition function Key_Date;

create partition function Key_Date (int)
    as range right for values ('20000101', '20050101', '20100101', '20150101');
go

create partition scheme DateScheme
    as partition Key_Date ALL TO ([primary]);
go

-- Create Partition on FactSalePerformance
drop index if exists idx_Fact_SP_Date on FactSalePerformance;
go

create clustered index idx_Fact_SP_Date on FactSalePerformance(DateKey)
  with (statistics_norecompute = off, ignore_dup_key = off,
        allow_row_locks = on, allow_page_locks = on)
  on DateScheme(DateKey);
go

-- Create Partition on FactSaleOrder
drop index if exists idx_Fact_SO_Date on FactSaleOrder;
go

create clustered index idx_Fact_SO_Date on FactSaleOrder(DateKey)
  with (statistics_norecompute = off, ignore_dup_key = off,
        allow_row_locks = on, allow_page_locks = on)
  on DateScheme(DateKey);
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

--select * into #FactOrder from production_FinanceDW.dbo.FactOrder where 1 = 0;
--go

--select * from #FactOrder;
--go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
drop procedure if exists fact_insert_into;
go

create procedure fact_insert_into
as
begin

    -- Fact_SalePerformance
    with fsp_1(
        SalesYear,
        RegionID,
        SalesPersonID,
        TotalAnnualKPI,
        TotalMonthlyKPI
        ) as
    (
    select
        SalesYear,
        RegionID,
        sp.SalesPersonID,
        sum(KPI) as TotalAnnualKPI,
        sum(KPI) / 12 as TotalMonthlyKPI
    from
        FinanceDB.dbo.SalesKPI sk
            inner join FinanceDB.dbo.SalesPerson sp on sk.SalesPersonID = sp.SalesPersonID
            inner join FinanceDB.dbo.SalesRegion sr on sk.SalesPersonID = sr.SalesPersonID
            inner join FinanceDB.dbo.SalesOrder so on sp.SalesPersonID = so.SalesPersonID
            inner join FinanceDB.dbo.SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
    group by
        SalesYear,
        RegionID,
        sp.SalesPersonID
    ),
    fsp_2 (
        SalesYear,
        RegionID,
        SalesPersonID,
        AnnualSalesPrice,
        AnnualPerformance
        ) as
    (
    select
        convert(int, convert(varchar(8), SalesOrderDate, 112)) as SalesYear,
        sr.RegionID,
        so.SalesPersonID,
        sum(SalePrice) as TotalSalesPrice,
        round(sum((SalePrice / KPI) * 100), 8) as AnnualPerformance
    from FinanceDB.dbo.SalesOrder so
        inner join FinanceDB.dbo.SalesKPI sk on so.SalesPersonID = sk.SalesPersonID
        inner join FinanceDB.dbo.SalesRegion sr on so.SalesPersonID = sr.SalesPersonID
        inner join FinanceDB.dbo.SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
    group by
        convert(int, convert(varchar(8), SalesOrderDate, 112)),
        sr.RegionID,
        so.SalesPersonID
    ),
    fsp_3 (
        SalesYear,
        SalesMonth,
        RegionID,
        SalesPersonID,
        MonthlySalesPrice
        ) as
    (
    select
        year(SalesOrderDate) as SalesYear,
        month(SalesOrderDate) as SalesMonth,
        sr.RegionID,
        so.SalesPersonID,
        sum(SalePrice) as MonthlySalesPrice
    from FinanceDB.dbo.SalesOrder so
        inner join FinanceDB.dbo.SalesKPI sk on so.SalesPersonID = sk.SalesPersonID
        inner join FinanceDB.dbo.SalesRegion sr on so.SalesPersonID = sr.SalesPersonID
        inner join FinanceDB.dbo.SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
    group by
        year(SalesOrderDate),
        month(SalesOrderDate),
        sr.RegionID,
        so.SalesPersonID
    )
    insert into production_FinanceDW.dbo.FactSalePerformance
        select
            fsp_2.SalesYear,
            fsp_3.SalesMonth,
            fsp_2.RegionID,
            fsp_2.SalesPersonID,
            fsp_1.TotalAnnualKPI,
            fsp_1.TotalMonthlyKPI,
            fsp_2.AnnualSalesPrice,
            fsp_2.AnnualPerformance,
            fsp_3.MonthlySalesPrice,
            sum((fsp_3.MonthlySalesPrice / fsp_1.TotalMonthlyKPI) * 100)
        from fsp_1
            inner join fsp_2 on fsp_1.SalesYear =  left(fsp_2.SalesYear, 4)
                and fsp_1.RegionID = fsp_2.RegionID
                and fsp_1.SalesPersonID = fsp_2.SalesPersonID
            inner join fsp_3 on fsp_1.SalesYear =  left(fsp_3.SalesYear, 4)
                and fsp_1.RegionID = fsp_3.RegionID
                and fsp_1.SalesPersonID = fsp_3.SalesPersonID
        group by
            fsp_2.SalesYear,
            fsp_3.SalesMonth,
            fsp_2.RegionID,
            fsp_2.SalesPersonID,
            fsp_1.TotalAnnualKPI,
            fsp_1.TotalMonthlyKPI,
            fsp_2.AnnualSalesPrice,
            fsp_2.AnnualPerformance,
            fsp_3.MonthlySalesPrice;
        
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
            sum(li.SalePrice) as TotalSalesPrice,
            sum(pc.ManufacturingPrice * li.UnitsSold) as TotalCost,
            sum(pc.RRP * li.UnitsSold) as TotalRRP,
            sum(li.UnitsSold) as TotalItems,
            round(sum(li.SalePrice - pc.ManufacturingPrice), 2) as GrossProfit,
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
                fso_1.RegionID,
                fso_1.SalesPersonID,
                fso_1.ProductID,
                fso_1.SalesOrderID,
                fso_1.UnitsSold,
                fso_1.SalePrice,
                fso_2.TotalSalesPrice,
                fso_2.TotalCost,
                fso_2.TotalRRP,
                fso_2.TotalItems,
                fso_2.GrossProfit,
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

-- Execute fact Insert Into procedure

exec fact_insert_into;
go  

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

select * from FactSalePerformance;
go

select * from FactSaleOrder;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Upsert & Merge Testing

-- DimProduct
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

-- DML merge tables

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Merge Into dimension tables procedure

drop procedure if exists dim_merge;
go

create procedure dim_merge
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

end;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Execute dim Merge Into procedure

exec dim_merge;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Merge Into fact tables procedure

drop procedure if exists dim_merge;
go

create procedure dim_merge
as
begin

    -- Fact_SalePerformance
    with fsp_1(
        SalesYear,
        RegionID,
        SalesPersonID,
        TotalAnnualKPI,
        TotalMonthlyKPI
        ) as
    (
    select
        SalesYear,
        RegionID,
        sp.SalesPersonID,
        sum(KPI) as TotalAnnualKPI,
        sum(KPI) / 12 as TotalMonthlyKPI
    from
        FinanceDB.dbo.SalesKPI sk
            inner join FinanceDB.dbo.SalesPerson sp on sk.SalesPersonID = sp.SalesPersonID
            inner join FinanceDB.dbo.SalesRegion sr on sk.SalesPersonID = sr.SalesPersonID
            inner join FinanceDB.dbo.SalesOrder so on sp.SalesPersonID = so.SalesPersonID
            inner join FinanceDB.dbo.SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
    group by
        SalesYear,
        RegionID,
        sp.SalesPersonID
    ),
    fsp_2 (
        SalesYear,
        RegionID,
        SalesPersonID,
        AnnualSalesPrice,
        AnnualPerformance
        ) as
    (
    select
        convert(int, convert(varchar(8), SalesOrderDate, 112)) as SalesYear,
        sr.RegionID,
        so.SalesPersonID,
        sum(SalePrice) as TotalSalesPrice,
        round(sum((SalePrice / KPI) * 100), 8) as AnnualPerformance
    from FinanceDB.dbo.SalesOrder so
        inner join FinanceDB.dbo.SalesKPI sk on so.SalesPersonID = sk.SalesPersonID
        inner join FinanceDB.dbo.SalesRegion sr on so.SalesPersonID = sr.SalesPersonID
        inner join FinanceDB.dbo.SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
    group by
        convert(int, convert(varchar(8), SalesOrderDate, 112)),
        sr.RegionID,
        so.SalesPersonID
    ),
    fsp_3 (
        SalesYear,
        SalesMonth,
        RegionID,
        SalesPersonID,
        MonthlySalesPrice
        ) as
    (
    select
        year(SalesOrderDate) as SalesYear,
        month(SalesOrderDate) as SalesMonth,
        sr.RegionID,
        so.SalesPersonID,
        sum(SalePrice) as MonthlySalesPrice
    from FinanceDB.dbo.SalesOrder so
        inner join FinanceDB.dbo.SalesKPI sk on so.SalesPersonID = sk.SalesPersonID
        inner join FinanceDB.dbo.SalesRegion sr on so.SalesPersonID = sr.SalesPersonID
        inner join FinanceDB.dbo.SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
    group by
        year(SalesOrderDate),
        month(SalesOrderDate),
        sr.RegionID,
        so.SalesPersonID
    )
    merge into production_FinanceDW.dbo.FactSalePerformance as Target
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


    insert into production_FinanceDW.dbo.FactSalePerformance
        select
            fsp_2.SalesYear,
            fsp_3.SalesMonth,
            fsp_2.RegionID,
            fsp_2.SalesPersonID,
            fsp_1.TotalAnnualKPI,
            fsp_1.TotalMonthlyKPI,
            fsp_2.AnnualSalesPrice,
            fsp_2.AnnualPerformance,
            fsp_3.MonthlySalesPrice,
            sum((fsp_3.MonthlySalesPrice / fsp_1.TotalMonthlyKPI) * 100)
        from fsp_1
            inner join fsp_2 on fsp_1.SalesYear =  left(fsp_2.SalesYear, 4)
                and fsp_1.RegionID = fsp_2.RegionID
                and fsp_1.SalesPersonID = fsp_2.SalesPersonID
            inner join fsp_3 on fsp_1.SalesYear =  left(fsp_3.SalesYear, 4)
                and fsp_1.RegionID = fsp_3.RegionID
                and fsp_1.SalesPersonID = fsp_3.SalesPersonID
        group by
            fsp_2.SalesYear,
            fsp_3.SalesMonth,
            fsp_2.RegionID,
            fsp_2.SalesPersonID,
            fsp_1.TotalAnnualKPI,
            fsp_1.TotalMonthlyKPI,
            fsp_2.AnnualSalesPrice,
            fsp_2.AnnualPerformance,
            fsp_3.MonthlySalesPrice;
        
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
            sum(li.SalePrice) as TotalSalesPrice,
            sum(pc.ManufacturingPrice * li.UnitsSold) as TotalCost,
            sum(pc.RRP * li.UnitsSold) as TotalRRP,
            sum(li.UnitsSold) as TotalItems,
            round(sum(li.SalePrice - pc.ManufacturingPrice), 2) as GrossProfit,
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
                fso_1.RegionID,
                fso_1.SalesPersonID,
                fso_1.ProductID,
                fso_1.SalesOrderID,
                fso_1.UnitsSold,
                fso_1.SalePrice,
                fso_2.TotalSalesPrice,
                fso_2.TotalCost,
                fso_2.TotalRRP,
                fso_2.TotalItems,
                fso_2.GrossProfit,
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

-- Execute Fact Merge Into procedure

exec fact_merge;
go

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- Create User Login and assign permissions

create login data_Analyst_Manager with password = 'P@ssword1';

create user data_Analyst_Manager for login data_Analyst_Manager;

grant select on DimDate to data_Analyst_Manager;
grant select on DimProduct to data_Analyst_Manager;
grant select on DimSalesLocation to data_Analyst_Manager;
grant select on DimSalesPerson to data_Analyst_Manager;
grant select on FactSaleOrder to data_Analyst_Manager;
grant select on FactSalePerformance to data_Analyst_Manager;

