USE AdventureWorksDW2017;
GO

ALTER AUTHORIZATION ON DATABASE:: [AdventureWorksDW2017] TO [sa]
GO

-- SQL Challenge 3

-- Q. 1A
-- Which 10 customers made the most orders during 2010? Return their name and
-- the total number of orders they made during 2010.

select  
    FirstName,
    LastName,
    TotalOrders
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






-- Q. 1D
-- Try to rewrite this query without the CTE and without the LOG ratio.





-- Q. 1B
-- Google the union all statement and re-write this query so that you have the 
-- top 3 selling products for Men and the top 3 selling products for Woman






-- Q. 1C
-- During 2011, there were two products where men are more than 4x as likely to 
-- purchase these than women. Try to complete the following query:






-- Q. 1D
-- Try to rewrite this query without the CTE and without the LOG ratio.