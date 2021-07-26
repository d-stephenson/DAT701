-- SQL Challenge 1

-- Example

SELECT 
    firstname,
    lastname,
    DepartmentName
FROM DimEmployee
WHERE DepartmentName = 'Marketing';

-- PART ONE
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


