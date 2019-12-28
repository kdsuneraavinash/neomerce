const router = require('express').Router();
const Report = require('../models/report');

router.get('/example/', async (req, res) => {
    res.render('reports/example');
});
router.get('/product/', async (req, res) => {
    const productResult = await Report.getProductCounts();
    // console.log(productResult[2]);
    res.render('reports/product_report', {
        productItems: productResult[0],
        productItemCount: productResult[1],
        productItemsWithQuantity: productResult[2],
    });
});

router.get('/category/', async (req, res) => {
    const categoryResult = await Report.getCategoryReport();
    // console.log(productResult[2]);
    res.render('reports/category_report', {
        categoryItems: categoryResult[0],
        categoryItemCount: categoryResult[1],
        treeItems: categoryResult[2],
        treeItemParents: categoryResult[3],
        treeItemCount: categoryResult[4],
    });
});

module.exports = router;
