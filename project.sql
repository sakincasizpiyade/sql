------The number of distinct customer id is 1736SELECT COUNT(DISTINCT Customer_id)FROM (SELECT CONVERT(INT , SUBSTRING(Cust_ID, 6, LEN('Cust_ID')-1)) AS Customer_idFROM dbo.e_commerce_data) subq;------The number of distinct customer name is 795SELECT COUNT(DISTINCT Customer_Name)FROM dbo.e_commerce_data;SELECT Customer_Name, COUNT(Cust_ID) AS total_num_custid_percustomerFROM dbo.e_commerce_dataGROUP BY Customer_NameORDER BY total_num_custid_percustomer DESC;SELECT *FROM dbo.e_commerce_data----1) Find the top 3 customers who have the maximum count of orders.---All customers with count of ordersSELECT Customer_Name, SUM(Order_Quantity) AS cnt_of_ordFROM dbo.e_commerce_dataGROUP BY Customer_NameORDER BY cnt_of_ord DESC;----top 3 customers who have the maximum count of orders.SELECT TOP 3 Customer_Name, SUM(Order_Quantity) AS cnt_of_ordFROM dbo.e_commerce_dataGROUP BY Customer_NameORDER BY cnt_of_ord DESC;----2) Find the customer whose order took the maximum time to get shipping.---Customer name with  maximum timeSELECT TOP 1 Customer_Name, MAX(DaysTakenForShipping) AS max_days_shipFROM dbo.e_commerce_dataGROUP BY Customer_NameORDER BY max_days_ship DESC;---Only Customer name  whose order took the maximum time to get shipping.SELECT Customer_NameFROM (SELECT TOP 1 Customer_Name, MAX(DaysTakenForShipping) AS max_days_shipFROM dbo.e_commerce_dataGROUP BY Customer_NameORDER BY max_days_ship DESC) subq;------3)Count the total number of unique customers in January and how many of them 
---------came back every month over the entire year in 2011---a) Count the total number of unique customers in January----For distinct customer name (327 dist)SELECT COUNT(DISTINCT Customer_Name) AS total_num_dist_custFROM dbo.e_commerce_dataWHERE DATEPART(M,Order_Date)= 01;-----Some customers may have different person in spite of the same name and surname so use Cust_id (382 Dist)SELECT COUNT(DISTINCT Cust_ID) AS total_num_dist_custFROM dbo.e_commerce_dataWHERE DATEPART(M,Order_Date)= 01;----b)Find the customers came back every month over the entire year in 2011-----This gives in 2011 which customer came back how many different monthSELECT Customer_Name, COUNT(DISTINCT MONTH(Order_Date)) AS num_different_monthFROM dbo.e_commerce_dataWHERE YEAR(Order_Date) = 2011GROUP BY Customer_NameORDER BY num_different_month DESC;---this gives the customers came back every month over the entire year in 2011 which is EMPTY SET!!!SELECT Customer_Name, COUNT(DISTINCT MONTH(Order_Date)) AS num_different_monthFROM dbo.e_commerce_dataWHERE YEAR(Order_Date) = 2011GROUP BY Customer_NameHAVING COUNT(DISTINCT MONTH(Order_Date)) = 12ORDER BY num_different_month DESC;------If the question was that count the total number of unique customers in January and how many of them 
---------came back ARBITRARY (not every) month over the entire year in 2011---this gives customer namesSELECT DISTINCT Customer_Name FROM dbo.e_commerce_dataWHERE DATEPART(M,Order_Date)= 01AND Customer_Name IN(SELECT Customer_NameFROM dbo.e_commerce_dataWHERE YEAR(Order_Date) = 2011);----this gives total number of unique customers in January and how many of them 
---------came back ARBITRARY (not every) month over the entire year in 2011SELECT COUNT(DISTINCT Customer_Name) AS total_num_january_2011 FROM dbo.e_commerce_dataWHERE DATEPART(M,Order_Date)= 01AND Customer_Name IN(SELECT Customer_NameFROM dbo.e_commerce_dataWHERE YEAR(Order_Date) = 2011);------4) Write a query to return for each user the time elapsed between the first 
-------purchasing and the third purchasing, in ascending order by Customer ID.SELECT Cust_ID, Customer_Name, Order_Date, third_purchasing, DATEDIFF(DAY, third_purchasing, Order_Date ) day_diff_elapsedFROM(SELECT  Customer_Name, Order_Date, Cust_ID, ROW_NUMBER() OVER(PARTITION BY Customer_Name ORDER BY Order_Date) first_purchasing, LAG(Order_Date,2) OVER(PARTITION BY Customer_Name ORDER BY Order_Date) AS third_purchasingFROM dbo.e_commerce_data) subqWHERE first_purchasing=3ORDER BY Cust_ID ASC------5) Write a query that returns customers who purchased both product 11 and 
---------product 14, as well as the ratio of these products to the total number of 
-------------products purchased by the customer


-------First find the customers who purchased both product 11 and product 14

SELECT Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_11'


INTERSECT

SELECT Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_14';


------Second, find the total number of orders of the customers who purchased both product 11 and product 14

SELECT Customer_Name, COUNT(Ord_ID) AS total_num_ord
FROM dbo.e_commerce_data
WHERE Customer_Name IN (SELECT Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_11'


INTERSECT

SELECT Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_14')
GROUP BY Customer_Name;


-----Third, the number of orders of Prod_11 and Prod_14 

SELECT Customer_Name, COUNT(Ord_ID) AS prod11_14_num_ord
FROM dbo.e_commerce_data
WHERE Customer_Name IN (SELECT Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_11'


INTERSECT

SELECT Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_14') 

AND ((Prod_ID = 'Prod_11') OR (Prod_ID = 'Prod_14'))
GROUP BY Customer_Name;



----FINALLY, compute rate by using CTE expression, consider two tables and so on..

WITH t1 AS
(SELECT Customer_Name, COUNT(Ord_ID) AS total_num_ord
FROM dbo.e_commerce_data
WHERE Customer_Name IN (SELECT Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_11'


INTERSECT

SELECT Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_14')
GROUP BY Customer_Name
), 

t2 AS (SELECT Customer_Name, COUNT(Ord_ID) AS prod11_14_num_ord
FROM dbo.e_commerce_data
WHERE Customer_Name IN (SELECT Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_11'


INTERSECT

SELECT Customer_Name
FROM dbo.e_commerce_data
WHERE Prod_ID = 'Prod_14') 

AND ((Prod_ID = 'Prod_11') OR (Prod_ID = 'Prod_14'))
GROUP BY Customer_Name
)
SELECT t1.Customer_Name, prod11_14_num_ord, total_num_ord, CAST(100.0*prod11_14_num_ord/total_num_ord AS decimal(10,2)) AS rate_percent
FROM t1, t2;


--------SECOND PART (CUSTOMER SEGMENTATION)


------1.)  Create a “view” that keeps visit logs of customers on a monthly basis. (For 
----------each log, three field is kept: Cust_id, Year, Month)




CREATE VIEW vw_cust_id
AS
   SELECT Cust_ID, YEAR(Order_Date) AS Year, MONTH(Order_Date) AS Month, COUNT(Ord_ID) AS num_monthly_visit
   FROM dbo.e_commerce_data
   GROUP BY Cust_ID, MONTH(Order_Date), YEAR(Order_Date)
  

GO

SELECT * FROM [dbo].[vw_cust_id]
ORDER BY 1,2,3;
GO










----2.) Create a “view” that keeps the number of monthly visits by users. (Show 
------separately all months from the beginning business)

CREATE VIEW vw_customer_name
AS
   SELECT Customer_Name, YEAR(Order_Date) AS Year, MONTH(Order_Date) AS Month, COUNT(Ord_ID) AS num_monthly_visit
   FROM dbo.e_commerce_data
   GROUP BY Customer_Name, MONTH(Order_Date), YEAR(Order_Date);
   
   
   
  GO

SELECT * FROM [dbo].[vw_customer_name]
ORDER BY 1,2,3;
GO



-----3.) For each visit of customers, create the next month of the visit as a separate column

SELECT Customer_Name, Order_Date,
	LEAD(Order_Date) OVER(PARTITION BY Customer_Name ORDER BY Order_Date) next_order_date
FROM dbo.e_commerce_data



------4.) Calculate the monthly time gap between two consecutive visits by each customer.
SELECT Customer_Name, Order_Date,
	LEAD(Order_Date) OVER(PARTITION BY Customer_Name ORDER BY Order_Date) next_order_date, DATEDIFF(Month, Order_Date, next_order_date) AS gap_month
FROM (SELECT Customer_Name, Order_Date,
	LEAD(Order_Date) OVER(PARTITION BY Customer_Name ORDER BY Order_Date) next_order_date
FROM dbo.e_commerce_data) subq;


----5.) Categorise customers using average time gaps. Choose the most fitted labeling model for you.

SELECT Customer_Name, AVG(gap_month) AS avg_gap_month, CASE WHEN AVG(gap_month) < 5 THEN 'Regular' 
					      
					     ELSE 'Churned' END "Discount Effect"

FROM(SELECT Customer_Name, Order_Date,
	LEAD(Order_Date) OVER(PARTITION BY Customer_Name ORDER BY Order_Date) next_order_date, DATEDIFF(Month, Order_Date, next_order_date) AS gap_month
FROM (SELECT Customer_Name, Order_Date,
	LEAD(Order_Date) OVER(PARTITION BY Customer_Name ORDER BY Order_Date) next_order_date
FROM dbo.e_commerce_data) subq1) subq2
GROUP BY Customer_Name


