/*

Cleaning Data in SQL Queries

*/

SELECT *
	FROM Nashville_HousingCSV

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.Nashville_HousingCSV


Update Nashville_HousingCSV
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE Nashville_HousingCSV
Add SaleDateConverted Date;

Update Nashville_HousingCSV
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM Nashville_HousingCSV

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_HousingCSV a
join Nashville_HousingCSV b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_HousingCSV a
join Nashville_HousingCSV b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.Nashville_HousingCSV
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.Nashville_HousingCSV


ALTER TABLE Nashville_HousingCSV
Add PropertySplitAddress Nvarchar(255);

Update Nashville_HousingCSV
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Nashville_HousingCSV
Add PropertySplitCity Nvarchar(255);

Update Nashville_HousingCSV
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.Nashville_HousingCSV

Select OwnerAddress
From PortfolioProject.dbo.Nashville_HousingCSV

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Nashville_HousingCSV

ALTER TABLE Nashville_HousingCSV
ADD OwnerSplitAdress nvarchar(255);

UPDATE Nashville_HousingCSV
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Nashville_HousingCSV
ADD OwnerSplitvCity nvarchar(255);

UPDATE Nashville_HousingCSV
SET OwnerSplitvCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Nashville_HousingCSV
ADD OwnerSplitState nvarchar(255);

UPDATE Nashville_HousingCSV
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_HousingCSV
GROUP BY SoldAsVacant
ORDER BY 2

ALTER TABLE Nashville_HousingCSV
ADD SoldAsVacant1 boolean;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = '1' THEN 'Yes'
	WHEN SoldAsVacant = '0' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM Nashville_HousingCSV

ALTER TABLE Nashville_HousingCSV
ALTER COLUMN SoldAsVacant nvarchar(255);

UPDATE Nashville_HousingCSV
SET SoldAsVacant = CASE WHEN SoldAsVacant = '1' THEN 'Yes'
	WHEN SoldAsVacant = '0' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Nashville_HousingCSV

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

FROM Nashville_HousingCSV
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.Nashville_HousingCSV


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

