
-- Nashville Housing Data 

-- We are going to perform Data Cleaning into this dataset 


SELECT * FROM Nashville_Housing;


-- While importing this dataset I got this ï»¿UniqueID so I have to rename this column.

ALTER TABLE nashville_housing
RENAME COLUMN ï»¿UniqueID to UniqueID;


-- Standardize the date 
-- We have to format this date April 9, 2013 to 2013-04-09.

SELECT SaleDate FROM nashville_housing;

SELECT 
    SaleDate,
    LEFT(Saledate , POSITION(' ' IN  SaleDate)-1) AS 'Month',
    RIGHT(Saledate , LENGTH(Saledate) - POSITION(' ' IN  SaleDate)) AS 'DayYear'
FROM
    nashville_housing;

-- Adding Month column in the dataset
ALTER TABLE Nashville_Housing
ADD Month NVARCHAR(15);

-- Updating Month column with month name which will extract from SaleDate column
UPDATE Nashville_Housing
SET Month =  LEFT(Saledate , POSITION(' ' IN  SaleDate)-1);

-- Now Adding DayYear column so that later we can extract Day and Year from that
ALTER TABLE Nashville_Housing
ADD DayYear NVARCHAR(15);

-- Updating DayYear column with day and year values
UPDATE Nashville_Housing
SET DayYear =  RIGHT(Saledate , LENGTH(Saledate) - POSITION(' ' IN  SaleDate));

-- Let's check the updated dataset
SELECT * FROM nashville_housing;

-- Now splitting Day from DayYear column

SELECT 
    DayYear,
    LEFT(DayYear , POSITION(',' IN  DayYear)-1) AS 'Day',
    RIGHT(DayYear , LENGTH(DayYear) - POSITION(' ' IN  DayYear)) AS 'Year'
FROM
    nashville_housing;
  
-- Here we adding Day column
ALTER TABLE Nashville_Housing
ADD Day text;

-- then updating day column with day number which we will extract from DayYear column
UPDATE Nashville_Housing
SET Day =   LEFT(DayYear , POSITION(',' IN  DayYear)-1);

-- Adding year column extract from DayYear
ALTER TABLE Nashville_Housing
ADD Year text;

-- Now update Year column
UPDATE Nashville_Housing
SET Year =  RIGHT(DayYear , LENGTH(DayYear) - POSITION(' ' IN  DayYear));



SELECT 
    month,
    CASE
		WHEN month = 'January' then 1
        WHEN month = 'February' then 2
        WHEN month = 'March' then 3
        WHEN month = 'April' then 4
        WHEN month = 'May' then 5
        WHEN month = 'June' then 6
        WHEN month = 'July' then 7
        WHEN month = 'August' then 8
        WHEN month = 'September' then 9
        WHEN month = 'October' then 10
        WHEN month = 'November' then 11
        WHEN month = 'December' then 12
		ELSE Month
	END AS Month_number
FROM
    nashville_housing;
    
    
-- So because we don't have month number so we have give month number to their respective month name
-- Here we can use CASE statement

-- first add Month_number to the dataset to get month number
ALTER TABLE nashville_housing
ADD Month_number text;

-- Updating Month_number using CASE
UPDATE nashville_housing
SET Month_number = CASE
		WHEN month = 'January' then 1
        WHEN month = 'February' then 2
        WHEN month = 'March' then 3
        WHEN month = 'April' then 4
        WHEN month = 'May' then 5
        WHEN month = 'June' then 6
        WHEN month = 'July' then 7
        WHEN month = 'August' then 8
        WHEN month = 'September' then 9
        WHEN month = 'October' then 10
        WHEN month = 'November' then 11
        WHEN month = 'December' then 12
		ELSE Month
	END;


-- Let's check updated columns 
SELECT * FROM nashville_housing;



SELECT 
    CONCAT(Year , '-' , Month_number , '-' , Day) AS Sale_Date
FROM
    nashville_housing;
    
 
-- We are adding new Sale_Date with proper date format 
 
ALTER TABLE nashville_housing
ADD Sale_Date Date;

-- Now at the end we are updating Sale_Date by concat to get complete Date column in proper date format

UPDATE nashville_housing
SET Sale_Date = CONCAT(Year , '-' , Month_number , '-' , Day);

   
-- Now let's see our new Sale_Date 
SELECT * FROM nashville_housing;
    
-- Splitting PropertyAdress and OwnerAddress into Address and City columns respectively.

-- Splitting PropertyAdress

SELECT 
        SUBSTRING(PropertyAddress , 1 , POSITION(',' IN PropertyAddress)-1) AS Property_Address,
        SUBSTRING(PropertyAddress , POSITION(',' IN PropertyAddress)+1 , LENGTH(PropertyAddress))AS Property_City
FROM
    Nashville_Housing;
    
    
ALTER TABLE Nashville_Housing
ADD Property_Address NVARCHAR(255);

UPDATE Nashville_Housing
SET Property_Address = SUBSTRING(PropertyAddress , 1 , POSITION(',' IN PropertyAddress)-1);

ALTER TABLE Nashville_Housing
ADD Property_City NVARCHAR(255);

UPDATE Nashville_Housing
SET Property_City =  SUBSTRING(PropertyAddress , POSITION(',' IN PropertyAddress)+1 , LENGTH(PropertyAddress));


-- Splitting OwnerAddress

SELECT 
      OwnerAddress
FROM
    Nashville_Housing;
    
    
SELECT 
      OwnerAddress,
      LEFT(owneraddress , POSITION(',' IN OwnerAddress)-1) AS Owner_address,
      RIGHT(owneraddress , LENGTH(owneraddress) - POSITION(',' IN OwnerAddress)) AS Owner_address2
FROM
    Nashville_Housing;
    
ALTER TABLE nashville_housing
ADD Owner_address NVARCHAR(255);

UPDATE nashville_housing
SET Owner_address = LEFT(owneraddress , POSITION(',' IN OwnerAddress)-1);

ALTER TABLE nashville_housing
DROP Owner_address2;
ALTER TABLE nashville_housing
ADD Owner_address2 NVARCHAR(255);

UPDATE nashville_housing
SET Owner_address2 = RIGHT(owneraddress , LENGTH(owneraddress) - POSITION(',' IN OwnerAddress));

SELECT * FROM nashville_housing;

SELECT
	Owner_address2,
    LEFT(Owner_address2 , POSITION(',' IN Owner_address2)-1) AS Owner_City,
    RIGHT(Owner_address2 , LENGTH(Owner_address2) - POSITION(',' IN Owner_address2)) AS Owner_State
FROM
	nashville_housing;
    
    
ALTER TABLE nashville_housing
ADD Owner_City NVARCHAR(255);

UPDATE nashville_housing
SET Owner_City = LEFT(Owner_address2 , POSITION(',' IN Owner_address2)-1);

ALTER TABLE nashville_housing
ADD Owner_State NVARCHAR(255);

UPDATE nashville_housing
SET Owner_State =RIGHT(Owner_address2 , LENGTH(Owner_address2) - POSITION(',' IN Owner_address2));


-- We have successfully created two columns (Property_address and Property_City) for PropertyAddress.
-- And Three columns (Owner_address , Owner_City and Owner_State) for OwnerAddress.

-- Now let's check those columns 

SELECT 
	*
FROM
    Nashville_Housing;
    
 
 
-- Now we can see that the in SoldAsVacant column we have irregularities we have to replace Y to Yes and N to No.
 
SELECT 
	DISTINCT(soldAsVacant),
    COUNT(soldAsVacant) AS Occurence
FROM
    Nashville_Housing
GROUP BY soldAsVacant
ORDER BY Occurence;
       


-- We can check that our query is right or wrong using common table expression  , check with below query-

WITH SoldAsVacant_cte AS (
SELECT
	SoldAsVacant,
    CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END AS Sold_As_Vacant
FROM
	Nashville_Housing)
SELECT 
	*, 
	COUNT(Sold_As_Vacant) AS Num_count
FROM 
	SoldAsVacant_cte
GROUP BY Sold_As_Vacant
ORDER BY Num_count;


-- If we want to replace those values permanently then we have to update that column.

UPDATE nashville_housing 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;


-- Let's check our changes

SELECT 
    DISTINCT(SoldAsVacant)
FROM
    nashville_housing;



-- Let's see how many duplicates records we have

SELECT * FROM nashville_housing;


WITH RowNum_cte AS(
SELECT 
	*,
    ROW_NUMBER() OVER(
		PARTITION BY ParcelID , 
					 Property_Address, 
                     Property_City,
					 SaleDate ,  
                     SalePrice , 
                     LegalReference
					 ORDER BY UniqueID) as Row_num
FROM
    Nashville_Housing)
SELECT 
	*
FROM
	RowNum_cte
WHERE Row_num > 1 ;
	
-- We have 103 duplicate rows that we have to remove it or filter it out while quering.




-- Delete Unused Columns - Not recommended

# We can drop PropertyAddress column because we have seperated it into address and city columns.

SELECT * FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN PropertyAddress;

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress;

ALTER TABLE nashville_housing
DROP COLUMN Owner_Address2;

ALTER TABLE nashville_housing
DROP COLUMN SaleDate,
DROP COLUMN DayYear,
DROP COLUMN Month_number;

-- So let's see our final dataset

SELECT * FROM nashville_housing;


-- So we have done here Data Cleaning now you can explore your data more.



