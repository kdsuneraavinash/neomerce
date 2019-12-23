const connection = require('../config/db');

const getCartItems = async (sessionID) => {
    let get_customerid_query = `select customer_id from session where session_id = $1`;
    const get_customerid_query_values = [sessionID];
    const out_customerid = await connection.query(get_customerid_query, get_customerid_query_values);
    const customerID = out_customerid.rows[0].customer_id;

    let get_cart_items_query = `select * from cartitem where customer_id = $1`;
    const out_cart_items = await connection.query(get_cart_items_query, [customerID]);
    const cartItems = out_cart_items.rows;
    const itemCount = out_cart_items.rowCount;

    var items = [];
    var subtotal = 0;
    for (i = 0; i < itemCount; i++) {
        const variant_id = cartItems[i].variant_id;
        let variant_query = `select product_id,title,selling_price from variant where variant_id = $1`;
        const out_variant = await connection.query(variant_query, [variant_id]);
        const product_id = out_variant.rows[0].product_id;
        const varient_title = out_variant.rows[0].title;
        const selling_price = out_variant.rows[0].selling_price;

        let product_title_query = `select title from product where product_id = $1`;
        const out_title = await connection.query(product_title_query, [product_id]);
        const product_title = out_title.rows[0].title;

        let get_image_url_query = `select image_url from productimage where product_id = $1`;
        const out_image_url = await connection.query(get_image_url_query, [product_id]);
        const image_url = out_image_url.rows[0].image_url;

        var total_price = selling_price * cartItems[i].quantity;

        var item = {
            id: variant_id,
            product: product_title,
            variant: varient_title,
            image: image_url,
            unitprice: selling_price,
            quantity: cartItems[i].quantity,
            totalprice: total_price

        };
        items.push(item);
        var subtotal = (subtotal + total_price);
    };
    return [items, subtotal.toFixed(2)];
};

const removeItemFromCart = async (session_id, variant_id) => {
    let get_customerid_query = `select customer_id from session where session_id = $1`;
    const get_customerid_query_values = [session_id];
    const out_customerid = await connection.query(get_customerid_query, get_customerid_query_values);
    const customerID = out_customerid.rows[0].customer_id;

    let get_cart_items_query = `delete from cartitem where customer_id = $1 and variant_id = $2`;
    const out_cart_items = await connection.query(get_cart_items_query, [customerID, variant_id]);

};

module.exports = {
    getCartItems, removeItemFromCart
};
