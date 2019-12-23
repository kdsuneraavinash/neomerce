const router = require('express').Router();

router.get('/', (req, res) => {
    res.render('checkout', {
        loggedIn: req.session.user != null,
        subtotal: '13800.00',
        estdelivery: '800.00',
        withdelivery: '14600.00',
        items: [
            {
                id: '5de2acbf14d983e4e097b174',
                product: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',
                variant: 'Blue Colored Variant',
                image: '/img/product/p2.jpg',
                unitprice: '4900.00',
                quantity: 1,
                totalprice: '4900.00',
            },
            {
                id: '5de2acbf2a9751c69c33133d',
                product: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',
                variant: 'Red Colored Variant',
                image: '/img/product/p7.jpg',
                unitprice: '8900.00',
                quantity: 1,
                totalprice: '8900.00',
            },
        ],
    });
});

module.exports = router;
