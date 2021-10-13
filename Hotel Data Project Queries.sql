--HOTEL DATA PROJECT 

USE HotelProject


-- adding the tables together because they were in different excel sheets, doing this puts the data from each year is into one table  
SELECT * FROM dbo.[2018]
UNION
SELECT * FROM dbo.[2019]
UNION
SELECT * FROM dbo.[2020]



-- BUSINESS/STAKEHOLDER QUESTION: IS HOTEL REVENUE GROWING?

-- creating a temporary table
WITH Hotels AS (
SELECT * FROM dbo.[2018]
UNION
SELECT * FROM dbo.[2019]
UNION
SELECT * FROM dbo.[2020]
)
SELECT * FROM Hotels

-- No revenue column, but there is 'adr' = average daily rate
-- Also have the 'stays in week nights' & 'stays in weekend nights' columns

-- creating a column that adds the 'stays on week nights' & 'stays on weekend nights'
WITH Hotels AS (
SELECT * FROM dbo.[2018]
UNION
SELECT * FROM dbo.[2019]
UNION
SELECT * FROM dbo.[2020]
)

SELECT stays_in_week_nights + stays_in_weekend_nights FROM Hotels


-- multiplying the number of days stayed by the adr
WITH Hotels AS (
SELECT * FROM dbo.[2018]
UNION
SELECT * FROM dbo.[2019]
UNION
SELECT * FROM dbo.[2020]
)

SELECT (stays_in_week_nights + stays_in_weekend_nights)*adr  AS Revenue FROM Hotels
-- This new column is now the revenue



-- Grouping the year column & revenue column
WITH Hotels AS (
SELECT * FROM dbo.[2018]
UNION
SELECT * FROM dbo.[2019]
UNION
SELECT * FROM dbo.[2020]
)

SELECT
arrival_date_year,
SUM((stays_in_week_nights + stays_in_weekend_nights)*adr)  AS Revenue FROM Hotels
GROUP BY arrival_date_year 


-- Separating it by Hotel Type & rounding the revenue to 2 decimal places
WITH Hotels AS (
SELECT * FROM dbo.[2018]
UNION
SELECT * FROM dbo.[2019]
UNION
SELECT * FROM dbo.[2020]
)

SELECT
arrival_date_year,
hotel,
ROUND(SUM((stays_in_week_nights + stays_in_weekend_nights)*adr), 2)  AS Revenue FROM Hotels
GROUP BY arrival_date_year, hotel 

--Output:
--arrival_date_year	hotel		Revenue
--2018				City Hotel		1764667.57
--2019				City Hotel		10755979.11
--2020				City Hotel		8018122.43
--2018				Resort Hotel	3120849.49
--2019				Resort Hotel	9432430.29
--2020				Resort Hotel	6266123.81

-- Yes, the Hotel revenue is growing for each Hotel, however it seems as though rvenue growth took a hit in 2020,
--- Most likely attributed to covid regulations 
