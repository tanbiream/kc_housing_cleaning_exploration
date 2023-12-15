SELECT *
FROM kc_house_data

-- Calculate mean, median, minimum, and maximum sale prices for 2014

WITH HouseData2014 AS (
  SELECT 
    price
  FROM kc_house_data
  WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2014
)
SELECT 
  'Mean' AS metric,
  CONCAT('$', ROUND(AVG(price), 0)) AS value
FROM HouseData2014

UNION

SELECT 
  'Min' AS metric,
  CONCAT('$', ROUND(MIN(price), 0)) AS value
FROM HouseData2014

UNION

SELECT 
  'Max' AS metric,
  CONCAT('$', ROUND(MAX(price), 0)) AS value
FROM HouseData2014

UNION

SELECT 
  'Median' AS metric,
  CONCAT('$', ROUND(AVG(price), 0)) AS value
FROM (
  SELECT price, 
         ROW_NUMBER() OVER (ORDER BY price) AS rownum,
         COUNT(*) OVER () AS total_rows
  FROM HouseData2014
) AS sorted
WHERE rownum = CEIL(total_rows / 2) OR rownum = CEIL(total_rows / 2) + 1;

-- Calculate mean, median, minimum, and maximum sale prices for 2014

WITH HouseData2015 AS (
  SELECT 
    price
  FROM kc_house_data
  WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2015
)
SELECT 
  'Mean' AS metric,
  CONCAT('$', ROUND(AVG(price), 0)) AS value
FROM HouseData2015

UNION

SELECT 
  'Min' AS metric,
  CONCAT('$', ROUND(MIN(price), 0)) AS value
FROM HouseData2015

UNION

SELECT 
  'Max' AS metric,
  CONCAT('$', ROUND(MAX(price), 0)) AS value
FROM HouseData2015

UNION

SELECT 
  'Median' AS metric,
  CONCAT('$', ROUND(AVG(price), 0)) AS value
FROM (
  SELECT price, 
         ROW_NUMBER() OVER (ORDER BY price) AS rownum,
         COUNT(*) OVER () AS total_rows
  FROM HouseData2015
) AS sorted
WHERE rownum = CEIL(total_rows / 2) OR rownum = CEIL(total_rows / 2) + 1;


-- Explore the distribution of sale prices for 2014
SELECT
  price,
  COUNT(*) AS frequency
FROM kc_house_data
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2014
GROUP BY price
ORDER BY frequency DESC;

-- Explore the distribution of sale prices for 2015
SELECT
  price,
  COUNT(*) AS frequency
FROM kc_house_data
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2015
GROUP BY price
ORDER BY frequency DESC;

-- price range for houses sold in 2014
SELECT
  price_range,
  COUNT(*) AS sales_count,
  CONCAT('$', FORMAT(MIN(price), 0)) AS min_price,
  CONCAT('$', FORMAT(MAX(price), 0)) AS max_price
FROM (
  SELECT
    price,
    CASE
      WHEN price < 500000 THEN 'Low'
      WHEN price BETWEEN 500000 AND 1000000 THEN 'Medium'
      WHEN price > 1000000 THEN 'High'
      ELSE 'Unknown'
    END AS price_range
  FROM kc_house_data
  WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2014
) AS price_ranges
GROUP BY price_range
ORDER BY sales_count DESC;

-- Relationship between house features and sale prices
SELECT
  bedrooms,
  bathrooms,
  sqft_living AS size,
  AVG(price) AS avg_price,
  COUNT(*) AS sales_count
FROM kc_house_data
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2014
GROUP BY bedrooms, bathrooms, size
ORDER BY sales_count DESC;

-- Most common features in houses that were sold
SELECT
  bedrooms,
  bathrooms,
  sqft_living AS size,
  COUNT(*) AS sales_count
FROM kc_house_data
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2014
GROUP BY bedrooms, bathrooms, size
ORDER BY sales_count DESC
LIMIT 10; -- Adjust the limit based on your preference


-- Distribution of sales across different states

WITH SalesDistribution AS (
  SELECT
    zipcode,
    COUNT(*) AS sales_count
  FROM kc_house_data
  WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2014
  GROUP BY zipcode
  ORDER BY sales_count DESC
)

SELECT
  sd.zipcode,
  sd.sales_count,
  AVG(khd.price) AS avg_price
FROM SalesDistribution sd
JOIN kc_house_data khd ON sd.zipcode = khd.zipcode
WHERE EXTRACT(YEAR FROM STR_TO_DATE(khd.date, '%m-%d-%Y')) = 2014
GROUP BY sd.zipcode, sd.sales_count
ORDER BY sales_count DESC;

-- Monthly distribution of house sales for 2014
SELECT
  EXTRACT(MONTH FROM STR_TO_DATE(date, '%m-%d-%Y')) AS sale_month,
  COUNT(*) AS sales_count_2014
FROM kc_house_data
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2014
GROUP BY sale_month
ORDER BY sale_month;

-- Monthly distribution of house sales for 2014
SELECT
  MONTHNAME(STR_TO_DATE(date, '%m-%d-%Y')) AS sale_month,
  COUNT(*) AS sales_count_2014
FROM kc_house_data
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2014
GROUP BY sale_month
ORDER BY sales_count_2014 DESC;

-- Monthly distribution of house sales for 2015
SELECT
  MONTHNAME(STR_TO_DATE(date, '%m-%d-%Y')) AS sale_month,
  COUNT(*) AS sales_count_2015
FROM kc_house_data
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2015
GROUP BY sale_month
ORDER BY saleS_COUNT_2015 DESC;

-- Comparison of monthly sales between 2014 and 2015
SELECT
  MONTHNAME(STR_TO_DATE(date, '%m-%d-%Y')) AS sale_month,
  COUNT(*) AS sales_count_2014,
  (SELECT COUNT(*)
   FROM kc_house_data
   WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2015
   AND MONTHNAME(STR_TO_DATE(date, '%m-%d-%Y')) = sale_month) AS sales_count_2015
FROM kc_house_data
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) = 2014
GROUP BY sale_month
ORDER BY sale_month;


-- Explore seasonal patterns in house sales
SELECT
  CASE
    WHEN MONTH(STR_TO_DATE(date, '%m-%d-%Y')) BETWEEN 3 AND 5 THEN 'Spring'
    WHEN MONTH(STR_TO_DATE(date, '%m-%d-%Y')) BETWEEN 6 AND 8 THEN 'Summer'
    WHEN MONTH(STR_TO_DATE(date, '%m-%d-%Y')) BETWEEN 9 AND 11 THEN 'Fall'
    ELSE 'Winter'
  END AS season,
  COUNT(*) AS sales_count
FROM kc_house_data
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) IN (2014, 2015)
GROUP BY season
ORDER BY FIELD(season, 'Spring', 'Summer', 'Fall', 'Winter');

-- Compare the number of houses sold in 2014 and 2015
SELECT
  EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) AS sale_year,
  COUNT(*) AS sales_count
FROM kc_house_data
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%m-%d-%Y')) IN (2014, 2015)
GROUP BY sale_year
ORDER BY sale_year;


















