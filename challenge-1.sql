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



