/* DATA CLEANING SQL QUERIES of the Nashville Housing Dataset*/
-- This is a Case study focus on data cleaning using SQL
-- The dataset is available on https://www.kaggle.com/tmthyjames/nashville-housing-data

SELECT *
FROM PortfolioProject.dbo.nashvillehousing

------------------------------------------------------
--Standardize Date format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.nashvillehousing;

UPDATE nashvillehousing
SET SaleDate = CONVERT(Date,SaleDate);

ALTER TABLE nashvillehousing
ADD SaleDateConverted Date;

UPDATE nashvillehousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject.dbo.nashvillehousing


------------------------------------------------------
-- Populate Property address data
SELECT *
FROM PortfolioProject.dbo.nashvillehousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID  -- Same ParcelID = Same address


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.nashvillehousing A
JOIN PortfolioProject.dbo.nashvillehousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject.dbo.nashvillehousing A
JOIN PortfolioProject.dbo.nashvillehousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

------------------------------------------------------
-- Breaking out Address into induvidual columns (Address, City)
 -- The delimiter is a comma
SELECT PropertyAddress
FROM PortfolioProject.dbo.nashvillehousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.nashvillehousing


ALTER TABLE nashvillehousing -- Address
ADD PropertySplitAdress NVARCHAR(255);
UPDATE nashvillehousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE nashvillehousing -- City
ADD PropertySplitCity NVARCHAR(255);
UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.nashvillehousing

------------------------------------------------------
-- Breaking Owner Address -- This time with PARSENAME
SELECT OwnerAddress
FROM PortfolioProject.dbo.nashvillehousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject.dbo.nashvillehousing


ALTER TABLE nashvillehousing -- Address
ADD OwnerSplitAdress NVARCHAR(255);
UPDATE nashvillehousing
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE nashvillehousing -- City
ADD OwnerSplitCity NVARCHAR(255);
UPDATE nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE nashvillehousing -- State
ADD OwnerSplitState NVARCHAR(255);
UPDATE nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT *
FROM PortfolioProject.dbo.nashvillehousing



------------------------------------------------------
-- Changing Y an N to Yes and No in SoldAsVacant field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.nashvillehousing

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END

------------------------------------------------------
-- Removing duplicates
( --temp table
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID)
					row_num					
FROM PortfolioProject.dbo.nashvillehousing

--ORDER BY ParcelID 
)
Select *
From RowNumCTE;

--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
WHERE row_num > 1


------------------------------------------------------
--Removing unused columns 
SELECT *
FROM PortfolioProject.dbo.nashvillehousing

ALTER TABLE PortfolioProject.dbo.nashvillehousing
DROP COLUMN OwnerAddress,
			PropertyAddress

ALTER TABLE PortfolioProject.dbo.nashvillehousing
DROP COLUMN SaleDate

------------------------------------------------------