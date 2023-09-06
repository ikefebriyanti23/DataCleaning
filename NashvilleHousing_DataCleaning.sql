/*CLEANING DATA IN SQL WITH NASHVILLE HOUSING*/
SELECT*
FROM NashvilleHousing;

--Standardize the Date Format
SELECT SaleDate
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate);

--Populate Property Address Data
SELECT*
FROM NashvilleHousing
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

--Breaking Down Address into Individual Columns (Address, City, State) [Property Address]
SELECT PropertyAddress
FROM NashvilleHousing;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

SELECT*
FROM NashvilleHousing;

--Breaking Down Address into Individual Columns (Address, City, State) [Owner Address]
SELECT OwnerAddress
FROM NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

--Change Y and N to 'Yes' and 'No' in 'Solid as Vacant' Field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END;

--Remove Duplicates
WITH rownum_CTE AS(
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) AS row_num
FROM NashvilleHousing)

SELECT*
FROM rownum_CTE
WHERE row_num > 1;

--Delete Unused Columns
SELECT*
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;