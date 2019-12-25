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




const checkStock = async (sessionID) => {
    const queryString = 'CALL checkAvailability($1)'
    const values = [sessionID]
    try{
        await connection.query(queryString,values)
    }catch(err){
        return err
    }
    return null
    
}


const proceedCheckOut = async(sessionID,loggedIn) => {
    console.log(loggedIn)
    let productDetailsObject = {};
    let result
    if(loggedIn){
        const userInfoQueryString = `SELECT email,first_name,last_name,addr_line1,addr_line2,city,postcode,phone_number
                                     delivery_days,delivery_charge from UserDeliveryView,session where UserDeliveryView.customer_id
                                     =session.customer_id and session.session_id = $1`
        const userInfoValues = [sessionID]
        result = await connection.query(userInfoQueryString,userInfoValues)
        productDetailsObject['delivery_info'] = result.rows[0]

    }

    const itemsInfoQueryString = `SELECT variant_id,product_id,quantity,variant_title,selling_price,product_title from
                                ProductVariantView,session where ProductVariantView.customer_id = session.customer_id and
                                session.session_id = $1`
    const itemInfoValues = [sessionID]

    result = await connection.query(itemsInfoQueryString,itemInfoValues)

    productDetailsObject['items'] = result.rows

    console.log(productDetailsObject)

    return productDetailsObject


}











module.exports = {
    getCartItems, removeItemFromCart, addItemToCart, transferCartItem,checkStock,proceedCheckOut
};
