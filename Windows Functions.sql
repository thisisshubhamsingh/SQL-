-- Windows Function

-- Window means - Set of rows

/*
	WINDOWS functions are permitted only in - SELECT AND ORDER BY clause
    forbidden in  - GROUP BY , HAVING , WHERE (Because they logically execute after the processing of those clauses,
    also they excecute after non-window functions.)
*/


# Advantages

/* 	
	-- Main adv. --> it doesn't group entire rows to single output row, rows retain their separate identities
	   and aggregated value will be added to each row.																																																												
	-- Calculate running totals , moving avg
	-- to give ranking 
    -- Enables users to perform calculations against partitions of a result set typically a table 
	   or the results from another query.
*/




CREATE DATABASE sales3;

DROP TABLE orders;
CREATE TABLE Orders
(
	order_id INT,
	order_date DATE,
	customer_name VARCHAR(250),
	city VARCHAR(100),	
	order_amount INT
);
 
INSERT INTO Orders
SELECT '1001','2017-04-01','David Smith','GuildFord',10000
UNION ALL	  
SELECT '1002','2017-04-02', 'David Jones','Arlington',20000
UNION ALL	  
SELECT '1003','2017-04-03','John Smith','Shalford',5000
UNION ALL	  
SELECT '1004','2017-04-04','Michael Smith','GuildFord',15000
UNION ALL	  
SELECT '1005','2017-04-05','David Williams','Shalford',7000
UNION ALL	  
SELECT '1006','2017-04-06','Paum Smith','GuildFord',25000
UNION ALL	 
SELECT '1007','2017-04-10','Andrew Smith','Arlington',15000
UNION ALL	  
SELECT '1008' ,'2017-04-11','David Brown','Arlington',2000
UNION ALL	  
SELECT '1009','2017-04-20','Robert Smith','Shalford',1000
UNION ALL	  
SELECT '1010','2017-04-25','Peter Smith','GuildFord',500;


SELECT * FROM orders;



-- Cumulative sales 


SELECT
	*,
    SUM(order_amount) OVER (PARTITION BY city ORDER BY order_amount DESC) AS cumulative_total_amount
FROM
	orders;
    


-- Total sales without affecting current rows means without loosing number of rows.

SELECT
	*,
    SUM(order_amount) OVER (PARTITION BY city ) AS total_amount
FROM
	orders;
    
    
    
-- The following query will give you average order amount for each city and for each month.



SELECT 
	*,
    AVG(order_amount) OVER (PARTITION BY city , MONTH(order_date)) AS avg_amount
FROM
	orders;
    


/*	MIN()

	The MIN() aggregate function will find the minimum value for a specified group or for the entire table if group is not specified.

	For example, we are looking for the smallest order (minimum order) for each city we would use the following query.
*/


SELECT 
	*,
    MIN(order_amount) OVER (PARTITION BY city) AS Min_order_amount
FROM
	orders;





/*
	MAX()

	Just as the MIN() functions gives you the minimum value, the MAX() function will identify the largest value of a specified field for a specified group of rows or for the entire table if a group is not specified.

	let’s find the biggest order (maximum order amount) for each city.
*/


SELECT 
	*,
    MAX(order_amount) OVER (PARTITION BY city) AS Min_order_amount
FROM
	orders;




/*
	COUNT()

	The COUNT() function will count the records / rows.

	Note that DISTINCT is not supported with window COUNT() function whereas it is supported for the regular COUNT() function. 
    DISTINCT helps you to find the distinct values of a specified field.

	For example, if we want to see how many customers have placed an order in April 2017, we cannot directly count all customers. 
    It is possible that the same customer has placed multiple orders in the same month.

	COUNT(customer_name) will give you an incorrect result as it will count duplicates. 
    Whereas COUNT(DISTINCT customer_name) will give you the correct result as it counts each unique customer only once.
*/




SELECT 
	*,
    COUNT(order_id) OVER (PARTITION BY city) AS Min_order_amount
FROM
	orders;
    
    
    
    
/*
RANK()

The RANK() function is used to give a unique rank to each record based on a specified value, for example salary, order amount etc.

If two records have the same value then the RANK() function will assign the same rank to both records by skipping the next rank. 
This means – if there are two identical values at rank 2, it will assign the same rank 2 to both records and then skip rank 3 and assign rank 4 to the next record.

Let’s rank each order by their order amount.
*/


SELECT 
	*,
    RANK() OVER (ORDER BY order_amount DESC) AS Rnk
FROM
	orders;
    
    
    
/*
	DENSE_RANK()

	The DENSE_RANK() function is identical to the RANK() function except that it does not skip any rank.
    This means that if two identical records are found then DENSE_RANK() will assign the same rank to both records but not skip then skip the next rank.
*/
    
    
SELECT 
	*,
    DENSE_RANK() OVER (ORDER BY order_amount DESC) AS Rnk
FROM
	orders;





/*
	The DENSE_RANK() function is identical to the RANK() function except that it does not skip any rank. 
	This means that if two identical records are found then DENSE_RANK() will assign the same rank to both records but not skip then skip the next rank.
*/


    
SELECT 
	*,
    DENSE_RANK() OVER (ORDER BY order_amount DESC) AS Rnk
FROM
	orders;
    
    
    
    
    
    
/*
	ROW_NUMBER()

	The name is self-explanatory. These functions assign a unique row number to each record.

	The row number will be reset for each partition if PARTITION BY is specified. Let’s see how ROW_NUMBER() works without PARTITION BY and then with PARTITION BY.
*/

-- ROW_ NUMBER() without PARTITION BY


SELECT 
	*,
    ROW_NUMBER() OVER (ORDER BY order_amount DESC) AS Rnk
FROM
	orders;


-- ROW_ NUMBER() with PARTITION BY

SELECT 
	*,
    ROW_NUMBER() OVER (PARTITION BY city ORDER BY order_amount DESC) AS Rnk
FROM
	orders;
    
    
    
    
/*
	NTILE()

NTILE() is a very helpful window function. It helps you to identify what percentile (or quartile, or any other subdivision) a given row falls into.

This means that if you have 100 rows and you want to create 4 quartiles based on a specified value field you can do so easily and see how many rows fall into each quartile.

Let’s see an example. In the query below, we have specified that we want to create four quartiles based on order amount. 
We then want to see how many orders fall into each quartile.
*/


SELECT 
	*,
    NTILE(4) OVER (ORDER BY order_amount) AS qaurtile
FROM
	orders;





-- Value Window functions

-- LAG()
-- LEAD()
-- FIRST_VALUE()              -- We can identify first and last record within a partittion or entire table if PARTITION BY is not specified.
-- LAST_VALUE()




SELECT 
    *,
    LAG(order_date, 1) OVER(ORDER BY order_date) AS Prev_order_date
FROM
    orders;


SELECT 
    *,
    LEAD(order_date, 1) OVER(ORDER BY order_date) AS Prev_order_date
FROM
    orders;




SELECT
	*,
    FIRST_VALUE(order_date) OVER(PARTITION BY city ORDER BY city) AS first_order_date,
    LAST_VALUE(order_date) OVER(PARTITION BY city ORDER BY city) AS last_order_date
FROM
	orders;
    
    
    
SELECT * FROM orders;
  
-- City wise cumulative sales   
  
SELECT
	*,
    SUM(order_amount) OVER (PARTITION BY city ORDER BY order_amount) AS Cumulative_order_amount
FROM 
	orders;
    
    
    
-- Total number of orders placed by city 
    
SELECT
	*,
    COUNT(order_id) OVER (PARTITION BY city ORDER BY city ) AS total_num_of_order
FROM 
	orders;
    
    
    
SELECT * FROM orders;



-- MIN order amount palced by each city 

SELECT 
	*,
    MIN(order_amount) OVER(PARTITION BY city) AS Min_order_amount
FROM
	orders;
    
-- MAX order amount palced by each city
  
SELECT 
	*,
    MAX(order_amount) OVER(PARTITION BY city) AS Min_order_amount
FROM
	orders;
    
 
 
 
-- We can calculate total amount without affecting current rows of dataset.
    
SELECT 
	*,
    SUM(order_amount) OVER(PARTITION BY city) AS Total_order_amount
FROM
	orders
    
    

