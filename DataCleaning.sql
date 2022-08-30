LOAD DATA local INFILE 'C:\\Users\\Federico Baraldi\\Desktop\\Corsi\\DataAnalysisProject\\AlexTheAnalyst\\Nashville Housing Data for Data Cleaning.csv' 
INTO TABLE nashvillehousing
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

select * from nashvillehousing;

select count(UniqueID) from nashvillehousing;

/* Standardize data format */
select SaleDate, STR_TO_DATE(SaleDate, "%M %d,%Y") from nashvillehousing;
update nashvillehousing
set SaleDate= STR_TO_DATE(SaleDate, "%M %d,%Y");

/* Populate Property Address Data */
select * from nashvillehousing
where PropertyAddress LIKE "";
select * from nashvillehousing
order by ParcelID;
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, coalesce(b.PropertyAddress) from nashvillehousing a
join nashvillehousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress like "";
update nashvillehousing a
join nashvillehousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
set a.PropertyAddress = coalesce(b.PropertyAddress)
where a.PropertyAddress like "";


-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From NashvilleHousing;
SELECT
SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as Address
From NashvilleHousing;
ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 );
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress));


Select *
From NashvilleHousing;
Select OwnerAddress
From NashvilleHousing;
select OwnerAddress, SUBSTRING(OwnerAddress, 1 , LOCATE(',', OwnerAddress)-1 )
, SUBSTRING(SUBSTRING_INDEX(OwnerAddress, ',', 2), (LOCATE(',', OwnerAddress)+2) , (length(OwnerAddress)))
, SUBSTRING_INDEX(OwnerAddress, ',', -1)
from nashvillehousing;
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1 , LOCATE(',', OwnerAddress)-1 );
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = SUBSTRING(SUBSTRING_INDEX(OwnerAddress, ',', 2), (LOCATE(',', OwnerAddress)+2) , (length(OwnerAddress)));
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);
Select *
From NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2;
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing;
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
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
From NashvilleHousing
-- order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;
Select *
From NashvilleHousing;

---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
Select *
From NashvilleHousing;
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;




/*
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	
--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it
--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

*/



