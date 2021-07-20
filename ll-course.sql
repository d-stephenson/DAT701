-- LinkedIn Learning Course
-- Useful Functions
-- Adventure Works

-- String Functions

SELECT FirstName
    , LastName
    , UPPER (FirstName) AS UpperCase
    , LOWER (LastName) AS LowerCase
    , LEN (FirstName) AS LengthOfFirstName
    , LEFT (LastName, 3) AS FirstThreeLetters
    , RIGHT (LastName, 3) AS LastThreeLetters
    , TRIM (LastName) AS TrimmedName
FROM Person.Person;

-- Text Concatenation

SELECT FirstName
    , LastName
    , CONCAT (FirstName, ' ', MiddleName, ' ', LastName) AS FullName
    , CONCAT_WS (' ', FirstName, MiddleName, LastName) AS WithSeparators
FROM Person.Person;

-- Round with Mathematical Functions

SELECT BusinessEntityID
    , SalesYTD
    , ROUND (SalesYTD, 2) AS Round2
    , ROUND (SalesYTD, -2) AS RoundHundreds
    , CEILING (SalesYTD) AS RoundCeiling
    , FLOOR (SalesYTD) AS RoundFloor
FROM Sales.SalesPerson;

-- Work with Date Functions

SELECT BusinessEntityID
    , HireDate
    , YEAR (HireDate) AS HireYear
    , MONTH (HireDate) AS HireMonth
    , DAY (HireDate) AS HireDay
FROM HumanResources.Employee;

SELECT YEAR(HireDate), COUNT(*) AS NewHires
FROM HumanResources.Employee
GROUP BY YEAR(HireDate);

SELECT BusinessEntityID
    , HireDate
    , DATEDIFF (year, HireDate, GETDATE()) AS YearsSinceHire
    , DATEADD (year, 10, HireDate) AS AnniversaryDate
FROM HumanResources.Employee;

-- Format Dates & Times

SELECT BusinessEntityID
    , HireDate
    , FORMAT (HireDate, 'dddd') AS FormattedDate
FROM HumanResources.Employee;

SELECT BusinessEntityID
    , HireDate
    , FORMAT (HireDate, 'dddd, MMM dd, yyyy') AS FormattedDate
FROM HumanResources.Employee;

SELECT BusinessEntityID
    , HireDate
    , FORMAT (HireDate, 'd-MMM') AS FormattedDate
FROM HumanResources.Employee;

-- Return random records with NEWID

SELECT WorkOrderID
    , NEWID () AS NewID
FROM Production.WorkOrder;

SELECT WorkOrderID
    , NEWID () AS NewID
FROM Production.WorkOrder
ORDER BY NewID;

SELECT TOP 10 WorkOrderID
    , NEWID () AS NewID
FROM Production.WorkOrder
ORDER BY NewID;

-- IIF Logical Function

SELECT BusinessEntityID
    , SalesYTD
    , IIF (SalesYTD > 2000000, 'Met sales goal', 'Has not met goal') AS Status
FROM Sales.SalesPerson

SELECT IIF (SalesYTD > 2000000, 'Met sales goal', 'Has not met goal') AS Status
    , COUNT(*)
FROM Sales.SalesPerson
GROUP BY IIF (SalesYTD > 2000000, 'Met sales goal', 'Has not met goal');

-- Square Brackets

SELECT FirstName AS [Person First Name]
    , LastName AS [Person Last Name]
FROM Person.Person;

-- Group By & Count

SELECT City, StateProvinceID, COUNT(*) AS CountOfAddress
FROM Person.Address
GROUP BY City, StateProvinceID
ORDER BY City DESC;

-- Aggregate Functions

SELECT SalesOrderID
    , SUM(LineTotal) AS OrderTotal
    , SUM(OrderQty) AS NumberOfItems
    , COUNT(DISTINCT ProductID) AS UniqueItems
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY OrderTotal DESC;

SELECT SalesOrderDetail.ProductID
    , Product.NAMES
    , SUM(SalesOrderDetail.OrderQty) AS TotalQtySold
FROM Sales.SalesOrderDetail INNER JOIN Production.ProductID
    ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
GROUP BY SalesOrderDetail.ProductID, Product.Name
ORDER BY TotalQtySold DESC;

-- Filter Groups with Having

SELECT Color, COUNT(*) AS NumberOfProducts
FROM Production.Product
WHERE Color IS NOT NULL
GROUP BY Color 
HAVING COUNT(*) > 25;

-- Subquery

SELECT BusinessEntityID
    , SalesYTD
    , 5
FROM Sales.SalesPerson
ORDER BY SalesYTD DESC;

SELECT TOP 1 SalesYTD
FROM Sales.SalesPerson
ORDER BY SalesYTD DESC;

SELECT MAX(SalesYTD)
FROM Sales.SalesPerson;

SELECT BusinessEntityID
    , SalesYTD
    , (SELECT MAX(SalesYTD)
       FROM Sales.SalesPerson) AS HighestSales
    , (SELECT MAX(SalesYTD)
       FROM Sales.SalesPerson) - SalesYTD AS SalesGap
FROM Sales.SalesPerson
ORDER BY SalesYTD DESC;

-- Subquery in a Where Clause

SELECT SalesOrderID, SUM(LineTotal) AS OrderTotal
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(LineTotal) > 20000;

SELECT SalesOrderID, SUM(LineTotal) AS OrderTotal
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(LineTotal) > 
    (SELECT AVG(ResultTable.MyValues) AS AverageValue
     FROM (SELECT SUM(LineTotal) AS MyValues
            FROM Sales.SalesOrderDetail
            GROUP BY SalesOrderID) AS ResultTable
    )
;