--Cleaning Data in SQL Queries
Select *
From PortfolioProject.dbo.NashvilleHousing
---------------------------------------------------------------------------------
-- Standardize Date format
Select SaleDateConverted, CONVERT (Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;
---------------------------------------------------------------------------------
--Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.parcelID, a.propertyAddress, b.parcelID, b.propertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select 
SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', ','), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', ','), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', ','), 1)
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', ','), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', ','), 2)

Select *
From PortfolioProject..NashvilleHousing
------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field.

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,Case when SoldAsVacant = 'Y' Then 'Yes'
	  when SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	  when SoldAsVacant = 'N' Then 'No'
	  Else SoldAsVacant
	  End
-----------------------------------------------------------------------------------------
--Remove Duplicates

With RowNumCTE As (
Select *,
ROW_NUMBER() Over (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			   UniqueID
			   ) Row_num
From PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
From RowNumCTE
Where Row_num>1
Order by PropertyAddress 

----------------------------------------------------------------------------------
--DELETE UNUSED COLUMNS
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress