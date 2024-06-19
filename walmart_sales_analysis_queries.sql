
create database if not exists walmart_sales_data;
use walmart_sales_data;

create table if not exists sales(
invoice_id varchar(30) not null primary key,
branch varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10,2) not null,
quantity int not null,
value_added_tax float(6,4) not null,
total decimal(12,4) not null,
date datetime not null,
time time not null,
payment_method varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_pct float(11,9),
gross_income decimal(12,4) not null,
rating float(2,1)
);

select * from walmart_sales_data.sales;





-- -----------------------------------------------------------------------------------------------
-- --------------------------- Feature Engineering -----------------------------------------------

--  time_of_day --
SELECT time,
		(CASE 
            WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
             WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
             ELSE "Evening" END
		 ) as time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
UPDATE sales
SET time_of_day = 
        (CASE 
            WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
             WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
             ELSE "Evening" END
		 );

-- day_name --
SELECT date,
	   DAYNAME(date)  as day_name FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales
SET day_name =  DAYNAME(date);

-- month_name --
SELECT date,
       MONTHNAME(date) as month_name FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
UPDATE sales
SET month_name = MONTHNAME(date);
-- ----------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------
-- --------------------------- Generic Questions ------------------------------------------------------

-- How many unique cities does the data have?
SELECT COUNT(DISTINCT city) FROM sales;

-- In which city is each branch?
SELECT DISTINCT city,branch FROM sales;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------- Product --------------------------------------------------------

-- How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line) FROM sales;

-- What is the most common payment method?
SELECT payment_method,COUNT(payment_method)  as payment_count FROM sales
GROUP BY payment_method
ORDER BY payment_count DESC;

-- What is the most selling product_line?
SELECT product_line,COUNT(product_line) as selling_count FROM sales
GROUP BY product_line
ORDER BY selling_count DESC;

-- What is the total revenue by month?
SELECT month_name as month, sum(total) as total_revenue
FROM sales GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT month_name as month, SUM(cogs) as cogs
FROM sales GROUP BY month_name
ORDER BY cogs DESC;

-- What product line had the largest revenue?
SELECT product_line,sum(total) as total_revenue FROM sales
GROUP BY product_line 
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT city,branch,sum(total) as total_revenue FROM sales
GROUP BY city,branch ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT product_line,sum(value_added_tax) as total_VAT , avg(value_added_tax) as avg_VAT FROM sales
GROUP BY product_line 
ORDER BY total_VAT desc;

-- Fetch each product line and add a column to those product line showing "Good","Bad".Good if its
 -- greater than avg sales.
 SELECT product_line, ROUND(avg(total),2) as avg_product_sales,
       (CASE  
            WHEN avg(total) > (SELECT avg(total) FROM sales) THEN "GOOD"
            ELSE "BAD" 
            END
	    ) as status
 FROM sales
 GROUP BY product_line
 ORDER BY avg_product_sales;
 
 
 -- Which branch sold more products that average product sold?
 SELECT branch, SUM(quantity) as qty
 FROM sales GROUP BY branch 
 HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);
 
 -- What is the most common product line by gender?
 SELECT gender ,product_line, count(product_line) as common_product_cnt FROM sales
 GROUP BY gender ORDER BY common_product_cnt DESC;
 
 -- What is the avg rating of each product line?
 SELECT product_line , ROUND(avg(rating),2) as avg_rating FROM sales
 GROUP BY product_line
 ORDER BY avg_rating DESC;
 
 -- --------------------------------------------------------------------------------------------------
 -- ------------------------------- Sales ------------------------------------------------------------
 
-- What are the Number of Sales made in each time of the day per weekday?.
SELECT time_of_day,
       COUNT(*) as total_sales
FROM sales
where day_name = 'Monday'
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT customer_type,sum(total) as total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/VAT?
SELECT city,AVG(value_added_tax) as avg_VAT
FROM sales
GROUP BY city
ORDER BY  avg_VAT DESC;

-- Which customer type pays the most in VAT?
SELECT customer_type,AVG(value_added_tax) as avg_VAT
FROM sales
GROUP BY customer_type
ORDER BY avg_VAT DESC;

-- ----------------------------------------------------------------------------------------------------
-- ---------------------------------- Customer --------------------------------------------------------

-- How many unique customer types does the data have?
SELECT DISTINCT customer_type FROM sales;

-- How many unique payment methods does the data have?
SELECT DISTINCT payment_method FROM sales;

-- What is the most common customer type?
SELECT customer_type, COUNT(customer_type) as customer_type_cnt
FROM sales GROUP BY customer_type
ORDER BY customer_type_cnt DESC;

 -- Which customer type buys the most?
 SELECT customer_type, COUNT(*) as customer_type_cnt
FROM sales GROUP BY customer_type
ORDER BY customer_type_cnt DESC;

-- What is the gender of the most of the customers?
SELECT gender, COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT branch,gender,COUNT(gender) as gender_count
From sales
GROUP BY branch,gender
ORDER BY gender_count DESC;

-- Which time of the day do customers give most ratings?
SELECT time_of_day,AVG(rating) as avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT time_of_day,AVG(rating) as avg_rating
FROM sales
WHERE branch = 'A'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day of the week has the best avg ratings?
SELECT day_name as week_day,AVG(rating) as avg_rating
FROM sales
GROUP BY week_day
ORDER BY avg_rating DESC;

-- Which day of the week has the best avg ratings per branch?
SELECT day_name as week_day,AVG(rating) as avg_rating
FROM sales
WHERE branch  = 'C'
GROUP BY week_day
ORDER BY avg_rating DESC;