const router = require('express').Router();
const helper = require('../utils/helper');
const Cart = require('./../models/cart');

router.post('/add/', async (req, res) => {
    const result = await Cart.addItemToCart(
        req.body.variant,
        req.body.qty,
        req.sessionID,
    );
    if (result === null) {
        res.redirect('/cart');
    } else {
        res.redirect(`/cart?error=${result}`);
    }
});

router.post('/edit/:id', async (req, res) => {
    req.body.quantity -= 0;
    if (Number.isNaN(req.body.quantity)) {
        res.redirect('/cart?error=Invalid quantity given');
    } else if (req.body.quantity < 0) {
        res.redirect('/cart?error=Negative quantity given');
    } else {
        const result = await Cart.editCartItemQuantity(req.sessionID, req.params.id,
            req.body.quantity);
        if (result === null) {
            res.redirect('/cart');
        } else {
            res.redirect(`/cart?error=${result}`);
        }
    }
});
router.post('/remove/:id', async (req, res) => {
    await Cart.removeItemFromCart(req.sessionID, req.params.id);
    res.redirect('/cart');
});

router.post('/transfer/:id', async (req, res) => {
    const result = await Cart.transferCartItem(
        req.sessionID, req.params.id,
    );
    if (result === null) {
        res.redirect('/cart');
    } else {
        res.redirect(`/cart?error=${result}`);
    }
});

router.get('/', async (req, res) => {
    try {
        const { cartItems, subtotal } = await Cart.getCartItems(req.sessionID);
        res.render('cart', {
            userData: req.userData,
            items: cartItems,
            subtotal,
            error: req.query.error,
        });
    } catch (error) {
        helper.errorResponse(res, error);
    }
});


module.exports = router;
