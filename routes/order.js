/* eslint-disable quote-props */
const router = require('express').Router();
const UUID = require('uuid/v4');
const Order = require('../models/order');
const Cart = require('../models/cart');

router.post('/', async (req, res) => {
    /* Temporary adapter to map passed variables to suitable values */
    if (req.body.delivery_method === 'deliver') {
        req.body.delivery_method = 'home_delivery';
    } else {
        req.body.delivery_method = 'shop_pickup';
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

            res.render('order', {
                loggedIn: req.session.user != null,
                show_thanks: false,
                subtotal: dataObj.subtotal,
                delivery: req.body.delivery_method === 'home_delivery' ? dataObj.delivery_charge : 0,
                total: totalCost,
                order: {
                    'id': orderId,
                    'date': new Date(),
                    'payment_method': req.body.payment_method,
                    'delivery_method': req.body.delivery_method,
                },
                user: {
                    'firstname': req.body.first_name,
                    'lastname': req.body.last_name,
                    'phonenumber': req.body.phone_number,
                    'email': req.body.email,
                },
                deliveryaddress: {
                    'address1': req.body.addr_line1,
                    'address2': req.body.addr_line2,
                    'city': req.body.city,
                    'postal': req.body.postcode,
                },
                items: dataObj.items,
            });
        } catch (err) {
            res.redirect(`/checkout?error=${err}`);
        }
    } else {
        res.redirect(`/cart?error=${result}`);
    }
});

router.get('/', (req, res) => {
    res.render('order', {
        loggedIn: req.session.user != null,
        show_thanks: false,
        subtotal: '13800.00' - 0,
        delivery: '800.00' - 0,
        total: '14600.00' - 0,
        order: {
            'id': '5de2acbf2a97',
            'date': '27/09/2019',
            'payment_method': 'pay_on_delivery',
            'delivery_method': 'delivery',
        },
        user: {
            'firstname': 'John',
            'lastname': 'Doe',
            'phonenumber': '1233332233',
            'email': 'user@user.com',
        },
        deliveryaddress: {
            'address1': '56/8',
            'address2': 'Street 1',
            'city': 'City 2',
            'postal': '12000',
        },
        items: [
            {
                id: '5de2acbf14d983e4e097b174',
                product_title: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',
                variant: 'Blue Colored Variant',
                selling_price: '4900.00' - 0,
                quantity: 1,
                totalprice: '4900.00',
            },
            {
                id: '5de2acbf2a9751c69c33133d',
                product_title: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',
                variant: 'Red Colored Variant' - 0,
                selling_price: '8900.00',
                quantity: 1,
                totalprice: '8900.00',
            },
        ],
    });
});

module.exports = router;
