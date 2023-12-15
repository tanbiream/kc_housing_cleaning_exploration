SELECT * 
FROM kc_house_data limit 22000;
-------------------------------------------------------------------------------------------------------------------------
-- NAMES OF ALL THE COLUMNS
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'kc_house_data';

-- type of data in column
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'kc_house_data';

-- Drop the "waterfront" and "view" columns
ALTER TABLE kc_house_data
DROP COLUMN waterfront,
DROP COLUMN view;

-- NULL value check in all columns
SELECT *
FROM kc_house_data
WHERE
id IS NULL
  OR date IS NULL
  OR price IS NULL
  OR bedrooms IS NULL
  OR bathrooms IS NULL
  OR sqft_living IS NULL
  OR sqft_lot IS NULL
  OR floors IS NULL
  OR `condition` IS NULL
  OR grade IS NULL
  OR sqft_above IS NULL
  OR sqft_basement IS NULL
  OR yr_built IS NULL
  OR yr_renovated IS NULL
  OR zipcode IS NULL
  OR lat IS NULL
  OR `long` IS NULL
  OR sqft_living15 IS NULL
  OR sqft_lot15 IS NULL;

show index 
from kc_house_data

-- UPDATING THE DATE FORMAT
SELECT date
FROM kc_house_data;

SELECT date
FROM kc_house_data
WHERE date IS NULL OR STR_TO_DATE(date, '%y-%m-%d') IS NULL;

UPDATE kc_house_data
SET date = DATE_FORMAT(STR_TO_DATE(date, '%m-%d-%y'), '%m-%d-%y')
WHERE date IS NOT NULL;
---------------------------------------------------------------------------------------------------------------------------

-- FIND AND DELETE ALL THE DUPLICATES VALUES
SELECT *
FROM kc_house_data
WHERE id in (
	SELECT id
    FROM kc_house_data
    group by id
    having count(*) > 1 
    );
    
-- UPDATING THE DUPLICATES VALUES AND KEEPING ALL THE RELEVANT DATA BASED ON RECENT DATES
WITH RankedData AS (
    SELECT
        id,
        date,
        price,
        ROW_NUMBER() OVER (PARTITION BY id ORDER BY date DESC) AS row_num
    FROM kc_house_data
    WHERE id IN (
        SELECT id
        FROM kc_house_data
        GROUP BY id
        HAVING COUNT(*) > 1
    )
)
UPDATE kc_house_data t
JOIN RankedData r ON t.id = r.id
SET t.price = r.price
WHERE r.row_num = 1;

SELECT 
	id,
    date,
    price
FROM kc_house_data
order by price desc;
--------------------------------------------------------------------------------------------------------------------------------
-- BEDROOMS AND BATHROOMS COUNT OF SOME OF THE EXPENSIVE HOUSES
SELECT 
	bedrooms, 
    bathrooms,
    price, 
    date
FROM kc_house_data
order by price desc ;

-- Properties with high bedroom and bathroom count
SELECT *
FROM kc_house_data
WHERE bedrooms > 10 OR bathrooms > 6;
----------------------------------------------------------------------------------------------------------------------------------
-- CREATING A SEPARATE TABLE FOR HOUSES WITHOUT BASEMENT

SELECT sqft_basement
FROM kc_house_data
WHERE sqft_basement = 0;

create table houses_without_basement 
SELECT *
FROM kc_house_data
WHERE sqft_basement = 0 ;

SELECT *
FROM houses_without_basement;
------------------------------------------------------------------------------------------------------------------------------------

SELECT yr_renovated
FROM kc_house_data;

SELECT 
    CASE 
        WHEN yr_renovated = '0' THEN 'Unknown'
        ELSE yr_renovated
    END AS yr_renovated
FROM kc_house_data
ORDER BY yr_renovated;

ALTER TABLE kc_house_data
MODIFY COLUMN yr_renovated VARCHAR(255); 

UPDATE kc_house_data
SET yr_renovated = 
    CASE 
        WHEN yr_renovated = '0' THEN 'Unknown'
        ELSE yr_renovated
    END;
----------------------------------------------------------------------------------------------------------------------------------
-- SEPARATE TABLES FOR PROPERTIES SOLD FOR EACH YEARS
CREATE TABLE properties_sold_2014 AS
SELECT *
FROM kc_house_data
WHERE YEAR(STR_TO_DATE(date, '%m-%d-%y')) = 2014;

SELECT *
FROM properties_sold_2014;
---------------------------------------------------------------------
CREATE TABLE properties_sold_2015 AS
SELECT *
FROM kc_house_data
WHERE YEAR(STR_TO_DATE(date, '%m-%d-%y')) = 2015;

SELECT *
FROM properties_sold_2015;
---------------------------------------------------------------------------------------------------------------------------------------






