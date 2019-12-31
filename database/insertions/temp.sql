select product_id, product.title, sum(orderitem.quantity), 
    sum(orderitem.quantity*variant.selling_price) from 
    (select order_id from orderdata
    where extract(quarter from orderdata.order_date)=4 and 
    extract(year from orderdata.order_date)=2019) as req_orders
        join orderitem using(order_id)
        join variant using(variant_id)
        join product using(product_id)
    group by product_id, product.title
