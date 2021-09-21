USE AdventureWorksDW2017;
GO

ALTER AUTHORIZATION ON DATABASE:: [AdventureWorksDW2017] TO [sa]
GO

-- SQL Challenge 3

-- Q. 1A
-- Which 10 customers made the most orders during 2010? Return their name and
-- the total number of orders they made during 2010.

select top 10
    FirstName,
    LastName,
    count(OrderDate) as TotalOrders
from
    DimCustomer cu
    inner join FactInternetSales fis on cu.CustomerKey = fis.CustomerKey
    inner join DimDate da on fis.OrderDateKey = da.DateKey
where
    da.CalendarYear = 2010
group by
    FirstName,
    LastName,
    OrderDate
order by
    TotalOrders DESC;

-- Q. 1B
-- Google the union all statement and re-write this query so that you have the
-- top 3 selling products for Men and the top 3 selling products for Woman

select top 3
    c.Gender,
    p.EnglishProductName,
    count(*) as TotalProductSales
from FactInternetSales f
    inner join DimCustomer c on c.CustomerKey = f.CustomerKey
    inner join DimDate d on d.DateKey= f.OrderDateKey
    inner join DimProduct p on p.ProductKey = f.ProductKey
where d.CalendarYear = 2011
group by
    c.Gender,
    p.EnglishProductName

select top 3
    c.Gender,
    p.EnglishProductName,
    count(*) as TotalProductSales
from FactInternetSales f
    inner join DimCustomer c on c.CustomerKey = f.CustomerKey
    inner join DimDate d on d.DateKey= f.OrderDateKey
    inner join DimProduct p on p.ProductKey = f.ProductKey
where d.CalendarYear = 2011 AND c.Gender = 'M'
group by
    c.Gender,
    p.EnglishProductName

union all

select top 3
    c.Gender,
    p.EnglishProductName,
    count(*) as TotalProductSales
from FactInternetSales f
    inner join DimCustomer c on c.CustomerKey = f.CustomerKey
    inner join DimDate d on d.DateKey= f.OrderDateKey
    inner join DimProduct p on p.ProductKey = f.ProductKey
where d.CalendarYear = 2011 AND c.Gender = 'F'
group by
    c.Gender,
    p.EnglishProductName
order by
    c.Gender DESC,
    TotalProductSales DESC;

-- Q. 1C
-- During 2011, there were two products where men are more than 4x as likely to
-- purchase these than women. Try to complete the following query:

with products_by_gender as
(
    select
        p.EnglishProductName,
        count(*) as TotalProductSales,
        sum(case when c.Gender = 'M' then 1 else 0 end) as SalesToMen,
        sum(case when c.Gender = 'F' then 1 else 0 end) as SalesToWomen
    from FactInternetSales f
        inner join DimCustomer c on c.CustomerKey = f.CustomerKey
        inner join DimProduct p on p.ProductKey = f.ProductKey
    where year(f.OrderDate) = 2011
    group by
        p.EnglishProductName
)
select *
from products_by_gender
where log(SalesToMen + 0.5, 1) / log(SalesToWomen + 0.5, 2) >= 2;

-- Q. 1D
-- Try to rewrite this query without the CTE and without the LOG ratio.

select
    EnglishProductName,
    TotalProductSales,
    SalesToMen,
    SalesToWomen
from
    (
    select
        p.EnglishProductName,
        count(*) as TotalProductSales,
        sum(case when c.Gender = 'M' then 1 else 0 end) as SalesToMen,
        sum(case when c.Gender = 'F' then 1 else 0 end) as SalesToWomen
    from FactInternetSales f
        inner join DimCustomer c on c.CustomerKey = f.CustomerKey
        inner join DimProduct p on p.ProductKey = f.ProductKey
    where year(f.OrderDate) = 2011
    group by
        p.EnglishProductName
    ) as NewTable
where SalesToMen >= (SalesToWomen * 4);

-- Q. 2

select
    fa.TicketDate,
    fa.TicketNumber,
    fa.TicketSummary,
    a.AlertVategory,
    a.AlertSubCategory,
    c.CustCode,
    c.SalesRegion,
    fte.HoursActual,
    fte.TicketStatus
from FactAlert fa
    inner join DimDate d on fa.DateId = d.DateId
    inner join DimAlertType a on fa.AlertTypeID = a.AlertTypeID
    inner join DimCustomer c on fa.CustomerID = c.CustomerID
    inner join FactTimeEntry fte on fa.TicketNumber = fte.TicketNumber
where fte.TicketNumber is not null
    and fa.TicketDate > '2018-01-01'
    and fte.TeamID = 11;

-- Q. 3
-- A: Replace 'outer apply' with an 'outer join' [below example]

CREATE DATABASE Library
GO
 
USE Library;
 
CREATE TABLE Author
(
    id INT PRIMARY KEY,
    author_name VARCHAR(50) NOT NULL,
);
 
CREATE TABLE Book
(
    id INT PRIMARY KEY,
    book_name VARCHAR(50) NOT NULL,
    price INT NOT NULL,
    author_id INT NOT NULL
);
 
USE Library;
 
INSERT INTO Author
VALUES
(1, 'Author1'),
(2, 'Author2'),
(3, 'Author3'),
(4, 'Author4'),
(5, 'Author5'),
(6, 'Author6'),
(7, 'Author7');
 
INSERT INTO Book
VALUES
(1, 'Book1',500, 1),
(2, 'Book2', 300 ,2),
(3, 'Book3',700, 1),
(4, 'Book4',400, 3),
(5, 'Book5',650, 5),
(6, 'Book6',400, 3);

-- Inner join results

SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
    INNER JOIN Book B
    ON A.id = B.author_id

-- Cross apply produces the same results as inner join

CREATE FUNCTION fnGetBooksByAuthorId(@AuthorId int
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Book
    WHERE author_id = @AuthorId
);

SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
    CROSS APPLY fnGetBooksByAuthorId(A.Id) B

SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
    LEFT JOIN Book B
    ON A.id = B.author_id
    
SELECT A.author_name, B.id, B.book_name, B.price
FROM Author A
    OUTER APPLY fnGetBooksByAuthorId(A.Id) B

-- Q. 4
-- Which SalesTerritories are meeting their sales quotas each year?

select top 50 * from FactSalesQuota; --> going to need the
EmployeeKey, DateKey / CalendarKey / Date columns
select top 50 * from FactInternetSales; --> Going to need the
OrderDate, SalesTerritoryKey, SalesAmount
select top 50 * from DimEmployee; --> going to need the
EmployeeKey, FirstName, LastName, SalesTerritoryKey
select top 50 * from DimSalesTerritory; --> going to need the
SalesTerritoryCountry and SalesTerritoryRegion

select top 50 *
from FactInternetSales fs
    inner join DimSalesTerritory st on st.SalesTerritoryKey = fs.SalesTerritoryKey
    inner join DimEmployee de on de.SalesTerritoryKey = st.SalesTerritoryKey
    inner join FactSalesQuota sq on sq.EmployeeKey = de.EmployeeKey;
    
select top 50
    year(fs.OrderDate) as SalesOrderYear,
    fs.SalesAmount,
    fs.SalesTerritoryKey,
    st.SalesTerritoryCountry,
    st.SalesTerritoryRegion,
    de.FirstName,
    de.LastName,
    sq.SalesAmountQuota
from FactInternetSales fs
    inner join DimSalesTerritory st on st.SalesTerritoryKey = fs.SalesTerritoryKey
    inner join DimEmployee de on de.SalesTerritoryKey = st.SalesTerritoryKey
    inner join FactSalesQuota sq on sq.EmployeeKey = de.EmployeeKey;

-- Plan of attack:
-- 1. Get a list of employees & their sales territories
-- 2. Get the sales quotas of each employee, then aggregate this by territory
-- 3. Get the actual sales for each territory
-- 4. Compare the actual sales to the sales quota

select
    SalesOrderYear,    
    SalesTerritoryKey,
    SalesTerritoryCountry,
    SalesTerritoryRegion,
    FirstName,
    LastName,
    SalesAmount,
    SalesAmountQuota
from
    (
    select
        sum(fs.SalesAmount) as SalesAmount,
        year(fs.OrderDate) as SalesOrderYear,
        fs.SalesTerritoryKey,
        st.SalesTerritoryCountry,
        st.SalesTerritoryRegion,
        de.FirstName,
        de.LastName,
        sq.SalesAmountQuota
    from FactInternetSales fs
        inner join DimSalesTerritory st on st.SalesTerritoryKey = fs.SalesTerritoryKey
        inner join DimEmployee de on de.SalesTerritoryKey = st.SalesTerritoryKey
        inner join FactSalesQuota sq on sq.EmployeeKey = de.EmployeeKey
    group by
        year(fs.OrderDate),
        de.FirstName,
        de.LastName,
        fs.SalesTerritoryKey,
        st.SalesTerritoryCountry,
        st.SalesTerritoryRegion,
        SalesAmount,
        sq.SalesAmountQuota
    ) as CompareTable
where
    SalesAmount >= SalesAmountQuota
order by
    SalesTerritoryKey DESC
