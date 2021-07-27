USE AdventureWorksDW2017;
GO

ALTER AUTHORIZATION ON DATABASE:: [AdventureWorksDW2017] TO [sa]
GO

-- SQL Challenge 2

-- Q. What are the fact and dimension tables?
-- A:

-- Q. How do they relate to each other?
-- A:

-- Challenge 

-- 1. Explore the FactInternetSales table. For what years are there sales?
-- a. Do this by selecting from the FactInternetSales table and ordering by a date column



-- b. Write a query that joins the FactInternetSales table to the DimDate table and use the min() and max() 
-- functions to get the range of calendar years



-- c. Change (B) above and use the distinct clause to get a list of the CalendarYears for which there are sales



-- 2. Explore FactInternetSalesReason and DimSalesReason. What is the most common sales reason for each year? 
-- Write a query that presents the sales reasons in a way that the most common sales reasons can be determined.