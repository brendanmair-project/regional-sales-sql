/* This SQL code will look into 5 different tables: regional_sales, Sales, Order, Product, Customer.
The code will answer these questions.
1. Which Sales channel had the least amount of Unit profit, the most? Which Warehouse offeres the most Profit?
2. What sales team work with what state the most, what region? Which region offered the most profit?
3. Which Sales DIstributor had the Most sales? How much is the order quantity?
4. Which proudct was sold most? Which Sales team Sold this the most?
5. How many orders were either very profitbale, somewhat, etc.?
6. What was the average distance between Order date and Ship date?
7. Which Store offered the most discount? What Sales team?
8. What customer segment ordered the most? What Ship mode most was used for each region? 
These questions will go more in depth if need 
Thank you for looking into this project! */

SELECT *
FROM sales_data.main;

-- 1. Which Sales channel had the least amount of Unit profit, the most? --
SELECT
	SalesChannel
  , WarehouseCode
-- Rounding the average unit and sum the total --
  , ROUND(AVG(UnitProfit),2) AS "Average Unit Profit"
  , ROUND(sum(TotalProfit),2) AS "Most total Profit"
FROM 
	sales_data.main
-- grouping them togeher by Sales channel and warehouse --
GROUP BY
	SalesChannel
  , WarehouseCode
ORDER BY 
	ROUND(sum(TotalProfit),2) DESC
LIMIT 5;
-- We see that the most total profir is ocassionally most in Store --


-- 2. What sales team work with what state the most, what region? Which region offered the most profit? --
SELECT
	_SalesTeamID
 ,  Max(TotalProfit)
 ,  OrderQuantity 
FROM
	sales_data.sales
GROUP BY 
	_SalesTeamID
  , OrderQuantity
ORDER BY 
	max(TotalProfit) DESC
LIMIT 3;

-- region --
SELECT 
	main._SalesTeamID
  , customer.State_ID
  , customer.Region
  , ROUND(SUM(TotalProfit),2) AS "Profit"
FROM 
	sales_data.main
LEFT JOIN sales_data.customer
	ON main.StateID_=customer.State_ID
GROUP BY
	Region
  , main._SalesTeamID
  , customer.State_ID
ORDER BY
	SUM(TotalProfit) DESC
LIMIT 5;

-- the lowest five states of profit--
SELECT 
	customer.State
  , customer.State_ID
  , ROUND(SUM(TotalProfit),2) AS "Profit"
FROM 
	sales_data.main
LEFT JOIN sales_data.customer
	ON main.StateID_=customer.State_ID
WHERE
	State IS NOT NULL
GROUP BY
	customer.State
  , customer.State_ID
ORDER BY
	SUM(TotalProfit) ASC
LIMIT 5;


-- Profit for each Sales Team and their highest earning region --
SELECT *
FROM (SELECT 
	main._SalesTeamID
  , customer.State_ID
  , customer.Region
  , customer.State
-- summing the total profits together --
  , ROUND(SUM(main.TotalProfit),2) AS "Profit"
-- Partitioning each row for Region to see what is the sum profit for each region by giving RN, where RN can only happen once --
  , ROW_NUMBER() OVER(PARTITION BY customer.Region ORDER BY (SUM(main.TotalProfit)) desc) RN
FROM 
	sales_data.main
-- Joining the two tables together --
LEFT JOIN sales_data.customer
	ON main.StateID_=customer.State_ID
WHERE
	customer.Region IS NOT NULL
GROUP BY
	customer.Region
  , main._SalesTeamID
  , customer.State_ID
  , State
)T1 
-- limit each RN to only one, so it gets the  highest profit for each region
WHERE RN = 1;

-- 3. Which Sales DIstributor had the Most sales? Which has the highest order quantity? Which is the greatest customer segment for each? --
SELECT
	SalesChannel
  , COUNT(OrderNumber) AS "Total Order"
 -- , DATEDIFF(day, OrderDate, ShipDate) AS "DateDiff" --
FROM
	sales_data.main
GROUP BY 
	SalesChannel;

SELECT
	SalesChannel
  , COUNT(OrderNumber)  AS "Total Order Quantity"
FROM
	sales_data.main
GROUP BY 
	 SalesChannel;

-- What is the most used shipMode for each State --
SELECT 
	COUNT(ShipMode) AS "States Prefer"
  , ShipMode
FROM ( SELECT
	customer.ShipMode
  , customer.State
-- Parition by each state the sum of the mode that each customer used --
  , ROW_NUMBER() OVER(PARTITION BY customer.State ORDER BY (COUNT(customer.ShipMode)) desc) RN
FROM
	sales_data.customer
LEFT JOIN sales_data.main
-- connect the two tables on the ID of the state --
	ON main.StateID_ = customer.State_ID
WHERE
-- Want only values that can be calculated --
	State IS NOT NULL
GROUP BY
	customer.State
  , customer.ShipMode) T2
-- Want Number One Rank to be taken account --
WHERE RN = 1
-- Group each by the Ship mode
GROUP BY
	ShipMode
ORDER BY
	COUNT(ShipMode) DESC;

-- Number one Segment for each state
SELECT 
	COUNT(Segment)
  , Segment
FROM 
(SELECT
	customer.Segment
  , customer.State
-- Parition by each state the sum of the segment of the customer --
  , ROW_NUMBER() OVER(PARTITION BY customer.State ORDER BY (COUNT(customer.Segment)) desc) RN
FROM
	sales_data.customer
LEFT JOIN sales_data.main
-- connect the two tables on the ID of the state --
	ON main.StateID_ = customer.State_ID
WHERE
-- Want only values that can be calculated --
	State IS NOT NULL
GROUP BY
	  customer.State
  , customer.Segment) T3
-- Want Number One Rank to be taken account --
WHERE RN = 1
-- Group each by the Customer Segment
GROUP BY
	Segment
ORDER BY
	COUNT(Segment) DESC;
    

-- 4. Which Sub-category proudct was sold most? Which Sales team Sold this the most? --
SELECT
	  product.SubCategory
  , COUNT(product.SubCategory) AS "Total amount"
FROM
	sales_data.product
GROUP BY
	product.SubCategory
ORDER BY
	COUNT(product.SubCategory) DESC
    
    
-- What Sales team sold the most of each sub Category --

-- 5. How many orders were either very profitbale, somewhat, etc.? --
