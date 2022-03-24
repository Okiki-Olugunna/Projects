USE FootAsylum;

SELECT * FROM SalesData;

-- checking for duplicates 
SELECT COUNT(*) AS num_duplicates, * 
FROM SalesData 
GROUP BY FinancialYear, FinancialWeek, LocationType,
LocationCode, Division, ProductGroup, ItemCategory, GrossSales,
UnitsSold, GrossProfit
HAVING COUNT(*) > 1;
-- no duplicates found


-- Is our revenue growing?
SELECT FinancialYear, ROUND(SUM(GrossSales), 2) AS GrossSales,
COALESCE(
ROUND(SUM(GrossSales), 2) /
LAG(ROUND(SUM(GrossSales), 2)) OVER( ORDER BY FinancialYear)*100 - 100
, 0) AS SalesGrowthPercent,
ROUND(SUM(GrossSales), 2) /
FIRST_VALUE(ROUND(SUM(GrossSales), 2)) OVER(ORDER BY FinancialYear)*100 - 100
AS ComparisonTo2020 
FROM SalesData
GROUP BY FinancialYear
ORDER BY FinancialYear; 
-- Yes. Though there was a 10% decrease in 2021, in 2022 it was made back with a 23% increase
/* In 2022 we made just under 1.8B in gross sales revenue, a 24% increase from 2021,
and a 10% increase from 2020 */

-- What is the year-over-year profit?
SELECT FinancialYear, ROUND(SUM(GrossProfit), 2) AS GrossProfit,
COALESCE(
ROUND(SUM(GrossProfit), 2) /
LAG(ROUND(SUM(GrossProfit), 2)) OVER( ORDER BY FinancialYear)*100 - 100
, 0)
AS ProfitGrowthPercent,
ROUND(SUM(GrossProfit), 2) /
FIRST_VALUE(ROUND(SUM(GrossProfit), 2)) OVER(ORDER BY FinancialYear)*100 - 100
AS ComparisonTo2020 
FROM SalesData
GROUP BY FinancialYear
ORDER BY FinancialYear; 
-- This year we made a profit of 985M, a 24% increase from last year of 792M

-- Pick one (or both) and put these in a bar chart



-- Are we more profitable in store or online?
SELECT 
RANK() OVER( ORDER BY SUM(GrossProfit) DESC) AS Rank,
LocationType, 
ROUND(SUM(GrossProfit),2) AS GrossProfit
FROM SalesData
GROUP BY LocationType;
-- We make more profit in our stores - about 150M difference 

/* Okay, so we're more "profitable" in stores, but are does that mean
we make more GrossSales in stores? Let's find out */

SELECT 
RANK() OVER( ORDER BY SUM(GrossSales) DESC) AS Rank,
LocationType, 
ROUND(SUM(GrossSales),2) AS GrossSales
FROM SalesData
GROUP BY LocationType;
-- Again, we can see that we make more gross sales in store than online 
--  About a 260M difference

/* Okay, yes we may make more profit and gross sales in store, but 
does that mean that we get a greater total number of items bought 
in store? 
This question is posed because it's essentially easier to buy
a lot more stuff online because you don't have to physically carry it all*/

-- Comparing the units sold column
SELECT 
RANK() OVER( ORDER BY SUM(UnitsSold) DESC) AS Rank,
LocationType,
SUM(UnitsSold) AS UnitsSold
FROM SalesData 
GROUP BY LocationType;
-- A total of 5M more items are purchased in store

-- Broken down by year:
SELECT
RANK() OVER(PARTITION BY FinancialYear ORDER BY SUM(UnitsSold) DESC) AS Rank,
FinancialYear,
LocationType,
SUM(UnitsSold) AS UnitsSold
FROM SalesData 
GROUP BY FinancialYear, LocationType
ORDER BY FinancialYear, UnitsSold DESC;
-- Could compare with a line chart (using labels/annotations and the 'M' unit)
/* So in 2021 we had a huge spike in online orders.
If we remember previously, our sales and profit dropped by 10% 
in this year as well. 
Previously, in 2020, we sold just under 15M units of goods, and our web stores
sold 8M - a combined total of almost 23M units.
In 2021, our web stores sold almost 11M units. "Fantastic", you would think,
"that's growth", in a way...
but this is where our drop in gross sales and profit in 2021 is realised - 
because in this same year (2021) we only sold 8M units in store - 6M less
than what we sold in store the previous year of 14M, and a combined total 
of 18M compared to 23M.
But this is where it gets good,
In 2022, our physical stores sold over 12M units of goods,
and even better our web stores maintained their purchase rate (units sold) 
of just under 11M units.

So what does this tell us?
So our total units sold in 2020 was about 22.8M, and in 2022 it was also 
around 22M - ,roughly, the same
however, our gross sales and gross profit for 2022 
was ,10%, greater than 2020.

This tells us that 
- we need our physical stores
- our web stores play a vital role in our revenue 
- we have a lot more room for upside in revenue growth 

*/ 


-- So let's break down our revenue a bit more 

--What division is more profitable?(overall)
SELECT 
Division,
ROUND(SUM(GrossProfit),2) AS GrossProfit
FROM SalesData
GROUP BY Division
ORDER BY GrossProfit DESC;
-- Over the past 3 years: Apparel 

--What division is more profitable?(over the years)
SELECT 
FinancialYear,
Division,
ROUND(SUM(GrossProfit), 2) AS GrossProfit
FROM SalesData
GROUP BY FinancialYear, Division
ORDER BY FinancialYear, GrossProfit DESC;
/* It was footwear in 2020, but has been apparel 
for the past 2 years running. With the gap getting wider and wider */
-- can use the bar charts that are grouped by year, different colour for apparel vs footwear

-- Is this division also producing more revenue?
SELECT 
FinancialYear,
Division,
ROUND(SUM(GrossSales), 2) AS GrossSales
FROM SalesData
GROUP BY FinancialYear, Division
ORDER BY FinancialYear, GrossSales DESC;
-- can use the bar charts that are grouped by year again, 
-- different colour for apparel vs footwear


/* Now that we know what division is more profitable, let's find out
What item category is the most popular */

SELECT
ItemCategory,
SUM(UnitsSold) AS UnitsSold
FROM SalesData
GROUP BY ItemCategory
ORDER BY Unitssold DESC;
-- Display results using a sideways bar chart in descending order (top 5)
-- Men's Apparel, all the way to Women's Footwear

/* So men's apparel is the most popular,
Are most of the sales online or in stores? */
SELECT 
ItemCategory, 
LocationType,
SUM(UnitsSold) AS UnitsSold
FROM SalesData
WHERE ItemCategory = 'Mens Apparel'
GROUP BY ItemCategory, LocationType
ORDER BY UnitsSold DESC;
-- The store 

-- Split by year 
SELECT 
FinancialYear,
ItemCategory, 
LocationType,
SUM(UnitsSold) AS UnitsSold
FROM SalesData
WHERE ItemCategory = 'Mens Apparel'
GROUP BY FinancialYear, ItemCategory, LocationType
ORDER BY FinancialYear, UnitsSold DESC;
-- 

-- What is the top performing product group?
SELECT TOP 10 
ProductGroup,
ROUND(SUM(GrossSales), 2) AS GrossSales,
ROUND(SUM(GrossProfit), 2) AS GrossProfit
FROM SalesData
GROUP BY ProductGroup
ORDER BY GrossSales DESC, GrossProfit DESC;
-- 'Running', followed by 'basketball' then 'padded jackets'
-- Show top 10 in graph 


-- [ What is the top performing ItemCategory within these ProductGroups?
SELECT 
ItemCategory,
ROUND(SUM(GrossSales), 2) AS GrossSales,
ROUND(SUM(GrossProfit), 2) AS GrossProfit
FROM SalesData
WHERE ProductGroup IN (SELECT TOP 10
	ProductGroup
	FROM SalesData
	GROUP BY ProductGroup
	ORDER BY SUM(GrossSales) DESC, SUM(GrossProfit) DESC)
GROUP BY ItemCategory
ORDER BY GrossSales DESC, GrossProfit DESC;
--- ]


-- What are our worst performing product groups?
SELECT TOP 5 
ProductGroup,
ROUND(SUM(GrossSales), 2) AS GrossSales,
ROUND(SUM(GrossProfit), 2) AS GrossProfit
FROM SalesData
GROUP BY ProductGroup
ORDER BY GrossSales ASC, GrossProfit ASC;
-- Only show 5 
-- Woven suits, skirts etc 


-- Broken down by year?
WITH WorstPerforming AS (
SELECT 
RANK() OVER(PARTITION BY FinancialYear ORDER BY SUM(GrossSales)) AS Rank, 
FinancialYear, 
ProductGroup,
ROUND(SUM(GrossSales), 2) AS GrossSales,
ROUND(SUM(GrossProfit), 2) AS GrossProfit
FROM SalesData
GROUP BY FinancialYear, ProductGroup)
SELECT * FROM WorstPerforming
WHERE WorstPerforming.Rank <= 5;



/* What productgroups have seen the greatest increase in customer 
interest over the past years? */

WITH CustomerInterest AS (
SELECT 
FinancialYear,
ProductGroup,
SUM(UnitsSold) AS UnitsSold,
LAG(SUM(UnitsSold)) OVER(PARTITION BY ProductGroup ORDER BY FinancialYear)
AS PreviousYearUnitssold,
SUM(UnitsSold) / 
LAG(SUM(UnitsSold)) OVER(PARTITION BY ProductGroup ORDER BY FinancialYear)
*100 -100 AS PercentDifference
FROM SalesData
GROUP BY FinancialYear, ProductGroup
-- ORDER BY FinancialYear, UnitsSold 
), Percentages AS (
SELECT 
RANK() OVER(PARTITION BY FinancialYear ORDER BY PercentDifference DESC)
AS Rank,
FinancialYear, ProductGroup, ROUND(PercentDifference, 1) AS PercentDifference
FROM CustomerInterest 
-- ORDER BY FinancialYear
)
SELECT * FROM Percentages 
WHERE Rank <=5 AND FinancialYear != 2020;

-- 2021: Woven Pants: 135% increase, 1/4 Zip Tops: 117% increase 
-- 2022: Fashion pants: 376% increase, Fashion Tops: 335% increase 