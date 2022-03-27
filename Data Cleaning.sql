-- Explore all the data in Nashville Properties

SELECT
	*
FROM
	DataCleaningProjects.dbo.NashvilleProperties;


---------------------------------------------------------------------------------------------------------------

--Standardize the date format

SELECT 
	SaleDate,
	CONVERT(DATE, SaleDate)
FROM
	DataCleaningProjects.dbo.NashvilleProperties;



--UPDATE 
--	DataCleaningProjects.dbo.NashvilleProperties
--SET
--	SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE
	DataCleaningProjects.dbo.NashvilleProperties
ADD
	SaleDateConverted Date;

UPDATE 
	DataCleaningProjects.dbo.NashvilleProperties
SET
	SaleDateConverted = CONVERT(Date, SaleDate);



SELECT 
	SaleDateConverted
FROM
	DataCleaningProjects.dbo.NashvilleProperties;


---------------------------------------------------------------------------------------------------------------

--Populate the property address data

SELECT
	ParcelID,
	PropertyAddress
FROM
	DataCleaningProjects.dbo.NashvilleProperties
--WHERE
--	PropertyAddress IS NULL
ORDER BY
	ParcelID;

SELECT 
	np1.PropertyAddress,
	np1.ParcelID,
	np2.ParcelID,
	np2.PropertyAddress
FROM
	DataCleaningProjects.dbo.NashvilleProperties np1
	JOIN DataCleaningProjects.dbo.NashvilleProperties np2
	ON np1.ParcelID = np2.ParcelID
	AND np1.[UniqueID ] <> np2.[UniqueID ]
WHERE
	np1.PropertyAddress IS NULL;

UPDATE
	np1
SET
	PropertyAddress = ISNULL(np1.PropertyAddress, np2.PropertyAddress)
FROM
	DataCleaningProjects.dbo.NashvilleProperties np1
	JOIN DataCleaningProjects.dbo.NashvilleProperties np2
	ON np1.ParcelID = np2.ParcelID
	AND np1.[UniqueID ] <> np2.[UniqueID ]
WHERE
	np1.PropertyAddress IS NULL;


---------------------------------------------------------------------------------------------------------------

--Breaking out address into individual columns(Address, city, state) [Atomicity]

--PropertyAddress


SELECT
	PropertyAddress
FROM
	DataCleaningProjects.dbo.NashvilleProperties;

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM
	DataCleaningProjects.dbo.NashvilleProperties;



ALTER TABLE
	DataCleaningProjects.dbo.NashvilleProperties
ADD
	PropertySplitAddress nvarchar(255),
	PropertyCity nvarchar(255);


UPDATE 
	DataCleaningProjects.dbo.NashvilleProperties
SET
	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));



SELECT
	PropertyAddress,
	PropertySplitAddress,
	PropertyCity
FROM
	DataCleaningProjects.dbo.NashvilleProperties;



--OwnerAddress

SELECT
	OwnerAddress
FROM
	DataCleaningProjects.dbo.NashvilleProperties;


SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM
	DataCleaningProjects.dbo.NashvilleProperties;


ALTER TABLE
	DataCleaningProjects.dbo.NashvilleProperties
ADD
	OwnerSplitAddress nvarchar(255),
	OwnerCity nvarchar(255),
	OwnerState nvarchar(255);


UPDATE 
	DataCleaningProjects.dbo.NashvilleProperties
SET
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT
	OwnerAddress,
	OwnerSplitAddress,
	OwnerCity,
	OwnerState
FROM
	DataCleaningProjects.dbo.NashvilleProperties;



---------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in Sold as Vacant field

SELECT
	DISTINCT(SoldAsVacant)
FROM
	DataCleaningProjects.dbo.NashvilleProperties;


SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM
	DataCleaningProjects.dbo.NashvilleProperties;


UPDATE 
	DataCleaningProjects.dbo.NashvilleProperties
SET
	SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END;



---------------------------------------------------------------------------------------------------------------

--Remove duplicates

WITH RowNumCTE AS
(
	SELECT 
		*,
		ROW_NUMBER() OVER 
		(
			PARTITION BY 
				ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference,
				SoldAsVacant,
				OwnerName,
				Acreage
				ORDER BY
					UniqueID
		) AS row_num
	FROM
		DataCleaningProjects.dbo.NashvilleProperties
)


DELETE
FROM
	RowNumCTE
WHERE
	row_num > 1;


---------------------------------------------------------------------------------------------------------------

--DROP UNUSED COLUMNS

ALTER TABLE 
	DataCleaningProjects.dbo.NashvilleProperties
DROP COLUMN 
	PropertyAddress,
	OwnerAddress,
	SaleDate,
	TaxDistrict;


SELECT
	PropertyAddress
FROM
	DataCleaningProjects.dbo.NashvilleProperties;



---------------------------------------------------------------------------------------------------------------

--Rename the columns to meaningfull names
