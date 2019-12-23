const connection = require('../config/db');

const getCartItems = async (sessionID) => {

    // console.log("sessionID: " + sessionID);
    let get_customerid_query = `select customer_id from session where session_id = $1`;
    const get_customerid_query_values = [sessionID];
    const out_customerid = await connection.query(get_customerid_query, get_customerid_query_values);
    const customerID = out_customerid.rows[0].customer_id;
    // console.log("customerID : " + customerID);

    let get_cart_items_query = `select * from cartitem where customer_id = $1`;
    const out_cart_items = await connection.query(get_cart_items_query, [customerID]);
    const cartItems = out_cart_items.rows;
    const itemCount = out_cart_items.rowCount;
    // console.log("Cart Items :");
    // console.log(cartItems);

    //##################################################################################################################
    // id: '5de2acbf14d983e4e097b174',                                  variant_id(variant tbl)
    // product: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',        product_id(variant tbl) -> title
    // variant: 'Blue Colored Variant',                                 title(variant tbl) , attribute_name(variantattribute tbl) : attribute_value(variant tbl)
    // image: '/img/product/p2.jpg',                                    image_url(productimage tbl)
    // unitprice: 'LKR4900.00',                                         selling_price(variant tbl)
    // quantity: 1,                                                     #
    // totalprice: 'LKR4900.00',                                        = unitprice*quantity
    //##################################################################################################################


    // console.log("Looping the cartItem list : ");
    var items = [];
    var subtotal = 0;
    for (i = 0; i < itemCount; i++) {
        const variant_id = cartItems[i].variant_id;
        let variant_query = `select product_id,title,selling_price from variant where variant_id = $1`;
        const out_variant = await connection.query(variant_query, [variant_id]);
        const product_id = out_variant.rows[0].product_id;
        // // const title = out_variant.rows[0].title;
        const selling_price = out_variant.rows[0].selling_price;

        let product_title_query = `select title from product where product_id = $1`;
        const out_title = await connection.query(product_title_query, [product_id]);
        const title = out_title.rows[0].title;

        let variant_attribute_query = `select attribute_name,attribute_value from variantattribute where variant_id = $1`;
        const out_variant_attribute = await connection.query(variant_attribute_query, [variant_id]);
        const variant_attributes = out_variant_attribute.rows;

        // console.log("variant_attributes : ");
        // console.log(variant_attributes);

        let get_image_url_query = `select image_url from productimage where product_id = $1`;
        const out_image_url = await connection.query(get_image_url_query, [product_id]);
        const image_url = out_image_url.rows[0].image_url;

        var total_price = (selling_price * cartItems[i].quantity).toFixed(2);

        var item = {
            id: variant_id,
            product: title,
            variant: JSON.stringify(variant_attributes),
            image: image_url,
            unitprice: selling_price,
            quantity: cartItems[i].quantity,
            totalprice: total_price

        };
        items.push(item);
        subtotal = subtotal + total_price;
    };
    // console.log(items);
    return [items, subtotal];
};


module.exports = {
    getCartItems
};
