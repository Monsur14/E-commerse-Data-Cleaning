Select *
From ecommerseraw;
-- Data cleaning
-- Create a new table don't want to mess with raw table

Create table ecommerse
Like ecommerseraw;

Select*
From ecommerse;

Insert into ecommerse
Select *
From ecommerseraw;

Select 
	Trim(`Transaction No`) as TransactionNo, Trim(`date`) as `Date`, Trim(`Product Number`) as Product_Number,
    Trim(`product_name`) as Product_Name, Trim(`Price($)`) as Price, Trim(`Qty`) as Quantity, Trim(`Customer No`) as CustomerNo,
    Trim(`Country`) as Country
From ecommerse;

Alter table ecommerse
Rename Column `Transaction No` To TransactionNo,
Rename Column `date` To `Date`,
Rename Column `Product Number` to Product_Number,
Rename Column product_name to Product_Name,
Rename Column `Price($)` to Price,
Rename Column Qty TO Quantity,
Rename Column `Customer No` to CustomerNo,
Rename Column Country to Country;

Select *
From ecommerse;

-- search for dupliactes now 
-- row numbers give a unique identifier
Select *,
	Row_Number() Over(
		Partition by TransactionNo, `Date`, Product_Number, Product_Name, Quantity, CustomerNo, Country) as row_num
From ecommerse;

-- shows duplicates if a row has a identifier greater than 1
With duplicate_cte as
(
Select *,
Row_Number() Over(
		Partition by TransactionNo, `Date`, Product_Number, Product_Name, Quantity, CustomerNo, Country) as row_num
From ecommerse
)
Select *
From duplicate_cte
Where row_num > 1;

-- create new table with the row_num as a column so you can proceed with the delete

CREATE TABLE `ecommerse2` (
  `TransactionNo` text,
  `Date` text,
  `Product_Number` text,
  `Product_Name` text,
  `Price` text,
  `Quantity` text,
  `CustomerNo` text,
  `Country` text,
  `Row_Num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select *
From ecommerse2;

-- fill in table

Insert into ecommerse2
Select *,
Row_Number() Over(
		Partition by TransactionNo, `Date`, Product_Number, Product_Name, Quantity, CustomerNo, Country) as row_num
From ecommerse;

-- Now delete the duplicates

Delete
From ecommerse2
Where Row_Num > 1;

Select *
From ecommerse2;

-- Standardize data correct grammatical errors
-- in real world usually transaction numbers have a letter behind it lets go with T

Select CONCAT('T', TransactionNo) as TransactionNo
From ecommerse2;

Update ecommerse2
Set TransactionNo = CONCAT('T', TransactionNo);

Select Replace(TransactionNo, 'TC', 'T')
From ecommerse2;

Update ecommerse2
Set TransactionNo = Replace(TransactionNo, 'TC', 'T');

-- let fix the date column now looks really bad use this format YYYY-MM-DD
-- find the nano second dates

Select Date(from_unixtime(CAST(`Date` as UNSIGNED)/1000000000)) as `Date`
From ecommerse2
WHERE `Date` REGEXP '^[0-9]{19}$';

UPDATE ecommerse2
SET `Date` = DATE(FROM_UNIXTIME(CAST(`Date` AS UNSIGNED) / 1000000000))
WHERE `Date` REGEXP '^[0-9]{19}$';

Select *
From ecommerse2;

-- now convert the whole column into the YYYY-MM-DD format
-- going to use regexp ^ =start of string, [0-9]=any digits between 0-9, {19}= characters length, $=end of string, [[A-Za-z]= letters between a-z
Update ecommerse2
Set `Date` = NULL
Where `Date` = '?';

Update ecommerse2
Set `Date` = NULL
Where `Date` = '';

Select `Date`
From ecommerse2;

Update ecommerse2
Set `Date` = str_to_date(`Date`, '%M %d, %Y')
Where `Date` REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$';

UPDATE ecommerse2
SET `Date` = DATE(STR_TO_DATE(`Date`, '%Y-%m-%d'))
WHERE `Date` REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

UPDATE ecommerse2
SET `Date` = DATE(STR_TO_DATE(`Date`, '%m/%d/%Y'))
WHERE `Date` REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$';

UPDATE ecommerse2
SET `Date` = DATE(STR_TO_DATE(`Date`, '%d-%b-%Y'))
WHERE `Date` REGEXP '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{4}$';

Describe ecommerse2;

Alter table ecommerse2
Modify `Date` Date;

-- now lets fix the product number column

SELECT 
    REGEXP_REPLACE(Product_Number, '[A-Za-z]', '') as Product_Number
FROM ecommerse2
WHERE Product_Number REGEXP '[A-Za-z]';

Update ecommerse2
Set Product_Number = REGEXP_REPLACE(Product_Number, '[A-Za-z]', '')
WHERE Product_Number REGEXP '[A-Za-z]';

Select *
From ecommerse2;

-- now lets fix the product name column

Select Product_Name
From ecommerse2;

-- removes all special charcters from the column
SELECT 
    REGEXP_REPLACE(lower(Product_Name), '[^A-Za-z0-9 ]', '') AS Product_Name
FROM ecommerse2;

Update ecommerse2
Set Product_Name = REGEXP_REPLACE(lower(Product_Name), '[^A-Za-z0-9 ]', '');

Select concat(upper(substring(Product_Name,1, 1)), lower(substring(Product_Name,2)))
From ecommerse2;

Update ecommerse2
Set Product_Name = concat(upper(substring(Product_Name,1, 1)), lower(substring(Product_Name,2)));

-- now lets move onto the price column

Select Price
From ecommerse2;

SELECT 
    Price AS original,
    REGEXP_REPLACE(Price, '[^0-9.]', '') AS cleaned
FROM ecommerse2;

UPDATE ecommerse2
SET Price = '00.00'
WHERE LOWER(Price) = 'free';

Alter Table ecommerse2
Add Column Currency VARCHAR(10);

Select *
From ecommerse2;

Select
    Price AS Original_Price,
    CASE
        WHEN Price LIKE '%USD%' OR Price LIKE '%$%' THEN 'USD'
        WHEN Price LIKE '%EUR%' OR Price LIKE '%€%' THEN 'EUR'
        WHEN Price LIKE '%GBP%' OR Price LIKE '%£%' THEN 'GBP'
        ELSE 'USD' 
    END AS Currency
From ecommerse2;
    
Update ecommerse2
Set Currency = CASE
        WHEN Price LIKE '%USD%' OR Price LIKE '%$%' THEN 'USD'
        WHEN Price LIKE '%EUR%' OR Price LIKE '%€%' THEN 'EUR'
        WHEN Price LIKE '%GBP%' OR Price LIKE '%£%' THEN 'GBP'
        ELSE 'USD' 
    END;
    
UPDATE ecommerse2
SET Price = CAST(REGEXP_REPLACE(Price, '[^0-9.]', '') AS DECIMAL(10,2))
WHERE Price IS NOT NULL;

-- now lets move onto the quantity column

Select Quantity
From ecommerse2;

Select Quantity,
	CASE 
		When Quantity Like Trim('N/A') Then Null
        When Quantity Like Trim('ten') Then 10
        Else Quantity
	End as quant
From ecommerse2;

Update ecommerse2
Set Quantity = CASE 
		When Quantity Like Trim('N/A') Then Null
        When Quantity Like Trim('ten') Then 10
        Else Quantity
	End;
    
Select Replace(Quantity, '-','')
From ecommerse2;

Update ecommerse2
Set Quantity = Replace(Quantity, '-','');

SELECT Quantity, ROUND(Quantity, 0) 
FROM ecommerse2;

Update ecommerse2
Set Quantity = ROUND(Quantity, 0);

Select *
From ecommerse2;

-- lets move to customer number column
Select CustomerNo, ROUND(CustomerNo, 0)
From ecommerse2;

Update ecommerse2
Set CustomerNo = ROUND(CustomerNo, 0);

-- lets move onto the the Country column

Select distinct Country,
	CASE
		When Country Like 'UK' Then 'United Kingdom'
        When Country Like 'Gr8 Britain' Then 'United Kingdom'
        When Country Like 'U.K.' Then 'United Kingdom'
        When Country Like 'GB' Then 'United Kingdom'
        When Country Like 'united kingdom' Then 'United Kingdom'
        When Country Like 'England' Then 'United Kingdom'
		When Country Like 'EIRE' Then 'Ireland'
		When Country Like 'USA' Then 'United States'
        Else Country
        End as count
From ecommerse2;

Update ecommerse2
Set Country = CASE
		When Country Like 'UK' Then 'United Kingdom'
        When Country Like 'Gr8 Britain' Then 'United Kingdom'
        When Country Like 'U.K.' Then 'United Kingdom'
        When Country Like 'GB' Then 'United Kingdom'
        When Country Like 'united kingdom' Then 'United Kingdom'
        When Country Like 'England' Then 'United Kingdom'
		When Country Like 'EIRE' Then 'Ireland'
		When Country Like 'USA' Then 'United States'
        Else Country
	End;

Select *
From ecommerse2;

-- lets go back to currency column and put in correct values
Select distinct country, currency,
	Case
		When Country = 'Australia' then 'AUD'
        When Country = 'Austria' then 'ATS'
        When Country = 'Belgium' then 'BEF'
        When Country = 'Canada' then 'CAD'
        When Country = 'Channel Islands' then 'JEP'
        When Country = 'Cyprus' then 'EUR'
        When Country = 'Czech Republic' then 'CZK'
        When Country = 'Denmark' then 'DKK'
        When Country = 'Finland' then 'EUR'
        When Country = 'France' then 'EUR'
        When Country = 'Germany' then 'EUR'
        When Country = 'Iceland' then 'ISK'
        When Country = 'Ireland' then 'EUR'
        When Country = 'Israel' then 'ILS'
        When Country = 'Italy' then 'EUR'
        When Country = 'Japan' then 'JPY'
        When Country = 'Lithuania' then 'LTL'
        When Country = 'Malta' then 'EUR'
        When Country = 'Netherlands' then 'EUR'
        When Country = 'Norway' then 'NOK'
        When Country = 'Portugal' then 'EUR'
        When Country = 'Singapore' then 'SGD'
        When Country = 'Spain' then 'EUR'
        When Country = 'Sweden' then 'SEK'
        When Country = 'Switzerland' then 'CHF'
        When Country = 'United Kingdom' then 'GBP'
        When Country = 'United States' then 'USD'
        Else 'UKN'
	End as Count
From ecommerse2;

Update ecommerse2
Set Currency = Case
		When Country = 'Australia' then 'AUD'
        When Country = 'Austria' then 'ATS'
        When Country = 'Belgium' then 'BEF'
        When Country = 'Canada' then 'CAD'
        When Country = 'Channel Islands' then 'JEP'
        When Country = 'Cyprus' then 'EUR'
        When Country = 'Czech Republic' then 'CZK'
        When Country = 'Denmark' then 'DKK'
        When Country = 'Finland' then 'EUR'
        When Country = 'France' then 'EUR'
        When Country = 'Germany' then 'EUR'
        When Country = 'Iceland' then 'ISK'
        When Country = 'Ireland' then 'EUR'
        When Country = 'Israel' then 'ILS'
        When Country = 'Italy' then 'EUR'
        When Country = 'Japan' then 'JPY'
        When Country = 'Lithuania' then 'LTL'
        When Country = 'Malta' then 'EUR'
        When Country = 'Netherlands' then 'EUR'
        When Country = 'Norway' then 'NOK'
        When Country = 'Portugal' then 'EUR'
        When Country = 'Singapore' then 'SGD'
        When Country = 'Spain' then 'EUR'
        When Country = 'Sweden' then 'SEK'
        When Country = 'Switzerland' then 'CHF'
        When Country = 'United Kingdom' then 'GBP'
        When Country = 'United States' then 'USD'
        Else 'UKN'
	End;
    
Select *
From ecommerse2;

-- delete blank rows and get rid of any uneccesary columns
SELECT *
FROM ecommerse2
WHERE TransactionNo IN ('T', 'T?');

Delete
From ecommerse2
Where TransactionNo IN ('T', 'T?');

Alter table ecommerse2
Drop Column Row_Num;

-- fix up table types
Describe ecommerse2;

Alter table ecommerse2
Modify Column Product_Number int,
Modify Column Price float,
Modify Column Quantity int,
Modify Column CustomerNo int;

Select *
From ecommerse2;

-- DONE CLEANING!!!