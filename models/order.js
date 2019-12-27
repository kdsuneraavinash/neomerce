const connection = require('../config/db');


const createOrder = async (sessionID, body, orderID, totalprice) => {
    const createOrderQueryString = 'CALL placeOrder($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)';
    const createOrderValues = [sessionID, body.first_name, body.last_name,
        body.email, body.phone_number, body.delivery_method,
        body.addr_line1, body.addr_line2, body.city, body.postcode,
        body.payment_method, orderID, totalprice];
    await connection.query(createOrderQueryString, createOrderValues);
};

const getOrderDetails = async (req) => {
    const productDetailsObject = {};
    let result;

    const itemsInfoQueryString = `SELECT variant_id, product_id, quantity, 
                                        variant_title, selling_price, product_title 
                                    from ProductVariantView, session 
                                    where ProductVariantView.customer_id = session.customer_id and
                                        session.session_id = $1`;
    const itemInfoValues = [req.sessionID];
    result = await connection.query(itemsInfoQueryString, itemInfoValues);
    productDetailsObject.items = result.rows;
    productDetailsObject.subtotal = 0;
    productDetailsObject.items.forEach((v) => {
        // eslint-disable-next-line no-param-reassign
        v.totalprice = (v.selling_price - 0) * (v.quantity - 0);
        productDetailsObject.subtotal += v.totalprice;
    });

    if (req.body.delivery_method === 'home_delivery') {
        const deliveryDetailQuery = `SELECT citytype.delivery_charge from citytype,city 
                                        where city.city_type=citytype.city_type and city.city=$1 `;
        const deliverValues = [req.body.city];
        result = await connection.query(deliveryDetailQuery, deliverValues);
        productDetailsObject.delivery_charge = result.rows[0].delivery_charge;
    }
    return productDetailsObject;
};


const getRecentOrders = async (sessionId) => {
    const itemsInfoQueryString = `select 
                                    order_id, 
                                    order_status, 
                                    order_date as timestamp_date,
                                    to_char(order_date, 'dd month yyyy') as order_date,
                                    '["' || string_agg(product_id, '","') || '"]' as product_ids,
                                    '["' || string_agg(image_url,  '","') || '"]' as image_urls,
                                    '["' || string_agg(title,  '","') || '"]' as titles,
                                    '[' || string_agg(cast (selling_price  as text),  ',') || ']' as selling_prices,
                                    '[' || string_agg(cast (quantity  as text),  ',') || ']' as quantities,
                                    count(product_id) as products
                                from orderdata 
                                    join customer using(customer_id) 
                                    join session using(customer_id) 
                                    join (
                                        select product_id, image_url, order_id, productbasicview.title, selling_price, orderitem.quantity
                                        from variant 
                                            join orderitem using(variant_id)
                                            join productbasicview using(product_id)
                                    ) as variantimages using(order_id) 
                                where session_id = $1
                                group by order_id
                                order by timestamp_date desc
                                limit 5;`;
    const itemInfoValues = [sessionId];
    const out = await connection.query(itemsInfoQueryString, itemInfoValues);
    return out.rows;
};



const getOrderHistory = async(orderID) => {

    let result;
    const querString1 = 'SELECT customer.customer_id,customer.account_type from customer,orderdata where customer.customer_id = orderdata.customer_id and orderdata.order_id=$1'
    const values1 = [orderID]
    result = await connection.query(querString1,values1)
    if(result.rows[0].account_type = 'user'){
        const account_type = 'user'
        const customer_id = result.rows[0].customer_id
    }else{
        const account_type = 'guest'
    }

    
    



}









module.exports = { createOrder, getOrderDetails, getRecentOrders };



