/*

Cleaning Nashville Housing Data in BigQuery SQL Queries

*/


SELECT *
FROM `portfolio-project-424902.Project_3.nashville_housing`


## Populate Property Address data


SELECT a.ParcelID, a.PropertyAddress AS a_PropertyAddress, b.ParcelID AS b_ParcelID, b.PropertyAddress AS b_PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) AS PropertyAddress
FROM `portfolio-project-424902.Project_3.nashville_housing` a
JOIN `portfolio-project-424902.Project_3.nashville_housing` b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

CREATE OR REPLACE TABLE `portfolio-project-424902.Project_3.nashville_housing` AS
SELECT a.UniqueID, a.ParcelID, a.LandUse, IFNULL(a.PropertyAddress, b.PropertyAddress) AS PropertyAddress, a.SaleDate, a.SalePrice, a.LegalReference, a.SoldAsVacant, a.OwnerName, a.OwnerAddress, a.Acreage, a.TaxDistrict, a.LandValue, a.BuildingValue, a.TotalValue, a.YearBuilt, a.Bedrooms, a.FullBath, a.HalfBath
FROM `portfolio-project-424902.Project_3.nashville_housing` a
LEFT JOIN `portfolio-project-424902.Project_3.nashville_housing` b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL
UNION ALL
SELECT UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath
FROM `portfolio-project-424902.Project_3.nashville_housing`
WHERE PropertyAddress IS NOT NULL

## Breaking out Address into Individual Columns (Address, City, State)


SELECT
  SUBSTR(PropertyAddress, 1, STRPOS(PropertyAddress, ',') - 1) AS Address1,
  SUBSTR(PropertyAddress, STRPOS(PropertyAddress, ',') + 1) AS Address2
FROM `portfolio-project-424902.Project_3.nashville_housing`


CREATE OR REPLACE TABLE `portfolio-project-424902.Project_3.nashville_housing` AS
SELECT UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath, CAST(NULL AS STRING) AS PropertySplitAddress, CAST(NULL AS STRING) AS PropertySplitCity
FROM `portfolio-project-424902.Project_3.nashville_housing`

UPDATE
  `portfolio-project-424902.Project_3.nashville_housing`
SET
  PropertySplitAddress = SUBSTR(PropertyAddress, 1, STRPOS(PropertyAddress, ',') -1)
WHERE
  PropertyAddress IS NOT NULL;

UPDATE 
  `portfolio-project-424902.Project_3.nashville_housing`
SET
  PropertySplitCity = SUBSTR(PropertyAddress, STRPOS(PropertyAddress, ',') +1)
WHERE
  PropertyAddress IS NOT NULL;


## Owner Address


SELECT
  SPLIT(OwnerAddress, ',')[OFFSET(0)] AS OwnerSplitAddress,
  SPLIT(OwnerAddress, ',')[OFFSET(1)] AS OwnerSplitCity,
  SPLIT(OwnerAddress, ',')[OFFSET(2)] AS OwnerSplitState
FROM
  `portfolio-project-424902.Project_3.nashville_housing`;


ALTER TABLE `portfolio-project-424902.Project_3.nashville_housing`
ADD Column OwnerSplitAddress STRING,
ADD Column OwnerSplitCity STRING,
ADD Column OwnerSplitState STRING;

UPDATE `portfolio-project-424902.Project_3.nashville_housing`
SET 
  OwnerSplitAddress = SPLIT(OwnerAddress, ',')[SAFE_OFFSET(0)],
  OwnerSplitCity = SPLIT(OwnerAddress, ',')[SAFE_OFFSET(1)],
  OwnerSplitState = SPLIT(OwnerAddress, ',')[SAFE_OFFSET(2)]
WHERE TRUE;


## Change Y and N to Yes and No in "Sold As Vacant"


SELECT SoldAsVacant, 
CASE 
  WHEN SoldAsVacant THEN 'Yes' 
  WHEN NOT SoldAsVacant THEN 'No' 
  ELSE 'Unknown'
  END AS SoldAsVacantLabel
FROM `portfolio-project-424902.Project_3.nashville_housing`


ALTER TABLE `portfolio-project-424902.Project_3.nashville_housing`
ADD COLUMN SoldAsVacantLabel STRING;

UPDATE `portfolio-project-424902.Project_3.nashville_housing`
SET SoldAsVacantLabel = 
  CASE 
    WHEN SoldAsVacant THEN 'Yes' 
    WHEN NOT SoldAsVacant THEN 'No' 
    ELSE 'Unknown' 
    END
WHERE TRUE;


## Removing Duplicates


MERGE `portfolio-project-424902.Project_3.nashville_housing` AS common
USING(
SELECT *,
  ROW_NUMBER() OVER (
    PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    ORDER BY UniqueID
  ) AS row_num
FROM `portfolio-project-424902.Project_3.nashville_housing`
) AS source
ON common.UniqueID = source.UniqueID
WHEN MATCHED AND source.row_num > 1 THEN DELETE;



WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER() OVER(
    PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    ORDER BY UniqueID
  ) AS row_num
FROM `portfolio-project-424902.Project_3.nashville_housing`
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


