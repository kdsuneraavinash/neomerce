const router = require('express').Router();
const Product = require('./../models/product');
const ProductImage = require('./../models/productimage');
const helper = require('../utils/helper');


router.get('/show/:id', async (req, res) => {
    try {
        const product = await Product.getProduct(req, res, req.params.id);
        const images = await ProductImage.getImages(req, res, req.params.id);
        if (images.length === 1) images.push(images[0]);

        const variantsData = await Product.getVariants(req, res, req.params.id);

        const releatedProducts = await Product.getRelatedProducts(req, res, req.params.id, 9);

        res.render('item', {
            userData: req.userData,
            name: product.title,
            description: product.description,
            weight: product.weight_kilos,
            brand: product.brand,
            images,
            attributes: product.attributes,
            variants: variantsData.result,
            variant_attributes: variantsData.attributes,
            related: releatedProducts,
        });
    } catch (error) {
        helper.errorResponse(res, error);
    }
});

module.exports = router;
