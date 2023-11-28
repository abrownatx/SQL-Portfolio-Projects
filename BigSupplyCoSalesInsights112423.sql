USE PortfolioProjects;

SELECT *
FROM Orders
INNER JOIN Products ON Orders.Product_Card_Id = Products.Product_Card_Id

--1) Top Item Purchased by year, frequency, and Country
WITH YearlyData AS (
    SELECT
        Orders.Order_Country,
        YEAR(Orders.order_date_DateOrders) AS OrderYear,
        Products.Product_Name,
        COUNT(*) AS Frequency
    FROM
        Orders
    INNER JOIN
        Products ON Orders.Product_Card_Id = Products.Product_Card_Id
    GROUP BY
        Orders.Order_Country,
        YEAR(Orders.order_date_DateOrders),
        Products.Product_Name
)

SELECT
    MostCommonCountry.OrderYear,
    MostCommonCountry.Order_Country,
    MostCommonCountry.Frequency,
    MostCommonCountry.Product_Name
FROM (
    SELECT
        OrderYear,
        Order_Country,
        Product_Name,
        MAX(Frequency) AS Frequency
    FROM YearlyData
    GROUP BY
        OrderYear,
        Order_Country,
        Product_Name
) MostCommonCountry
JOIN (
    SELECT
        OrderYear AS MaxFreqYear,
        MAX(Frequency) AS MaxFrequency
    FROM YearlyData
    GROUP BY
        OrderYear
) MaxFreqByYear ON MostCommonCountry.OrderYear = MaxFreqByYear.MaxFreqYear
    AND MostCommonCountry.Frequency = MaxFreqByYear.MaxFrequency
ORDER BY
    MostCommonCountry.OrderYear ASC;

/* 
OrderYr OrderCountry	Freq.   Product_Name      
2015	Francia	        1003	Perfect Fitness Perfect Rip Deck
2016	United States	3578	Perfect Fitness Perfect Rip Deck
2017	M̩exico	        924	Nike Men's CJ Elite 2 TD Football Cleat
2018	Australia	144	Fighting video games

*/

--2) Top sales and profits by year, country, and product name.

WITH YearlyData AS (
    SELECT
        Orders.Order_Country,
        YEAR(Orders.order_date_DateOrders) AS OrderYear,
        MAX(CAST(Orders.order_date_DateOrders AS DATE)) AS order_date_DateOrders,
        MAX(Orders.Sales) AS MaxSales,
        Products.Product_Name
    FROM
        Orders
    INNER JOIN
        Products ON Orders.Product_Card_Id = Products.Product_Card_Id
    GROUP BY
        Orders.Order_Country,
        YEAR(Orders.order_date_DateOrders),
        Products.Product_Name
)

SELECT
    MainQuery.Order_Country,
    MainQuery.OrderYear,
    MainQuery.Product_Name,
    MainQuery.MaxSales AS HighestSales
FROM YearlyData AS MainQuery
JOIN (
    SELECT
        Order_Country,
        OrderYear,
        MAX(MaxSales) AS HighestSales
    FROM YearlyData
    GROUP BY
        Order_Country,
        OrderYear
) AS SubQuery ON MainQuery.Order_Country = SubQuery.Order_Country
    AND MainQuery.OrderYear = SubQuery.OrderYear
    AND MainQuery.MaxSales = SubQuery.HighestSales
ORDER BY
    MainQuery.OrderYear DESC, MainQuery.Order_Country, MainQuery.Product_Name;

--
--3) Highest sales by year only
WITH YearlyData AS (
    SELECT
        YEAR(order_date_DateOrders) AS OrderYear,
        MAX(Sales) AS MaxSales,
        MAX(Order_Profit) AS MaxOrderProfit
    FROM
        Orders
    GROUP BY
        YEAR(order_date_DateOrders)
)

SELECT
    OrderYear,
    MAX(MaxSales) AS HighestSales,
    MAX(MaxOrderProfit) AS HighestOrderProfit
FROM YearlyData
GROUP BY
    OrderYear
ORDER BY
    OrderYear DESC;

/*
Year	HighestSales        HighestOrderProfit
2018	532.580017089844	250.529998779297
2017	1999.98999023438	911.799987792969
2016	499.950012207031	249.979995727539
2015	499.950012207031	249.979995727539
*/

--4) Highest sales and profit by year, product name, highest sales, and highest profit by region

WITH YearlyData AS (
    SELECT
        Orders.Order_Region,
        YEAR(Orders.order_date_DateOrders) AS OrderYear,
        MAX(CAST(Orders.order_date_DateOrders AS DATE)) AS order_date_DateOrders,
        MAX(Orders.Sales) AS MaxSales,
        MAX(Orders.Order_Profit) AS MaxOrderProfit,
        Products.Product_Name
    FROM
        Orders
    INNER JOIN
        Products ON Orders.Product_Card_Id = Products.Product_Card_Id
    GROUP BY
        Orders.Order_Region,
        YEAR(Orders.order_date_DateOrders),
        Products.Product_Name
)

SELECT
    MainQuery.Order_Region,
    MainQuery.OrderYear,
    MainQuery.Product_Name,
    MainQuery.MaxSales AS HighestSales,
    MainQuery.MaxOrderProfit AS HighestOrderProfit
FROM YearlyData AS MainQuery
JOIN (
    SELECT
        Order_Region,
        OrderYear,
        MAX(MaxSales) AS HighestSales
    FROM YearlyData
    GROUP BY
        Order_Region,
        OrderYear
) AS SubQuery ON MainQuery.Order_Region = SubQuery.Order_Region
    AND MainQuery.OrderYear = SubQuery.OrderYear
    AND MainQuery.MaxSales = SubQuery.HighestSales
ORDER BY
    MainQuery.OrderYear DESC, MainQuery.Order_Region, MainQuery.Product_Name;

--5) Joining the 'Customers' table to the linked 'Orders' and 'Products' table
--and filter order region and segment by year and count.

SELECT *
FROM
    Orders
INNER JOIN Products ON Orders.Product_Card_Id = Products.Product_Card_Id
INNER JOIN Customers ON Orders.Order_Customer_Id = Orders.Order_Customer_Id


USE PortfolioProjects;

-- Rename the 'Customer Id' column in the 'Customers' table
EXEC sp_rename 'Customers.[Customer Id]', 'Order_Customer_Id', 'COLUMN';

SELECT
    YEAR(Orders.order_date_DateOrders) AS OrderYear,
    Orders.Order_Region,
    Customers.Customer_Segment,
    COUNT(*) AS SegmentCount
FROM
    Orders
INNER JOIN Products ON Orders.Product_Card_Id = Products.Product_Card_Id
INNER JOIN Customers ON Orders.Order_Customer_Id = Orders.Order_Customer_Id
GROUP BY
    YEAR(Orders.order_date_DateOrders),
    Orders.Order_Region,
    Customers.Customer_Segment
ORDER BY
    OrderYear DESC, Orders.Order_Region, SegmentCount DESC;

--6) What were the top product in the United States by Year?
SELECT
    YEAR(Orders.order_date_DateOrders) AS OrderYear,
    Products.Product_Name,
    COUNT(*) AS ProductCount
FROM
    Orders
INNER JOIN Products ON Orders.Product_Card_Id = Products.Product_Card_Id
INNER JOIN Customers ON Orders.Order_Customer_Id = Orders.Order_Customer_Id
WHERE
    Orders.Order_Country = 'Estados Unidos'
GROUP BY
    YEAR(Orders.order_date_DateOrders),
    Products.Product_Name
ORDER BY
    OrderYear DESC, ProductCount DESC;

-- The highest selling item in the United States was the Perfect Fitness Rip Deck.

--Products were only sold in the United states Market from 2016-2017. Top products and customer segments are listed as follows

SELECT
    YEAR(Orders.order_date_DateOrders) AS OrderYear,
    Products.Product_Name,
    COUNT(*) AS ProductCount, 
	Customers.Customer_Segment
FROM
    Orders
INNER JOIN Products ON Orders.Product_Card_Id = Products.Product_Card_Id
INNER JOIN Customers ON Orders.Order_Customer_Id = Orders.Order_Customer_Id
WHERE
    Orders.order_date_DateOrders BETWEEN '2016-01-01' AND '2018-12-31'
    AND Orders.Market like 'US%'
GROUP BY
    YEAR(Orders.order_date_DateOrders),
    Products.Product_Name,
	Customers.Customer_Segment
ORDER BY
    YEAR(Orders.order_date_DateOrders) DESC, ProductCount DESC, Customers.Customer_Segment DESC

--In the United States, the consumer segment accounts for the larget amount of goods sold, followed by the corporate and home Office segments respectively. 

--7) What is the least selling products in the US by year?
SELECT
    YEAR(Orders.order_date_DateOrders) AS OrderYear,
    Products.Product_Name,
    COUNT(*) AS ProductCount
FROM
    Orders
INNER JOIN Products ON Orders.Product_Card_Id = Products.Product_Card_Id
INNER JOIN Customers ON Orders.Order_Customer_Id = Orders.Order_Customer_Id
WHERE
    Orders.Order_Country = 'Estados Unidos'
GROUP BY
    YEAR(Orders.order_date_DateOrders),
    Products.Product_Name
ORDER BY
    OrderYear ASC, ProductCount ASC;

--The least selling product in the US is the Columbia Men's PFG Anchor Tought T-shirt

--8) Where are the top sales coming from in the US market?

SELECT
    YEAR(Orders.order_date_DateOrders) AS OrderYear,
    Products.Product_Name,
    COUNT(*) AS ProductCount, 
    Orders.Order_City,
	Orders.Order_State,
    Orders.Sales,
    Orders.Order_Profit,
    Customers.Customer_Segment
FROM
    Orders
INNER JOIN Products ON Orders.Product_Card_Id = Products.Product_Card_Id
INNER JOIN Customers ON Orders.Order_Customer_Id = Orders.Order_Customer_Id
WHERE
    Orders.order_date_DateOrders BETWEEN '2016-01-01' AND '2018-12-31'
    AND Orders.Market LIKE 'US%'
GROUP BY
    YEAR(Orders.order_date_DateOrders),
    Products.Product_Name,
    Orders.Order_City,
    Orders.Sales,
	Orders.Order_State,
    Orders.Order_Profit,
    Customers.Customer_Segment
ORDER BY
    OrderYear DESC, ProductCount DESC, Orders.Order_City, Orders.Order_state, Orders.Sales DESC, Orders.Order_Profit, Customers.Customer_Segment DESC;

--In 2017, the highest purchases in the US market originated from Brampton, Ontario.
--In 2016, the highest purchases in the US market originated from New York, USA

--9) Where in the US market did the sales originate from (supplier location)?

SELECT
    YEAR(Orders.order_date_DateOrders) AS OrderYear,
    Products.Product_Name,
    COUNT(*) AS ProductCount, 
    Customers.Customer_City,
    SUM(Orders.Sales) AS TotalSales,
    SUM(Orders.Order_Profit) AS TotalOrderProfit,
    Customers.Customer_Segment
FROM
    Orders
INNER JOIN Products ON Orders.Product_Card_Id = Products.Product_Card_Id
INNER JOIN Customers ON Orders.Order_Customer_Id = Orders.Order_Customer_Id
WHERE
    Orders.order_date_DateOrders BETWEEN '2016-01-01' AND '2018-12-31'
    AND Orders.Market LIKE 'US%'
GROUP BY
    YEAR(Orders.order_date_DateOrders),
    Products.Product_Name,
    Customers.Customer_City,
    Customers.Customer_Segment
ORDER BY
    OrderYear DESC, Products.Product_Name, ProductCount DESC, Customers.Customer_City, TotalSales DESC, TotalOrderProfit DESC, Customers.Customer_Segment DESC;

--Caguas, Puerto Rico is accounting for the largest swath of sales.

--10) 2016 US City purchases and product of interest

WITH ProductSummary AS (
    SELECT
        YEAR(Orders.order_date_DateOrders) AS OrderYear,
        Products.Product_Name,
        Orders.Order_City,
		Orders.Order_State,
        SUM(Orders.Sales) AS TotalSales,
        SUM(Orders.Order_Profit) AS TotalOrderProfit,
        Customers.Customer_Segment
    FROM
        Orders
    INNER JOIN Products ON Orders.Product_Card_Id = Products.Product_Card_Id
    INNER JOIN Customers ON Orders.Order_Customer_Id = Orders.Order_Customer_Id
    WHERE
        Orders.order_date_DateOrders BETWEEN '2016-01-01' AND '2018-12-31'
        AND Orders.Market LIKE 'USCA'
    GROUP BY
        YEAR(Orders.order_date_DateOrders),
        Products.Product_Name,
        Orders.Order_City,
		Orders.Order_State,
        Customers.Customer_Segment
)

SELECT TOP 1
    OrderYear,
    Product_Name,
    Order_City,
	Order_State,
    TotalSales,
    TotalOrderProfit,
    Customer_Segment
FROM ProductSummary
ORDER BY
    TotalOrderProfit DESC;

--In 2016 New York City, USA accounted for the highest amount of sales with $902,612,891 in sales and a total profit of $120,172,228.
--The Field & Stream Sportsman 16 Gun Fire Safe was the most purchased item.

--11) From 2016-2018 where did the highest sales and profits globally? 

WITH ProductSummary AS (
    SELECT
        YEAR(Orders.order_date_DateOrders) AS OrderYear,
        Products.Product_Name,
        Orders.Order_City,
		Orders.Order_State,
        SUM(Orders.Sales) AS TotalSales,
        SUM(Orders.Order_Profit) AS TotalOrderProfit,
        Customers.Customer_Segment
    FROM
        Orders
    INNER JOIN Products ON Orders.Product_Card_Id = Products.Product_Card_Id
    INNER JOIN Customers ON Orders.Order_Customer_Id = Orders.Order_Customer_Id
    WHERE
        Orders.order_date_DateOrders BETWEEN '2016-01-01' AND '2018-12-31'
            GROUP BY
        YEAR(Orders.order_date_DateOrders),
        Products.Product_Name,
        Orders.Order_City,
		Orders.Order_State,
        Customers.Customer_Segment
)

SELECT TOP 1
    OrderYear,
    Product_Name,
    Order_City,
	Order_State,
    TotalSales,
    TotalOrderProfit,
    Customer_Segment
FROM ProductSummary
ORDER BY
    TotalOrderProfit DESC;

--Globally, New York City also accounted for the highest sales, with the highest sales observed in 2016 with the Field & Stream Sportsman 16 Gun Fire Safe.
