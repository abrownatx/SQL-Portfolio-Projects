/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject..[dbo.NashvilleHousing]

--------------------------------------------------------------------------------------------------------------------------

-- We need to standardize Date Format
Select SaleDate
From PortfolioProject..[dbo.NashvilleHousing]

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..[dbo.NashvilleHousing]

Update [dbo.NashvilleHousing]
SET SaleDate = CONVERT(Date,SaleDate)

-- This method was tried, however when we run the above Select saleDateConverted....statement, it fails so we will repeat the process with the alternative method below and rerun the converted statement.

ALTER TABLE [dbo.NashvilleHousing]
Add SaleDateConverted Date;

Update [dbo.NashvilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select saleDateConverted as FormattedSaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..[dbo.NashvilleHousing]

--This time it works, and the date is formatted correctly.
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertySplitAddress
From PortfolioProject..[dbo.NashvilleHousing]
Where PropertySplitAddress is null

--We have properties that are missing the address

Select *
From PortfolioProject..[dbo.NashvilleHousing]
Where PropertySplitAddress is null
order by ParcelID

Select *
From PortfolioProject..[dbo.NashvilleHousing]
--Where PropertyAddress is null
order by ParcelID

--Some ParcelID's match to a specific address. Furthermore, some Parcel ID's are duplicated or missing an address. We want to write a query here that takes an existing address and copies it for a duplicate ParcelID that may be missing an address.
--We are going to perform a selfjoin, to do this. (note: <> not equal to)
--ISNULL statement: if a.propertyaddress is null, we will populate the b. address and insert into null place

Select a.ParcelID, a.PropertySplitAddress, b.ParcelID, b.PropertySplitAddress, ISNULL(a.PropertySplitAddress,b.PropertySplitAddress) As NewPropertyAddress
From PortfolioProject..[dbo.NashvilleHousing] a
JOIN PortfolioProject..[dbo.NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--Where a.PropertySplitAddress is null

--Revised Statement to update the table to remove the nulls with the NewPropertyAddress
--Rerun the above statement to show that there are no null addresses since all have an address that has been inserted

Update a
SET PropertySplitAddress = ISNULL(a.PropertySplitAddress,b.PropertySplitAddress)
From PortfolioProject..[dbo.NashvilleHousing] a
JOIN PortfolioProject..[dbo.NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--Where a.PropertySplitAddress is null


-------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertySplitAddress
From PortfolioProject..[dbo.NashvilleHousing]
--Where PropertyAddress is null
--order by ParcelID

--We want to seperate out the address and the city from the results. (Seperate at the delimeter-comma)

SELECT
SUBSTRING(PropertySplitAddress, 1, CHARINDEX(',', PropertySplitAddress) -1 ) as Address
, SUBSTRING(PropertySplitAddress, CHARINDEX(',', PropertySplitAddress) + 1 , LEN(PropertySplitAddress)) as Address

From PortfolioProject..[dbo.NashvilleHousing]

--Create 2 new columns and add the value in

ALTER TABLE [dbo.NashvilleHousing]
Add PropertySplitAddress Nvarchar(255);

Update [dbo.NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertySplitAddress, 1, CHARINDEX(',', PropertySplitAddress) -1 )


ALTER TABLE [dbo.NashvilleHousing]
Add PropertySplitCity Nvarchar(255);

Update [dbo.NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertySplitAddress, CHARINDEX(',', PropertySplitAddress) + 1 , LEN(PropertySplitAddress))

--Check the Revisions

Select *
From PortfolioProject..[dbo.NashvilleHousing]

--A simpler and more complicated version 

Select OwnerSplitAddress
From PortfolioProject..[dbo.NashvilleHousing]

--PARSENAME is great for values delimted by a specific value  such a period, and so we'll do this on the owneraddress
--Again, we will split multiple datapoints into 3 seperate columns


Select
PARSENAME(REPLACE(OwnerSplitAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerSplitAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerSplitAddress, ',', '.') , 1)
From PortfolioProject..[dbo.NashvilleHousing]


ALTER TABLE [dbo.NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update [dbo.NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerSplitAddress, ',', '.') , 3)


ALTER TABLE [dbo.NashvilleHousing]
Add OwnerSplitCity Nvarchar(255);

Update [dbo.NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerSplitAddress, ',', '.') , 2)


ALTER TABLE [dbo.NashvilleHousing]
Add OwnerSplitState Nvarchar(255);

Update [dbo.NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerSplitAddress, ',', '.') , 1)

--Check our results

Select *
From PortfolioProject..[dbo.NashvilleHousing]


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..[dbo.NashvilleHousing]
Group by SoldAsVacant
order by 2

--Need to change the values y to yes, and n to no.

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..[dbo.NashvilleHousing]

--Put in the statement below

Update [dbo.NashvilleHousing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Check the results to see that Yes and No's have been aggregated

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..[dbo.NashvilleHousing]
Group by SoldAsVacant
order by 2


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicate data in specified columns
--Not recommended to use this method since we are removing real data from the table, so its better to run a CTE to find the duplicate values and work from there
--

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..[dbo.NashvilleHousing]
--order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertySplitAddress

--Since we found that we have 104 rows of duplicates we need to delete them

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..[dbo.NashvilleHousing]
--order by ParcelID
)
DELETE RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--Now that 104 rows have been deleted we rerun the statement

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..[dbo.NashvilleHousing]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertySplitAddress

--We have confirmed that all have been deleted

--Now we check our work

Select *
From PortfolioProject..[dbo.NashvilleHousing]


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns (Usually done on views, typically not to raw data!) Check with legal first! 


Select *
From PortfolioProject..[dbo.NashvilleHousing]


ALTER TABLE PortfolioProject..[dbo.NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
