create database E_Commerce_Company;

-- Business Context: 
-- Your work will directly impact the following business verticals:

-- 1.Customer Insights: Understanding our customer base to tailor marketing strategies.
-- 2.Product Analysis: Evaluating product performance to inform stock and sales strategies.
-- 3.Sales Optimization: Analyzing sales data to identify trends, opportunities, and areas for improvement.
-- 4.Inventory Management: Managing stock levels to ensure product availability while minimizing excess inventory.

use E_Commerce_Company;
describe customers;
describe orderdetails;
describe orders;
describe products;

-- Q1.Identify the top 3 cities with the highest number of 
-- customers to determine key markets for targeted marketing and logistic optimization.
select location, COUNT(*) as number_of_customers
from customers
group by 1
order by 2 DESC
limit 3; 

-- Q2.Determine how many customers fall into each order frequency category based on the number of orders they have placed.
-- Using the Orders table, calculate the number of customers who placed 1 order, 2 orders, 3 orders, etc.
-- Return a table showing:
-- The number of orders placed
-- The count of customers who placed that many orders
-- Sort the results by NumberOfOrders in ascending order.
with cte1 as (select customer_id , count(*) as NumberOfOrders
from orders
GROUP BY 1)
select NumberOfOrders , count(*) as CustomerCount
from cte1 
GROUP BY 1
ORDER BY 1 asc;

-- Q3.Identify products where the 
-- average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends. 
SELECT product_id, avg(quantity) as AvgQuantity , sum(quantity*price_per_unit) as TotalRevenue
from orderdetails
group by 1
HAVING AvgQuantity = 2 
ORDER BY 3 desc;

-- Q4.For each product category, calculate the unique number of customers
-- purchasing from it. This will help understand which categories have wider appeal across the customer base.
select a.category , count(DISTINCT customer_id) as unique_customers
from products a 
join orderdetails b 
on a.product_id = b.product_id
join orders c 
on b.order_id = c.order_id
GROUP BY 1
order by 2 DESC;

-- Q5.Analyze the month-on-month percentage change in total sales to identify growth trends.
with cte1 as 
(select date_format(str_to_date(order_date,"%Y-%m-%d"),"%Y-%m") as Month,
sum(total_amount) as TotalSales
from orders
GROUP BY 1),
cte2 as
(select Month,TotalSales, lag(TotalSales) over (order by month) as previous_month_sales
from cte1)
select Month, TotalSales , round(((TotalSales - previous_month_sales)/previous_month_sales*100),2)as PercentChange
from cte2;

-- Q6.Examine how the average order value changes month-on-month. 
-- Insights can guide pricing and promotional strategies to enhance order value.
with cte1 as (select date_format(str_to_date(order_date,"%Y-%m-%d"),"%Y-%m") as Month,
round(avg(total_amount),2) as AvgOrderValue 
from orders
group by 1),
cte2 as(
select Month,AvgOrderValue , 
lag(AvgOrderValue) over (order by Month) as previous_order_value
from cte1)
select Month,AvgOrderValue,round((AvgOrderValue - previous_order_value),2) as ChangeInValue
from cte2
order by 1 asc;

-- Q7.Based on sales data, identify products with the fastest turnover rates,
-- suggesting high demand and the need for frequent restocking.
SELECT product_id, count(order_id) as SalesFrequency
FROM orderdetails
GROUP BY 1
ORDER BY 2 desc
limit 5;

-- Q8.List products purchased by less than 40% of the customer base,
-- indicating potential mismatches between inventory and customer interest.
select a.product_id,a.name,COUNT(DISTINCT(c.customer_id)) as UniqueCustomerCount
from products a 
join orderdetails b 
on a.product_id = b.product_id
join orders c
on b.order_id = c.order_id
GROUP BY 1,2
having UniqueCustomerCount < (select count(*) from customers)*0.4;

-- Q9.Evaluate the month-on-month growth rate in the customer base to understand
-- the effectiveness of marketing campaigns and market expansion efforts.
with cte1 as 
(select *,date_format(str_to_date(order_date,"%Y-%m-%d"),"%Y-%m") as new_date
from orders),
cte2 as 
(select customer_id, min(new_date) as FirstPurchaseMonth
from cte1
GROUP BY 1)
select FirstPurchaseMonth , count(*) as TotalNewCustomers
from cte2
group by 1
order by 1 asc;

-- Q10.Identify the months with the highest sales volume, aiding in planning for stock levels,
-- marketing efforts, and staffing in anticipation of peak demand periods.
select date_format(str_to_date(order_date,"%Y-%m-%d"),"%Y-%m") as Month , 
sum(total_amount) as TotalSales
from orders
group by 1
ORDER BY 2 DESC
limit 3;

/*
Customer Insights :- 
  Top Cities :-
  Finding :- Delhi, Chennai, Jaipur contribute maximum number of 
             customers.
  Action :- Run city-specific campaigns in these three cities 
			and make sure fulfillment stock on them. 
  Order Frequency:-
  Finding :- Maximum number of customers placed 1,2 and 3 orders,
             rest of them placed 4 or more.
  Action :- Launch a post-purchase message and a second-order discount,
            and give some coupens for repeat buyers. 

Product Analysis :-
  Fastest-Selling Products:-
  Finding :- Product IDs 7, 3, 4, 2, and 8 appear in the most orders.
  Action :-  Make sure of sufficient stock on those products.
  Low-Reach Products :-
  Finding:-  2 products were bought by fewer than 40% of customers.
  Action :-  Reduce reorder quantities.

Sales Optimization :-
   Sales Trend and Peak Months :-
   Finding :- Sales grew peaked in July, September and December.
   Action :-  Start campaigns and stock build-up 4 to 6 weeks before
              that. 
   Average Order Value Change :- 
   Finding :-  There are some fluctuations on changing like,on 2023-04
               it will change 20450 , on 2023-05 is 6746 , on 2023-06 is
               16111 , and 2023-07 it will -5230 and so on. 
   Action :-   Introduce free-shipping and give some offers.

Inventory Management :- 
   Finding :-  Electronics products purchases more by customers 
               in compare to Wearable Tech and Photograpgy. 
   Action  :-  Raise stock for top products. 