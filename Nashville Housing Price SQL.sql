select * from PortfolioProyect..NashvilleHousing


-- Estandarizamos el formato a Date

Select SaleDate, CONVERT(VARCHAR(10), SaleDate, 23)
From PortfolioProyect..NashvilleHousing

Update PortfolioProyect..NashvilleHousing
SET SaleDate = CONVERT(VARCHAR(10), SaleDate, 23)

Alter table PortfolioProyect..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProyect..NashvilleHousing
SET saleDateConverted = CONVERT(Date,SaleDate)

SELECT saledateconverted
FROM PortfolioProyect..NashvilleHousing

-- Despues voy a borrar SaleDate. Solo voy a usar SaleDateConverted como SaleDate.


-- Populate Property Address Data.

select *
from PortfolioProyect..NashvilleHousing
 where PropertyAddress is null

 select nash1.ParcelID, Nash1.PropertyAddress, Nash2.ParcelID, Nash2.PropertyAddress, ISNULL(Nash1.PropertyAddress, Nash2.PropertyAddress)
from PortfolioProyect..NashvilleHousing AS Nash1
join PortfolioProyect..NashvilleHousing AS Nash2
	on Nash1.ParcelID = Nash2.ParcelID
	and Nash1.[UniqueID ] <> Nash2.[UniqueID ]
where Nash1.PropertyAddress is null

update Nash1
set PropertyAddress = ISNULL(Nash1.PropertyAddress, Nash2.PropertyAddress)
from PortfolioProyect..NashvilleHousing AS Nash1
join PortfolioProyect..NashvilleHousing AS Nash2
	on Nash1.ParcelID = Nash2.ParcelID
	and Nash1.[UniqueID ] <> Nash2.[UniqueID ]
where Nash1.PropertyAddress is null


-- Separando Address en columnas individuales (Address, City, State)

Select PropertyAddress
From PortfolioProyect..NashvilleHousing
 
 
 
 Select PropertyAddress,
 SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) AS Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,len(propertyaddress)) AS Town
 From PortfolioProyect..NashvilleHousing


Alter table PortfolioProyect..NashvilleHousing
Add HouseAddress nvarchar(255);

Alter table PortfolioProyect..NashvilleHousing
Add HouseTown nvarchar(255);

update PortfolioProyect..NashvilleHousing
set HouseAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1)

Update PortfolioProyect..NashvilleHousing
set HouseTown = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,len(propertyaddress))

select HouseAddress, HouseTown from PortfolioProyect..NashvilleHousing

-- Trabajes con la direccion de los dueños

Select 
parsename(REPLACE(OwnerAddress, ',', '.'),3),
parsename(REPLACE(OwnerAddress, ',', '.'),2),
parsename(REPLACE(OwnerAddress, ',', '.'),1)
from PortfolioProyect..NashvilleHousing


Alter table PortfolioProyect..NashvilleHousing
Add OwnerHouse nvarchar(255);

Alter table PortfolioProyect..NashvilleHousing
Add OwnerTown nvarchar(255);

Alter table PortfolioProyect..NashvilleHousing
Add OwnerState nvarchar(255);

update PortfolioProyect..NashvilleHousing
set OwnerHouse = parsename(REPLACE(OwnerAddress, ',', '.'),3)

update PortfolioProyect..NashvilleHousing
set OwnerTown = parsename(REPLACE(OwnerAddress, ',', '.'),2)

update PortfolioProyect..NashvilleHousing
set OwnerState = parsename(REPLACE(OwnerAddress, ',', '.'),1)

-- Como ya formatie la informacion como la necesito, luego borrare OwnerAddress.


-- Cambio Y y N a Yes y No en 'Sold as Vacant' 

select distinct(SoldAsVacant), count(soldasvacant)
from PortfolioProyect..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE
	When SoldAsVacant = 'n' THEN 'No'
	When SoldAsVacant = 'y' THEN 'Yes'
	--When SoldAsVacant = 'Yes' THEN 'Yes'
	--WHEN SoldAsVacant = 'No' THEN 'No'
	ELSE SoldAsVacant
END
From PortfolioProyect..NashvilleHousing

update PortfolioProyect..NashvilleHousing
set SoldAsVacant =
CASE
	When SoldAsVacant = 'n' THEN 'No'
	When SoldAsVacant = 'y' THEN 'Yes'
	--When SoldAsVacant = 'Yes' THEN 'Yes'
	--WHEN SoldAsVacant = 'No' THEN 'No'
	ELSE SoldAsVacant
END


-- Borremos los duplicados

-- CTe

With RowNumCTE AS(
select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
				) AS Row_Num
From PortfolioProyect..NashvilleHousing
)
SELECT *
--DELETE 
FROM RowNumCTE
--where Row_Num > 1
ORDER BY PropertyAddress



-- Borremos las columnas que no necesitamos.
SELECT *
FROM PortfolioProyect..NashvilleHousing

/*
ALTER TABLE PortfolioProyect..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress
*/


