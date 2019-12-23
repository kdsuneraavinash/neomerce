const router = require('express').Router();
const helper = require('../utils/helper');
const Cart = require('./../models/cart');

router.get('/', async (req, res) => {
    try {
        const loggedIn = req.session.user != null;

        const cartItems_subtotal = await Cart.getCartItems(req.sessionID);
        console.log(cartItems_subtotal);

        res.render('cart', {
            loggedIn,
            subtotal: cartItems_subtotal[1],
            items: cartItems_subtotal[0]
        });
    } catch (error) {
        helper.errorResponse(res, error);
    }
});

module.exports = router;
