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
FROM Sales.SalesOrderDetail INNER JOIN Production.Product
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

-- Correlated Subqueries
    -- Which Subquery performs better?

SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person;

SELECT BusinessEntityID, JobTitle
FROM HumanResources.Employee;

SELECT Person.BusinessEntityID
    , Person.FirstName
    , Person.LastName
    , Employee.JobTitle
FROM Person.Person INNER JOIN HumanResources.Employee 
    ON Person.BusinessEntityID = Employee.BusinessEntityID;

SELECT BusinessEntityID
    , FirstName
    , LastName
    , (SELECT JobTitle
        FROM HumanResources.Employee
        WHERE BusinessEntityID = MyPeople.BusinessEntityID) AS JobTitle
FROM Person.Person AS MyPeople
WHERE JobTitle IS NOT NULL;

SELECT BusinessEntityID
    , FirstName
    , LastName
    , (SELECT JobTitle
        FROM HumanResources.Employee
        WHERE BusinessEntityID = MyPeople.BusinessEntityID) AS JobTitle
FROM Person.Person AS MyPeople
WHERE (SELECT JobTitle
        FROM HumanResources.Employee
        WHERE BusinessEntityID = MyPeople.BusinessEntityID) IS NOT NULL;

SELECT BusinessEntityID
    , FirstName
    , LastName
    , (SELECT JobTitle
        FROM HumanResources.Employee
        WHERE BusinessEntityID = MyPeople.BusinessEntityID) AS JobTitle
FROM Person.Person AS MyPeople
WHERE EXISTS (SELECT JobTitle
        FROM HumanResources.Employee
        WHERE BusinessEntityID = MyPeople.BusinessEntityID);

-- PIVOT the Result Set

SELECT ProductLine, AVG(ListPrice) AS AveragePrice
FROM Production.Product
WHERE ProductLine IS NOT NULL
GROUP BY ProductLine;

SELECT M, R, S, T
FROM (SELECT ProductLine, ListPrice
      FROM Production.Product) AS SourceData
PIVOT (AVG(ListPrice) FOR ProductLine IN (M, R, S, T)) AS PivotTable;

SELECT 'Average List Price' AS 'Product Line'
    , M, R, S, T
FROM (SELECT ProductLine, ListPrice
      FROM Production.Product) AS SourceData
PIVOT (AVG(ListPrice) FOR ProductLine IN (M, R, S, T)) AS PivotTable;

-- Variable in a Query

DECLARE @MyFirstVariable INT;

SET @MyFirstVariable = 5; -- Change variable and re-run e.g. 10

SELECT @MyFirstVariable AS MyValue
    , @MyFirstVariable * 5 AS Multipliction
    , @MyFirstVariable + 10 AS Addition;

DECLARE @VarColor VARCHAR(20) = 'Blue'; -- Change variable and re-run e.g. Red

SELECT ProductID, Name, ProductNumber, Color, ListPrice
FROM Production.Product
WHERE Color = @VarColor;

-- Counter for Looping Statement 

DECLARE @Counter INT = 1;

WHILE @Counter <=3
BEGIN 
    SELECT @Counter AS CurrentValue
    SET @Counter = @Counter + 1
END

DECLARE @Counter INT = 1;
DECLARE @Product INT = 710;

WHILE @Counter <=3
BEGIN 
    SELECT ProductID, Name, ProductNumber, Color, ListPrice
    FROM Production.Product
    WHERE ProductID = @Product;
    SET @Counter = @Counter + 1
    SET @Product = @Product + 10;
END

-- Combine Results with Union

SELECT ProductCategoryID
    , NULL AS ProductSubcategoryID
    , Name 
FROM Production.ProductCategory

UNION

SELECT ProductSubcayegoryID
    , ProductSubcayegoryID
    , Name 
FROM Production.ProductSubcategory;

-- Distinct Rows with Except

SELECT BusinessEntityID
FROM Person.Person 
WHERE PersonType <> 'EM'

EXCEPT

SELECT BusinessEntityID
FROM Sales.PersonCreditCard;

    -- Result should be same as above

SELECT Person.BusinessEntityID
FROM Person.Person LEFT JOIN Sales.PersonCreditCard
ON Person.BusinessEntityID = PersonCreditCard.BusinessEntityID
WHERE Person.PersonType <> 'EM' AND PersonCreditCard.CreditCardID IS NULL;

-- Common Rows with Intersect

SELECT *
FROM Production.ProductProductPhoto;

SELECT *
FROM Production.ProductReview;

    -- Using Intersect

SELECT ProductID
FROM Production.ProductProductPhoto

INTERSECT

SELECT ProductID
FROM Production.ProductReview

    -- Try this, what is the result

SELECT DISTINCT A.ProductID
FROM Production.ProductProductPhoto AS A 
    INNER JOIN Production.ProductReview AS B
    ON A.ProductID = B.ProductID;