// Change over time analysis
select
YEAR(ORDER_date) AS order_year,
MONTH(order_date) as order_month,
SUM(SALES_AMOUNT) AS total_sales,
COUNT(distinct customer_key)as total_customer,
sum(quantity) as total_quantity
from SALES WHERE ORDER_DATE IS NOT NULL
GROUP BY MONTH(order_date),YEAR(ORDER_DATE)
ORDER BY MONTH(order_date),YEAR(ORDER_DATE)

//Cumulative Analysis

  //running total of sales 

select
order_date,
total_sales,
sum(total_sales) over (order by order_date) as running_total_sales
from
(select

date_trunc(year, order_date)as order_date,
sum(sales_amount) as total_sales
from sales
where order_date is not null
group by DATE_TRUNC(year, order_date)) t



  //moving average

select
order_date,
total_sales,
avg (avg_price) over (order by order_date) as moving_avg
from
(select

date_trunc(year, order_date)as order_date,
sum(sales_amount) as total_sales,
avg(price) as avg_price
from sales
where order_date is not null
group by DATE_TRUNC(year, order_date)) t


//Performance Analysis

  /*analyze yearly performance of products by comparing 
   sales to both the average sales performance of the 
   product and previous years sale */

   with yearly_product_sales as
   (select 
   year(f.order_date) as order_year,
   p.product_name,
   sum(f.sales_amount) as current_sales
   from sales f
   left join products p
   on f.product_key=p.product_key
   where f.order_date is not null
   group by 
   year (f.order_date),
   p.product_name
   )
   select
   order_year,
   product_name,
   current_sales,
   avg(current_sales) over (partition by product_name) as 
   avg_sales,
   current_sales - avg(current_sales) over (partition by 
   product_name) as diff_avg,

   CASE when current_sales - avg(current_sales) over 
   (partition by product_name) > 0 then 'Above avg'
        when current_sales - avg(current_sales) over 
             (partition by product_name) <0 then 'Below avg'
        else 'Avg' 
   end avg_change, 
   Lag (current_sales) over (partition by product_name 
   order by order_year) prv_sales,
   current_sales - Lag (current_sales) over (partition by 
   product_name order by order_year) as prv_diff,

   CASE when current_sales - Lag (current_sales) over 
   (partition by product_name order by order_year) > 0 then 
   'increase'
        when current_sales - Lag (current_sales) over 
       (partition by 
        product_name order by order_year) <0 then 'decrease'
        else 'No change' 
   end prv_change
   
   from yearly_product_sales
   order by product_name, order_year




//Part to whole analysis

  // which category contributes the most 
     with category_sales as (
     
     select
     category,
     sum(sales_amount) total_sales
     
     from sales f
     left join products p
     on f.product_key= p.product_key 
     group by category)

     select
     category,
     total_sales,
     sum (total_sales) over () overall_sales,
     Concat (round ((CAST (total_sales as float)/ sum 
     (total_sales) over ()) * 100 ,2),'%') as 
      percentage_of_total

      from category_sales
      order by total_sales desc
     

// Data Segmentation

   /* segment products into cost ranges and count how many 
      products fall into each segment*/
      
      with product_segments as (
      select
      product_key,
      product_name,
      cost,
      case when cost<100 then 'below 100'
           when cost between 100 and 500 then '100-500'
           when cost between 500 and 1000 then '500-1000'
           else 'above 1000'
       end cost_range
       from products
       )
       select
       cost_range,
       count (product_key) as total_products
       from product_segments
       group by cost_range
       order by total_products DESC



    /* segmenting customers based on their behaviours and 
        total number of customers each geoup */

       with customer_spending as (
       select 
       c.customer_key,
       sum(f.sales_amount) as total_spending,
       
       min (order_date) as first_order,
       max (order_date) as last_order,
       datediff(month, min(order_date), max (order_date)) 
       as lifespan
       from sales f
       left join customer c 
       on f.customer_key= c.customer_key
       group by c.customer_key
       )

       select
       customer_segment,
       count (customer_key) as total_customers
       from(
       select 
       customer_key,
       total_spending ,
       lifespan,
       case when lifespan>= 12 and total_spending > 5000 
       then 'VIP '
            when lifespan>= 12 and total_spending <= 5000 
            then 'Regular '
       else 'New'
       end customer_segment
       from customer_spending ) t
       group by customer_segment 
       order by total_customers DESC 
        
      




    


