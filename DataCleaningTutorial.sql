/* Data Cleaning 
Learned via FreeCodeCamp course: "Learn Data Analysis with Python in this Comprehensive 19-Hour Bootcamp" (https://www.freecodecamp.org/news/learn-data-analysis-with-comprehensive-19-hour-bootcamp/)

-- 1. Base Data
Select * 
FROM Projects..NashHousing

-- 2. Change Date Format

Select SaleDate, Convert(Date,SaleDate)
FROM Projects..NashHousing

------Update NashHousing
------SET SaleDate = Convert(Date,SaleDate)

----ALTER TABLE NashHousing
----Add SaleDateTwo Date;
--SELECT TOP 0 * FROM Projects..NashHousing
 
Update NashHousing
Set SaleDateTwo = Convert(Date,SaleDate)

SELECT SaleDateTwo FROM Projects..NashHousing

-- 3. Populate Property Address Data; 

Select a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Projects..NashHousing a
JOIN Projects..NashHousing b ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL-- OR b.PropertyAddress IS NULL

--Update a
--SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
--FROM Projects..NashHousing a
--JOIN Projects..NashHousing b ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
--WHERE a.PropertyAddress IS NULL

SELECT PropertyAddress FROM Projects..NashHousing WHERE PropertyAddress IS NULL



-- 4. Breaking address into columns (Address, City, State) ; Substring

Select PropertyAddress
FROM Projects..NashHousing 
 

 SELECT
 Substring(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)- 1) as PropertyAdd
 , Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) PropertyCity
 , Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1) PropertyCity_JJTest
  FROM Projects..NashHousing

  ALTER TABLE NashHousing
  Add PropertyCleanAddress NVarChar(500);

  Update NashHousing
  SET PropertyCleanAddress = Substring(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)- 1)

  ALTER TABLE NashHousing
  Add PropertyCleanCity NVarChar(500);

  Update NashHousing
  SET PropertyCleanCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

  SELECT TOP 1 * FROM Projects..NashHousing



  -- 5. Breaking address into columns 2 (Address, City, State) ; ParseString

  SELECT OwnerAddress FROM Projects..NashHousing

  SELECT
  OwnerAddress
  , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS CleanOwnerAddress
  , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS CleanOwnerCity
  , PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS CleanOwnerState
  FROM Projects..NashHousing

  ----ALTER TABLE NashHousing
  ----Add OwnerCleanAddress NVarChar(500);

  ----ALTER TABLE NashHousing
  ----Add OwnerCleanCity NVarChar(500);

  ----ALTER TABLE NashHousing
  ----Add OwnerCleanState NVarChar(50);

  ----SELECT TOP 0 * FROM Projects..NashHousing

  --Update NashHousing
  --Set OwnerCleanAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

  --Update NashHousing
  --Set OwnerCleanCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

  --Update NashHousing
  --Set OwnerCleanState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

  SELECT TOP 10 * FROM Projects..NashHousing


-- 6. Change Y/N to "Yes"/"No."

SELECT Distinct (SoldAsVacant), COUNT(SoldAsVacant)
FROM Projects..NashHousing
GROUP BY SoldAsVacant
--0 = 51802 ; 1= 4675 ; No Y/N in the given file.    

SELECT SoldAsVacant
, CASE When SoldAsVacant = '0' THEN 'No' ELSE 'Yes' END AS SoldAsVacant_YN
FROM Projects..NashHousing

Update NashHousing
SET SoldAsVacant = CASE When SoldAsVacant = '0' THEN 'No' ELSE 'Yes' END 
-- Receiving Conversion Error.  Updating Column type. Not part of the given tutorial.
----ALTER Table NashHousing 
----ALTER Column SoldAsVacant VARCHAR(10);

SELECT SoldAsVacant FROM Projects..NashHousing


-- 7. Remove duplicates
WITH 
RowNumCTE AS
(
SELECT *, ROW_NUMBER() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference ORDER BY UniqueID) row_num
FROM Projects..NashHousing
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


    */

-- 8. Remove Columns (usually from views, not tables/raw data.)

SELECT * FROM Projects..NashHousing

--ALTER TABLE Projects..NashHousing
----DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
--DROP COLUMN SaleDate
-- Renamed columns outside of the tutorial.  In SQL Server utilized ObjectExplorer to manually rename.


