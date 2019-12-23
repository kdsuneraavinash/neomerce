const router = require('express').Router();
const category = require('./../models/category');
const product = require('./../models/product');
const helper = require('../utils/helper');

router.get('/', async (req, res) => {
    try {
        const loggedIn = req.session.user != null;
        if (req.query.query === undefined && req.query.category === undefined) {
            if (req.query.category === undefined) {
                helper.errorResponse(res, 'Category or query unspecified');
            }
        } else if (req.query.query === undefined) {
            const categories = await category.getChildren(req, res, req.query.category);
            const categoryDetails = await category.getDetails(req, res, req.query.category);
            const productDetails = await product.getProductsFromCategory(req, res,
                req.query.category);

            res.render('category', {
                loggedIn,
                products: productDetails.result,
                categories,
                categorytitle: categoryDetails.title,
                parentid: categoryDetails.parent_id,
                topprice: productDetails.topprice,
                title: `Search Results for ${categoryDetails.title}`,
            });
        } else if (req.query.category === undefined) {
            const categories = await category.getChildren(req, res, req.query.category);
            const productDetails = await product.getProductsFromQuery(req, res, req.query.query);

            res.render('category', {
                loggedIn,
                products: productDetails.result,
                categories,
                categorytitle: null,
                parentid: null,
                topprice: productDetails.topprice,
                title: `Search Results for ${req.query.query}`,
            });
        } else {
            helper.errorResponse(res, 'Category or query both specified');
        }
    } catch (error) {
        helper.errorResponse(res, error);
    }
});

module.exports = router;
