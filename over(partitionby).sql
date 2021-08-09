-- OVER(PARTITION BY) CLAUSE

-- https://dotnettutorials.net/lesson/over-clause-sql-server/

CREATE TABLE Employees
(
     ID INT,
     Name VARCHAR(50),
     Department VARCHAR(50),
     Salary int
)
Go
INSERT INTO Employees Values (1, 'James', 'IT', 15000)
INSERT INTO Employees Values (2, 'Smith', 'IT', 35000)
INSERT INTO Employees Values (3, 'Rasol', 'HR', 15000)
INSERT INTO Employees Values (4, 'Rakesh', 'Payroll', 35000)
INSERT INTO Employees Values (5, 'Pam', 'IT', 42000)
INSERT INTO Employees Values (6, 'Stokes', 'HR', 15000)
INSERT INTO Employees Values (7, 'Taylor', 'HR', 67000)
INSERT INTO Employees Values (8, 'Preety', 'Payroll', 67000)
INSERT INTO Employees Values (9, 'Priyanka', 'Payroll', 55000)
INSERT INTO Employees Values (10, 'Anurag', 'Payroll', 15000)
INSERT INTO Employees Values (11, 'Marshal', 'HR', 55000)
INSERT INTO Employees Values (12, 'David', 'IT', 96000)

SELECT  Department,
    COUNT(*) AS NoOfEmployees,
    SUM(Salary) AS TotalSalary,
    AVG(Salary) AS AvgSalary,
    MIN(Salary) AS MinSalary,
    MAX(Salary) AS MaxSalary
FROM Employees
GROUP BY Department

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
GROUP BY Department

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
ON Departments.Department = Employees.Department

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
FROM Employees
