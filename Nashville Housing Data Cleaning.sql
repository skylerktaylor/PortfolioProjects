-- Cleaning Data SQL Queries


SELECT *
FROM nashville_housing

-- Populate Property Address data

--------------------------------------------------------------------------------------------


SELECT *
FROM nashville_housing
-- WHERE property_address iS NULL
ORDER BY parcel_id


SELECT a.parcel_id, b.parcel_id, a.property_address, b.property_address, 
	COALESCE (a.property_address, b.property_address)
FROM nashville_housing a
JOIN nashville_housing b 
	ON a.parcel_id = b.parcel_id
	AND a.unique_id <> b.unique_id
WHERE a.property_address IS NULL; 

UPDATE nashville_housing a
SET property_address = COALESCE(a.property_address, b.property_address)
FROM nashville_housing b 
WHERE a.parcel_id = b.parcel_id
  AND a.unique_id <> b.unique_id
  AND a.property_address IS NULL;

-------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Column(Address, City, State )

SELECT property_address
FROM nashville_housing 
-- WHERE property_address IS NULL
-- ORDER BY parcel_id

SELECT 
  SUBSTRING(property_address FROM 1 FOR POSITION(',' IN property_address) - 1) AS Address,
  SUBSTRING(property_address FROM POSITION(',' IN property_address) + 1) AS City
FROM nashville_housing;


ALTER TABLE nashville_housing
ADD property_split_address VARCHAR(255)


UPDATE nashville_housing
SET property_split_address = SUBSTRING(property_address FROM 1 FOR POSITION(',' IN property_address) - 1) 


ALTER TABLE nashville_housing
ADD property_split_city VARCHAR(255)


UPDATE nashville_housing
SET property_split_city = SUBSTRING(property_address FROM POSITION(',' IN property_address) + 1) 




SELECT *
FROM nashville_housing


SELECT 
  SPLIT_PART(owner_address, ',', 1) AS part1,
  SPLIT_PART(owner_address, ',', 2) AS part2,
  SPLIT_PART(owner_address, ',', 3) AS part3
FROM nashville_housing;


ALTER TABLE nashville_housing
ADD owner_split_address VARCHAR(255)


UPDATE nashville_housing
SET owner_split_address = SPLIT_PART(owner_address, ',', 1)


ALTER TABLE nashville_housing
ADD owner_split_city VARCHAR(255)


UPDATE nashville_housing
SET owner_split_city= SPLIT_PART(owner_address, ',', 2)


ALTER TABLE nashville_housing
ADD owner_split_state VARCHAR(255)


UPDATE nashville_housing
SET owner_split_state  = SPLIT_PART(owner_address, ',', 3) 


SELECT * 
FROM nashville_housing



--------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold As Vacant" field

SELECT DISTINCT(sold_as_vacant), COUNT(sold_as_vacant)
FROM nashville_housing
GROUP BY sold_as_vacant
ORDER BY 2;



SELECT sold_as_vacant,
CASE 
	WHEN sold_as_vacant = 'Y' THEN 'Yes'
	WHEN sold_as_vacant = 'N' THEN 'No'
	ELSE sold_as_vacant
	END
FROM nashville_housing


UPDATE nashville_housing 
SET sold_as_vacant =
CASE 
	WHEN sold_as_vacant = 'YES' THEN 'Yes'
	WHEN sold_as_vacant = 'NO' THEN 'No'
	ELSE sold_as_vacant
	END
	
	
---------------------------------------------------------------------------------------------------


-- Remove Duplicates

WITH rownumcte AS (
  SELECT *, 
  ROW_NUMBER() OVER(PARTITION BY parcel_id, 
                     property_address, 
                     sale_date, 
                     sale_price, 
                     legal_reference
                     ORDER BY unique_id) AS row_num
  FROM nashville_housing
)
DELETE FROM nashville_housing
WHERE (parcel_id, property_address, sale_date, sale_price, legal_reference) IN (
  SELECT parcel_id, property_address, sale_date, sale_price, legal_reference
  FROM rownumcte
  WHERE row_num > 1
);

---------------------------------------------------------------------------------

-- Delete Unused Columns

				   
SELECT * 
FROM nashville_housing

ALTER TABLE nashville_housing
DROP COLUMN owner_address,
DROP COLUMN tax_district,
DROP COLUMN property_address;


ALTER TABLE nashville_housing
DROP COLUMN sale_date;

