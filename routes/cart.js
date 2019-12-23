const router = require('express').Router();
const helper = require('../utils/helper');
const Cart = require('./../models/cart');

router.get('/', async (req, res) => {
    try {
        const loggedIn = req.session.user != null;

        const cartItems = await Cart.getCartItems(req.sessionID);
        console.log(cartItems);

        res.render('cart', {
            loggedIn,
            subtotal: 'LKR13800.00',
            items: cartItems
            // items: [
            //     {
            //         id: '5de2acbf14d983e4e097b174',
            //         product: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',
            //         variant: 'Blue Colored Variant',
            //         image: '/img/product/p2.jpg',
            //         unitprice: 'LKR4900.00',
            //         quantity: 1,
            //         totalprice: 'LKR4900.00',
            //     },
            //     {
            //         id: '5de2acbf2a9751c69c33133d',
            //         product: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',
            //         variant: 'Red Colored Variant',
            //         image: '/img/product/p7.jpg',
            //         unitprice: 'LKR8900.00',
            //         quantity: 1,
            //         totalprice: 'LKR8900.00',
            //     },
            // ],
        });
    } catch (error) {
        helper.errorResponse(res, error);
    }
});

module.exports = router;
