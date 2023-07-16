
--1. Product Sales

SELECT TOP 3 c.customer_id, c.first_name, c.last_name, 'No' AS Other_Product
FROM sale.customer c 
 INNER JOIN  sale.orders o ON c.customer_id=o.customer_id
 INNER JOIN  sale.order_item s ON o.order_id = s.order_id
 INNER JOIN product.product p ON s.product_id=p.product_id
 WHERE p.product_name= '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
                      AND  c.customer_id NOT IN 
					       (
						     SELECT c.customer_id
                             FROM sale.customer c 
                             INNER JOIN  sale.orders o ON c.customer_id=o.customer_id
                              INNER JOIN  sale.order_item s ON o.order_id = s.order_id
                               INNER JOIN product.product p ON s.product_id=p.product_id
                                 WHERE p.product_name= 'Polk Audio - 50 W Woofer - Black' 
								 )
 ORDER BY customer_id ASC;


 --2. Conversion Rate

 CREATE TABLE Actions (
	Visitor_ID int,
	Adv_Type varchar(255),
	Action varchar(255)
	)

--'Left', 'Order','Left', 'Order','Review','Left','Left','Order','Review','Review'	

INSERT INTO Actions (Visitor_ID, Adv_Type, Action)
VALUES (1, 'A', 'Left'),(2,'A','Order'),
        (3,'B','Left'),(4,'A','Order'),
		(5,'A','Review'),(6,'A', 'Left'),
		(7,'B', 'Left'), (8,'B','Order'),
		(9,'B','Review'),(10,'A','Review');


--DELETE FROM Actions
SELECT *
FROM Actions

SELECT Adv_Type, COUNT(Visitor_ID)
FROM Actions
GROUP BY Adv_Type;

SELECT Adv_Type, Action,  COUNT(Visitor_ID)
FROM Actions
GROUP BY Adv_Type, Action;

SELECT Adv_Type, COUNT(Visitor_ID)
FROM Actions
WHERE Action='Order'
GROUP BY Adv_Type;

-- Answer Part
SELECT a1.Adv_Type, CAST(a1.Order_Count *1.0/ a2.Total_Count AS decimal(10,2)) AS Conversion_Rate
FROM
(
    SELECT Adv_Type, COUNT(Visitor_ID) AS Order_Count
    FROM Actions
    WHERE Action = 'Order'
    GROUP BY Adv_Type
) a1
INNER JOIN
(
    SELECT Adv_Type, COUNT(Visitor_ID) AS Total_Count
    FROM Actions
    GROUP BY Adv_Type
) a2 ON a1.Adv_Type = a2.Adv_Type;
