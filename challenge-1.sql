USE AdventureWorksDW2017;

ALTER AUTHORIZATION ON DATABASE:: [AdventureWorksDW2017] TO [sa]
go 

SELECT TOP 1 * FROM FactInternetSales
SELECT TOP 1 *  FROM DimProduct
SELECT TOP 1 *  FROM DimSalesTerritory
SELECT TOP 1 *  FROM DimCustomer

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

SELECT 
    firstname,
    lastname,
    DepartmentName,
    StartDate,
    Status
FROM DimEmployee
WHERE DepartmentName = 'Marketing' AND Status = 'Current';

-- Q. 1B

SELECT 
    ProductKey,
    EnglishProductName,
    Color,
    Weight
FROM DimProduct
WHERE Weight > 50
    ORDER BY Weight;

-- Q. 1C

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
SELECT DISTINCT 
    p.EnglishDescription,
    s.EnglishProductSubcategoryName,
    c.EnglishProductCategoryName
FROM DimProduct p 
    JOIN DimProductSubCategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
    JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey
WHERE EnglishProductCategoryName = 'Bikes';

-- iii ///// NOT WORKING
SELECT DISTINCT
    p.EnglishDescription,
    s.EnglishProductSubcategoryName,
    c.EnglishProductCategoryName,
	COUNT(p.EnglishDescription) AS 'Count'   
FROM DimProduct p 
    JOIN DimProductSubCategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
    JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey
WHERE EnglishProductCategoryName = 'Bikes'
GROUP BY p.EnglishDescription; 

SELECT 
	(COUNT(DISTINCT p.EnglishDescription)) AS 'Count'   
FROM DimProduct p 
    JOIN DimProductSubCategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
    JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey
WHERE EnglishProductCategoryName = 'Bikes'
GROUP BY p.EnglishDescription; 

-- Q. 2B

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

-- Q. 2C ///// NOT WORKING

SELECT TOP 5 
    sq.CalendarYear,
    e.FirstName,
    e.LastName,
    e.DepartmentName,
    SELECT SUM(sq.SalesAmountQuota) AS 'SalesAmountQuota'
FROM FactSalesQuota sq
    JOIN DimEmployee e ON sq.EmployeeKey = e.EmployeeKey
WHERE sq.CalendarYear = 2010;

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
SELECT 
	sr.SalesReasonName,
	COUNT(fis.OrderQuantity) AS 'TotalOrders'
FROM DimSalesReason sr
	JOIN FactInternetSalesReason fisr ON sr.SalesReasonKey = fisr.SalesReasonKey
	JOIN FactInternetSales fis ON fisr.SalesOrderNumber = fis.SalesOrderNumber
GROUP BY
	sr.SalesReasonName;

-- Q. 3C