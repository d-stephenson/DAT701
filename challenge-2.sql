USE AdventureWorksDW2017;
GO

ALTER AUTHORIZATION ON DATABASE:: [AdventureWorksDW2017] TO [sa]
GO

-- SQL Challenge 2

-- Q. What are the fact and dimension tables?
-- A:

-- Q. How do they relate to each other?
-- A:

-- Challenge 

-- 1. Explore the FactInternetSales table. For what years are there sales?
-- a. Do this by selecting from the FactInternetSales table and ordering by a date column

SELECT * FROM FactInternetSales;

SELECT DISTINCT
	YEAR(OrderDate)
FROM FactInternetSales
ORDER BY YEAR(OrderDate);

-- b. Write a query that joins the FactInternetSales table to the DimDate table and use the min() and max() 
-- functions to get the range of calendar years

SELECT * FROM DimDate;

IF EXISTS (SELECT dd.CalendarYear
		   FROM DimDate dd)
SELECT 
	MAX(YEAR(OrderDate)) AS 'MaxYear',
	MIN(YEAR(OrderDate)) AS 'MinYear'
FROM DimDate dd
	INNER JOIN FactInternetSales fis ON dd.DateKey = fis.ShipDateKey;

-- c. Change (B) above and use the distinct clause to get a list of the CalendarYears for which there are sales

SELECT DISTINCT
	MAX(YEAR(OrderDate)) AS 'MaxYear',
	MIN(YEAR(OrderDate)) AS 'MinYear'
FROM DimDate dd
	INNER JOIN FactInternetSales fis ON dd.DateKey = fis.ShipDateKey;

-- 2. Explore FactInternetSalesReason and DimSalesReason. What is the most common sales reason for each year? 
-- Write a query that presents the sales reasons in a way that the most common sales reasons can be determined.

SELECT * FROM FactInternetSalesReason;
SELECT * FROM DimSalesReason;

SELECT 
	YEAR(OrderDate) AS 'Year',
	SalesReasonName,
	COUNT(SalesReasonName) AS 'Count'
FROM DimSalesReason dsr
	JOIN FactInternetSalesReason fisr ON dsr.SalesReasonKey = fisr.SalesReasonKey
	JOIN FactInternetSales fis ON fisr.SalesOrderNumber = fis.SalesOrderNumber
GROUP BY 
	YEAR(OrderDate),
	SalesReasonName
ORDER BY COUNT(SalesReasonName) DESC;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

SELECT MAX(SRN_Count) AS MaxCount
FROM (SELECT
           YEAR(OrderDate) AS Sales_Year,
           SalesReasonName,
           COUNT(SalesReasonName) AS SRN_Count
        FROM DimSalesReason dsr
           JOIN FactInternetSalesReason fisr ON dsr.SalesReasonKey = fisr.SalesReasonKey
           JOIN FactInternetSales fis ON fisr.SalesOrderNumber = fis.SalesOrderNumber
        GROUP BY
           YEAR(OrderDate),
           SalesReasonName) AS MaxCount;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

WITH MaxCount_CTE(Sales_Year, SalesReasonName, SRN_Count) AS
    (
    SELECT
        YEAR(OrderDate) AS Sales_Year,
        SalesReasonName,
        COUNT(SalesReasonName) AS SRN_Count
    FROM DimSalesReason dsr
        JOIN FactInternetSalesReason fisr ON dsr.SalesReasonKey = fisr.SalesReasonKey
        JOIN FactInternetSales fis ON fisr.SalesOrderNumber = fis.SalesOrderNumber
    GROUP BY
        YEAR(OrderDate),
        SalesReasonName
    )

SELECT Sales_year, MAX(SRN_Count) AS MaxCount
FROM MaxCount_CTE
GROUP BY
    Sales_Year;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

WITH MaxCount_CTE(Sales_Year, SalesReasonName, SRN_Count) AS
    (
    SELECT
        YEAR(OrderDate) AS Sales_Year,
        SalesReasonName,
        COUNT(SalesReasonName) AS SRN_Count
    FROM DimSalesReason dsr
        JOIN FactInternetSalesReason fisr ON dsr.SalesReasonKey = fisr.SalesReasonKey
        JOIN FactInternetSales fis ON fisr.SalesOrderNumber = fis.SalesOrderNumber
    GROUP BY
        YEAR(OrderDate),
        SalesReasonName
    )
    ,
    MaxYearCount_CTE(Sales_Year, MaxCount) AS
    (
    SELECT Sales_Year, MAX(SRN_Count) AS MaxCount
    FROM MaxCount_CTE
    GROUP BY
        Sales_Year
    )
SELECT MaxYearCount_CTE.Sales_Year, SalesReasonName, MaxCount
FROM MaxCount_CTE
JOIN MaxYearCount_CTE ON MaxCount_CTE.SRN_Count = MaxYearCount_CTE.MaxCount
ORDER BY
    MaxYearCount_CTE.Sales_Year,
    MaxCount;




