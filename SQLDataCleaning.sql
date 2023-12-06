
-- Cleaning Data in SQL Queries-- 
Select *
From DataCleaning.dbo.Real_Estate

-- Standardize Date format
Select SaleDate
From DataCleaning.dbo.Real_Estate

ALTER TABLE Real_Estate
ALTER COLUMN SaleDate date

-- Populate Property Adress data
SELECT *
FROM DataCleaning.dbo.Real_Estate
WHERE PropertyAddress is NULL

Select ISNULL(a.PropertyAddress,b.PropertyAddress) as PopulatedPropertyID, *
From DataCleaning.dbo.Real_Estate a
    JOIN DataCleaning.dbo.Real_Estate b ON a.ParcelID=b.ParcelID AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress is NULL
ORDER BY a.ParcelID

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
From DataCleaning.dbo.Real_Estate a
    JOIN DataCleaning.dbo.Real_Estate b ON a.ParcelID=b.ParcelID AND a.UniqueID<>b.UniqueID 
WHERE a.PropertyAddress is NULL

-- Breaking out PropertyAddress into Individual Columns (PropertyAddress, PropertyCity)
Select PropertyAddress
From DataCleaning.dbo.Real_Estate

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1),
    SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
FROM DataCleaning.dbo.Real_Estate

ALTER TABLE DataCleaning.dbo.Real_Estate
ADD PropertySplitAddress Nvarchar(255),PropertySplitCity Nvarchar(255)

UPDATE DataCleaning.dbo.Real_Estate
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1), 
PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


-- Breaking out OwnerAddress into Individual Columns (OwnerAddress, OwnerCity, OwnerState)
SELECT OwnerAddress
FROM DataCleaning.dbo.Real_Estate

SELECT PARSENAME(REPLACE (OwnerAddress, ',','.'),3),
    PARSENAME(REPLACE (OwnerAddress, ',','.'),2),
    PARSENAME(REPLACE (OwnerAddress, ',','.'),1)
FROM DataCleaning.dbo.Real_Estate

ALTER TABLE DataCleaning.dbo.Real_Estate 
ADD OwnerSplitAddress varchar(255), OwnerSplitCity varchar(255), OwnerSplitState varchar(255)

UPDATE DataCleaning.dbo.Real_Estate
SET OwnerSplitAddress=PARSENAME(REPLACE (OwnerAddress, ',','.'),3), OwnerSplitCity=PARSENAME(REPLACE (OwnerAddress, ',','.'),2), 
OwnerSplitState=PARSENAME(REPLACE (OwnerAddress, ',','.'),1)

-- Change Y and N to Yes and No in 'Sold as Vacant' field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaning.dbo.Real_Estate
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
WHEN  SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant
END
FROM DataCleaning.dbo.Real_Estate

UPDATE DataCleaning.dbo.Real_Estate
SET SoldAsVacant=CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
WHEN  SoldAsVacant ='N' THEN 'No'
ELSE SoldAsVacant
END

-- RemoveDublicates
WITH
    Cte_Row_Num
    as
    (
        SELECT *, ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference
ORDER BY UniqueID) as row_num
        FROM DataCleaning.dbo.Real_Estate
    )
DELETE 
FROM Cte_Row_Num 
WHERE row_num > 1

-- Delete Unused Columns
Select *
From DataCleaning.dbo.Real_Estate

ALTER TABLE DataCleaning.dbo.Real_Estate
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict
