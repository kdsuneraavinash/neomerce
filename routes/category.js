const router = require('express').Router();
const category = require('./../models/category');
const product = require('./../models/product');

router.get('/', async (req, res) => {
    if (req.query.query === undefined && req.query.category === undefined) {
        if (req.query.category === undefined) {
            res.json({
                code: 404,
                failed: 'Category or query unspecified',
            });
        }
    } else if (req.query.query === undefined) {
        const categories = await category.getChildren(req, res, req.query.category);
        if (categories === null) return;

        const categoryDetails = await category.getDetails(req, res, req.query.category);
        if (categoryDetails === null) return;

        const productDetails = await product.getProductsFromCategory(req, res, req.query.category);
        if (productDetails === null) return;

        res.render('category', {
            products: productDetails.result,
            categories,
            categorytitle: categoryDetails.title,
            parentid: categoryDetails.parent_id,
            topprice: productDetails.topprice,
            title: `Search Results for ${categoryDetails.title}`,
        });
    } else if (req.query.category === undefined) {
        const categories = await category.getChildren(req, res, req.query.category);
        if (categories === null) return;

        const productDetails = await product.getProductsFromQuery(req, res, req.query.query);
        if (productDetails === null) return;

        res.render('category', {
            products: productDetails.result,
            categories,
            categorytitle: null,
            parentid: null,
            topprice: productDetails.topprice,
            title: `Search Results for ${req.query.query}`,
        });
    } else {
        res.json({
            code: 500,
            failed: 'Category or query both specified',
        });
    }
});

module.exports = router;
