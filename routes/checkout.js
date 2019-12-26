const router = require('express').Router();
const Cart = require('../models/cart');

router.get('/', async (req, res) => {
    const result = await Cart.checkStock(req.sessionID);

    if (result == null) {
        const proceedCheckOutObj = await Cart.proceedCheckOut(req.sessionID, req.session.user);

        res.render('checkout', {
            loggedIn: req.session.user != null,
            proceedCheckOutObj,
        });
    } else {
        res.redirect(`/cart?error=${result}`);
    }
});

module.exports = router;
