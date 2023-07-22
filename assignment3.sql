---Generate a report including product IDs and discount effects on whether the increase in the discount rate positively 
---impacts the number of orders for the products.

SELECT *
FROM sale.order_item
ORDER BY product_id, order_id;


SELECT product_id, discount, COUNT( DISTINCT order_id) num_of_orders
FROM sale.order_item
GROUP BY product_id, discount
ORDER BY product_id, discount;

SELECT product_id, discount, COUNT( order_id) num_of_orders
FROM sale.order_item
GROUP BY product_id, discount
ORDER BY product_id, discount;

-------I HAVE TWO DIFFERENT APPROACH




---FIRST APPROACH: GROUP BY product_id, discount, calculate difference between current cnt_ord and next cnt_ord so set a new column cnt_order_diff





SELECT
	product_id,discount, cnt_ord,
	cnt_ord-LEAD(cnt_ord) OVER(PARTITION BY product_id ORDER BY product_id)  cnt_order_diff
FROM(

SELECT
		DISTINCT
		product_id,discount
		
		,COUNT(order_id) OVER(PARTITION BY product_id, discount) cnt_ord
	FROM
		sale.order_item
     ) subq;


---- Fill NULL to 0 in cnt_order_diff column.

SELECT
	product_id,discount, cnt_ord,
	COALESCE(cnt_ord-LEAD(cnt_ord) OVER(PARTITION BY product_id ORDER BY product_id), 0)  cnt_order_diff
FROM(

SELECT
		DISTINCT
		product_id,discount
		
		,COUNT(order_id) OVER(PARTITION BY product_id, discount) cnt_ord
	FROM
		sale.order_item
     ) subq1;


----- SUM the values of cnt_order_diff according to group by product_id so get a new column named is total_change_per_product

SELECT product_id, SUM(cnt_order_diff) AS total_change_per_product
FROM 
(
SELECT
	product_id,discount, cnt_ord,
	COALESCE(cnt_ord-LEAD(cnt_ord) OVER(PARTITION BY product_id ORDER BY product_id), 0)  cnt_order_diff
FROM(

SELECT
		DISTINCT
		product_id,discount
		
		,COUNT(order_id) OVER(PARTITION BY product_id, discount) cnt_ord
	FROM
		sale.order_item
     ) subq1
	 ) subq2
GROUP BY product_id


----FINAL STEP1: SET a column name Discount Effect which is Positive if total_change_per_product < 0
                       ----------------------------which is Negative if total_change_per_product > 0
					   ----------------------------which is Neutral if total_change_per_product = 0
					   -----------------------------Because, we took current - next value (discount rate increase) if it is negative then  discount effect must be positive.


SELECT  product_id, SUM(cnt_order_diff) AS total_change_per_product, 
                    CASE WHEN SUM(cnt_order_diff) < 0 THEN 'Positive' 
					     WHEN SUM(cnt_order_diff) > 0 THEN 'Negative' 
					     ELSE 'Neutral' END "Discount Effect"
FROM 
(
SELECT
	product_id,discount, cnt_ord,
	COALESCE(cnt_ord-LEAD(cnt_ord) OVER(PARTITION BY product_id ORDER BY product_id), 0)  cnt_order_diff
FROM(

SELECT
		DISTINCT
		product_id,discount
		
		,COUNT(order_id) OVER(PARTITION BY product_id, discount) cnt_ord
	FROM
		sale.order_item
     ) subq1
	 ) subq2
GROUP BY product_id

----FINAL STEP 2: Remove unwanted column and set the result table


SELECT  product_id, ---SUM(cnt_order_diff) AS total_change_per_product, 
                    CASE WHEN SUM(cnt_order_diff) > 0 THEN 'Positive' 
					     WHEN SUM(cnt_order_diff) < 0 THEN 'Negative' 
					     ELSE 'Neutral' END "Discount Effect"
FROM 
(
SELECT
	product_id,discount, cnt_ord,
	COALESCE(cnt_ord-LEAD(cnt_ord) OVER(PARTITION BY product_id ORDER BY product_id), 0)  cnt_order_diff
FROM(

SELECT
		DISTINCT
		product_id,discount
		
		,COUNT(order_id) OVER(PARTITION BY product_id, discount) cnt_ord
	FROM
		sale.order_item
     ) subq1
	 ) subq2
GROUP BY product_id








---SECOND APPROACH: The change of quantity may be considered, because quantity of product may differ according to different order and we will determine the discount effect
---- in terms of the change of the number of quantities in orders according to group by product_id samely in the previous approach. 

SELECT
	product_id,discount, cnt_quantity,
	cnt_quantity-LEAD(cnt_quantity) OVER(PARTITION BY product_id ORDER BY product_id)  cnt_quantity_diff
FROM(

SELECT
		DISTINCT
		product_id,discount
		
		,SUM(quantity) OVER(PARTITION BY product_id, discount) cnt_quantity
	FROM
		sale.order_item
     ) subq;


---- Fill NULL to 0 in cnt_quantity_diff column.

SELECT
	product_id,discount, cnt_quantity,
	COALESCE(cnt_quantity-LEAD(cnt_quantity) OVER(PARTITION BY product_id ORDER BY product_id), 0)  cnt_quantity_diff
FROM(

SELECT
		DISTINCT
		product_id,discount
		
		,SUM(quantity) OVER(PARTITION BY product_id, discount) cnt_quantity
	FROM
		sale.order_item
     ) subq1;


----- SUM the values of cnt_order_diff according to group by product_id so get a new column named is total_change_per_product

SELECT product_id, SUM(cnt_quantity_diff) AS total_change_per_product_quantity
FROM 
(
SELECT
	product_id,discount, cnt_quantity,
	COALESCE(cnt_quantity-LEAD(cnt_quantity) OVER(PARTITION BY product_id ORDER BY product_id), 0)  cnt_quantity_diff
FROM(

SELECT
		DISTINCT
		product_id,discount
		
		,SUM(quantity) OVER(PARTITION BY product_id, discount) cnt_quantity
	FROM
		sale.order_item
     ) subq1
	 ) subq2
GROUP BY product_id


----FINAL STEP1: SET a column name Discount Effect which is Positive if total_change_per_product_quantity < 0
                       ----------------------------which is Negative if total_change_per_product_quantity > 0
					   ----------------------------which is Neutral if total_change_per_product_quantity = 0
					   -----------------------------Because, we took current - next value (discount rate increase) if it is negative then  discount effect must be positive.


SELECT  product_id, SUM(cnt_quantity_diff) AS total_change_per_product_quantity, 
                    CASE WHEN SUM(cnt_quantity_diff) < 0 THEN 'Positive' 
					     WHEN SUM(cnt_quantity_diff) > 0 THEN 'Negative' 
					     ELSE 'Neutral' END "Discount Effect"
FROM 
(
SELECT
	product_id,discount, cnt_quantity,
	COALESCE(cnt_quantity-LEAD(cnt_quantity) OVER(PARTITION BY product_id ORDER BY product_id), 0)  cnt_quantity_diff
FROM(

SELECT
		DISTINCT
		product_id,discount
		
		,SUM(quantity) OVER(PARTITION BY product_id, discount) cnt_quantity
	FROM
		sale.order_item
     ) subq1
	 ) subq2
GROUP BY product_id

----FINAL STEP 2: Remove unwanted column and set the result table

SELECT  product_id, --SUM(cnt_quantity_diff) AS total_change_per_product_quantity, 
                    CASE WHEN SUM(cnt_quantity_diff) < 0 THEN 'Positive' 
					     WHEN SUM(cnt_quantity_diff) > 0 THEN 'Negative' 
					     ELSE 'Neutral' END "Discount Effect"
FROM 
(
SELECT
	product_id,discount, cnt_quantity,
	COALESCE(cnt_quantity-LEAD(cnt_quantity) OVER(PARTITION BY product_id ORDER BY product_id), 0)  cnt_quantity_diff
FROM(

SELECT
		DISTINCT
		product_id,discount
		
		,SUM(quantity) OVER(PARTITION BY product_id, discount) cnt_quantity
	FROM
		sale.order_item
     ) subq1
	 ) subq2
GROUP BY product_id;
