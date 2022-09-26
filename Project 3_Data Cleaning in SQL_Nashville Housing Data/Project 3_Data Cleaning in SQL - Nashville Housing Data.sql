
/*
Project 3 - Data Cleaning in SQL Queries -- Nashville Housing Data
*/

-- First, taka a brief look at the data set

Select *
From [Portfolio Project 3_Nashville Housing Data]..[Nashville Housing]

--------------------------------------------------------------------------------------------------------------------------

-- Standardize date format

Select SaleDateConverted, Convert(Date, SaleDate)
From [Portfolio Project 3_Nashville Housing Data]..[Nashville Housing]

Update [Nashville Housing]
Set SaleDate = Convert(Date, SaleDate)

-- If it doesn't update properly, try the below method

Alter table [Nashville Housing]
Add SaleDateConverted Date

Update [Nashville Housing]
Set SaleDateConverted = Convert(Date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate property address data

Select *
From [Portfolio Project 3_Nashville Housing Data]..[Nashville Housing]
-- Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project 3_Nashville Housing Data]..[Nashville Housing] a
Join [Portfolio Project 3_Nashville Housing Data]..[Nashville Housing] b
	 on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project 3_Nashville Housing Data]..[Nashville Housing] a
Join [Portfolio Project 3_Nashville Housing Data]..[Nashville Housing] b
	 on a.ParcelID = b.ParcelID
	 and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking up addresses into individual columns (Address, City, State)

-- Splitting PropertyAddress into 2 separate columns: Address and City

Select PropertyAddress
From [Portfolio Project 3_Nashville Housing Data]..[Nashville Housing]

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From [Portfolio Project 3_Nashville Housing Data]..[Nashville Housing]

Alter table [Nashville Housing]
Add PropertySplitAdress varchar(255)

Update [Nashville Housing]
Set PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table [Nashville Housing]
Add PropertySplitCity varchar(255)

Update [Nashville Housing]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

Select *
From [Nashville Housing]

-- Splitting OwnerAddress into 3 separate columns: Address, City, and State

Select OwnerAddress
From [Nashville Housing]

Select
Parsename(Replace(OwnerAddress, ',', '.'), 3) as Address,
Parsename(Replace(OwnerAddress, ',', '.'), 2) as City,
Parsename(Replace(OwnerAddress, ',', '.'), 1) as State
From [Nashville Housing]

Alter table [Nashville Housing]
Add OwnerSplitAddress varchar(255)

Update [Nashville Housing]
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter table [Nashville Housing]
Add OwnerSplitCity varchar(255)

Update [Nashville Housing]
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter table [Nashville Housing]
Add OwnerSplitState varchar(255)

Update [Nashville Housing]
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

Select *
From [Nashville Housing]

--------------------------------------------------------------------------------------------------------------------------

-- Change 'Y' and 'N' to 'Yes' and 'No' in the "Sold as Vacant" field

Select distinct SoldAsVacant, Count(SoldAsVacant)
From [Nashville Housing]
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From [Nashville Housing]

Update [Nashville Housing]
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						Else SoldAsVacant
						End

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove duplicates

Select * 
From [Nashville Housing]


With RowNum_CTE as
(Select *,
	ROW_NUMBER() Over
	(Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	 Order by UniqueID) as row_num
From [Nashville Housing]
--Order by ParcelID
)
Delete
From RowNum_CTE
Where row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete unused columns

Select *
From [Nashville Housing]

Alter table [Nashville Housing]
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

