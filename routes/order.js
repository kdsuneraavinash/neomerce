/* eslint-disable quote-props */
const router = require('express').Router();

router.get('/', (req, res) => {
    res.render('order', {
        show_thanks: false,
        subtotal: '13800.00',
        delivery: '800.00',
        total: '14600.00',
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
                product: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',
                variant: 'Blue Colored Variant',
                unitprice: '4900.00',
                quantity: 1,
                totalprice: '4900.00',
            },
            {
                id: '5de2acbf2a9751c69c33133d',
                product: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',
                variant: 'Red Colored Variant',
                unitprice: '8900.00',
                quantity: 1,
                totalprice: '8900.00',
            },
        ],
    });
});

module.exports = router;
