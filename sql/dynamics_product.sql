--drop view v2
--create view v2
--as
select 
 	distinct 
 	city,
 	t1.title_category,
 	t1.title_product,
 	round(sum(t1.year_21) over(),0) as sum_2021, -- Выручка на 2021 год
	round(sum(t1.year_22) over(),0) as sum_2022, -- Выручка на 2021 год
	round(sum(t1.year_21) over(partition by city),0) as city_2021, -- Выручка на по городу 2021 год
	round(sum(t1.year_22) over(partition by city),0) as city_2022, -- Выручка на по городу 2021 год
	round(sum(t1.year_21) over(partition by t1.city, t1.title_category),0) as category_2021, --Выручка категории в разрезе города на 2021 год
	round(sum(t1.year_22) over(partition by t1.city, t1.title_category),0) as category_2022, --Выручка категории в разрезе города на 2021 год
	round(sum(t1.year_21) over(partition by t1.city, t1.title_category, t1.title_product),0) as product_2021, -- Выручка конкретного товара в категории в разрезе города на 2021 год
	round(sum(t1.year_22) over(partition by t1.city, t1.title_category, t1.title_product),0) as product_2022  -- Выручка конкретного товара в категории в разрезе города на 2021 год
 from 
		(select
				city,
				sp2.title as title_category,
				sp.title as title_product,
				case 
					when extract ( year from so.created_at ) = '2021' -- выручка 2021 год
					then (so2.price * so2.quantity)
				end as year_21,
				case 
					when extract ( year from so.created_at ) = '2022' -- выручка 2022 год
					then (so2.price * so2.quantity)
				end as year_22
		from shop_customer sc 
		inner join shop_order so 
		on sc.id = so.customer_id 
		inner join shop_orderitem so2 
		on so.id = so2.order_id
		inner join shop_product sp 
		on so2.product_id = sp.id 
		inner join shop_productcategory sp2 
		on sp.category_id = sp2.id  
		) t1
order by 
city,
t1.title_category,
t1.title_product

--Распределение итоговой выручки категории в городе на товары, динамика (увеличение/снижение выручки по товарам) с 2021 по 2022 год 

select
	city,
	title_category,
	title_product,
	case 
		when product_2021_prc is not null
	    then concat (product_2021_prc,'%')
	    else '-'
	end as product_2021_prc ,-- Доля выручки товара в категории на 2021 год
	case 
		when product_2022_prc is not null
		then concat (product_2022_prc,'%')
		else '-'
	end as product_2021_prc , -- Доля выручки товара в категории на 2022 год
	case
		when product_2021_prc is null and product_2022_prc is not null
		then concat ('+',round(product_2022_prc,2), '%')
		when product_2022_prc is null and product_2021_prc is not null
		then concat ('-',round(product_2021_prc,2), '%')
		when product_2022_prc > product_2021_prc
		then concat ('+',round(product_2022_prc - product_2021_prc,2) , '%')
		when product_2022_prc < product_2021_prc
		then concat (round(product_2022_prc - product_2021_prc,2), '%')
	end as product_prc, -- Прирост пп товара в категории c 2021 на 2022 год
	case
		when product_2021 is null and product_2022 is not null
		then concat ('+',round(product_2022,2))
		when product_2022 is null and product_2021 is not null
		then concat ('-',round(product_2021,2))
		when product_2022 > product_2021
		then concat ('+',round(product_2022 - product_2021,2))
		when product_2022 < product_2021
		then concat (round(product_2022 - product_2021,2))
	end as product_d -- Прирост руб. товара в категории c 2021 на 2022 год
from
	(select
		distinct
	 	city,
	 	title_category,
	 	title_product,
	 	product_2021,
	 	product_2022,
	 	case 
		 	when product_2021 > 0
		 	then round((product_2021/category_2021)*100,2)
		end as product_2021_prc , -- Доля товара в категории за 2021 год
		case 
		 	when product_2022 > 0
		 	then round((product_2022/category_2022)*100,2)
		end as product_2022_prc   -- Доля товара в категории за 2022 год
	from v2
	) t1
order by city, title_category, title_product