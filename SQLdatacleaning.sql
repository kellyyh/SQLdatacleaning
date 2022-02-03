/*

Cleaning Data in SQL Queries 

*/

Select * 
From DataCleaningProject.dbo.NashvilleHousing

-------------------------------------------------------------------------

-- Standardize Data Format 

Select SaleDateConverted, CONVERT(Date,SaleDate)
From DataCleaningProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------
-- Populate Property Address Data 

Select *
From DataCleaningProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From DataCleaningProject.dbo.NashvilleHousing A
JOIN DataCleaningProject.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null


Update A
SET PropertyAddress= ISNULL(A.PropertyAddress, B.PropertyAddress)
From DataCleaningProject.dbo.NashvilleHousing A
JOIN DataCleaningProject.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null



-------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From DataCleaningProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

From DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
From DataCleaningProject.dbo.NashvilleHousing





SELECT OwnerAddress
From DataCleaningProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From DataCleaningProject.dbo.NashvilleHousing


-------------------------------------------------------------------------

-- Change Y and N to Yes and No in "sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleaningProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
,CASE when SoldAsVacant = 'Y' THEN 'YES'
   	when SoldAsVacant = 'N' THEN 'NO'
	Else SoldAsVacant
	END
From DataCleaningProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'YES'
   	when SoldAsVacant = 'N' THEN 'NO'
	Else SoldAsVacant
	END


-------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE As(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
				ORDER BY 
					UniqueID
					) Row_Num
From DataCleaningProject.dbo.NashvilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where Row_Num >1
--Order by PropertyAddress



Select *
From DataCleaningProject.dbo.NashvilleHousing

-------------------------------------------------------------------------
-- Delete Unused Columns 

Select *
From DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN SaleDate