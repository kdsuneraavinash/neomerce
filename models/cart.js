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
    const itemCount = out_cart_items.rowCount;
    console.log("Cart Items :");
    console.log(cartItems);
    // id: '5de2acbf14d983e4e097b174',                                  variant_id(variant tbl)
    // product: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',        product_id(variant tbl) -> 
    // variant: 'Blue Colored Variant',                                 title(variant tbl) , attribute_name(variantattribute tbl) : attribute_value(variant tbl)
    // image: '/img/product/p2.jpg',                                    image_url(productimage tbl)
    // unitprice: 'LKR4900.00',                                         selling_price(variant tbl)
    // quantity: 1,                                                     #
    // totalprice: 'LKR4900.00',                                        = unitprice*quantity
   
   console.log("Looping the cartItem list : ");
    var items = [];
    for (i = 0; i < itemCount; i++) {
        var item = {
            id: cartItems[i].variant_id,
            product: "Test Product",
            variant : "Red Color Variant",
            image: "http://ecx.images-amazon.com/images/I/51W35ZG1PWL._SY300_.jpg",
            unitprice : "LKR 2000",
            quantity: cartItems[i].quantity,
            totalprice : "LKR 2000"
        };
        items.push(item);
    };
    // console.log(items);
    return items;
};


module.exports = {
    getCartItems
};
