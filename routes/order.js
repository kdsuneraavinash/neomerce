const router = require('express').Router();
const UUID = require('uuid/v4');
const Order = require('../models/order');
const Cart = require('../models/cart');
const helper = require('../utils/helper');

router.post('/', async (req, res) => {
    /* Temporary adapter to map passed variables to suitable values */
    if (req.body.delivery_method === 'deliver') {
        req.body.delivery_method = 'home_delivery';
    } else {
        req.body.delivery_method = 'store_pickup';
    }
    if (req.body.payment_method !== 'card') {
        req.body.payment_method = 'cash';
    }

    /* Check if all the items are avaiable in stocks */
    const result = await Cart.checkStock(req.sessionID);

    if (result == null) {
        try {
            /* Get details needed to make and order(subtotal and delivery_charge) */
            const dataObj = await Order.getOrderDetails(req);

            /* In case user refresh the order confirmation page, redirects him to home */
            if (dataObj.subtotal === 0) {
                res.redirect('/');
                return;
            }

            let totalCost;

            /* Define total based on the delivery type */
            if (req.body.delivery_method === 'home_delivery') {
                totalCost = (parseFloat(dataObj.subtotal)
                    + parseFloat(dataObj.delivery_charge)).toFixed(2);
            } else {
                totalCost = dataObj.subtotal;
            }

            /* Create the order */
            const orderId = UUID();
            await Order.createOrder(req.sessionID, req.body, orderId, totalCost);

            res.redirect(`/order/${orderId}`);
        } catch (err) {
            res.redirect(`/checkout?error=${err}`);
        }
    } else {
        res.redirect(`/cart?error=${result}`);
    }
});

router.get('/:orderId', async (req, res) => {
    try {
        /* check for user permission to view order history */
        const permission = await Order.orderHistoryPermissionChecker(req);
        if (!permission) {
            res.redirect('/');
            return;
        }

        /* Create an order history object with all the information needed for order history page */
        const orderHistoryObj = await Order.getOrderHistory(req.params.orderId);

        res.render('order', {
            userData: req.userData,
            show_thanks: false,
            orderHistoryObj,
        });
    } catch (error) {
        helper.errorResponse(res, 'Invalid order id');
    }
});


router.get('/', async (req, res) => {
    if (req.query.id) {
        res.redirect(`/order/${req.query.id}`);
    } else {
        res.render('error', { code: 404, failed: 'Unspecified order id' });
    }
});


module.exports = router;
