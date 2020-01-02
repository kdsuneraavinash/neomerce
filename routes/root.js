const router = require('express').Router();
const Product = require('./../models/product');


router.get('/', async (req, res) => {
    const products = await Product.getRecentProducts(req, res, 18);
    res.render('index', { userData: req.userData, products });
});

module.exports = router;
