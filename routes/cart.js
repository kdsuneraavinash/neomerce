const router = require('express').Router();
const helper = require('../utils/helper');
const Cart = require('./../models/cart');
const Product = require('./../models/product');

router.post('/add/', async (req, res) => {
    const result = await Product.addToCart(
        req.body.variant,
        req.body.qty,
        req.sessionID,
    );
    if (result == null) {
        res.redirect('/cart');
    } else {
        res.redirect(`/cart?error= + ${result}`);
    }
});

router.post('/remove/:id', async (req, res) => {
    await Cart.removeItemFromCart(req.sessionID, req.params.id);
    res.redirect('/cart');
});

router.get('/', async (req, res) => {
    try {
        const loggedIn = req.session.user != null;
        const cartItemsSubtotal = await Cart.getCartItems(req.sessionID);
        console.log(req.query);
        if (!req.query == null) {
            res.render('cart', {
                loggedIn,
                items: cartItemsSubtotal[0],
                subtotal: cartItemsSubtotal[1],
                error: req.query.error,
            });
        } else {
            res.render('cart', {
                loggedIn,
                items: cartItemsSubtotal[0],
                subtotal: cartItemsSubtotal[1],
                error: null,
            });
        }
    } catch (error) {
        helper.errorResponse(res, error);
    }
});


module.exports = router;
