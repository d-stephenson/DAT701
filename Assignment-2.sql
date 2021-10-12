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























DECLARE @StartDate DATETIME = '01/01/2010' --Starting value of Date Range
DECLARE @EndDate DATETIME = '01/01/2021' --End Value of Date Range

--Temporary Variables To Hold the Values During Processing of Each Date of Year
DECLARE
	@DayOfWeekInMonth INT,
	@DayOfWeekInYear INT,
	@DayOfQuarter INT,
	@WeekOfMonth INT,
	@CurrentYear INT,
	@CurrentMonth INT,
	@CurrentQuarter INT

/*Table Data type to store the day of week count for the month and year*/
DECLARE @DayOfWeek TABLE (DOW INT, MonthCount INT, QuarterCount INT, YearCount INT)

INSERT INTO @DayOfWeek VALUES (1, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (2, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (3, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (4, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (5, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (6, 0, 0, 0)
INSERT INTO @DayOfWeek VALUES (7, 0, 0, 0)

--Extract and assign various parts of Values from Current Date to Variable

DECLARE @CurrentDate AS DATETIME = @StartDate
SET @CurrentMonth = DATEPART(MM, @CurrentDate)
SET @CurrentYear = DATEPART(YY, @CurrentDate)
SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)

/********************************************************************************************/
--Proceed only if Start Date(Current date ) is less than End date you specified above

WHILE @CurrentDate < @EndDate
BEGIN
 
/*Begin day of week logic*/

         /*Check for Change in Month of the Current date if Month changed then 
          Change variable value*/
	IF @CurrentMonth != DATEPART(MM, @CurrentDate) 
	BEGIN
		UPDATE @DayOfWeek
		SET MonthCount = 0
		SET @CurrentMonth = DATEPART(MM, @CurrentDate)
	END

        /* Check for Change in Quarter of the Current date if Quarter changed then change 
         Variable value*/

	IF @CurrentQuarter != DATEPART(QQ, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET QuarterCount = 0
		SET @CurrentQuarter = DATEPART(QQ, @CurrentDate)
	END
       
        /* Check for Change in Year of the Current date if Year changed then change 
         Variable value*/
	

	IF @CurrentYear != DATEPART(YY, @CurrentDate)
	BEGIN
		UPDATE @DayOfWeek
		SET YearCount = 0
		SET @CurrentYear = DATEPART(YY, @CurrentDate)
	END
	
        -- Set values in table data type created above from variables 

	UPDATE @DayOfWeek
	SET 
		MonthCount = MonthCount + 1,
		QuarterCount = QuarterCount + 1,
		YearCount = YearCount + 1
	WHERE DOW = DATEPART(DW, @CurrentDate)

	SELECT
		@DayOfWeekInMonth = MonthCount,
		@DayOfQuarter = QuarterCount,
		@DayOfWeekInYear = YearCount
	FROM @DayOfWeek
	WHERE DOW = DATEPART(DW, @CurrentDate)
	
/*End day of week logic*/


/* Populate Your Dimension Table with values*/
	
	INSERT INTO [dbo].[DimDate]
	SELECT
		
		CONVERT (char(8),@CurrentDate,112) as DateKey,
		@CurrentDate AS Date,
		CONVERT (char(10),@CurrentDate,103) as FullDateUK,
		CONVERT (char(10),@CurrentDate,101) as FullDateUSA,
		DATEPART(DD, @CurrentDate) AS DayOfMonth,
		--Apply Suffix values like 1st, 2nd 3rd etc..
		CASE 
			WHEN DATEPART(DD,@CurrentDate) IN (11,12,13) _
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 1 _
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'st'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 2 _
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'nd'
			WHEN RIGHT(DATEPART(DD,@CurrentDate),1) = 3 _
			THEN CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'rd'
			ELSE CAST(DATEPART(DD,@CurrentDate) AS VARCHAR) + 'th' 
			END AS DaySuffix,
		
		DATENAME(DW, @CurrentDate) AS DayName,
		DATEPART(DW, @CurrentDate) AS DayOfWeekUSA,

		-- check for day of week as Per US and change it as per UK format 
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 7
			WHEN 2 THEN 1
			WHEN 3 THEN 2
			WHEN 4 THEN 3
			WHEN 5 THEN 4
			WHEN 6 THEN 5
			WHEN 7 THEN 6
			END 
			AS DayOfWeekUK,
		
		@DayOfWeekInMonth AS DayOfWeekInMonth,
		@DayOfWeekInYear AS DayOfWeekInYear,
		@DayOfQuarter AS DayOfQuarter,
		DATEPART(DY, @CurrentDate) AS DayOfYear,
		DATEPART(WW, @CurrentDate) + 1 - DATEPART(WW, CONVERT(VARCHAR, _
		DATEPART(MM, @CurrentDate)) + '/1/' + CONVERT(VARCHAR, _
		DATEPART(YY, @CurrentDate))) AS WeekOfMonth,
		(DATEDIFF(DD, DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0), _
		@CurrentDate) / 7) + 1 AS WeekOfQuarter,
		DATEPART(WW, @CurrentDate) AS WeekOfYear,
		DATEPART(MM, @CurrentDate) AS Month,
		DATENAME(MM, @CurrentDate) AS MonthName,
		CASE
			WHEN DATEPART(MM, @CurrentDate) IN (1, 4, 7, 10) THEN 1
			WHEN DATEPART(MM, @CurrentDate) IN (2, 5, 8, 11) THEN 2
			WHEN DATEPART(MM, @CurrentDate) IN (3, 6, 9, 12) THEN 3
			END AS MonthOfQuarter,
		DATEPART(QQ, @CurrentDate) AS Quarter,
		CASE DATEPART(QQ, @CurrentDate)
			WHEN 1 THEN 'First'
			WHEN 2 THEN 'Second'
			WHEN 3 THEN 'Third'
			WHEN 4 THEN 'Fourth'
			END AS QuarterName,
		DATEPART(YEAR, @CurrentDate) AS Year,
		'CY ' + CONVERT(VARCHAR, DATEPART(YEAR, @CurrentDate)) AS YearName,
		LEFT(DATENAME(MM, @CurrentDate), 3) + '-' + CONVERT(VARCHAR, _
		DATEPART(YY, @CurrentDate)) AS MonthYear,
		RIGHT('0' + CONVERT(VARCHAR, DATEPART(MM, @CurrentDate)),2) + _
		CONVERT(VARCHAR, DATEPART(YY, @CurrentDate)) AS MMYYYY,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, _
		@CurrentDate) - 1), @CurrentDate))) AS FirstDayOfMonth,
		CONVERT(DATETIME, CONVERT(DATE, DATEADD(DD, - (DATEPART(DD, _
		(DATEADD(MM, 1, @CurrentDate)))), DATEADD(MM, 1, _
		@CurrentDate)))) AS LastDayOfMonth,
		DATEADD(QQ, DATEDIFF(QQ, 0, @CurrentDate), 0) AS FirstDayOfQuarter,
		DATEADD(QQ, DATEDIFF(QQ, -1, @CurrentDate), -1) AS LastDayOfQuarter,
		CONVERT(DATETIME, '01/01/' + CONVERT(VARCHAR, DATEPART(YY, _
		@CurrentDate))) AS FirstDayOfYear,
		CONVERT(DATETIME, '12/31/' + CONVERT(VARCHAR, DATEPART(YY, _
		@CurrentDate))) AS LastDayOfYear,
		NULL AS IsHolidayUSA,
		CASE DATEPART(DW, @CurrentDate)
			WHEN 1 THEN 0
			WHEN 2 THEN 1
			WHEN 3 THEN 1
			WHEN 4 THEN 1
			WHEN 5 THEN 1
			WHEN 6 THEN 1
			WHEN 7 THEN 0
			END AS IsWeekday,
		NULL AS HolidayUSA, Null, Null

	SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END