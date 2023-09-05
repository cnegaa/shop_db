select 
sum(so.price * so.quantity) - as total_revenue
(select a.price_cost + b.price_refund + c.delivery_refund as COGS from 
 (  select 
	sum(sp."cost" * so.quantity) as price_cost -- себестоимость
	from shop_orderitem so 
	inner join shop_product sp 
	on so.product_id = sp.id
 ) as a
,(  select 
	sum(sr2.price * sr2.quantity) as price_refund-- стоимость бракованных товаров которую вернут клиенту
	from shop_refunditem sr2
 ) as b
,(  select 
	sum(sd."cost") as delivery_refund-- стоимость доставки бракованных товаров на склад
	from shop_delivery sd 
	where sd.delivery_type = 'REFUND'
 ) as c)
from shop_orderitem so 