select * from Nashville;

--WHAT TO DO?

--STANDARDIZE DATE FORMAT

SELECT saledate, convert(date, saledate)
from Nashville;

update Nashville
set saledate = convert(date, saledate) --not working

alter table Nashville
alter column saledate date



--POPULATE PROPERTY ADDRESS DATA
select * 
from Nashville
where PropertyAddress is null

--some have the same address for different parcel id (same person)
--if parcel id has address then copy 

select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville a
join Nashville b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null

update a
set PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville a
join Nashville b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null



--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
--delimeter

select PropertyAddress
from Nashville

select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1,LEN(propertyaddress))
from Nashville

alter table nashville
add address_split nvarchar(255)

update Nashville
set address_split = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1)

alter table nashville
add city_split nvarchar(255)

update Nashville
set city_split = SUBSTRING(propertyaddress, CHARINDEX(',',PropertyAddress)+1, LEN(propertyaddress))


Select * from Nashville


--OwnerAddress without using substring

Select OwnerAddress from Nashville;

select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) as OwnerStreet,
PARSENAME(REPLACE(OwnerAddress, ',','.'),2) as OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',','.'),1) as OwnerState
from Nashville


alter table nashville
add OwnerStreet nvarchar(255)

update Nashville
set OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',','.'),3);

alter table nashville
add OwnerCity nvarchar(255)

update Nashville
set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2);

alter table nashville
add OwnerState nvarchar(255)

update Nashville
set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1);





--CHANGE Y AND N TO SOLD OR VACCANT
Select * from Nashville

select distinct(soldasvacant), count(soldasvacant)--checks all the values in this column
from Nashville 
group by SoldAsVacant
order by 2

select soldasvacant,
case when SoldAsVacant = 'Y' then 'YES'
	 when SoldAsVacant = 'N' then 'NO'
	 else SoldAsVacant
	 end
from Nashville

update Nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'YES'
	 when SoldAsVacant = 'N' then 'NO'
	 else SoldAsVacant
	 end




--REMOVE DUPLICATES 
select *,
ROW_NUMBER() OVER (
	partition by parcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by 
	uniqueId
) RowNum
from nashville
order by RowNum desc

--CTE
With RowNumCte as (
select *,
ROW_NUMBER() OVER (
	partition by parcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by 
	uniqueId
) RowNum
from nashville
)
delete 
from RowNumCte
where RowNum > 1
--order by PropertyAddress



--DELETE UNUSED COLUMNS
select *
from Nashville

alter table nashville
drop column OwnerAddress, PropertyAddress


