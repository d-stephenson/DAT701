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