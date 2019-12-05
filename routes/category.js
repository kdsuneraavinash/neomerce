const router = require('express').Router();
const category = require('./../models/category');

router.get('/', (req, res) => {
    category.getChildren(req, res, req.query.category, (categories) => {
        if (categories === null) {
            return;
        }

        res.render('category', {
            topprice: 10000,
            products: [
                {
                    id: '5de2acbfbef439b0016b9c9a',
                    show: true,
                    image: '/img/product/p1.jpg',
                    title: 'QUORDATE NEW COGENTRY SPACEWAX FOR SPORTS PERSON',
                    price: 1200,
                },
                {
                    id: '5de2acbf7848e81fc1b179b4',
                    show: true,
                    image: '/img/product/p2.jpg',
                    title: 'VETRON NEW FITCORE BULLJUICE FOR SPORTS PERSON',
                    price: 4000,
                },
                {
                    id: '5de2acbf14d983e4e097b174',
                    show: true,
                    image: '/img/product/p3.jpg',
                    title: 'SUPPORTAL NEW XUMONK ZENSOR FOR SPORTS PERSON',
                    price: 4500,
                },
                {
                    id: '5de2acbfab216fce7c291eca',
                    show: true,
                    image: '/img/product/p4.jpg',
                    title: 'BUZZNESS NEW XIXAN IDETICA FOR SPORTS PERSON',
                    price: 5000,
                },
                {
                    id: '5de2acbf2a9751c69c33133d',
                    show: true,
                    image: '/img/product/p5.jpg',
                    title: 'EGYPTO NEW IMKAN EVIDENDS FOR SPORTS PERSON',
                    price: 5000,
                },
                {
                    id: '5de2acbfb842f81e4dad37d9',
                    show: true,
                    image: '/img/product/p6.jpg',
                    title: 'ZAGGLE NEW MARQET DIGIQUE FOR SPORTS PERSON',
                    price: 6700,
                },
                {
                    id: '5de2acbf0fbbadd27119e04b',
                    show: true,
                    image: '/img/product/p7.jpg',
                    title: 'ISOSPHERE NEW HOMETOWN COSMETEX FOR SPORTS PERSON',
                    price: 7200,
                },
                {
                    id: '5de2ad43536366a79dedb0ea',
                    show: true,
                    image: '/img/product/p8.jpg',
                    title: 'NEUROCELL NEW QUORDATE SLOGANAUT FOR SPORTS PERSON',
                    price: 8120,
                },
            ],
            categories,
        });
    });
});

module.exports = router;
