select product_id, min(selling_price) as min_selling_price from Variant group by product_id;