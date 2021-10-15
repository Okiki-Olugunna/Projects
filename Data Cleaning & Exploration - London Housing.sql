--London Housing Data--
--DATA CLEANING & DATA EXPLORATION

 
USE LondonHousing
SELECT * FROM LondonHousing..[5YrsData]


--Data Cleaning

SELECT deed_date FROM ..[5YrsData]

-- Standardising the date format 
ALTER TABLE [5YrsData]
ADD deed_date_converted DATE

UPDATE [5YrsData]
SET deed_date_converted = CONVERT(Date,deed_date)
SELECT deed_date_converted FROM ..[5YrsData]

ALTER TABLE ..[5YrsData]
DROP COLUMN deed_date 

SELECT * FROM [5YrsData]



-- Putting the Property Address into one column
SELECT CONCAT(saon, ', ', paon, ', ', street) AS Address1
FROM [5YrsData]

ALTER TABLE [5YrsData]
ADD Address1 VARCHAR(255)

UPDATE [5YrsData]
SET Address1 = CONCAT(saon, ', ', paon, ', ', street)
SELECT Address1 FROM [5YrsData] 


--
SELECT * FROM [5YrsData]


--Changing Y and N to Yes and No in 'new_build' field 
SELECT new_build,
CASE 
	WHEN new_build = 'Y' THEN 'Yes'
	WHEN new_build = 'N' THEN 'No'
	END 
FROM ..[5YrsData]

UPDATE [5YrsData]
SET new_build = CASE 
	WHEN new_build = 'Y' THEN 'Yes'
	WHEN new_build = 'N' THEN 'No'
	END 

SELECT new_build FROM ..[5YrsData]


--
SELECT * FROM ..[5YrsData]
-- doing something similar as above but for 'property_type' and 'estate_type'

SELECT DISTINCT(property_type), COUNT(property_type)
FROM ..[5YrsData]
GROUP BY property_type
-- property types are O, T, S, D, F

SELECT DISTINCT(estate_type), COUNT(estate_type)
FROM ..[5YrsData]
GROUP BY estate_type
-- estate types are F and L


UPDATE [5YrsData]
SET property_type = CASE 
	WHEN property_type = 'F' THEN 'Flat'
	WHEN property_type = 'D' THEN 'Detached'
	WHEN property_type = 'S' THEN 'Semi-Detached'
	WHEN property_type = 'T' THEN 'Terraced'
	WHEN property_type = 'O' THEN 'Other'
	END 

UPDATE [5YrsData]
SET estate_type = CASE 
	WHEN estate_type = 'F' THEN 'Freehold'
	WHEN estate_type = 'L' THEN 'Lease'
	END 

SELECT * FROM ..[5YrsData]

-- Are there any duplicates?
SELECT DISTINCT(unique_id), COUNT(unique_id)
FROM ..[5YrsData]
GROUP BY unique_id 
HAVING COUNT(unique_id) > 1 

-- There is only 1 duplicate in the data 
-- The unique_id is BA558B33-6338-76EF-E053-6B04A8C0B4B7

-- Removing this duplicate from the table
DELETE FROM ..[5YrsData]
WHERE unique_id = 'BA558B33-6338-76EF-E053-6B04A8C0B4B7'

--check again to see if there are duplicates
SELECT DISTINCT(unique_id), COUNT(unique_id)
FROM ..[5YrsData]
GROUP BY unique_id 
HAVING COUNT(unique_id) > 1 
-- No results; therefore it is confirmed that there are no duplicates left


SELECT * FROM ..[5YrsData]

-- Deleting an unused column 'locality'
ALTER TABLE ..[5YrsData]
DROP COLUMN locality

SELECT * FROM ..[5YrsData]





--
--Data Exploration 


-- Finding the average house price (general) 
SELECT AVG(price_paid)
FROM ..[5YrsData]
-- £342774.815

--Rounding this to 2 decimal places
SELECT ROUND(AVG(price_paid), 2) AS Average_Price
FROM ..[5YrsData]
-- Average house price (general) = £342774.82


-- Finding the average house price by House Type 
SELECT property_type, ROUND(AVG(price_paid), 2) AS Average_Price 
FROM ..[5YrsData] 
GROUP BY property_type 
ORDER BY Average_Price DESC

-- So Semi-detached houses are the most expensive at £415562.62

--I'm interested in finding out what the highest price paid was, let's see
SELECT property_type, ROUND(MAX(price_paid), 2) AS Average_Price 
FROM ..[5YrsData] 
GROUP BY property_type 
ORDER BY Average_Price DESC
-- Came out as £500,000 - which reminds me that I put that
-----as a filter on the HM Land Registry website when I was 
-------pulling this data 


-- Finding the average price in certain districts, e.g. Wimbledon vs Hackney 
SELECT district, ROUND(AVG(price_paid), 2) AS Average_Price 
FROM ..[5YrsData] 
GROUP BY district 
ORDER BY Average_Price DESC 
-- Harlow is the most epensive district


-- Finding what district has the most new builds 
SELECT district, COUNT(new_build)
FROM ..[5YrsData]
GROUP BY district
ORDER BY new_build DESC
--error came up because new build is stored as a string

-- going to turn 'yes' into 1 and 'no' into 0
-- using a temp table for this



SELECT *  
INTO #TEMP
FROM ..[5YrsData]

SELECT * FROM #TEMP

UPDATE #TEMP
SET new_build = CASE 
	WHEN new_build = 'Yes' THEN 1
	WHEN new_build = 'No' THEN 0
	END 

SELECT district, SUM(new_build)
FROM #TEMP 
GROUP BY district
ORDER BY new_build DESC
-- Still saying it's a string, going to have to CAST it

SELECT * FROM #TEMP

--also need to group by new_build as well

SELECT district, SUM(CAST(new_build AS INT)) AS total_new_builds
FROM #TEMP 
GROUP BY district, new_build
ORDER BY total_new_builds DESC

-- Highest number of new builds in the past 5 years has been in Newham
--- 4487 new builds
--Followed by Tower Hamlets(3393) and Greenwich(2388)
