------The number of distinct customer id is 1736
---------came back every month over the entire year in 2011
---------came back ARBITRARY (not every) month over the entire year in 2011
---------came back ARBITRARY (not every) month over the entire year in 2011
-------purchasing and the third purchasing, in ascending order by Customer ID.
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


------1.)  Create a �view� that keeps visit logs of customers on a monthly basis. (For 
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










----2.) Create a �view� that keeps the number of monthly visits by users. (Show 
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

