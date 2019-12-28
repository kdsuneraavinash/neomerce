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
    const categoryTreeResult = await Report.getCategoryTreeReport();
    const topCategoryLeafNodes = await Report.getTopCategoryLeafNodes();
    // console.log(productResult[2]);
    res.render('reports/category_report', {
        categoryItems: topCategoryLeafNodes[0],
        categoryItemCount: topCategoryLeafNodes[1],
        categoryitemsWithQuantity: topCategoryLeafNodes[2],
        treeItems: categoryTreeResult[0],
        treeItemParents: categoryTreeResult[1],
        treeItemCount: categoryTreeResult[2],
    });
});

module.exports = router;
