-- Class Sessions 2
-- DAT701 Enterprise Database Systems

-- OVER(PARTITION BY) CLAUSE

-- https://dotnettutorials.net/lesson/over-clause-sql-server/

CREATE TABLE Employees
(
     ID INT,
     Name VARCHAR(50),
     Department VARCHAR(50),
     Salary int
);
Go

INSERT INTO Employees Values (1, 'James', 'IT', 15000);
INSERT INTO Employees Values (2, 'Smith', 'IT', 35000);
INSERT INTO Employees Values (3, 'Rasol', 'HR', 15000);
INSERT INTO Employees Values (4, 'Rakesh', 'Payroll', 35000);
INSERT INTO Employees Values (5, 'Pam', 'IT', 42000);
INSERT INTO Employees Values (6, 'Stokes', 'HR', 15000);
INSERT INTO Employees Values (7, 'Taylor', 'HR', 67000);
INSERT INTO Employees Values (8, 'Preety', 'Payroll', 67000);
INSERT INTO Employees Values (9, 'Priyanka', 'Payroll', 55000);
INSERT INTO Employees Values (10, 'Anurag', 'Payroll', 15000);
INSERT INTO Employees Values (11, 'Marshal', 'HR', 55000);
INSERT INTO Employees Values (12, 'David', 'IT', 96000);

SELECT  Department,
    COUNT(*) AS NoOfEmployees,
    SUM(Salary) AS TotalSalary,
    AVG(Salary) AS AvgSalary,
    MIN(Salary) AS MinSalary,
    MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY Department;

-- this fails

SELECT  
    Name, 
    Salary, 
    Department,
    COUNT(*) AS NoOfEmployees,
    SUM(Salary) AS TotalSalary,
    AVG(Salary) AS AvgSalary,
    MIN(Salary) AS MinSalary,
    MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY Department;

-- return results by including all the aggregations in a subquery and then JOINING that subquery with the main query

SELECT 
    Name, 
    Salary, 
    Employees.Department,
    Departments.DepartmentTotals,
    Departments.TotalSalary,
    Departments.AvgSalary,
    Departments.MinSalary,
    Departments.MaxSalary   
FROM  Employees
INNER JOIN
(   SELECT 
        Department, 
        COUNT(*) AS DepartmentTotals,
        SUM(Salary) AS TotalSalary,
        AVG(Salary) AS AvgSalary,
        MIN(Salary) AS MinSalary,
        MAX(Salary) AS MaxSalary
    FROM Employees
    GROUP BY Department) AS Departments
ON Departments.Department = Employees.Department;

-- using the OVER clause combined with the PARTITION BY clause

SELECT 
    Name,
    Salary,
    Department,
    COUNT(Department) OVER(PARTITION BY Department) AS DepartmentTotals,
    SUM(Salary) OVER(PARTITION BY Department) AS TotalSalary,
    AVG(Salary) OVER(PARTITION BY Department) AS AvgSalary,
    MIN(Salary) OVER(PARTITION BY Department) AS MinSalary,
    MAX(Salary) OVER(PARTITION BY Department) AS MaxSalary
FROM Employees;

-- row number

SELECT Name, Department, Salary,
ROW_NUMBER() OVER (ORDER BY Department) AS RowNumber
FROM Employees;

SELECT 
    Name, 
    Department, 
    Salary,
    ROW_NUMBER() OVER
                    (
                        PARTITION BY Department
                        ORDER BY Salary
                    ) AS RowNumber
FROM Employees;

-- truncate

INSERT INTO Employees Values (1, 'James', 'IT', 15000);
INSERT INTO Employees Values (1, 'James', 'IT', 15000);
INSERT INTO Employees Values (2, 'Rasol', 'HR', 15000);
INSERT INTO Employees Values (2, 'Rasol', 'HR', 15000);
INSERT INTO Employees Values (2, 'Rasol', 'HR', 15000);
INSERT INTO Employees Values (3, 'Stokes', 'HR', 15000);
INSERT INTO Employees Values (3, 'Stokes', 'HR', 15000);
INSERT INTO Employees Values (3, 'Stokes', 'HR', 15000);
INSERT INTO Employees Values (3, 'Stokes', 'HR', 15000);

WITH DeleteDuplicateCTE AS
(
     SELECT *, ROW_NUMBER() OVER(PARTITION BY ID ORDER BY ID) AS RowNumber
     FROM Employees
)
DELETE FROM DeleteDuplicateCTE WHERE RowNumber > 1;

-- rank

SELECT Name, Department, Salary,
RANK() OVER (ORDER BY Salary DESC) AS [Rank]
FROM Employees

SELECT Name, Department, Salary,
               RANK() OVER (
                               PARTITION BY Department
                               ORDER BY Salary DESC) AS [Rank]
FROM Employees;

-- dense rank

SELECT Name, Department, Salary,
               DENSE_RANK() OVER (
                               PARTITION BY Department
                               ORDER BY Salary DESC) AS [DenseRank]
FROM Employees;

-- Fetch the 2nd Highest Salary
WITH EmployeeCTE  AS
(
    SELECT Salary, RANK() OVER (ORDER BY Salary DESC) AS Rank_Salary
    FROM Employees
)

SELECT TOP 1 Salary FROM EmployeeCTE WHERE Rank_Salary = 2;

-- Fetch the 2nd Hight Salary
WITH EmployeeCTE  AS
(
    SELECT Salary, DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRank_Salary
    FROM Employees
)

SELECT TOP 1 Salary FROM EmployeeCTE WHERE DenseRank_Salary = 2;

-- Top N pattern
-- CTE + subquery

with sick_leave as
(
    select
        s.SalesTerritoryCountry,
        s.SalesTerritoryRegion,
        e.FirstName + e.LastName as EmployeeName,
        e.SickLeaveHours
    from DimEmployee e
        inner join DimSalesTerritory s on s.SalesTerritoryKey = e.SalesTerritoryKey
    where Status = 'Current' and SalesTerritoryCountry != 'NA'
)
select * from sick_leave a where EmployeeName in (
                                                    select top 5 EmployeeName
                                                    from sick_leave b
                                                    order by SickLeaveHours desc
                                                );

-- Top N pattern
-- rank()

with sick_leave as (
                    select
                        s.SalesTerritoryCountry,
                        s.SalesTerritoryRegion,
                        e.FirstName + e.LastName as EmployeeName,
                        e.SickLeaveHours,
                        rank() over (order by SickLeaveHours desc) as RankedLeave
                    from DimEmployee e
                        inner join DimSalesTerritory s on s.SalesTerritoryKey = e.SalesTerritoryKey
                    where Status = 'Current' and SalesTerritoryCountry != 'NA'
)
select * from sick_leave a where RankedLeave <= 5;

-- Top N by group pattern
-- Partitioned rank()

with sick_leave_by_country as (
                                select
                                    RankedLeave
                                    s.SalesTerritoryCountry,
                                    s.SalesTerritoryRegion,
                                    e.FirstName + e.LastName as EmployeeName,
                                    e.SickLeaveHours,
                                    rank() over (partition by SalesTerritoryCountry order by SickLeaveHours desc ) as RankedLeave
                                from DimEmployee e
                                    inner join DimSalesTerritory s on s.SalesTerritoryKey = e.SalesTerritoryKey
                                where SalesTerritoryCountry != 'NA'
)
select * from sick_leave_by_country where RankedLeave <= 3;

-- Exercises
-- Simpler is usually better Rewrite this query without the CTE and without the subquery

with sick_leave as
(
    select
        s.SalesTerritoryCountry,
        s.SalesTerritoryRegion,
        e.FirstName + e.LastName as EmployeeName,
        e.SickLeaveHours
    from DimEmployee e
        inner join DimSalesTerritory s on s.SalesTerritoryKey = e.SalesTerritoryKey
    where Status = 'Current' and SalesTerritoryCountry != 'NA'
)
select * from sick_leave a where EmployeeName in (
    select top 5 EmployeeName
    from sick_leave b
    order by SickLeaveHours desc
);

-- Correlated subquery
-- Rewrite the query from Slide 11. Remove the rank() function and use a correlated subquery instead.
-- Compare the performance of these two

 with sick_leave_by_country as
 (
     select
            s.SalesTerritoryCountry,
            s.SalesTerritoryRegion,
            e.FirstName + e.LastName as EmployeeName,
            e.SickLeaveHours
        from DimEmployee e
            inner join DimSalesTerritory s on s.SalesTerritoryKey = e.SalesTerritoryKey
        where SalesTerritoryCountry != 'NA'
)
select * from sick_leave_by_country a
where EmployeeName in (
);