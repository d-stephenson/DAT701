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

