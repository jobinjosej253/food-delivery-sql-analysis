/*setup*/

alter table order_items
add column total_amount decimal(10,2)
generated always as (quantity*price) stored;

/*1 */
select r.restaurant_id,r.cuisine,r.city,
sum(total_amount) as total_revenue
from restaurants r
join orders_medium o on r.restaurant_id = o.restaurant_id
join order_items oi on o.order_id = oi.order_id
where o.status<>"Cancelled"
group by r.restaurant_id,r.cuisine,r.city
ORDER BY total_revenue DESC;

/*2*/
select c.customer_id,sum(total_amount) as total_spend,
count(distinct o.order_id) as order_count,
round(sum(total_amount) / count(distinct o.order_id),2) as avg_order_value
from customers_medium c
join orders_medium o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
where o.status<>"Cancelled"
group by c.customer_id
order by total_spend desc
limit 10;

/*3*/

select oi.item_id,o.restaurant_id,r.cuisine,sum(oi.quantity) as total_quantity
from order_items oi join orders_medium o on oi.order_id = o.order_id
join restaurants r on o.restaurant_id = r.restaurant_id
where o.status<>"Cancelled"
group by oi.item_id, o.restaurant_id, r.cuisine
order by total_quantity desc
limit 5;

/*4*/

select r.cuisine,r.city,
round(sum(total_amount) / count(distinct o.order_id),2) as avg_ordervalue
from restaurants r
join orders_medium o on r.restaurant_id = o.restaurant_id
join order_items oi on o.order_id = oi.order_id
where o.status<>"Cancelled"
group by r.cuisine,r.city;

/*5*/

select customer_id from customers_medium
where customer_id not in (select customer_id from orders_medium);

/*6*/

select item_id from menu_items 
where item_id not in (select item_id from order_items);

/*7*/

select date_format(o.order_time, '%Y-%m') as month,count(distinct o.order_id) as total_orders,
sum(oi.total_amount) as total_revenue
from orders_medium o join order_items oi on o.order_id = oi.order_id
where o.status<>"Cancelled"
group by month
order by month asc;

/*8*/

select r.restaurant_id,o.status,count(o.order_id) as orders_status,
round(count(o.order_id) * 100.0 / sum(count(o.order_id)) over(partition by r.restaurant_id), 2) as percentage_of_orders
from restaurants r
join orders_medium o on r.restaurant_id = o.restaurant_id
group by r.restaurant_id,o.status
order by r.restaurant_id,percentage_of_orders desc;

/*9*/

with restaurant_avgorder_value as (
select o.restaurant_id,sum(total_amount) / count(distinct o.order_id) as restaurant_avg_order_value
from orders_medium o join order_items oi on o.order_id = oi.order_id
where o.status<>"Cancelled"
group by o.restaurant_id
),
overall_avgorder_value as (
select sum(total_amount) / count(distinct o.order_id) as overall_avg_order_value
from orders_medium o join order_items oi on o.order_id = oi.order_id
where o.status<>"Cancelled"
)
select r.restaurant_id,r.cuisine,r.city,round(ra.restaurant_avg_order_value, 2) as restaurant_aov
from restaurant_avgorder_value ra
join restaurants r on ra.restaurant_id = r.restaurant_id
where ra.restaurant_avg_order_value > (select overall_avg_order_value from overall_avgorder_value)
order by restaurant_aov desc;

/*10*/
select dayname(order_time) as day_of_week, hour(order_time) as hour_,
count(order_id) as order_count from orders_medium
group by day_of_week,hour_
order by order_count desc;

/*11*/

select r.restaurant_id,r.cuisine,
round(avg(timestampdiff(minute, o.order_time, o.delivery_time)), 2) as avg_deliverytime
from restaurants r
join orders_medium o on r.restaurant_id = o.restaurant_id
where o.status = 'Delivered'
group by r.restaurant_id,r.cuisine;

/*12*/

select 
case 
when r.rating < 3.5 then 'Low (< 3.5)'
when r.rating between 3.5 and 4.2 then 'Medium (3.5 - 4.2)'
when r.rating > 4.2 then 'High (> 4.2)'
else 'Unrated'
end as rating_band,
round(sum(oi.total_amount) / count(distinct r.restaurant_id), 2) as average_revenue,
round(avg(case when o.status = 'Delivered' 
then timestampdiff(minute, o.order_time, o.delivery_time) end), 2) as avg_delivery_time
from restaurants r 
join orders_medium o on r.restaurant_id = o.restaurant_id
join order_items oi on o.order_id = oi.order_id
where o.status<>"Cancelled"
group by rating_band;

/*13*/

with itemrevenue as (
select o.restaurant_id,oi.item_id,sum(total_amount)as total_itemrevenue,
dense_rank() over(partition by o.restaurant_id order by sum(total_amount) desc) as item_rank
from orders_medium o join order_items oi on o.order_id = oi.order_id
where o.status<>"Cancelled"
group by o.restaurant_id,oi.item_id
)
select restaurant_id,item_id,total_itemrevenue,item_rank
from itemrevenue where item_rank <= 3
order by restaurant_id,item_rank;

/*14*/

with monthlyrevenue as (
select date_format(o.order_time, '%Y-%m') as month,sum(oi.total_amount) as current_monthrevenue
from orders_medium o join order_items oi on o.order_id = oi.order_id
where o.status<>"Cancelled"
group by month
),
revenuewithlag as (
select month,current_monthrevenue,
lag(current_monthrevenue) over(order by month) as previous_monthrevenue
from monthlyrevenue
)
select month,current_monthrevenue,previous_monthrevenue,
round(((current_monthrevenue - previous_monthrevenue) / previous_monthrevenue) * 100,2) as growth_percentage
from revenuewithlag
order by month asc;

/*15*/

with daily_restaurantrevenue as (
select o.restaurant_id,date(o.order_time) as order_date,round(sum(oi.total_amount),2) as daily_revenue
from orders_medium o join order_items oi on o.order_id = oi.order_id
group by o.restaurant_id, order_date
)
select restaurant_id,order_date,daily_revenue,
round(sum(daily_revenue) over (partition by restaurant_id order by order_date asc),2) as cumulative_revenue
from daily_restaurantrevenue
order by restaurant_id,order_date asc;

/*16*/

with dailyorders as (
select date(order_time) as order_date,count(distinct order_id) as total_orders
from orders_medium
group by order_date
)
select order_date,total_orders,
round(avg(total_orders) over(order by order_date rows between 6 preceding and current row),2) as 7day_movingavg
from dailyorders
order by order_date asc;


