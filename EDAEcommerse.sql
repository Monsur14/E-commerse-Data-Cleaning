Select *
From ecommerse2;

-- Count of total number of transactions
Select count(TransactionNo)
From ecommerse2;

-- count of distinct customers
Select count(distinct CustomerNo)
From ecommerse2;

-- count of distinct products
Select count(distinct Product_Number)
From ecommerse2;

-- total revenue price x quantity
Select sum(price * quantity) AS Revenue
From ecommerse2;

-- top 10 best selling products
Select product_name, sum(price * quantity) as revenue
From ecommerse2
Group by product_name
Order by revenue desc
Limit 10;

-- top 10 best selling by quantity sold
Select product_name, sum(quantity) as total
From ecommerse2
Group by product_name
Order by total desc
Limit 10;

-- products with lowest sales or no sales
Select product_name, sum(price * quantity) as revenue
From ecommerse2
Where price is not null and quantity is not null
Group by product_name 
Order by revenue asc
Limit 10;

-- monthly revenue trends over time
SELECT DATE_FORMAT(Date, '%Y-%m') AS `Month`, SUM(Quantity * Price) AS Revenue
FROM ecommerse2
GROUP BY `Month`
ORDER BY revenue desc;

-- revenue by country
SELECT Country, SUM(Quantity * Price) AS Revenue
FROM ecommerse2
GROUP BY Country
ORDER BY Revenue DESC;

-- revenue by product
SELECT Product_Number, SUM(Quantity * Price) AS Revenue
FROM ecommerse2
GROUP BY Product_Number
ORDER BY Revenue DESC
LIMIT 10;

-- average order value
SELECT AVG(Quantity * Price) AS Avg_Order_Value
FROM ecommerse2;

-- top 5 countries by order
SELECT Country, COUNT(*) AS Order_Count
FROM ecommerse2
GROUP BY Country
ORDER BY Order_Count DESC
LIMIT 5;

-- highest quantities per product
SELECT Product_Number, SUM(Quantity) AS Total_Units_Sold
FROM ecommerse2
GROUP BY Product_Number
ORDER BY Total_Units_Sold DESC
LIMIT 10;


SELECT *
FROM ecommerse2
WHERE Date IS NULL OR Quantity IS NULL OR Price IS NULL;

SELECT Currency, COUNT(*) AS Row_Count
FROM ecommerse2
GROUP BY Currency;


-- End of EDA