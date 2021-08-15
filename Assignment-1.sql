-- Assignment 1 | DAT701

USE FinanceDB
GO
SELECT SUSER_SNAME(sid), * from sys.database_principals

ALTER AUTHORIZATION ON DATABASE::[FinanceDB] TO [sa]
GO

-- Section A - Query Writing (a total of 43 marks)
 
-- This section has a series of questions which will require you to a) write a t-sql query, b) produce some basic visualisations using PowerBI and c) provide brief answers to short answer questions.

-- You should include all t-sql (copy and paste and then format it so that it is easy to read) and screenshots of any visualisations you create.
 
-- Query A1 (10 marks)
-- This company has a presence in 5 countries across 5 industries (Segments) within each country. Calculate the total sales per year and the total profit per year for each Country / Segment. Note that profit can be calculated:  

-- Profit = SalePrice - (ManufacturingPrice x UnitsSold)

-- 1A: (5 marks) Write & then run this query and include a screenshot of the results.

select
    year(SalesOrderDate) as SalesYear,
    CountryName,
    SegmentName,
    round(sum(SalePrice), 2) as TotalSale,
    round(sum(SalePrice - (ManufacturingPrice * UnitsSold)), 2) as GrossProfit
from SalesOrderLineItem li
    inner join SalesOrder so
    on li.SalesOrderID = so.SalesOrderID
    inner join SalesRegion sr
    on so.SalesRegionID = sr.SalesRegionID
    inner join Region r
    on sr.RegionID = r.RegionID
    inner join Segment s
    on r.SegmentID = s.SegmentID
    inner join Country c
    on r.CountryID = c.CountryID
    inner join ProductCost pc
    on c.CountryID = pc.CountryID
group by
    year(SalesOrderDate),
    CountryName,
    SegmentName
order by
    SalesYear,
    CountryName,
    SegmentName;

-- 1B: (5 marks) Produce one or more visualisations using PowerBI to display this information.
-- Based on your visualisations, which region performed the best? Which region performed the worst?

-- Query A2 (10 marks)

-- 2A: (4 marks)
-- Each sales person has a yearly sales KPI. This is their yearly sales target which they are expected to meet. I’d like you to use this information to calculate a yearly sales KPI for each Country and Segment: 
-- For all Countries (c):
-- For all Segments (s):
-- YearlySale〖sKPI〗_(c,s)   = ∑_n 〖StaffYearlySalesKPI〗_n,for all Staff (n | c,s)〗_

-- Include your t-sql below.

-- 2B: (4 marks):
-- Once you have calculated this KPI, calculate the yearly performance against the KPI (i.e. if the KPI for Mexico, Midmarket is $100,000 and the total sales was $110,000, then the yearly performance would be 110%). Include your t-sql below.

-- 2C: (2 marks) Produce one or more visualisations in PowerBI to show this information.

-- Query A3 (8 marks)
-- 3A: A lot of information about sales performance is lost when it is aggregated yearly. Change your query from (Query Two 2B) to calculate the month-by-month total sales performances and plot these data in PowerBI. (4 marks)

-- Include your t-sql and a screenshot of your visualisations below.

-- 3B: What general conclusions can you draw from this visualisation? Justify your reasoning. (4 marks)

-- Query A4 (15 marks)
-- Finally, the company wants to reward the best performing sales people. But they don’t really know what they mean by “best performing”.  

-- 4A: (6 marks) Explain how could you rank & compare each salesperson’s performance? 

-- 4B (6 marks): Create a query & one or more visualisations that allows the company to explore the performance of their salespeople. Include the t-sql and a screenshot of the visualisations below.

-- 4C (3 marks): Using your results, which salespeople do you believe are the “top 10 best performers”?

-- Section B - Query Performance and indexing (a total of 40 marks)
 
-- This section has a series of questions which will require you to review query execution plans and design appropriate indexes to improve the performance of these queries.

-- You should include all t-sql (copy and paste and then format it so that it is easy to read) and screenshots of relevant parts of the execution plans where appropriate
 
-- Question B1 (20 marks)
-- Run the following query and review the execution plan:

        -- select 
        -- 	year(so.SalesOrderDate) as SalesYear,
        -- 	c.CountryName,
        -- 	s.SegmentName,
        -- 	sp.FirstName,
        -- 	sp.LastName,
        -- 	p.ProductName,
        -- 	count(*) as TotalProductSales,
        -- 	sum(case when sli.PromotionID = 0 then 0 else 1 end) as TotalPromotionalSales
        -- from SalesOrderLineItem sli
        -- 	inner join Product p on p.ProductID = sli.ProductID
        -- 	inner join SalesOrder so on so.SalesOrderID = sli.SalesOrderID
        -- 	inner join SalesRegion sr on sr.SalesRegionID = so.SalesRegionID
        -- 	inner join SalesPerson sp on sp.SalesPersonID = sr.SalesPersonID
        -- 	inner join Region r on r.RegionID = sr.RegionID
        -- 	inner join Segment s on s.SegmentID = r.SegmentID
        -- 	inner join Country c on c.CountryID = r.CountryID
        -- where year(so.SalesOrderDate) > 2012
        -- group by
        -- 	year(so.SalesOrderDate),
        -- 	c.CountryName,
        -- 	s.SegmentName,
        -- 	sp.FirstName,
        -- 	sp.LastName,
        -- 	p.ProductName
        -- ;

-- B1A (3 marks): What are the most expensive operations in this query execution plan? Include the relative cost of each operation you identify.

-- B1B (4 marks): What is a clustered index scan? Why can this be a problem for performance? When would it not be a major concern?

-- B1C (5 marks): Design an index to remove the clustered index scan on SalesOrderLineItem. Include the t-sql you used to create the index.

-- B1D (2 marks): After creating your index, review the execution plan again. Did this index substantially reduce the relative execution cost of querying data from SalesOrderLineItems? 

-- B1E (2 marks): Describe what indexes are used for and when they improve query performance. 

-- B1F (2 marks): In what situations would you limit the number of indexes you have on a table and why.

-- B1G (2 marks): Explain whether you would keep the index you created in B1C.

-- Question B2 (20 marks) 
-- Review the following query:

        -- with monthly_sales_info as (
        -- 	select
        -- 		sales_info.SalesMonth,
        -- 		c.CountryName,
        -- 		s.SegmentName,
        -- 		sales_info.PromotionRate,
        -- 		sales_info.TotalMonthlySales
        -- 	from Region r 
        -- 		inner join Country c on c.CountryID = r.CountryID
        -- 		inner join Segment s on s.SegmentID = r.SegmentID
        -- 		inner join SalesRegion sr on sr.RegionID = r.RegionID
        -- 		left join (
        -- 			select 
        -- 				so.SalesRegionID,
        -- 				so.SalesMonth,
        -- 				sum(case when sli.PromotionID = 0 then 0.0 else 1.0 end) / count(*) as PromotionRate,
        -- 				sum(SalePrice) as TotalMonthlySales
        -- 			from SalesOrder so
        -- 				inner join SalesOrderLineItem sli on sli.SalesOrderID = so.SalesOrderID
        -- 			group by 
        -- 				so.SalesRegionID,
        -- 				so.SalesMonth
        -- 		) sales_info on sales_info.SalesRegionID = sr.SalesRegionID
        -- )
        -- select *
        -- from monthly_sales_info
        -- where SalesMonth >= '2016-01-01';

-- B2A (5 marks): In simple terms, explain the business question which this query is addressing.

-- B2B (10 marks): A developer has suggested creating the following index to improve the query:

-- create index idx_promotions on SalesOrderLineItem (PromotionID, SalesOrderID);

-- 	Review the execution plan before creating the index. What part of the execution plan do you think the developer is trying to improve? Include a screenshot of this part of the execution plan (2 marks)

-- 	Create the index and review the execution plan again. Has the index improved this part of the execution plan? Explain why (2 marks)

-- 	Drop this index and create a suitable index to improve the execution of this query. Include a screenshot of the new execution plan. (2 marks)

-- 	Has your index improved the part of the execution plan that you expected it to? (i.e. has it substantially decreased the execution cost of this part of the plan?). If so, why? If not, what has it done? (4 marks)

-- B2C (5 marks)
-- Have a careful look at the results from the query above. Notice that there is a row for each Country / Segment every month. Adjust this query so that it only returns the Country / Segment with the highest TotalMonthlySales in each month. You should get 12 rows. 

-- Note that there are a few different ways that you could write this query and get the correct result. 
-- 	3 marks will be given for the correct solution. 
-- 	2 marks will be awarded for a simple, elegant approach.

-- Include your query below and a screenshot of the results. (5 marks)

-- Section C - Query Refactoring (a total of 35 marks)
 
-- This section has one question which requires you to first understand and then refactor a badly performing query. You should try to simplify this query as much as possible, balancing readability and performance. You should investigate potential indexes to improve the performance of this query.

-- Note that this query is very similar to a real query that I had to refactor for a client a number of years ago. It’s not always easy… Take your time and try to break it down into small pieces. Aim to understand all the small parts and then combine them back up to create the big picture.

-- While I was creating this question, the original query took ~40 seconds to run on my laptop. After my changes, I was able to get my revised query down to < 2 seconds.

-- You should include all t-sql (copy and paste and then format it so that it is easy to read) and screenshots of relevant parts of the execution plans where appropriate
 
-- To maximise their future profits, the Marketing Team need to be able to track the margin (profitability) and discount on all orders in real-time . They have had a business analyst attempt to write a SQL query which tracks information about every order. An example of the output of the query is shown below for you:

-- Unfortunately, the business analyst’s query is way too slow to run in real time. The analyst’s query is available from here. Your job is to rewrite this query so that it is scalable (can run over large amounts of historical data and is quick enough to run in real-time).

-- Question C1: 10 marks
-- Review the query execution plan and clearly describe why this query will not scale well.

-- Question C2: 10 marks
-- Rewrite this query so that it is scalable. Include your t-sql code below.

-- Question C3: 15 marks
-- Run both the original query and your version of the query. Review the execution plans of both queries. Make any additional changes that will improve the performance of this query. 

-- Explain simply how has the execution plan changed from the original query to your query? (5 marks)

-- Make any additional changes (for example indexing) that you think would help. Include the t-sql for these changes (5 marks)

-- Run both queries together and include a screenshot that shows the relative costs of both queries. Include a screenshot of the execution plan of your query after all changes have been applied.
-- (5 marks) 







