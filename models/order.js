const connection = require('../config/db');
const helper = require('../utils/helper');

/* Function to create an order */
const createOrder = async (sessionID, body, orderID, totalprice) => {
    const createOrderQueryString = 'CALL placeOrder($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)';
    const createOrderValues = [sessionID, body.first_name, body.last_name,
        body.email, body.phone_number, body.delivery_method,
        body.addr_line1, body.addr_line2, body.city, body.postcode,
        body.payment_method, orderID, totalprice];
    await connection.query(createOrderQueryString, createOrderValues);
};

/* Function to get details required to create an order */
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

/* Function to get recent orders for a particular session */
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


/* Function to get the order history for a particular order id */
const getOrderHistory = async(orderID) => {
    let orderHistoryDataObj = {customer_info:{},delivery_info:{},order_info:{},items:{}}
    let result;
    const values = [orderID]
    /* Ouery to get customer details of a registered user */
    const querString1 = `SELECT u.customer_id, u.email, u.first_name, u.last_name, d.addr_line1,
                        d.addr_line2, d.city, d.postcode, t.phone_number, ct.delivery_days, ct.delivery_charge,
                        o.dispatch_method,p.payment_amount,p.payment_method,o.order_date
                        FROM userinformation as u
                        LEFT JOIN orderdata as o ON u.customer_id = o.customer_id
                        LEFT JOIN telephonenumber as t ON u.customer_id = t.customer_id
                        LEFT JOIN delivery as d ON d.order_id = o.order_id
                        LEFT JOIN payment as p ON p.order_id = o.order_id
                        LEFT JOIN city as c ON d.city = c.city
                        LEFT JOIN citytype as ct ON ct.city_type=c.city_type where o.order_id = $1`                    
    result = await connection.query(querString1,values)
    if(result.rows[0]){
        /* If the order dispatch method is home delivery */
        if(result.rows[0].dispatch_method === 'home_delivery'){
            orderHistoryDataObj.delivery_info.addr_line1 = result.rows[0].addr_line1
            orderHistoryDataObj.delivery_info.addr_line2 = result.rows[0].addr_line2
            orderHistoryDataObj.delivery_info.city = result.rows[0].city
            orderHistoryDataObj.delivery_info.postcode = result.rows[0].postcode
            orderHistoryDataObj.delivery_info.delivery_charge = result.rows[0].delivery_charge
     
        }
        orderHistoryDataObj.order_info.dispatch_method = result.rows[0].dispatch_method
        orderHistoryDataObj.customer_info.first_name = result.rows[0].first_name
        orderHistoryDataObj.customer_info.last_name = result.rows[0].last_name
        orderHistoryDataObj.customer_info.email = result.rows[0].email
        orderHistoryDataObj.customer_info.phone_number = result.rows[0].phone_number
        orderHistoryDataObj.order_info.payment_method = result.rows[0].payment_method
        orderHistoryDataObj.order_info.payment_amount = result.rows[0].payment_amount
        orderHistoryDataObj.order_info.order_date = result.rows[0].order_date
    }else{
        /* Query to get customer information of a guest user */
        const querString2 = `SELECT g.email, g.first_name, g.last_name,g.phone_number,d.addr_line1,
                            d.addr_line2, d.city, d.postcode,ct.delivery_days, ct.delivery_charge,
                            o.dispatch_method,p.payment_amount,p.payment_method,o.order_date
                            FROM guestinfomation as g
                            LEFT JOIN orderdata as o ON g.order_id = o.order_id
                            LEFT JOIN delivery as d ON d.order_id = o.order_id
                            LEFT JOIN payment as p ON p.order_id = o.order_id
                            LEFT JOIN city as c ON d.city = c.city
                            LEFT JOIN citytype as ct ON ct.city_type=c.city_type where o.order_id = $1`
        result = await connection.query(querString2,values)
        orderHistoryDataObj.customer_info.first_name = result.rows[0].first_name
        orderHistoryDataObj.customer_info.last_name = result.rows[0].last_name
        orderHistoryDataObj.customer_info.email = result.rows[0].email
        orderHistoryDataObj.customer_info.phone_number = result.rows[0].phone_number
        orderHistoryDataObj.order_info.dispatch_method = result.rows[0].dispatch_method
        orderHistoryDataObj.order_info.payment_method = result.rows[0].payment_method
        orderHistoryDataObj.order_info.payment_amount = result.rows[0].payment_amount
        orderHistoryDataObj.order_info.order_date = result.rows[0].order_date
        /* If the order dispatch method is home delivery */
        if(result.rows[0].dispatch_method === 'home_delivery'){
            orderHistoryDataObj.delivery_info.addr_line1 = result.rows[0].addr_line1
            orderHistoryDataObj.delivery_info.addr_line2 = result.rows[0].addr_line2
            orderHistoryDataObj.delivery_info.city = result.rows[0].city
            orderHistoryDataObj.delivery_info.postcode = result.rows[0].postcode
            orderHistoryDataObj.delivery_info.delivery_charge = result.rows[0].delivery_charge
            orderHistoryDataObj.delivery_info.delivery_days = result.rows[0].delivery_days
            
        }

    }
    /* Query to get orderitems of a certain order */
    const querString3 = `SELECT product.title,product.product_id,variant.variant_id,variant.selling_price,orderitem.quantity 
                        from product,variant,orderitem where orderitem.variant_id = variant.variant_id and variant.product_id = product.product_id
                        and orderitem.order_id = $1`
    result = await connection.query(querString3,values)

    orderHistoryDataObj.items = result.rows
    orderHistoryDataObj.order_info.order_id = orderID

    return orderHistoryDataObj


}


const orderHistoryPermissionChecker = async (req) => {
    const queryString = 'SELECT checkOrderHistoryPriviledge($1,$2)'
    const values = [req.sessionID,req.params.orderId]
    const result = await connection.query(queryString,values)
    return result.rows[0]
}



module.exports = { createOrder, getOrderDetails, getRecentOrders ,getOrderHistory,orderHistoryPermissionChecker};



