/* EDA Project - Review Latitude/Longitude of Earthquakes, distances from each, and determine if tsunami frequency is determined by distance and time.  This is only looking at one table of data, there are no Joins in this document. */
--------------/*  1 - Finding the table that houses the column I'm looking for */

--------------SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME
--------------FROM INFORMATION_SCHEMA. COLUMNS
--------------WHERE COLUMN_NAME LIKE '%atit%'

------------/* 2 - Checking the first few rows of table */
------------SELECT TOP 10 * FROM dbo.Earthquake_Tsunami_Data


----------/* 3 - Order the table by Descending-Date. Exlcuding unneded columns. */
----------SELECT TOP 100 magnitude, depth, latitude, longitude, year, month, tsunami 
----------FROM dbo.Earthquake_Tsunami_Data
----------ORDER BY year DESC, month DESC

--------/* 4 - Count Earthquakes by year-month */

--------SELECT year, month, COUNT(year) AS Count
--------FROM dbo.Earthquake_Tsunami_Data
--------GROUP BY year, month
--------ORDER BY year DESC, month DESC

--------/*Validate*/
--------SELECT year, COUNT(year) AS Count
--------FROM dbo.Earthquake_Tsunami_Data
--------WHERE year = 2022
--------GROUP BY year
--------ORDER BY year DESC
----------7+1+7+1+1+1+3+1+6+2+10 =>40.  2022 = 40.  Match.

------/* 5 - Review just 2022-01 data and determine Lat/Long Distances from each other item.  CTEs are needed.
------Data does not include time periods, so sorting by latitude with the assumption that aftershocks are also recorded.*/
------WITH PositionData AS (
------SELECT year, month, magnitude, latitude, longitude, cdi, mmi, sig, nst, dmin, gap, tsunami 
------, CONCAT (latitude , ', ',  longitude) AS CombinedLatLong
------, LAG(latitude, 1) OVER (ORDER BY year, month) AS Prev_Latitude
------, LAG(longitude, 1) OVER (ORDER BY year, month) AS Prev_Longitude
------FROM dbo.Earthquake_Tsunami_Data
------WHERE year = 2022 AND month = 1
------)
------, 
------DeltaData AS (SELECT *
------, CONCAT (Prev_Latitude, ', ',  Prev_Longitude) AS Prev_CombinedLatLong
------, (latitude - Prev_Latitude) AS Lat_Delta
------, (longitude - Prev_Longitude) AS Long_Delta
--------Disclosure: The following was researched online
------, CASE WHEN Prev_Latitude IS NULL THEN 0 
------        ELSE 
------            3959 * acos(
------                cos(radians(Prev_Latitude)) * cos(radians(Latitude)) * cos(radians(Longitude) - radians(Prev_Longitude)) + 
------                sin(radians(Prev_Latitude)) * sin(radians(Latitude))
------            )
------    END AS Mile_Delta
------FROM PositionData),
------RelatedRows AS (
------SELECT *,
------LEAD(Mile_Delta, 1) OVER (ORDER BY Year, Month) AS RelatedRow
------FROM DeltaData
------)

------/* Of note, the positions with no changes between one recording and another have the exact same magnitude, indicating that there may be duplicates in this file.  
------Re-added previously removed columns to explore further. */

------SELECT *
------FROM RelatedRows
------WHERE Mile_Delta = 0 OR RelatedRow = 0

------/* Not too familiar with earthquake science, but the results in this set do NOT appear to be due to bad data - rather the instruments at two different locations caught the same quakes
------and recorded the same numbers, which makes the data more reliable (though we'd need to weed out duplicates for visualizations, etc.)  A SME would be helpful in doing this research. */ 

----/* 6 - Expanded the above step to include all the year/month data. */

----WITH PositionData AS (
----SELECT year, month, magnitude, latitude, longitude, cdi, mmi, sig, nst, dmin, gap, tsunami 
----, CONCAT (latitude , ', ',  longitude) AS CombinedLatLong
----, LAG(latitude, 1) OVER (ORDER BY year, month) AS Prev_Latitude
----, LAG(longitude, 1) OVER (ORDER BY year, month) AS Prev_Longitude
----FROM dbo.Earthquake_Tsunami_Data
----)
----, 
----DeltaData AS (SELECT *
----, CONCAT (Prev_Latitude, ', ',  Prev_Longitude) AS Prev_CombinedLatLong
----, (latitude - Prev_Latitude) AS Lat_Delta
----, (longitude - Prev_Longitude) AS Long_Delta
------Disclosure: The following was researched online
----, CASE WHEN Prev_Latitude IS NULL THEN 0 
----        ELSE 
----            3959 * acos(
----                cos(radians(Prev_Latitude)) * cos(radians(Latitude)) * cos(radians(Longitude) - radians(Prev_Longitude)) + 
----                sin(radians(Prev_Latitude)) * sin(radians(Latitude))
----            )
----    END AS Mile_Delta
----FROM PositionData),
----RelatedRows AS (
----SELECT *,
----LEAD(Mile_Delta, 1) OVER (ORDER BY Year, Month) AS RelatedRow
----FROM DeltaData
----)

----SELECT *
----FROM RelatedRows
------WHERE Mile_Delta = 0 OR RelatedRow = 0
----ORDER BY year DESC, month DESC

----/* It looks like the only items with 'duplicates' are from the 2022 data set.  Still no SME to reach out to, but it is possible that this is a quirk in the system. */


--/* 7 - Now looking at rows where tsunamis were detected.  Cleaning up the columns to avoid data overload. */

--WITH PositionData AS (
--SELECT year, month, magnitude, latitude, longitude, cdi, mmi, sig, nst, dmin, gap, tsunami 
--, CONCAT (latitude , ', ',  longitude) AS CombinedLatLong
--, LAG(latitude, 1) OVER (ORDER BY year, month) AS Prev_Latitude
--, LAG(longitude, 1) OVER (ORDER BY year, month) AS Prev_Longitude
--FROM dbo.Earthquake_Tsunami_Data
--)
--, 
--DeltaData AS (SELECT *
--, CONCAT (Prev_Latitude, ', ',  Prev_Longitude) AS Prev_CombinedLatLong
--, (latitude - Prev_Latitude) AS Lat_Delta
--, (longitude - Prev_Longitude) AS Long_Delta
----Disclosure: The following was researched online
--, CASE WHEN Prev_Latitude IS NULL THEN 0 
--        ELSE 
--            3959 * acos(
--                cos(radians(Prev_Latitude)) * cos(radians(Latitude)) * cos(radians(Longitude) - radians(Prev_Longitude)) + 
--                sin(radians(Prev_Latitude)) * sin(radians(Latitude))
--            )
--    END AS Mile_Delta
--FROM PositionData),
--RelatedRows AS (
--SELECT *,
--LEAD(Mile_Delta, 1) OVER (ORDER BY Year, Month) AS RelatedRow
--FROM DeltaData
--)

--SELECT year, month, magnitude, CombinedLatLong, tsunami, Mile_Delta
--FROM RelatedRows
--WHERE Mile_Delta != 0 --AND tsunami = 1
--ORDER BY Mile_Delta ASC

--/* Refined the Query to Order By the Mile_Delta with the assumption that the Delta may be a factor. Closest Non-0 Delta is 2.29mi.  Furthest is 11956.4mi. 
--However, removing the tsunami flag, we see that other Mile_Deltas under 10mi do not result in a tsunami, even if the magnitude is higher.*/


/* 8 - Next step.  Determine how many tsunamis are being caused by the various magnitudes. */
WITH PositionData AS (
SELECT year, month, magnitude, latitude, longitude, cdi, mmi, sig, nst, dmin, gap, tsunami 
, CONCAT (latitude , ', ',  longitude) AS CombinedLatLong
, LAG(latitude, 1) OVER (ORDER BY year, month) AS Prev_Latitude
, LAG(longitude, 1) OVER (ORDER BY year, month) AS Prev_Longitude
FROM dbo.Earthquake_Tsunami_Data
)
, 
DeltaData AS (SELECT *
, CONCAT (Prev_Latitude, ', ',  Prev_Longitude) AS Prev_CombinedLatLong
, (latitude - Prev_Latitude) AS Lat_Delta
, (longitude - Prev_Longitude) AS Long_Delta
--Disclosure: The following was researched online
, CASE WHEN Prev_Latitude IS NULL THEN 0 
        ELSE 
            3959 * acos(
                cos(radians(Prev_Latitude)) * cos(radians(Latitude)) * cos(radians(Longitude) - radians(Prev_Longitude)) + 
                sin(radians(Prev_Latitude)) * sin(radians(Latitude))
            )
    END AS Mile_Delta
FROM PositionData),
RelatedRows AS (
SELECT *,
LEAD(Mile_Delta, 1) OVER (ORDER BY Year, Month) AS RelatedRow
FROM DeltaData
),
Level AS (
SELECT year, month, magnitude
, CASE WHEN magnitude < 5 THEN '<5'
    WHEN magnitude BETWEEN 5 AND 6 THEN 5
    WHEN magnitude BETWEEN 6 AND 7 THEN 6
    WHEN magnitude BETWEEN 7 AND 8 THEN 7
    WHEN magnitude BETWEEN 8 AND 9 THEN 8
    ELSE '9' END AS MagLevel
    , tsunami
FROM RelatedRows
)

SELECT COUNT(tsunami) AS TsunamiCount, MagLevel
FROM Level
GROUP BY MagLevel
ORDER BY MagLevel DESC

/* Glossary: cdi (Felt Intensity), mmi (Instrumental Intensity), sig (Significance Score), nst (# Monitoring Stations)  dmin (distance to nearest station), gap (degree between stations) */