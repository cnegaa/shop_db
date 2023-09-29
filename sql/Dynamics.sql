--drop view v1
create view v1
as
select 
	distinct city,
	round(min(t0.year_21) over(partition by city),0) as min_2021,
	round(min(t0.year_22) over(partition by city),0) as min_2022,
	round(max(t0.year_21) over(partition by city),0) as max_2021,
	round(max(t0.year_22) over(partition by city),0) as max_2022,
	round(sum(t0.year_21) over(partition by city),0) as sum_2021,
	round(sum(t0.year_22) over(partition by city),0) as sum_2022,
	round(sum(t0.order_21) over(partition by city),0) as order_2021,
	round(sum(t0.order_22) over(partition by city),0) as order_2022,
	round(sum(t0.item_21) over(partition by city),0) as item_2021,
	round(sum(t0.item_22) over(partition by city),0) as item_2022
from
	   (select
			city,
			case 
				when extract ( year from so.created_at ) = '2021' -- выручка 2021 год
				then sum(so2.price * so2.quantity)
			end as year_21,
			case 
				when extract ( year from so.created_at ) = '2022' -- выручка 2022 год
				then sum(so2.price * so2.quantity)
			end as year_22,
			case 
				when extract ( year from so.created_at ) = '2021'  -- кол-во предметов в заказе 2021 год
				then  sum(so2.quantity) 
			end as item_21,
				case 
				when extract ( year from so.created_at ) = '2022'  -- кол-во предметов в заказе 2022 год
				then  sum(so2.quantity) 
			end as item_22,
			case 
				when extract ( year from so.created_at ) = '2021' -- кол-во заказов 2021 год
				then count(distinct so.id) 
			end as order_21,
				case 
				when extract ( year from so.created_at ) = '2022' -- кол-во заказов 2022 год
				then count(distinct so.id) 
			end as order_22	
		from shop_customer sc 
		inner join shop_order so 
		on sc.id = so.customer_id 
		inner join shop_orderitem so2 
		on so.id = so2.order_id 
		group by city, so.created_at) t0
order by city

select 
	city,
	round(sum_2021 / order_2021,0) as avg_order_2021,
	round(sum_2022 / order_2022,0) as avg_order_2022,
	round(sum_2021 / item_2021,0) as avg_item_2021,
	round(sum_2022 / item_2022,0) as avg_item_2022
from v1
group by 
		v1.city, 
		v1.sum_2021,
		v1.sum_2022,  
		v1.order_2021,
		v1.order_2022,
		v1.item_2021, 
		v1.item_2022
		
select 
	city,
	sum_2021,
	sum_2022,
	order_2021,
	order_2022,
	item_2021,
	item_2022,
	round(((sum_2022/sum_2021)-1)*100,2) as prc_sum,
	round(((order_2022/order_2021)-1)*100,2) as prc_order,
	round(((item_2022/item_2021)-1)*100,2) as prc_item
from v1