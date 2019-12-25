const router = require('express').Router();
const Product = require('./../models/product');


router.get('/', async (req, res) => {
    const products = await Product.getRecentProducts(req, res, 18);
    const loggedIn = req.session.user != null;
    res.render('index', { loggedIn, products });
});

module.exports = router;
