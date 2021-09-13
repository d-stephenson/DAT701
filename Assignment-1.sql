-- Assignment 1 | DAT701

use FinanceDB
go

select suser_sname(sid), * from sys.database_principals

alter authorization on database::[FinanceDB] to [sa]
go


-- Section A - Query Writing (a total of 43 marks)
 
-- This section has a series of questions which will require you to a) write a t-sql query, b) produce some basic visualisations using PowerBI and c) provide brief answers to short answer questions.

-- You should include all t-sql (copy and paste and then format it so that it is easy to read) and screenshots of any visualisations you create.
 
-- Query A1 (10 marks)
-- This company has a presence in 5 countries across 5 industries (Segments) within each country. Calculate the total sales per year and the total profit per year for each Country / Segment. Note that profit can be calculated:  

-- Profit = SalePrice - (ManufacturingPrice x UnitsSold)

-- 1A: (5 marks) Write & then run this query and include a screenshot of the results.
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select
    year(SalesOrderDate) as SalesYear,
    CountryName,
    SegmentName,
    round(sum(SalePrice), 2) as TotalSale,
    round(sum(SalePrice - ManufacturingPrice), 2) as GrossProfit
from SalesOrderLineItem li
    inner join SalesOrder so on li.SalesOrderID = so.SalesOrderID
    inner join SalesRegion sr on so.SalesRegionID = sr.SalesRegionID
    inner join Region r on sr.RegionID = r.RegionID
    inner join Segment s on r.SegmentID = s.SegmentID
    inner join Country c on r.CountryID = c.CountryID
    inner join ProductCost pc on c.CountryID = pc.CountryID
group by
    year(SalesOrderDate),
    CountryName,
    SegmentName
order by
    SalesYear,
    CountryName,
    SegmentName;
go

-- 1B: (5 marks) Produce one or more visualisations using PowerBI to display this information.
-- Based on your visualisations, which region performed the best? Which region performed the worst?

-- Query A2 (10 marks)

-- 2A: (4 marks)
-- Each sales person has a yearly sales KPI. This is their yearly sales target which they are expected to meet. I’d like you to use this information to calculate a yearly sales KPI for each Country and Segment: 
-- For all Countries (c):
-- For all Segments (s):

-- YearlySale〖sKPI〗_(c,s)   = ∑_n 〖StaffYearlySalesKPI〗_n,for all Staff (n | c,s)〗_

-- Include your t-sql below.
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select
    SalesYear,
    concat(FirstName, ' ', LastName) as SalesRepName,
    CountryName,
    SegmentName,
    sum(KPI) as TotalYearlyKPI
from SalesPerson sp
    inner join SalesKPI sk on sp.SalesPersonID = sk.SalesPersonID
    inner join SalesRegion sr on sp.SalesPersonID = sr.SalesPersonID
    inner join Region r on sr.RegionID = r.RegionID
    inner join Segment s on r.SegmentID = s.SegmentID
    inner join Country c on r.CountryID = c.CountryID
group by
    SalesYear,
    concat(FirstName, ' ', LastName),
    CountryName,
    SegmentName;
go

-- 2B: (4 marks):
-- Once you have calculated this KPI, calculate the yearly performance against the KPI (i.e. if the KPI for Mexico, Midmarket is $100,000 and the total sales was $110,000, then the yearly performance would be 110%). Include your t-sql below.
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


with kpi_cte(SalesYear, SalesRepName, CountryName, SegmentName, TotalYearlyKPI) as  
    (
    select
        SalesYear,
        concat(FirstName, ' ', LastName) as SalesRepName,
        CountryName,
        SegmentName,
        sum(KPI) as TotalYearlyKPI
    from SalesPerson sp
        inner join SalesKPI sk on sp.SalesPersonID = sk.SalesPersonID
        inner join SalesRegion sr on sp.SalesPersonID = sr.SalesPersonID
        inner join Region r on sr.RegionID = r.RegionID
        inner join Segment s on r.SegmentID = s.SegmentID
        inner join Country c on r.CountryID = c.CountryID
    group by
        SalesYear,
        concat(FirstName, ' ', LastName),
        CountryName,
        SegmentName
    ),
    performance_cte(SalesYear, CountryName, SegmentName, TotalSalesPrice) as  
    (
    select
        year(SalesOrderDate) as OrderYear,
        CountryName,
        SegmentName,
        sum(SalePrice) as TotalSalesPrice
    from SalesRegion sr
        inner join Region r on sr.RegionID = r.RegionID
        inner join Segment s on r.SegmentID = s.SegmentID
        inner join Country c on r.CountryID = c.CountryID
        inner join SalesOrder so on sr.SalesRegionID = so.SalesRegionID
        inner join SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
    group by
        year(SalesOrderDate),
        CountryName,
        SegmentName
    )
select
    kpi_cte.SalesYear,
    kpi_cte.SalesRepName,
    kpi_cte.CountryName,
    kpi_cte.SegmentName,
    TotalYearlyKPI,
    TotalSalesPrice,
    round(sum((TotalSalesPrice / TotalYearlyKPI) * 100), 2) as AnnualPerformance
from kpi_cte
    inner join performance_cte on kpi_cte.SalesYear = performance_cte.SalesYear
        and kpi_cte.CountryName = performance_cte.CountryName
        and kpi_cte.SegmentName = performance_cte.SegmentName
group by
    kpi_cte.SalesYear,
    kpi_cte.SalesRepName,
    kpi_cte.CountryName,
    kpi_cte.SegmentName,
    TotalYearlyKPI,
    TotalSalesPrice
order by
    SalesYear;
go

-- 2C: (2 marks) Produce one or more visualisations in PowerBI to show this information.

-- Query A3 (8 marks)
-- 3A: A lot of information about sales performance is lost when it is aggregated yearly. Change your query from (Query Two 2B) to calculate the month-by-month total sales performances and plot these data in PowerBI. (4 marks)

-- Include your t-sql and a screenshot of your visualisations below.
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

with kpi_cte(SalesYear, SalesRepName, TotalMonthlyKPI) as  
    (
    select
        SalesYear,
        concat(FirstName, ' ', LastName) as SalesRepName,
        round(sum(KPI) / 12, 2) as TotalMonthlyKPI
    from SalesPerson sp
        inner join SalesKPI sk on sp.SalesPersonID = sk.SalesPersonID
    group by
        SalesYear,
        concat(FirstName, ' ', LastName)
    ),
    performance_cte(OrderYear, OrderMonth, SalesRepName, CountryName, SegmentName, TotalSalesPrice) as  
    (
    select
        year(SalesOrderDate) as OrderYear,
        month(SalesOrderDate) as OrderMonth,
        concat(FirstName, ' ', LastName) as SalesRepName,
        CountryName,
        SegmentName,
        sum(SalePrice) as TotalSalesPrice
    from SalesPerson sp
        inner join SalesRegion sr on sp.SalesPersonID = sr.SalesPersonID
        inner join Region r on sr.RegionID = r.RegionID
        inner join Segment s on r.SegmentID = s.SegmentID
        inner join Country c on r.CountryID = c.CountryID
        inner join SalesOrder so on sr.SalesRegionID = so.SalesRegionID
        inner join SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
    group by
        year(SalesOrderDate),
        month(SalesOrderDate),
        concat(FirstName, ' ', LastName),
        CountryName,
        SegmentName
    )
select
    performance_cte.OrderYear,
    performance_cte.OrderMonth,
    performance_cte.SalesRepName,
    performance_cte.CountryName,
    performance_cte.SegmentName,
    TotalMonthlyKPI,
    TotalSalesPrice,
    round(sum((TotalSalesPrice / TotalMonthlyKPI) * 100), 2) as Performance
from kpi_cte
    inner join performance_cte on kpi_cte.SalesYear = performance_cte.OrderYear
        and kpi_cte.SalesRepName = performance_cte.SalesRepName
group by
    performance_cte.OrderYear,
    performance_cte.OrderMonth,
    performance_cte.SalesRepName,
    performance_cte.CountryName,
    performance_cte.SegmentName,
    TotalMonthlyKPI,
    TotalSalesPrice
order by
    OrderYear desc,
    OrderMonth desc,
    SalesRepName;
go

-- 3B: What general conclusions can you draw from this visualisation? Justify your reasoning. (4 marks)

-- Query A4 (15 marks)
-- Finally, the company wants to reward the best performing sales people. But they don’t really know what they mean by “best performing”.  

-- 4A: (6 marks) Explain how could you rank & compare each salesperson’s performance? 

-- 4B (6 marks): Create a query & one or more visualisations that allows the company to explore the performance of their salespeople. Include the t-sql and a screenshot of the visualisations below.

-- Total sales ranked for each sales rep in 2016
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select
    concat(FirstName, ' ', LastName) as SalesRepName,
    dense_rank() over (order by round(sum(SalePrice), 2) desc) as SalesRank,
    round(sum(SalePrice), 2) as TotalSales
from SalesPerson sp
    inner join SalesOrder so on sp.SalesPersonID = so.SalesPersonID
    inner join SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
    inner join Product p on li.ProductID = p.ProductID
    inner join ProductCost pc on p.ProductID = pc.ProductID
where
    year(SalesOrderDate) = 2016
group by
    LastName,
    FirstName;
go

-- Gross profit ranked for each sales rep in 2016
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select
    concat(FirstName, ' ', LastName) as SalesRepName,
    dense_rank() over (order by round(sum(SalePrice - ManufacturingPrice), 2) desc) as GrossProfitRank,
    round(sum(SalePrice - ManufacturingPrice), 2) as GrossProfit
from SalesPerson sp
    inner join SalesOrder so on sp.SalesPersonID = so.SalesPersonID
    inner join SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
    inner join Product p on li.ProductID = p.ProductID
    inner join ProductCost pc on p.ProductID = pc.ProductID
where
    year(SalesOrderDate) = 2016
group by
    LastName,
    FirstName;
go

-- Top 10 sales representatives bases on total sales and gross profits
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

with salesrank_cte(SalesRepName, SalesRank, TotalSales) as
    (
    select
        concat(FirstName, ' ', LastName) as SalesRepName,
        dense_rank() over (order by round(sum(SalePrice), 2) desc) as SalesRank,
        round(sum(SalePrice), 2) as TotalSales
    from SalesPerson sp
        inner join SalesOrder so on sp.SalesPersonID = so.SalesPersonID
        inner join SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
        inner join Product p on li.ProductID = p.ProductID
        inner join ProductCost pc on p.ProductID = pc.ProductID
    where
        year(SalesOrderDate) = 2016
    group by
        LastName,
        FirstName
    ),
    grossprofitrank_cte(SalesRepName, GrossProfitRank, GrossProfit) as
    (
    select
        concat(FirstName, ' ', LastName) as SalesRepName,
        dense_rank() over (order by round(sum(SalePrice - ManufacturingPrice), 2) desc) as GrossProfitRank,
        round(sum(SalePrice - ManufacturingPrice), 2) as GrossProfit
    from SalesPerson sp
        inner join SalesOrder so on sp.SalesPersonID = so.SalesPersonID
        inner join SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
        inner join Product p on li.ProductID = p.ProductID
        inner join ProductCost pc on p.ProductID = pc.ProductID
    where
        year(SalesOrderDate) = 2016
    group by
        LastName,
        FirstName
    )
select top 10
    salesrank_cte.SalesRepName,
    SalesRank,
    GrossProfitRank
from salesrank_cte
    inner join grossprofitrank_cte on salesrank_cte.SalesRepName = grossprofitrank_cte.SalesRepName
order by
    SalesRank,
    GrossProfitRank;
go

-- All sales representatives by country ranked by sales in 2016
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select
    concat(FirstName, ' ', LastName) as SalesRepName,
    CountryName,
    dense_rank() over (order by round(sum(SalePrice), 2) desc) as SalesRank,
    round(sum(SalePrice), 2) as TotalSales,
    round(sum(SalePrice - ManufacturingPrice), 2) as GrossProfit
from SalesPerson sp
    inner join SalesOrder so on sp.SalesPersonID = so.SalesPersonID
    inner join SalesOrderLineItem li on so.SalesOrderID = li.SalesOrderID
    inner join Product p on li.ProductID = p.ProductID
    inner join ProductCost pc on p.ProductID = pc.ProductID
    inner join SalesRegion sr on sp.SalesPersonID = sr.SalesPersonID
    inner join Region r on sr.RegionID = r.RegionID
    inner join Segment s on r.SegmentID = s.SegmentID
    inner join Country c on r.CountryID = c.CountryID
where
    year(SalesOrderDate) = 2016
group by
    LastName,
    FirstName,
    CountryName;
go

-- All sales representatives by country and segment ranked by sales in 2016
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select
    concat(FirstName, ' ', LastName) as SalesRepName,
    CountryName,
    SegmentName,
    dense_rank() over (order by round(sum(SalePrice), 2) desc) as SalesRank,
    round(sum(SalePrice), 2) as TotalSales,
    round(sum(SalePrice - ManufacturingPrice), 2) as GrossProfit
from SalesOrderLineItem li
    inner join SalesOrder so on li.SalesOrderID = so.SalesOrderID
    inner join SalesRegion sr on so.SalesRegionID = sr.SalesRegionID
    inner join Region r on sr.RegionID = r.RegionID
    inner join Segment s on r.SegmentID = s.SegmentID
    inner join Country c on r.CountryID = c.CountryID
    inner join ProductCost pc on c.CountryID = pc.CountryID
    inner join SalesPerson sp on so.SalesPersonID = sp.SalesPersonID
where
    year(SalesOrderDate) = 2016
group by
    LastName,
    FirstName,
    CountryName,
    SegmentName;
go

-- Top 5 sales representatives by country and segment ranked by sales in 2016
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select top 5
    concat(FirstName, ' ', LastName) as SalesRepName,
    CountryName,
    SegmentName,
    dense_rank() over (order by round(sum(SalePrice), 2) desc) as SalesRank,
    round(sum(SalePrice), 2) as TotalSales,
    round(sum(SalePrice - ManufacturingPrice), 2) as GrossProfit
from SalesOrderLineItem li
    inner join SalesOrder so on li.SalesOrderID = so.SalesOrderID
    inner join SalesRegion sr on so.SalesRegionID = sr.SalesRegionID
    inner join Region r on sr.RegionID = r.RegionID
    inner join Segment s on r.SegmentID = s.SegmentID
    inner join Country c on r.CountryID = c.CountryID
    inner join ProductCost pc on c.CountryID = pc.CountryID
    inner join SalesPerson sp on so.SalesPersonID = sp.SalesPersonID
where
    year(SalesOrderDate) = 2016
group by
    LastName,
    FirstName,
    CountryName,
    SegmentName;
go

-- Best ranking performance against KPI's in 2016
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select
    concat(FirstName, ' ', LastName) as SalesRepName,
    dense_rank() over (order by round(sum((SalePrice / KPI) * 100), 2) desc) as KPIPerformance
from SalesOrderLineItem li
    inner join SalesOrder so on li.SalesOrderID = so.SalesOrderID
    inner join SalesRegion sr on so.SalesRegionID = sr.SalesRegionID
    inner join SalesPerson sp on so.SalesPersonID = sp.SalesPersonID
    inner join SalesKPI sl on sp.SalesPersonID = sl.SalesPersonID
where
    year(SalesOrderDate) = 2016
group by
    LastName,
    FirstName;
go

-- 4C (3 marks): Using your results, which salespeople do you believe are the “top 10 best performers”?

-- Section B - Query Performance and indexing (a total of 40 marks)
 
-- This section has a series of questions which will require you to review query execution plans and design appropriate indexes to improve the performance of these queries.

-- You should include all t-sql (copy and paste and then format it so that it is easy to read) and screenshots of relevant parts of the execution plans where appropriate
 
-- Question B1 (20 marks)
-- Run the following query and review the execution plan:
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select
    year(so.SalesOrderDate) as SalesYear,
    c.CountryName,
    s.SegmentName,
    sp.FirstName,
    sp.LastName,
    p.ProductName,
    count(*) as TotalProductSales,
    sum(case when sli.PromotionID = 0 then 0 else 1 end) as TotalPromotionalSales
from SalesOrderLineItem sli
    inner join Product p on p.ProductID = sli.ProductID
    inner join SalesOrder so on so.SalesOrderID = sli.SalesOrderID
    inner join SalesRegion sr on sr.SalesRegionID = so.SalesRegionID
    inner join SalesPerson sp on sp.SalesPersonID = sr.SalesPersonID
    inner join Region r on r.RegionID = sr.RegionID
    inner join Segment s on s.SegmentID = r.SegmentID
    inner join Country c on c.CountryID = r.CountryID
where year(so.SalesOrderDate) > 2012
group by
    year(so.SalesOrderDate),
    c.CountryName,
    s.SegmentName,
    sp.FirstName,
    sp.LastName,
    p.ProductName
;
go

-- B1A (3 marks): What are the most expensive operations in this query execution plan? Include the relative cost of each operation you identify.

-- B1B (4 marks): What is a clustered index scan? Why can this be a problem for performance? When would it not be a major concern?

-- B1C (5 marks): Design an index to remove the clustered index scan on SalesOrderLineItem. Include the t-sql you used to create the index.
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Remove clustered index scan and add nonclustered index scan on column IDs
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

exec sp_helpindex 'SalesOrderLineItem';
go

alter table SalesOrderLineItem drop constraint PK__SalesOrd__DAA33720861CAF46;
go

drop index if exists PK__SalesOrd__DAA33720861CAF46 on SalesOrderLineItem;
go

select top 10 * from SalesOrderLineItem;
go

create nonclustered index IX_SalesOrderLineItem
    on SalesOrderLineItem
        (SalesOrderLineItemID asc, SalesOrderID, PromotionID, ProductID);
go

-- Update nonclustered index scan on column IDs required by query
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

exec sp_helpindex 'SalesOrderLineItem';
go

drop index if exists IX_SalesOrderLineItem on SalesOrderLineItem;
go

create nonclustered index IX_SalesOrderLineItem
    on SalesOrderLineItem
        (PromotionID, ProductID);
go

-- Remove nonclustered index scan and re-add clustered index scan
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

exec sp_helpindex 'SalesOrderLineItem';
go

drop index if exists IX_SalesOrderLineItem on SalesOrderLineItem;
go

create clustered index PK__SalesOrd__DAA33720861CAF46
    on SalesOrderLineItem
        (SalesOrderLineItemID);
go

-- B1D (2 marks): After creating your index, review the execution plan again. Did this index substantially reduce the relative execution cost of querying data from SalesOrderLineItems? 

-- B1E (2 marks): Describe what indexes are used for and when they improve query performance. 

-- B1F (2 marks): In what situations would you limit the number of indexes you have on a table and why.

-- B1G (2 marks): Explain whether you would keep the index you created in B1C.

-- Question B2 (20 marks) 
-- Review the following query:

with monthly_sales_info as (
	select
		sales_info.SalesMonth,
		c.CountryName,
		s.SegmentName,
		sales_info.PromotionRate,
		sales_info.TotalMonthlySales
	from Region r 
		inner join Country c on c.CountryID = r.CountryID
		inner join Segment s on s.SegmentID = r.SegmentID
		inner join SalesRegion sr on sr.RegionID = r.RegionID
		left join (
			select 
				so.SalesRegionID,
				so.SalesMonth,
				sum(case when sli.PromotionID = 0 then 0.0 else 1.0 end) / count(*) as PromotionRate,
				sum(SalePrice) as TotalMonthlySales
			from SalesOrder so
				inner join SalesOrderLineItem sli on sli.SalesOrderID = so.SalesOrderID
			group by 
				so.SalesRegionID,
				so.SalesMonth
		) sales_info on sales_info.SalesRegionID = sr.SalesRegionID
)
select *
from monthly_sales_info
where SalesMonth >= '2016-01-01';

-- B2A (5 marks): In simple terms, explain the business question which this query is addressing.

-- B2B (10 marks): A developer has suggested creating the following index to improve the query:

-- create index idx_promotions on SalesOrderLineItem (PromotionID, SalesOrderID);

-- 	Review the execution plan before creating the index. What part of the execution plan do you think the developer is trying to improve? Include a screenshot of this part of the execution plan (2 marks)

-- 	Create the index and review the execution plan again. Has the index improved this part of the execution plan? Explain why (2 marks)

-- 	Drop this index and create a suitable index to improve the execution of this query. Include a screenshot of the new execution plan. (2 marks)

-- 	Has your index improved the part of the execution plan that you expected it to? (i.e. has it substantially decreased the execution cost of this part of the plan?). If so, why? If not, what has it done? (4 marks)

-- Test create index

create index idx_promotions on SalesOrderLineItem(PromotionID, SalesOrderID);
go

exec sp_helpindex 'SalesOrderLineItem';
go

-- Drop index and create a new execution plan
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

drop index if exists idx_promotions on SalesOrderLineItem;
go

create nonclustered index IX_PromotionsGrouped
    on SalesOrderLineItem
        (PromotionID, SalesOrderID, SalePrice);
go

drop index if exists IX_PromotionsGrouped on SalesOrderLineItem;
go

create nonclustered index IX_PromotionsGrouped_2
    on SalesOrderLineItem
        (PromotionID, SalesOrderID, SalePrice, UnitsSold);
go

drop index if exists IX_PromotionsGrouped_2 on SalesOrderLineItem;
go

create nonclustered index IX_PromotionsGrouped_2
    on SalesOrderLineItem
        (PromotionID, SalesOrderID, SalePrice, UnitsSold)
    with (data_compression = row);
go

-- B2C (5 marks)
-- Have a careful look at the results from the query above. Notice that there is a row for each Country / Segment every month. Adjust this query so that it only returns the Country / Segment with the highest TotalMonthlySales in each month. You should get 12 rows. 

-- Note that there are a few different ways that you could write this query and get the correct result. 
-- 	3 marks will be given for the correct solution. 
-- 	2 marks will be awarded for a simple, elegant approach.

-- Include your query below and a screenshot of the results. (5 marks)
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

select *
from (
    select
           SalesMonth,
           c.CountryName,
           s.SegmentName,
           sum(case when sli.PromotionID = 0 then 0.0 else 1.0 end) / count(*) as PromotionRate,
           sum(SalePrice) as TotalMonthlySales,
           dense_rank() over (partition by SalesMonth order by sum(SalePrice) desc) as salesmonth_rank
    from Region r
         inner join Country c on c.CountryID = r.CountryID
         inner join Segment s on s.SegmentID = r.SegmentID
         inner join SalesRegion sr on sr.RegionID = r.RegionID
         inner join SalesOrder so on sr.SalesRegionID = so.SalesRegionID
         inner join SalesOrderLineItem sli on sli.SalesOrderID = so.SalesOrderID
    where
         SalesMonth >= '2016-01-01'
    group by
         SalesMonth,
         c.CountryName,
         s.SegmentName) ranks
where
    salesmonth_rank = 1
order by
    SalesMonth desc;
go

-- Section C - Query Refactoring (a total of 35 marks)
 
-- This section has one question which requires you to first understand and then refactor a badly performing query. You should try to simplify this query as much as possible, balancing readability and performance. You should investigate potential indexes to improve the performance of this query.

-- Note that this query is very similar to a real query that I had to refactor for a client a number of years ago. It’s not always easy… Take your time and try to break it down into small pieces. Aim to understand all the small parts and then combine them back up to create the big picture.

-- While I was creating this question, the original query took ~40 seconds to run on my laptop. After my changes, I was able to get my revised query down to < 2 seconds.

-- You should include all t-sql (copy and paste and then format it so that it is easy to read) and screenshots of relevant parts of the execution plans where appropriate
 
-- To maximise their future profits, the Marketing Team need to be able to track the margin (profitability) and discount on all orders in real-time . They have had a business analyst attempt to write a SQL query which tracks information about every order. An example of the output of the query is shown below for you:

-- Unfortunately, the business analyst’s query is way too slow to run in real time. The analyst’s query is available from here. Your job is to rewrite this query so that it is scalable (can run over large amounts of historical data and is quick enough to run in real-time).

select
	basic_metrics.SalesOrderDate,
	basic_metrics.SalesOrderNumber,
	basic_metrics.SalesPersonID,
	margin_calculation.SalesOrderID,
	basic_metrics.TotalSalesPrice,
	basic_metrics.TotalCost,
	basic_metrics.TotalRRP,
	basic_metrics.UniqueItems,
	basic_metrics.TotalItems,
	round(margin_calculation.Margin, 2) as Margin,
	round(discount_calculation.PercentageDiscount, 2) as PercentageDiscount
from (

	-- Calculate Discount
	select
		so.SalesOrderID,
		sum((pc.RRP * sli.UnitsSold) - SalePrice) / sum(pc.RRP * sli.UnitsSold) as PercentageDiscount
	from SalesOrder so
		inner join SalesOrderLineItem sli on sli.SalesOrderID = so.SalesOrderID
		inner join ProductCost pc on pc.ProductID = sli.ProductID
	group by 
		so.SalesOrderID
) discount_calculation
	inner join (

		-- Calculate Margin
		select
			so.SalesOrderID,
			case 
				when sum(SalePrice) = 0 then 0 
				else sum(SalePrice - (pc.ManufacturingPrice * sli.UnitsSold)) / sum(SalePrice) 
			end as Margin
		from SalesOrder so
			inner join SalesOrderLineItem sli on sli.SalesOrderID = so.SalesOrderID
			inner join ProductCost pc on pc.ProductID = sli.ProductID
		group by 
			so.SalesOrderID
	) margin_calculation on margin_calculation.SalesOrderID = discount_calculation.SalesOrderID
	inner join (

	-- basic metrics
	select 
		so.SalesOrderID,
		so.SalesOrderNumber,
		so.SalesOrderDate,
		so.SalesPersonID,
		so.SalesMonth,
		sum(sli.SalePrice) as TotalSalesPrice,
		sum(pc.ManufacturingPrice * sli.UnitsSold) as TotalCost,
		sum(pc.RRP * sli.UnitsSold) as TotalRRP,
		count(distinct sli.ProductID) as UniqueItems,
		sum(UnitsSold) as TotalItems
	from SalesOrder so
		inner join SalesOrderLineItem sli on sli.SalesOrderID = so.SalesOrderID
		inner join ProductCost pc on pc.ProductID = sli.ProductID
	group by 
		so.SalesOrderID,
		so.SalesOrderNumber,
		so.SalesOrderDate,
		so.SalesPersonID,
		so.SalesMonth
) basic_metrics on basic_metrics.SalesOrderID = margin_calculation.SalesOrderID
where SalesOrderDate > '2016-01-01';
go

-- Query Time 1:16

-- Question C1: 10 marks
-- Review the query execution plan and clearly describe why this query will not scale well.

-- Question C2: 10 marks
-- Rewrite this query so that it is scalable. Include your t-sql code below.

-- TEST ONE

-- Tested the query in one single select statement which improves performance at the expense
-- of scalability

select
    so.SalesOrderDate,
    so.SalesOrderNumber,
    so.SalesPersonID,
    so.SalesOrderID,
    sum(sli.SalePrice) as TotalSalesPrice,
    sum(pc.ManufacturingPrice * sli.UnitsSold) as TotalCost,
    sum(pc.RRP * sli.UnitsSold) as TotalRRP,
    count(distinct sli.ProductID) as UniqueItems,
    sum(UnitsSold) as TotalItems,
    round(case
        when sum(SalePrice) = 0 then 0
        else sum(SalePrice - (pc.ManufacturingPrice * sli.UnitsSold)) / sum(SalePrice)
        end, 2) as Margin,
    round(sum((pc.RRP * sli.UnitsSold) - SalePrice) / sum(pc.RRP * sli.UnitsSold), 2) as PercentageDiscount
from SalesOrder so
    inner join SalesOrderLineItem sli on sli.SalesOrderID = so.SalesOrderID
    inner join ProductCost pc on pc.ProductID = sli.ProductID
where SalesOrderDate > '2016-01-01'
group by
    so.SalesOrderID,
    so.SalesOrderNumber,
    so.SalesOrderDate,
    so.SalesPersonID
order by SalesOrderID;
go

-- Query Time 10 secs

-- TEST TWO

-- Separating calculation to improve scalability = 10 secs like the select query
-- 13 seconds when on the two round calculations were split in the calcs_cte
-- Used sargable for the dates doing between 1st and last day of the year no improvement in query performance
-- tried dates in this format - was a second slower at 11 secs [> '2016-01-01' and SalesOrderDate < '2016-12-31']
-- removed unnecessary joins from sales_cte improved time to 8 seconds
-- removed the * in the final select statement and replaced with columns specified and reduced query to 7 seconds

with sales_cte as
    (
    select
        so.SalesOrderDate,
        so.SalesOrderNumber,
        so.SalesPersonID,
        so.SalesOrderID
    from SalesOrder so
    where SalesOrderDate between '2016-01-01' and '2016-12-31'
    group by
    so.SalesOrderID,
    so.SalesOrderNumber,
    so.SalesOrderDate,
    so.SalesPersonID
    ),
    calcs_cte as
    (
    select
        so.SalesOrderID,
        sum(sli.SalePrice) as TotalSalesPrice,
        sum(pc.ManufacturingPrice * sli.UnitsSold) as TotalCost,
        sum(pc.RRP * sli.UnitsSold) as TotalRRP,
        count(distinct sli.ProductID) as UniqueItems,
        sum(UnitsSold) as TotalItems,
        round(case
            when sum(SalePrice) = 0 then 0
            else sum(SalePrice - (pc.ManufacturingPrice * sli.UnitsSold)) / sum(SalePrice)
            end, 2) as Margin,
        round(sum((pc.RRP * sli.UnitsSold) - SalePrice) / sum(pc.RRP * sli.UnitsSold), 2) as PercentageDiscount
    from SalesOrder so
        inner join SalesOrderLineItem sli on sli.SalesOrderID = so.SalesOrderID
        inner join ProductCost pc on pc.ProductID = sli.ProductID
    where SalesOrderDate between '2016-01-01' and '2016-12-31'
    group by
        so.SalesOrderID
    )
select
    sales_cte.SalesOrderDate,
    sales_cte.SalesOrderNumber,
    sales_cte.SalesPersonID,
    sales_cte.SalesOrderID,
    calcs_cte.TotalSalesPrice,
    calcs_cte.TotalCost,
    calcs_cte.TotalRRP,
    calcs_cte.UniqueItems,
    calcs_cte.TotalItems,
    calcs_cte.Margin,
    calcs_cte.PercentageDiscount
from sales_cte
    inner join calcs_cte on sales_cte.SalesOrderID = calcs_cte.SalesOrderID
order by sales_cte.SalesOrderID;
go

-- TEST THREE

-- The following query adapts the query above but takes the calculations out of the cte and uses the existing calculations 
-- to generate the information - reduced the query time by 1 second to 5 secs

with sales_cte as
    (
    select
        convert(date, so.SalesOrderDate) as SalesOrderDate,
        so.SalesOrderNumber,
        so.SalesPersonID,
        so.SalesOrderID
    from SalesOrder so
    where SalesOrderDate between '2016-01-01' and '2016-12-31'
    group by
        so.SalesOrderID,
        so.SalesOrderNumber,
        so.SalesOrderDate,
        so.SalesPersonID
    ),
    calcs_cte as
    (
    select
        so.SalesOrderID,
        sum(sli.SalePrice) as TotalSalesPrice,
        sum(pc.ManufacturingPrice * sli.UnitsSold) as TotalCost,
        sum(pc.RRP * sli.UnitsSold) as TotalRRP,
        count(distinct sli.ProductID) as UniqueItems,
        sum(UnitsSold) as TotalItems
    from SalesOrder so
        inner join SalesOrderLineItem sli on sli.SalesOrderID = so.SalesOrderID
        inner join ProductCost pc on pc.ProductID = sli.ProductID
    where SalesOrderDate between '2016-01-01' and '2016-12-31'
    group by
        so.SalesOrderID
    )
select
    sales_cte.SalesOrderDate,
    sales_cte.SalesOrderNumber,
    sales_cte.SalesPersonID,
    sales_cte.SalesOrderID,
    calcs_cte.TotalSalesPrice,
    calcs_cte.TotalCost,
    calcs_cte.TotalRRP,
    calcs_cte.UniqueItems,
    calcs_cte.TotalItems,
    round(case
            when calcs_cte.TotalSalesPrice = 0 then 0
            else (calcs_cte.TotalSalesPrice - calcs_cte.TotalRRP) / calcs_cte.TotalSalesPrice
            end, 2) as Margin,
    round(sum((calcs_cte.TotalRRP) - (calcs_cte.TotalSalesPrice)) / sum(calcs_cte.TotalRRP), 2) as PercentageDiscount
from sales_cte
    inner join calcs_cte on sales_cte.SalesOrderID = calcs_cte.SalesOrderID
group by
    sales_cte.SalesOrderDate,
    sales_cte.SalesOrderNumber,
    sales_cte.SalesPersonID,
    sales_cte.SalesOrderID,
    calcs_cte.TotalSalesPrice,
    calcs_cte.TotalCost,
    calcs_cte.TotalRRP,
    calcs_cte.UniqueItems,
    calcs_cte.TotalItems
order by sales_cte.SalesOrderID;
go

-- Testing indexes

exec sp_helpindex 'SalesOrder';
go

exec sp_helpindex 'SalesOrderLineItem';
go

exec sp_helpindex 'ProductCost';
go

create nonclustered index IX_sales_cte
    on SalesOrder
        (SalesOrderDate, SalesOrderNumber, SalesPersonID) -- include (SalesOrderID)
    with (data_compression = row);
go

-- Test index FK on SOLI SalesOrderID, unsuccessful

drop index if exists IX_solisoid_cte on SalesOrder;
go

create nonclustered index IX_solisoid_cte
    on SalesOrderLineItem
        (SalesOrderID)
    with (data_compression = row);
go

-- This increase query time by 1 second, no longer using index seek as a result increasing time

drop index if exists IX_sales_cte on SalesOrder;
go

-- Removing SalesOrderID improved the query to 7 seconds, (this is already available in the clustered index)

create nonclustered index IX_sales_cte
    on SalesOrder
        (SalesOrderDate, SalesOrderNumber, SalesPersonID);
go

-- Updates to index on SLI to include ProductID

drop index if exists IX_calcs_cte_1 on SalesOrderLineItem;
go

-- Adding include ProductId reduced time by 1 second to 6 seconds

create nonclustered index IX_calcs_cte_1
    on SalesOrderLineItem
        (SalesOrderID, UnitsSold, SalePrice) include (ProductID)
    with (data_compression = row);
go

-- This increased the query time to 9 seconds

drop index if exists IX_calcs_cte_2 on SalesOrderLineItem;
go

create nonclustered index IX_calcs_cte_2
    on SalesOrderLineItem
        (SalePrice, UnitsSold) -- include (SalesOrderID)
    with (data_compression = row);
go

-- Create index on Product table

create nonclustered index IX_cte_ProductCost
    on ProductCost
        (ManufacturingPrice)
    with (data_compression = row);
go

drop index if exists IX_cte_ProductCost on ProductCost;
go

-- Question C3: 15 marks
-- Run both the original query and your version of the query. Review the execution plans of both queries. Make any additional changes that will improve the performance of this query. 

-- Explain simply how has the execution plan changed from the original query to your query? (5 marks)

-- Make any additional changes (for example indexing) that you think would help. Include the t-sql for these changes (5 marks)

-- Run both queries together and include a screenshot that shows the relative costs of both queries. Include a screenshot of the execution plan of your query after all changes have been applied.
-- (5 marks) 
















































-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- JUNK CODE

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

select *
from (
    select dense_rank() over (partition by SalesMonth order by sum(SalePrice) desc) as salesmonth_rank,
           SalesMonth,
           c.CountryName,
           s.SegmentName,
           sum(case when sli.PromotionID = 0 then 0.0 else 1.0 end) / count(*) as PromotionRate,
           sum(SalePrice) as TotalMonthlySales--,
           --dense_rank() over (partition by c.CountryName order by sum(SalePrice) desc) as country_rank,
           --dense_rank() over (partition by s.SegmentName order by sum(case when sli.PromotionID = 0 then 0.0 else 1.0 end) / count(*) desc) as segment_rank
    from Region r
         inner join Country c on c.CountryID = r.CountryID
         inner join Segment s on s.SegmentID = r.SegmentID
         inner join SalesRegion sr on sr.RegionID = r.RegionID
         inner join SalesOrder so on sr.SalesRegionID = so.SalesRegionID
         inner join SalesOrderLineItem sli on sli.SalesOrderID = so.SalesOrderID
    where
        SalesMonth >= '2016-01-01'
    group by
         SalesMonth,
         c.CountryName,
         s.SegmentName) ranks
where salesmonth_rank = 1
    and country_rank = 1
    or segment_rank = 1
order by
    SalesMonth desc;


    with monthly_sales_info as (
    select
        sales_info.SalesMonth,
        c.CountryName,
        s.SegmentName,
        sales_info.PromotionRate,
        sales_info.TotalMonthlySales
    from Region r
        inner join Country c on c.CountryID = r.CountryID
        inner join Segment s on s.SegmentID = r.SegmentID
        inner join SalesRegion sr on sr.RegionID = r.RegionID
        left join (
            select
                so.SalesRegionID,
                so.SalesMonth,
                sum(case when sli.PromotionID = 0 then 0.0 else 1.0 end) / count(*) as PromotionRate,
                sum(SalePrice) as TotalMonthlySales
            from SalesOrder so
                inner join SalesOrderLineItem sli on sli.SalesOrderID = so.SalesOrderID
            group by
                so.SalesRegionID,
                so.SalesMonth
        ) sales_info on sales_info.SalesRegionID = sr.SalesRegionID
)
select *
from monthly_sales_info
where SalesMonth >= '2016-01-01'
order by
    SalesMonth desc,
    monthly_sales_info.TotalMonthlySales desc;

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






