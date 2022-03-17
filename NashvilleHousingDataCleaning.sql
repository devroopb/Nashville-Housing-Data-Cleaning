--Data Cleaning on Nashville Housing Dataset



Select *
From PortfolioProject..NashvilleHousing$


--Standardize Date Format
Alter Table NashvilleHousing$
Add SaleDateConverted Date;

Update NashvilleHousing$
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDateConverted
From PortfolioProject..NashvilleHousing$

--Alter Table NashvilleHousing$
--Drop Column SaleDate;




--Populate Property Address data
Select *
From PortfolioProject..NashvilleHousing$
order by ParcelID

Select first.ParcelID, first.PropertyAddress, second.ParcelID, second.PropertyAddress, ISNULL(first.PropertyAddress, second.PropertyAddress)
From PortfolioProject..NashvilleHousing$ first
Join NashvilleHousing$ second 
	on first.ParcelID = second.ParcelID
	and first.[UniqueID ] <> second.[UniqueID ]
Where first.PropertyAddress is null

Update first
Set PropertyAddress = ISNULL(first.PropertyAddress, second.PropertyAddress)
From PortfolioProject..NashvilleHousing$ first
Join NashvilleHousing$ second 
	on first.ParcelID = second.ParcelID
	and first.[UniqueID ] <> second.[UniqueID ]
Where first.PropertyAddress is null




--Divide PropertyAddress into Individual Columns (Address, City) and then OwnerAddress into (Address, City, State)
Select PropertyAddress
From PortfolioProject..NashvilleHousing$

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) City
From NashvilleHousing$


Alter Table NashvilleHousing$
Add PropertySplitAddress nvarchar(255);

Alter Table NashvilleHousing$
Add PropertySplitCity nvarchar(100);


Update NashvilleHousing$
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Update NashvilleHousing$
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Alter Table NashvilleHousing$
--Drop Column PropertyAddress;





Select 
Parsename(Replace(OwnerAddress, ',', '.'), 3) Address,
Parsename(Replace(OwnerAddress, ',', '.'), 2) City,
Parsename(Replace(OwnerAddress, ',', '.'), 1) State
From NashvilleHousing$


Alter Table NashvilleHousing$
Add OwnerSplitAddress nvarchar(255);

Alter Table NashvilleHousing$
Add OwnerSplitCity nvarchar(100);

Alter Table NashvilleHousing$
Add OwnerSplitState nvarchar(50);


Update NashvilleHousing$
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing$
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing$
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)


--Alter Table NashvilleHousing$
--Drop Column OwnerAddress;




--Change Y/N to Yes/No under "Sold as Vacant"
Select Distinct(SoldAsVacant), Count(SoldAsVacant) cnt
From NashvilleHousing$
Group by SoldAsVacant
Order by cnt

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing$

Alter Table NashvilleHousing$
Add SoldAsVacantUpdated nvarchar(10);

Update NashvilleHousing$
Set SoldAsVacantUpdated = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

--Alter Table NashvilleHousing$
--Drop Column SoldAsVacant;

Select Distinct(SoldAsVacantUpdated), Count(SoldAsVacantUpdated) cnt
From NashvilleHousing$
Group by SoldAsVacantUpdated
Order by cnt





--Remove Duplicates
With RowNumCTE As(
Select *,
	ROW_NUMBER() over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing$
)
Delete
From RowNumCTE
Where row_num > 1



--Delete Unuused Columns
Select *
From PortfolioProject..NashvilleHousing$

Alter Table NashvilleHousing$
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SoldAsVacant, SaleDate
