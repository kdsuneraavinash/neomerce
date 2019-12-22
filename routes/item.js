/* eslint-disable quote-props */
const router = require('express').Router();
const Product = require('./../models/product');
const ProductImage = require('./../models/productimage');
const helper = require('../utils/helper');
const bodyParser = require('body-parser');


router.get('/show/:id', async (req, res) => {
    try {
        const loggedIn = req.session.user != null;
        const product = await Product.getProduct(req, res, req.params.id);
        const images = await ProductImage.getImages(req, res, req.params.id);
        if (images.length === 1) images.push(images[0]);

        const variantsData = await Product.getVariants(req, res, req.params.id);

        res.render('item', {
            loggedIn,
            name: product.title,
            description: product.description,
            weight: product.weight_kilos,
            brand: product.brand,
            images,
            attributes: product.attributes,
            variants: variantsData.result,
            variant_attributes: variantsData.attributes,
        });
    } catch (error) {
        helper.errorResponse(res, error);
    }
});

router.post('/add/', async (req, res) => {
    // console.log("req body: ");
    Product.addToCart(
        req.body.varient,
        req.body.qty,
        req.sessionID,
        res
    );
    res.redirect('/cart');
});

module.exports = router;
