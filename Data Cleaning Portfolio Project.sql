/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject.dbo.[Nashville Housing]

-- Standardize Date Format

SELECT SaleDate --CONVERT(DATE,SaleDate)
FROM PortfolioProject.dbo.[NashvilleHousing]

UPDATE [NashvilleHousing]
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT SaleDate,SaleDateConverted
FROM NashvilleHousing

-- Populate property Address data
SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- self join property address if null to  property address of not null
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--Breaking out Address into IndividualColumns (Address, city, state)
--CHARINDEX(substring, string, start)
--SUBSTRING(string, start, length)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address2
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing

----------------------- Breaking down owner address-----------------------------------
-- lets use parsename ruther than substring
--PARSENAME(string, '.') looks for . so where 'we replace with .
--REPLACE(string, ', .)

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in sold as vacant field


SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM PortfolioProject..NashvilleHousing  

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


----------------- Remove Duplicate---------------
 WITH RowNumCTE AS(
 SELECT *,
	 ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
)


DELETE 
FROM RowNumCTE   -- all these are duplicates > 1
WHERE row_num > 1
--ORDER BY PropertyAddress



-------------Delete Unused Coulumns--------------

SELECT *
FROM PortfolioProject .. NashvilleHousing


ALTER TABLE PortfolioProject .. NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject .. NashvilleHousing
DROP COLUMN SaleDate

