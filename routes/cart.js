const router = require('express').Router();
const helper = require('../utils/helper');
const Cart = require('./../models/cart');
const Product = require('./../models/product');

router.post('/add/', async (req, res) => {
    await Product.addToCart(
        req.body.varient,
        req.body.qty,
        req.sessionID
    );
    res.redirect('/cart');
});

router.post("/remove/:id", async (req, res) => {
    await Cart.removeItemFromCart(req.sessionID, req.params.id);
    res.redirect('/cart');
});

router.get('/', async (req, res) => {
    try {
        const loggedIn = req.session.user != null;
        const cartItems_subtotal = await Cart.getCartItems(req.sessionID);

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
