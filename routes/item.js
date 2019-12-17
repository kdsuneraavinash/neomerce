/* eslint-disable quote-props */
const router = require('express').Router();
const Product = require('./../models/product');
const ProductImage = require('./../models/productimage');

router.get('/show/:id', async (req, res) => {
    const loggedIn = req.session.user ? true : false
    const product = await Product.getProduct(req, res, req.params.id);
    if (product === null) return;

    const images = await ProductImage.getImages(req, res, req.params.id);
    if (images === null) return;
    if (images.length === 1) images.push(images[0]);

    const variantsData = await Product.getVariants(req, res, req.params.id);
    if (variantsData === null) return;

    console.log(variantsData);

    res.render('item', {
        loggedIn:loggedIn,
        name: product.title,
        category: 'clothes',
        description: product.description,
        weight: product.weight_kilos,
        brand: product.brand,
        images,
        attributes: product.attributes,
        variants: variantsData.result,
        variant_attributes: variantsData.attributes,
    });
});

module.exports = router;
