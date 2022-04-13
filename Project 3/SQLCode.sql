SELECT *
FROM PortfolioProject3..Housing

-- Query 1
-- Standardize SaleDate format

--Using the CONVERT function

SELECT Saledate, CONVERT(Date, SaleDate) AS SaleDate_fixed
FROM PortfolioProject3..Housing

-- Using the CAST function

SELECT SaleDate, CAST(SaleDate AS date) AS SaleDate_fixed
FROM PortfolioProject3..Housing

-- Adding a new column (SaleDateConverted) and populating it with the new date format

ALTER TABLE PortfolioProject3..Housing
ADD SaleDateConverted date;

UPDATE PortfolioProject3..Housing
SET SaleDateConverted = CAST(SaleDate AS date)

-- Query 2
-- Populate Property Address data

-- rows with identical ParcelIDs should have the same address
-- Selecting the rows with identical ParcelID and NULL PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject3..Housing AS a
INNER JOIN PortfolioProject3..Housing AS b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject3..Housing AS a
INNER JOIN PortfolioProject3..Housing AS b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Query 3
-- Breaking out PropertyAddress & OwnerAddress into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject3..Housing

-- Separating address and city

SELECT 
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS City
FROM PortfolioProject3..Housing

-- Creating two new columns Address & City and inserting the new values

ALTER TABLE PortfolioProject3..Housing
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject3..Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject3..Housing
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject3..Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM PortfolioProject3..Housing

-- OwnerAddress

SELECT OwnerAddress
FROM PortfolioProject3..Housing

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject3..Housing

-- Creating two new columns Address & City and inserting the new values

ALTER TABLE PortfolioProject3..Housing
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject3..Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

ALTER TABLE PortfolioProject3..Housing
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject3..Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject3..Housing
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject3..Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Query 4
-- Change Y and N to Yes and No in the SoldAsVacant field

-- Checking how many Y and N values are in the dataset

SELECT DISTINCT(SoldAsVacant), count(*)
FROM PortfolioProject3..Housing
GROUP BY SoldAsVacant
ORDER BY count(*)

-- Replacing Y with Yes and N with No

SELECT	SoldAsVacant,
		CASE
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		END AS Flag
FROM PortfolioProject3..Housing

UPDATE PortfolioProject3..Housing
SET SoldAsVacant =	CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END

-- Query 5
-- Removing duplicates

WITH RowNumCTE AS
(SELECT *,
		ROW_NUMBER() OVER (PARTITION BY
											ParcelID,
											PropertyAddress,
											SalePrice,
											SaleDate,
											LegalReference
							ORDER BY		UniqueID) AS row_num
FROM PortfolioProject3..Housing)

DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Delete unused columns

ALTER TABLE PortfolioProject3..Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject3..Housing
DROP COLUMN SaleDate