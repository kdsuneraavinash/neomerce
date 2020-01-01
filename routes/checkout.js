const router = require('express').Router();
const Cart = require('../models/cart');
const Order = require('../models/order');

router.get('/', async (req, res) => {
    const dataObj = Order.getOrderDetails(req);

    /* After order confirmation user redirect back to check out and try to check out again */
    if (dataObj.subtotal === 0) {
        res.redirect('/');
    }

    const result = await Cart.checkStock(req.sessionID);

    if (result == null) {
        const proceedCheckOutObj = await Cart.proceedCheckOut(req.sessionID, req.session.user);

        res.render('checkout', {
            userData: req.userData,
            proceedCheckOutObj,
            error: req.query.error,
        });
    } else {
        res.redirect(`/cart?error=${result}`);
    }
});

module.exports = router;
