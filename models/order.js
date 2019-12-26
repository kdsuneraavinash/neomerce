const connection = require('../config/db');


const createOrder = async(sessionID,body,orderID,totalprice) => {

    const createOrderQueryString = 'CALL placeOrder($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)'
    const createOrderValues = [sessionID,body.first_name,body.last_name,body.email,body.phone_number,body.delivery_method,body.addr_line1,body.addr_line2,body.city,body.postcode,body.payment_method,orderID,totalprice]
    await connection.query(createOrderQueryString,createOrderValues)


}

const getOrderDetails = async(req) => {
    let productDetailsObject ={}
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

    if(req.body.delivery_method === 'home_delivery'){
        const deliveryDetailQuery = 'SELECT citytype.delivery_charge from citytype,city where city.city_type=citytype.city_type and city.city=$1'
        const deliverValues = [req.body.city]
        result = await connection.query(deliveryDetailQuery,deliverValues)
        console.log('FROM getOrder del '+result.rows[0].delivery_charge)
        productDetailsObject.delivery_charge = result.rows[0].delivery_charge

    }
    return productDetailsObject;
}


module.exports = {createOrder,getOrderDetails}