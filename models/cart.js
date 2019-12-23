const connection = require('../config/db');

const getCartItems = async (sessionID) => {

    console.log("sessionID: " + sessionID);
    let get_customerid_query = `select customer_id from session where session_id = $1`;
    const get_customerid_query_values = [sessionID];
    const out_customerid = await connection.query(get_customerid_query, get_customerid_query_values);
    const customerID = out_customerid.rows[0].customer_id;
    console.log("customerID : " + customerID);

    let get_cart_items_query = `select * from cartitem where customer_id = $1`;
    const out_cart_items = await connection.query(get_cart_items_query, [customerID]);
    const cartItems = out_cart_items.rows;
    console.log("Cart Items :");
    console.log(cartItems);
    // id: '5de2acbf14d983e4e097b174',
    // product: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',
    // variant: 'Blue Colored Variant',
    // image: '/img/product/p2.jpg',
    // unitprice: 'LKR4900.00',
    // quantity: 1,
    // totalprice: 'LKR4900.00',

    return null;
};


module.exports = {
    getCartItems
};
