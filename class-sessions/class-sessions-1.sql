-- Class Sessions 1
-- DAT701 Enterprise Database Systems

USE AdventureWorks2017;
GO

-- CROSS APPLY
WITH CTE_Cust AS 
(
    SELECT 
        CustomerID,
        AccountNumber
    FROM
        Sales.Customer
    WHERE 
        CustomerID IN (30011,30022,30042,30067,30076,30095,30107,30117)

),
CTE_CustOrders AS
(
    SELECT 
        CustomerID,
        SalesOrderID,
        TotalDue
    FROM
        Sales.SalesOrderHeader
    WHERE 
        CustomerID IN (30011,30022,30042,30067,30076,30095,30107,30117)
)
SELECT C.CustomerID,
       C.AccountNumber,
       O.SalesOrderID,
       O.TotalDue
FROM CTE_Cust as C

CROSS APPLY
(
    SELECT TOP(3)
        CustomerID,
        SalesOrderID, 
        TotalDue
    FROM CTE_CustOrders AS CO
    WHERE CO.CustomerID = C.CustomerID
    ORDER BY TotalDue DESC
) AS O

ORDER BY C.CustomerID, O.TotalDue



--  OUTER APPLY

WITH CTE_CustOA AS 
(
    SELECT 
        CustomerID,
        AccountNumber
    FROM
        Sales.Customer
    WHERE 
        CustomerID IN (30011,30022,30042,30067)

),
CTE_CustOrdersOA AS
(
    SELECT 
        CustomerID,
        SalesOrderID,
        TotalDue
    FROM
        Sales.SalesOrderHeader
    WHERE 
        CustomerID IN (30011,30022)
)
SELECT C.CustomerID,
       C.AccountNumber,

       O.SalesOrderID,
       O.TotalDue
FROM CTE_CustOA as C

OUTER APPLY 
(
    SELECT TOP(2)
        CustomerID,
        SalesOrderID, 
        TotalDue
    FROM CTE_CustOrdersOA AS CO
    WHERE CO.CustomerID = C.CustomerID
    ORDER BY TotalDue DESC
) AS O

ORDER BY C.CustomerID, O.TotalDue

