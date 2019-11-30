const router = require('express').Router();

router.get('/', (req, res) => {
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
        categories: [{
            id: '5de2b062d48ac159e72fe214',
            name: 'Portable Audio & Headphones',
            count: 20,
            children: [{
                id: '5de2b06242a4d51403f3586e',
                name: 'TV, Video & Home Audio',
                count: 4,
            },
            {
                id: '5de2b0625079851ea8f1e44e',
                name: 'Video Games & Consoles',
                count: 16,
                children: [{
                    id: '5de2b0627caea9294ad3dd7f',
                    name: 'Vehicle Electronics & GPS',
                    count: 4,
                },
                {
                    id: '5de2b06207b26b72cd80fa8b',
                    name: 'Smart Home',
                    count: 12,
                },
                ],
            },
            ],
        },
        {
            id: '5de2b0624bea5998530c81f1',
            name: 'Surveillance & Smart Home',
            count: 38,
            children: [{
                id: '5de2b0622b04bd8afabd69ce',
                name: 'Cell Phones, Smart Watches & Accessories',
                count: 42,
            },
            {
                id: '5de2b0625c35a64120c9c0bd',
                name: 'Cameras & Photo',
                count: 24,
            },
            {
                id: '5de2b062e8d1e1174f330430',
                name: 'Computers, Tablets & Network Hardware',
                count: 12,
            },
            ],
        },
        {
            id: '5de2b1533ac223264b655e67',
            name: 'Home Entertainment',
            count: 22,
        },
        {
            id: '5de2b1535a9370bdc573f5f1',
            name: 'Home Telephones & Accessories',
            count: 24,
        },
        ],
    });
});

module.exports = router;
