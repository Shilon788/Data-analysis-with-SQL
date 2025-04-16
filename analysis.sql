//Explore all objects 
SELECT * from INFORMATION_SCHEMA.tables

//Explore all collums
SELECT * from INFORMATION_SCHEMA.columns

//Explore all category
SELECT DISTINCT category, subcategory,product_name from PRODUCT
order by 1,2,3


//Find Youngest and Oldest Customer
select min(AGE) AS Youngest_Customer from customer ;
select max(AGE) AS Youngest_Customer from customer ;

//total customer
select count(Customer_key) as Total_Customers from customer

// Avg cost in each category
select 
category,
avg(cost) as avg_cost,
from product
group by category
ORDER by count(product_id) DESC

// total revenue for each category
select 
p.category,
sum(sales_amount) as Total_revenue 
from sales f
left join product p
on p.product_key=f.product_key
group by p.category
Order by Total_revenue DESC

//total revenue by each customer

select 
c.customer_key,
c.customer_name,
SUM(sales_amount) as Total_revenue 
from sales f
left join customer c
on f.customer_key=c.customer_key
group by
c.customer_key
c.customer_name
Order by Total_revenue DESC

// Top 5 best products 
select 
p.product_name,
sum(sales_amount) as Total_revenue 
from sales f
left join product p
on p.product_key=f.product_key
group by p.product_name
Order by Total_revenue DESC

// Top 5 worst products
select
p.product_name,
sum(sales_amount) as Total_revenue 
from sales f
left join product p
on p.product_key=f.product_key
group by p.product_name
Order by Total_revenue
