USE AdventureWorksDW2017;
GO

ALTER AUTHORIZATION ON DATABASE:: [AdventureWorksDW2017] TO [sa]
GO

-- SQL Challenge 1

-- PART ONE
-- Example

SELECT 
    firstname,
    lastname,
    DepartmentName
FROM DimEmployee
WHERE DepartmentName = 'Marketing';

-- Q. 1A
-- Extend the example query above to include the StartDate and employment Status of employees. Filter the results to only include current employees. Compare the results 
-- from the example query and your query, who is missing?

SELECT 
    firstname,
    lastname,
    DepartmentName,
    StartDate,
    Status
FROM DimEmployee
WHERE DepartmentName = 'Marketing' AND Status = 'Current';

-- Q. 1B
-- Explore the DimProduct table. Get a list of all products that weigh more than 50. Sort the results from lowest to highest weight. Return the ProductKey, 
-- EnglishProductName, Color and Weight.

SELECT 
    ProductKey,
    EnglishProductName,
    Color,
    Weight
FROM DimProduct
WHERE Weight > 50
    ORDER BY Weight;

-- Q. 1C
-- Explore the DimSalesTerritory table. Return a list of all SalesTerritories in North America. Include the columns shown below.

SELECT  
    SalesTerritoryKey,
    SalesTerritoryRegion,
    SalesTerritoryCountry,
    SalesTerritoryGroup
FROM DimSalesTerritory
WHERE SalesTerritoryGroup = 'North America';

-- PART TWO
-- Example

SELECT 
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    e.Title,
    t.SalesTerritoryCountry,
    t.SalesTerritoryGroup,
    t.SalesTerritoryRegion
FROM DimEmployee e 
    JOIN DimSalesTerritory t ON t.SalesTerritoryKey = e.SalesTerritoryKey
WHERE t.SalesTerritoryGroup = 'Europe';

-- Q. 2A

-- i
-- Join the DimProduct, DimProductSubCategory and DimProductCategory tables, returning the columns shown below. Filter the results 
-- where the EnglishProductCategoryName is Bikes. Sort by EnglishProductSubCategoryName. You should have 125 rows, the first 12 are shown below.

SELECT 
    p.ProductKey,
    p.EnglishDescription,
    s.EnglishProductSubcategoryName,
    c.EnglishProductCategoryName
FROM DimProduct p 
    JOIN DimProductSubCategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
    JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey
WHERE EnglishProductCategoryName = 'Bikes'
    ORDER BY EnglishProductSubCategoryName;

-- ii
-- Now, remove the ProductKey column and return a distinct list as shown below

SELECT DISTINCT 
    p.EnglishDescription,
    s.EnglishProductSubcategoryName,
    c.EnglishProductCategoryName
FROM DimProduct p 
    JOIN DimProductSubCategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
    JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey
WHERE EnglishProductCategoryName = 'Bikes';

-- iii 
-- Then count all the distinct columns from the same output above. Use an alias Count for the newly added column.

SELECT DISTINCT
    p.EnglishDescription,
    s.EnglishProductSubcategoryName,
    c.EnglishProductCategoryName,
	COUNT(*) AS 'Count'   
FROM DimProduct p 
    JOIN DimProductSubCategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
    JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey
WHERE EnglishProductCategoryName = 'Bikes'
GROUP BY p.EnglishDescription,
		 s.EnglishProductSubcategoryName,
		 c.EnglishProductCategoryName; 

-- Q. 2B
-- For this query you will need to join 4 tables, FactInternetSales, DimProduct, DimSalesTerritory and DimCustomer. Get a list of all orders from 2010, return the 
-- CustomerName (concatenate the FirstName and LastName to create CustomerName), the product’s EnglishDescription, the SalesTerritoryCountry, the OrderDate and 
-- YearOrdered. Note:
--  • The OrderDate field must be showing the date format dd/mm/yyyy using the Convert function.
--  • The YearOrdered field was derived from the OrderDate field using the Year function. Sort the results by the orderdate and return the top 10.

-- i
SELECT TOP 10
    CONCAT(c.FirstName, c.LastName) AS 'Customer Name',
    p.EnglishDescription,
    t.SalesTerritoryCountry,
    FORMAT(f.OrderDate, 'dd/MM/yyyy') AS 'OrderDate',
    FORMAT(f.OrderDate, 'yyyy') AS 'YearOrdered'
FROM DimProduct p 
    JOIN FactInternetSales f ON p.ProductKey = f.ProductKey
    JOIN DimSalesTerritory t ON f.SalesTerritoryKey = t.SalesTerritoryKey
    JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey;

-- ii
SELECT TOP 10
    CONCAT(c.FirstName, c.LastName) AS 'Customer Name',
    p.EnglishDescription,
    t.SalesTerritoryCountry,
    CONVERT(varchar, f.OrderDate, 103) AS 'OrderDate',
    YEAR(CONVERT(varchar, f.OrderDate, 0)) AS 'YearOrdered'
FROM DimProduct p 
    JOIN FactInternetSales f ON p.ProductKey = f.ProductKey
    JOIN DimSalesTerritory t ON f.SalesTerritoryKey = t.SalesTerritoryKey
    JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey;

-- Q. 2C 
-- Get the top 5 employees with the highest SalesAmountQuota for the 2010 CalendarYear. Use the FactSalesQuota and DimEmployee tables.

SELECT TOP 5 
    sq.CalendarYear,
    e.FirstName,
    e.LastName,
    e.DepartmentName,
    SUM(sq.SalesAmountQuota) AS 'SalesAmountQuota'
FROM FactSalesQuota sq
    JOIN DimEmployee e ON sq.EmployeeKey = e.EmployeeKey
WHERE sq.CalendarYear = 2010
GROUP BY sq.CalendarYear,
    e.FirstName,
    e.LastName,
    e.DepartmentName
ORDER BY 'SalesAmountQuota' DESC;

-- PART THREE
-- Test example 

SELECT
    e.DepartmentName,
    sq.CalendarYear,
    COUNT(e.EmployeeKey) AS TotalStaff,
    SUM(sq.SalesAmountQuota) AS TotalQuota
FROM DimEmployee e
    JOIN FactSalesQuota sq ON sq.EmployeeKey = e.EmployeeKey
GROUP BY
    e.DepartmentName,
    sq.CalendarYear;

-- Q. 3A
-- Use FactInternetSales and DimProduct to calculate the total number of orders (use count()) for each product during 2010. Sort this from the highest selling product 
-- to the lowest selling product

SELECT 
	p.EnglishProductName,
    p.EnglishDescription,
    COUNT(s.OrderQuantity) AS 'TotalOrders'
FROM FactInternetSales s 
    JOIN DimProduct p ON s.ProductKey = p.ProductKey
WHERE YEAR(s.OrderDate) = 2010
GROUP BY 	
	p.EnglishProductName,
    p.EnglishDescription
ORDER BY
	'TotalOrders' DESC;

-- Q. 3B

-- i
-- Look at the FactInternetSales and FactInternetSalesReason tables. Use these (and DimSalesReason) to get a count of the number of orders for each SalesReasonName. 
-- Filter your results to orders from 2010.

SELECT 
	sr.SalesReasonName,
	COUNT(fis.OrderQuantity) AS 'TotalOrders'
FROM DimSalesReason sr
	JOIN FactInternetSalesReason fisr ON sr.SalesReasonKey = fisr.SalesReasonKey
	JOIN FactInternetSales fis ON fisr.SalesOrderNumber = fis.SalesOrderNumber
WHERE YEAR(fis.OrderDate) = 2010
GROUP BY
	sr.SalesReasonName;

-- ii
-- Remove the filter for year 2010.

SELECT 
	sr.SalesReasonName,
	COUNT(fis.OrderQuantity) AS 'TotalOrders'
FROM DimSalesReason sr
	JOIN FactInternetSalesReason fisr ON sr.SalesReasonKey = fisr.SalesReasonKey
	JOIN FactInternetSales fis ON fisr.SalesOrderNumber = fis.SalesOrderNumber
GROUP BY
	sr.SalesReasonName;

-- Q. 3C
-- Use FactInternetSales and DimPromotion to calculate the TotalOrders (count(ProductKey)) and TotalSalesAmount (sum(SalesAmount)) for each promotion.
-- To be more interesting, use the orderdate and the year() function to calculate these statistics for each CalendarYear. Sort by CalendarYear then by 
-- TotalOrders both in ascending order.

SELECT DISTINCT
	YEAR(fis.OrderDate) AS 'CalendarYear',
	p.EnglishPromotionName,
	COUNT(fis.ProductKey) AS 'TotalOrders',
	SUM(fis.SalesAmount) AS 'TotalSalesAmount'
FROM FactInternetSales fis 
	JOIN DimPromotion p ON fis.PromotionKey = p.PromotionKey
GROUP BY
	p.EnglishPromotionName,
	YEAR(fis.OrderDate)
ORDER BY
	'CalendarYear',
	'TotalOrders';