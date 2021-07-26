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
    `Status`
FROM DimEmployee
WHERE DepartmentName = 'Marketing' AND `Status` = 'Current';

-- Q. 1B

SELECT 
    ProductKey,
    EnglishProductName,
    Color,
    `Weight`
FROM DimProduct
WHERE `Weight` > 50
    ORBER BY `Weight`;

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

-- iii
SELECT DISTINCT 
    p.EnglishDescription,
    s.EnglishProductSubcategoryName,
    c.EnglishProductCategoryName
FROM DimProduct p 
    JOIN DimProductSubCategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
    JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey
WHERE EnglishProductCategoryName = 'Bikes'
    ORDER BY EnglishProductSubCategoryName;

-- iv
SELECT COUNT (DISTINCT s.EnglishProductSubcategoryName) AS 'Count'
    p.EnglishDescription,
    s.EnglishProductSubcategoryName,
    c.EnglishProductCategoryName
FROM DimProduct p 
    JOIN DimProductSubCategory s ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
    JOIN DimProductCategory c ON s.ProductCategoryKey = c.ProductCategoryKey
WHERE EnglishProductCategoryName = 'Bikes'
    ORDER BY EnglishProductSubCategoryName;

-- Q. 2B

SELECT 
    TOP 10 OrderDate,
    CONCAT(c.FirstName, c.LastName) AS 'Customer Name',
    p.EnglishDescription,
    t.SalesTerritoryCountry,
    CONVERT(f.OrderDate, 'dddd, MMM, yyyy'),
    YEAR(f.YearOrdered)
FROM DimProduct p 
    JOIN FactInternetSales f ON p.ProductKey = f.ProductKey
    JOIN DimSalesTerritory t ON f.SalesTerritoryKey = t.SalesTerritoryKey
    JOIN DimCustomer c ON f.CustomerKey = c.CustomerKey
WHERE f.OrderDate = 2010
ORDER BY OrderDate;

-- Q. 2C

SELECT 
    TOP 5 SalesAmountQuota,
    q.CalendarYear,
    e.FirstName,
    e.LastName,
    e.DepartmentName,
    q.SalesAmountQuota
FROM FactSalesQuota q
    JOIN DimEmployee e
WHERE q.CalendarYear = 2010;








