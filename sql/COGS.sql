-- COGS 
-- COGS = a + b + c + d
-- где 
-- a - себестоимость (sp."cost" * so.quantity)
-- b - стоимость возвращенных товаров ()
-- c - стоимость доставки для возвращенных товаров, оплата транспортной компании
-- d - стоимость доставки для возвращенных товаров, оплата компенсации доставки для клиента, если происходит возврат всех позиций заказа
select a.price_cost, b.price_refund, c.delivery_refund , d.cost_delivery from 
 (
	 select 
	sp."cost" * so.quantity as price_cost -- себестоимость
	from shop_orderitem so 
	inner join shop_product sp 
	on so.product_id = sp.id
 ) as a
,(
	select 
	sr2.price * sr2.quantity as price_refund-- стоимость бракованных товаров которую вернут клиенту
	from shop_refunditem sr2
 ) as b
,(
	select 
	sd."cost" as delivery_refund-- стоимость доставки бракованных товаров на склад
	from shop_delivery sd 
	where sd.delivery_type = 'REFUND'
 ) as c
,(	 select sum(cost) as cost_delivery from -- компенсация доставки для клиента, если все товары в заказе бракованные
		(select cost
			 ,(select sum(quantity) from shop_orderitem so
				where order_id = delivery_order
			  ) as order_quantity -- количество товаров в заказе
			 ,(select sum(quantity)  from shop_refunditem sr
				inner join shop_refund sr2 
				on sr.refund_id = sr2.id 
				where sr2.order_id = delivery_order
			  ) as refund_quantity -- количество возвращенных товаров в заказе
		from 
		(select 
			  sd.cost
			, so.id as delivery_order
		from shop_delivery sd 
		inner join shop_order so 
		on sd.id = so.delivery_id 
		where delivery_type = 'ORDER' 
		) as deliveries) 
	as delivery
	where order_quantity = refund_quantity
 ) as d
 
-- a -- 
select 
sp."cost" * so.quantity as price_cost -- себестоимость
from shop_orderitem so 
inner join shop_product sp 
on so.product_id = sp.id
where so.price is not null and so.price != 0

-- b --
select 
sr2.price * sr2.quantity as price_refund-- стоимость бракованных товаров которую вернут клиенту
from shop_refunditem sr2

-- c -- 
select 
sd."cost" as delivery_refund-- стоимость доставки бракованных товаров на склад
from shop_delivery sd 
where sd.delivery_type = 'REFUND'

-- d --
 select sum(cost) as cost_delivery from -- компенсация доставки для клиента, если все товары в заказе бракованные
		(select cost
			 ,(select sum(quantity) from shop_orderitem so
				where order_id = delivery_order
			  ) as order_quantity -- количество товаров в заказе
			 ,(select sum(quantity)  from shop_refunditem sr
				inner join shop_refund sr2 
				on sr.refund_id = sr2.id 
				where sr2.order_id = delivery_order
			  ) as refund_quantity -- количество возвращенных товаров в заказе
		from 
		(select 
			  sd.cost
			, so.id as delivery_order
		from shop_delivery sd 
		inner join shop_order so 
		on sd.id = so.delivery_id 
		where delivery_type = 'ORDER'
		) as deliveries) 
as delivery
where order_quantity = refund_quantity
;