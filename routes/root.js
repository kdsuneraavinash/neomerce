const router = require('express').Router();
const auth = require('../utils/auth');
const Product = require('./../models/product');


router.get('/', auth.sessionChecker, async (req, res) => {
    const products = await Product.getRecentProducts(req, res, 18);
    res.render('index', { loggedIn: false, products });
});

module.exports = router;
