/* eslint-disable no-await-in-loop */
const connection = require('../config/db');

const getCartItems = async (sessionID) => {
    const query = `select cart_item_id as id,
                        variant_id as variant_id, 
                        CartItem.quantity as quantity, 
                        cart_item_status,
                        image_url as image,
                        Variant.title as variant, 
                        Product.title as product, 
                        Product.product_id as productid,
                        selling_price as unitprice
                    from 
                        Customer natural join 
                        Session natural join 
                        CartItem join Variant using(variant_id) natural join
                        ProductMainImageView join Product using(product_id) 
                    where 
                        session_id = $1 and
                        (cart_item_status='added' or cart_item_status='transferred')`;
    const out = await connection.query(query, [sessionID]);
    let subtotal = 0;
    out.rows.forEach((v) => {
        if (v.cart_item_status === 'added') {
            // eslint-disable-next-line no-param-reassign
            v.totalprice = v.unitprice * v.quantity;
            subtotal += v.totalprice;
        }
    });
    return {
        cartItems: out.rows, subtotal,
    };
};

const addItemToCart = async (variantId, qty, sessionID) => {
    const query = 'CALL addItemToCart($1, $2, $3)';
    const values = [sessionID, variantId, qty];
    try {
        await connection.query(query, values);
    } catch (err) {
        return err;
    }
    return null;
};

const removeItemFromCart = async (sessionId, cartItemId) => {
    const query = 'CALL removeCartItem($1, $2)';
    const values = [sessionId, cartItemId];
    await connection.query(query, values);
};

const transferCartItem = async (sessionId, cartItemId) => {
    const query = 'CALL transferCartItem($1, $2)';
    const values = [sessionId, cartItemId];
    try {
        await connection.query(query, values);
    } catch (err) {
        return err;
    }
    return null;
};

module.exports = {
    getCartItems, removeItemFromCart, addItemToCart, transferCartItem,
};
