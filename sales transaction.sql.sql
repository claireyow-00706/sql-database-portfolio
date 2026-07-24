-- 1. Create a fresh sandbox database
CREATE DATABASE IF NOT EXISTS analytics_sandbox;
USE analytics_sandbox;

CREATE TABLE sales_transactions (
transaction_id INT PRIMARY KEY,
amount INT,
discount_code VARCHAR(40)
);

-- Remove the quotes around NULL to make them real NULL values
-- Ensure the table name matches the database schema
INSERT INTO sales_transactions VALUES (101, 500, 'SAVE10');
INSERT INTO sales_transactions VALUES (102, 0, NULL);
INSERT INTO sales_transactions VALUES (103, 150, NULL);
INSERT INTO sales_transactions VALUES (104, 0, 'WELCOME5');

-- building CTE, NULLIF(column, value), NULLIF on amount to turn 0 into NULL
WITH prep_transaction AS (
SELECT 
transaction_id,
NULLIF(amount,0) AS cleaned_amount, -- nullif: turns a certain value into Null
COALESCE(discount_code, 'NONE') AS cleaned_discount -- Coalesce: turns null into something else
FROM analytics_sandbox.sales_transactions
)
SELECT * 
FROM prep_transaction;


-- TRIM(column); removes invisible spaces at the start or end of text
-- UPPER(column): forces all letters to be uppercase 
-- LOWER(column): forces all letters to be lowercase

INSERT INTO sales_transactions VALUES (105,200,'save10');

WITH cleaned_transactions AS (
SELECT 
transaction_id,
NULLIF(amount,0) AS cleaned_amount, -- converts 0 into null 
UPPER(TRIM(discount_code)) AS cleaned_discount
FROM sales_transactions
)
SELECT 
cleaned_discount,
COUNT(*) as transaction_count
FROM cleaned_transactions 
GROUP BY cleaned_discount; 

WITH categorized_transactions AS (
    SELECT 
        transaction_id,
        amount,
        NULLIF(amount, 0) AS cleaned_amount,
        CASE 
            WHEN NULLIF(amount, 0) < 200 THEN 'Budget'
            WHEN NULLIF(amount, 0) >= 200 THEN 'Premium'
            ELSE 'Unknown'
        END AS value_tier 
    FROM analytics_sandbox.sales_transactions
)
SELECT 
    transaction_id,
    amount,
    value_tier,
    -- Calculate average per tier
    AVG(cleaned_amount) OVER(PARTITION BY value_tier) AS average_tier_amount,
    -- Rank transactions by amount within their tier
    RANK() OVER(PARTITION BY value_tier ORDER BY amount DESC) AS rank_in_tier
FROM categorized_transactions;

-- Cleaing: handling errors with NULLIF and COALESCE
-- Standardizing; normalizing text with TRIM and UPPER
-- COntextualising: using CASE WHEN for logic and WIndows function 

-- option one
SELECT 
NULLIF(amount,0) AS cleaned_amount, -- cleans data by removing 0 and filing it in with nul 
TRIM(discount_code), -- cleans text by removing any unnecessary spaces
CASE WHEN NULLIF(amount,0) < 200 THEN 'Budget' 
     WHEN NULLIF(amount,0) >= 200 THEN 'Premium'
     ELSE 'Normal'
END AS tier_amount,
RANK() OVER(PARTITION BY (CASE WHEN NULLIF(amount,0) < 200 THEN 'Budget' ELSE 'Premium' END) ORDER BY amount DESC) AS rank_in_tier
FROM analytics_sandbox.sales_transactions;

-- option 2 if option 1 was too confusing
WITH cleaned_data AS (
SELECT 
amount,
CASE WHEN NULLIF(amount,0) <  200 THEN 'Budget'
     ELSE 'Premium'
END AS tier_amount
FROM analytics_sandbox.sales_transactions
)
SELECT
amount,
tier_amount,
RANK() OVER(PARTITION BY tier_amount ORDER BY amount DESC) AS rank_in_tier
FROM cleaned_data;

WITH total_revenue AS (
    -- Calculate ONLY the single total value here
    SELECT SUM(amount) AS grand_total 
    FROM analytics_sandbox.sales_transactions
)
SELECT 
    t.transaction_id,
    t.amount,
    -- Running total
    SUM(t.amount) OVER(ORDER BY t.transaction_id DESC) AS running_total,
    -- Percentage calculation using the single value from the CTE
    (100.0 * t.amount / (SELECT grand_total FROM total_revenue)) AS percentage_of_total_revenue
FROM analytics_sandbox.sales_transactions t;


CREATE TABLE analytics_sandbox.discount_codes (
discount_code VARCHAR(20),
discount_value FLOAT -- float is for values with approximate decimal, good for metric data, and physical measurements
);

INSERT INTO analytics_sandbox.discount_codes VALUES ('SAVE10', 10.0);
INSERT INTO analytics_sandbox.discount_codes VALUES ('OFF20', 20.0);
INSERT INTO analytics_sandbox.discount_codes VALUES ('WELCOME5', 5.0);

SELECT * FROM analytics_sandbox.discount_codes;

SELECT 
    s.transaction_id,
    s.amount,
    s.discount_code, -- Added the missing comma here
    COALESCE(s.discount_code, 'No Discount') AS discount_label,
    (s.amount - COALESCE(d.discount_value, 0)) AS net_amount
FROM analytics_sandbox.sales_transactions AS s
LEFT JOIN analytics_sandbox.discount_codes AS d
    ON s.discount_code = d.discount_code;

CREATE TABLE analytics_sandbox.product_info (
product_id INT,
category VARCHAR(50)
);


INSERT INTO analytics_sandbox.product_info (product_id,category) VALUES 
(1,'Electronics'),
(2,'Clothing'),
(3,'Books'),
(4,'Snacks'),
(5,'Stationary');


CREATE TABLE analytics_sandbox.transaction_map (
transaction_id INT,
product_id INT 
);


-- create middleman table to establish a connection between transaction id and product id so that left join is applicable
INSERT INTO analytics_sandbox.transaction_map (transaction_id, product_id) VALUES
(101,1),
(102,2),
(103,3),
(104,4),
(105,50);

-- summary table of product group, transaction id and amount
SELECT 
s.transaction_id,
s.amount,
COALESCE(p.category,'General') AS product_group, 
CASE WHEN s.discount_code IS NOT NULL THEN 'YES'
     ELSE 'NO'
END AS discount_status     
FROM analytics_sandbox.sales_transactions AS s 
LEFT JOIN analytics_sandbox.transaction_map AS tm
ON s.transaction_id = tm.transaction_id
LEFT JOIN analytics_sandbox.product_info AS p
ON tm.product_id = p.product_id;






WITH enriched_sales AS (
    SELECT 
        s.transaction_id,
        s.amount,
        COALESCE(p.category, 'General') AS product_group,
      -- Calculate the net_amount 
       (s.amount - COALESCE(d.discount_value, 0)) AS net_amount
    FROM analytics_sandbox.sales_transactions AS s 
    LEFT JOIN analytics_sandbox.transaction_map AS tm ON s.transaction_id = tm.transaction_id
    LEFT JOIN analytics_sandbox.product_info AS p ON tm.product_id = p.product_id
    LEFT JOIN analytics_sandbox.discount_codes AS d ON s.discount_code = d.discount_code
)
-- Now we aggregate the clean data from the CTE
SELECT 
    product_group,
    SUM(net_amount) AS total_revenue,
    COUNT(transaction_id) AS total_transactions
FROM enriched_sales
GROUP BY product_group;

CREATE TABLE customer_particulars (
customer_name VARCHAR(50) PRIMARY KEY
);

INSERT INTO customer_particulars VALUES ('Cindy');
INSERT INTO customer_particulars VALUES ('Malcom');
INSERT INTO customer_particulars VALUES ('Lincoln');
INSERT INTO customer_particulars VALUES ('Luke');
INSERT INTO customer_particulars VALUES ('Dean');

CREATE TABLE analytics_sandbox.transaction_name_map (
transaction_id INT,
customer_name VARCHAR(50) 
);

-- create middleman table to establish a connection between transaction id and customer name so that left join is applicable
INSERT INTO analytics_sandbox.transaction_name_map (transaction_id, customer_name) VALUES
(101,'Cindy'),
(102,'Malcom'),
(103,'Lincoln'),
(104,'Luke'),
(105,'Dean');


-- creating inner query to shrink the parameters in which data is extracted (filtered out) 
WITH customer_sales AS ( -- naming the inner query for easy reference later on
SELECT 
s.transaction_id,
s.amount,
tnm.customer_name
FROM analytics_sandbox.sales_transactions AS s
LEFT JOIN analytics_sandbox.transaction_name_map AS tnm -- matching the transaction id from sale table to transaction_name_map so that it matches
ON s.transaction_id = tnm.transaction_id
LEFT JOIN customer_particulars AS c -- linking the customer name from customer table to the transaction_name_map table so that both match
ON tnm.customer_name = c.customer_name
)
SELECT  -- selecting from the customer_sales table made above (extraction of data from a smaller scale)
customer_name,
SUM(amount) AS total_spent,
COUNT(transaction_id) AS transaction_count
FROM customer_sales 
GROUP BY customer_name;




WITH customer_sales AS ( -- naming the inner query for easy reference later on
SELECT 
s.transaction_id,
s.amount,
tnm.customer_name
FROM analytics_sandbox.sales_transactions AS s
LEFT JOIN analytics_sandbox.transaction_name_map AS tnm -- matching the transaction id from sale table to transaction_name_map so that it matches
ON s.transaction_id = tnm.transaction_id
LEFT JOIN customer_particulars AS c -- linking the customer name from customer table to the transaction_name_map table so that both match
ON tnm.customer_name = c.customer_name
)
SELECT 
   customer_name,
   SUM(amount) AS total_spent,
   COUNT(transaction_id) AS transaction_count
FROM customer_sales
GROUP BY customer_name --  1) group the total spend according to customer name 
HAVING SUM(amount) > 100; --  2) from the total spent by each customer, filter out only those who spend more than 100


WITH customer_sales AS ( -- naming the inner query for easy reference later on
SELECT 
s.transaction_id,
s.amount,
tnm.customer_name
FROM analytics_sandbox.sales_transactions AS s
LEFT JOIN analytics_sandbox.transaction_name_map AS tnm -- matching the transaction id from sale table to transaction_name_map so that it matches
ON s.transaction_id = tnm.transaction_id
LEFT JOIN customer_particulars AS c -- linking the customer name from customer table to the transaction_name_map table so that both match
ON tnm.customer_name = c.customer_name
)
SELECT 
customer_name,
SUM(amount) AS total_spent,
CASE WHEN SUM(amount) > 100 THEN 'VIP'
     ELSE 'Standard'
END AS segment
FROM customer_sales
GROUP BY customer_name;




WITH customer_sales AS ( -- naming the inner query for easy reference later on
SELECT 
s.transaction_id,
s.amount,
tnm.customer_name
FROM analytics_sandbox.sales_transactions AS s
LEFT JOIN analytics_sandbox.transaction_name_map AS tnm -- matching the transaction id from sale table to transaction_name_map so that it matches
ON s.transaction_id = tnm.transaction_id
LEFT JOIN customer_particulars AS c -- linking the customer name from customer table to the transaction_name_map table so that both match
ON tnm.customer_name = c.customer_name
)
SELECT 
customer_name,
ROUND(SUM(amount),2) AS total_spent, -- rounds the sum of the amount to 2dp
COUNT(transaction_id) AS transaction_count, 
CASE WHEN SUM(amount) > 100 THEN 'VIP'
     ELSE 'Standard'
END AS segment
FROM customer_sales
GROUP BY customer_name 
ORDER BY total_spent DESC;
     

SELECT
s.transaction_id,
s.amount
FROM analytics_sandbox.sales_transactions AS s 
LEFT JOIN analytics_sandbox.product_info AS p
ON p.product_id = s.transaction_id
WHERE p.product_id IS NULL -- filters out NUll data

-- time series analysis; transforming a "sale_date" column to "month" or "year" to group data correctly

ALTER TABLE analytics_sandbox.sales_transactions -- this is needed because the original table didnt have a sales_date column
ADD COLUMN sales_date DATE;
UPDATE analytics_sandbox.sales_transactions
SET sales_date = CASE transaction_id
    WHEN 101 THEN '2026-01-15'
    WHEN 102 THEN '2026-02-15'
    WHEN 103 THEN '2026-03-15'
    WHEN 104 THEN '2026-04-15'
END 
WHERE transaction_id IN (101,102,103,104); -- tells database engine to only look at these 4 specific rows and nothing else


SELECT 
EXTRACT(MONTH FROM sales_date) AS sale_month, -- looks at the sales_date column and pulls out only the month and label that column a sale_month
SUM(amount) AS monthly_revenue
FROM sales_transactions
WHERE EXTRACT(YEAR FROM sales_date) = 2026 -- only sees data from 2026
GROUP BY 1 -- '1' refers to the first line of code positioned under SELECT, it is a shorthand for GROUP BY sales_month 
ORDER BY 1; -- shorthand for order by sales month, '1' refers to the first line of code under SELECT ie sales_month

SELECT 
EXTRACT(MONTH FROM sales_date) AS sale_month,
SUM(amount) AS monthly_revenue
FROM sales_transactions
WHERE EXTRACT(YEAR FROM sales_date) = 2026
GROUP BY 1 -- group by sales_month ie group each data entry in the same month together, if there were 50 entries then all of that will be grouped into one
HAVING SUM(amount) > 200 -- filters out months with low revenue
ORDER BY 1; -- order by sales month ie 1,2,3...


CREATE TABLE customer_orders (
customer_id INT PRIMARY KEY,
number_of_orders INT,
amount_spent float
);

INSERT INTO customer_orders (customer_id, number_of_orders, amount_spent) VALUES
(1,3,12.33),
(2,5,13.45),
(3,7,14.31),
(4,9,16.53);


WITH customer_stats AS (
    -- 1. First, aggregate the data to get the counts and totals per customer
    SELECT 
        customer_id,
        COUNT(*) AS total_orders,
        SUM(amount_spent) AS total_revenue
    FROM customer_orders
    GROUP BY customer_id
    ORDER BY total_orders DESC
)
-- 2. Then, classify and filter the results
SELECT 
    customer_id,
    total_revenue,
    CASE 
        WHEN total_orders > 5 THEN 'VIP'
        ELSE 'Normal'
    END AS customer_class
FROM customer_stats;


-- core SQL aggregation functions
-- SUM() adds up numerical column 
-- COUNT() counts how many rows exits 
-- AVG() calculate average value 
-- MIN() or MAX() finds the smallest or largest value 












