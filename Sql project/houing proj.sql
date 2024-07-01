--Cleaning data with SQL

Select * from [housing proj]..Sheet1;

--Standardize date format

Select SaleDate,convert(Date,SaleDate)
from [housing proj]..Sheet1

alter table [housing proj]..Sheet1 add saledateconverted date;
update [housing proj]..Sheet1 set SaleDateconverted =Convert(date,saleDate)
select saleDateconverted from Sheet1

---populate property address data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [housing proj]..Sheet1 a
JOIN [housing proj]..Sheet1 b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [housing proj]..Sheet1 a
JOIN [housing proj]..Sheet1 b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--address into address and city 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [housing proj]..Sheet1;

ALTER TABLE [housing proj]..Sheet1
Add PropertySplitAddress Nvarchar(255);

Update [housing proj]..Sheet1
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [housing proj]..Sheet1
Add PropertySplitCity Nvarchar(255);

Update [housing proj]..Sheet1
SET PropertySplitCity = 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From [housing proj]..Sheet1

---parse name Returns the specified part of an object name. 
--The parts of an object that can be retrieved are 
--the object name, schema name, database name, and server name. 

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [housing proj]..Sheet1;

ALTER TABLE [housing proj]..Sheet1
Add OwnerSplitAddress Nvarchar(255);

Update [housing proj]..Sheet1
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [housing proj]..Sheet1
Add OwnerSplitCity Nvarchar(255);

Update [housing proj]..Sheet1
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE [housing proj]..Sheet1
Add OwnerSplitState Nvarchar(255);

Update [housing proj]..Sheet1
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select * FROM
[housing proj]..Sheet1
 
 --CHANGE Y AND N TO YES AND NO IN SOLD AS VACANT COLUMN
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [housing proj]..Sheet1
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [housing proj]..Sheet1

UPDATE [housing proj]..Sheet1
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
SELECT *FROM [housing proj]..Sheet1

--REMOVE DUPLICATES
--TThis divides the rows or query result set into small partitions
--PARTITION BY does not affect the number of rows returned
--ROW_NUMBER numbers all rows sequentially

--The ROW_NUMBER() function is applied to each partition separately 
--and reinitialized the row number for each partition. 
--The PARTITION BY clause is optional. If you skip it, the ROW_NUMBER() function 
--will treat the whole result set as a single partition.

---remove duplicates with cte

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

From [housing proj]..Sheet1
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From [housing proj]..Sheet1

---delete unused column

ALTER TABLE [housing proj]..Sheet1
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


Select *
From [housing proj]..Sheet1