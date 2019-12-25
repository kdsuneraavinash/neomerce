/* eslint-disable no-await-in-loop */
const connection = require('../config/db');

const getCartItems = async (sessionID) => {
    const getCustomerIdQuery = 'select customer_id from session where session_id = $1';
    const outCustomerId = await connection.query(getCustomerIdQuery, [sessionID]);
    const customerID = outCustomerId.rows[0].customer_id;

    const getCartItemsQuery = 'select * from cartitem where customer_id = $1';
    const outCartItems = await connection.query(getCartItemsQuery, [customerID]);
    const cartItems = outCartItems.rows;
    const itemCount = outCartItems.rowCount;

    const items = [];
    let subtotal = 0;
    for (let i = 0; i < itemCount; i += 1) {
        const variantId = cartItems[i].variant_id;
        const variantQuery = 'select product_id,title,selling_price from variant where variant_id = $1';
        const outVariant = await connection.query(variantQuery, [variantId]);
        const variant = outVariant.rows[0];
        const productId = variant.product_id;
        const sellingPrice = variant.selling_price;

        const productTitleQuery = 'select title from product where product_id = $1';
        const outTitle = await connection.query(productTitleQuery, [productId]);
        const productTitle = outTitle.rows[0].title;

        const getImageUrlQuery = 'select image_url from productimage where product_id = $1';
        const outImageUrl = await connection.query(getImageUrlQuery, [productId]);
        const imageUrl = outImageUrl.rows[0].image_url;

        const totalPrice = sellingPrice * cartItems[i].quantity;

        const item = {
            id: variantId,
            product: productTitle,
            variant: variant.title,
            image: imageUrl,
            unitprice: sellingPrice,
            quantity: cartItems[i].quantity,
            totalprice: totalPrice,

        };
        items.push(item);
        subtotal += totalPrice;
    }
    return [items, subtotal.toFixed(2)];
};

const removeItemFromCart = async (sessionId, variantId) => {
    const getCustomerIdQuery = 'select customer_id from session where session_id = $1';
    const outCustomerId = await connection.query(getCustomerIdQuery, [sessionId]);
    const customerID = outCustomerId.rows[0].customer_id;

    const getCartItemsQuery = 'delete from cartitem where customer_id = $1 and variant_id = $2';
    await connection.query(getCartItemsQuery, [customerID, variantId]);
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











module.exports = {
    getCartItems, removeItemFromCart,checkStock
};
