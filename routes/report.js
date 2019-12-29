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
        productItemCount: productResult[0].length,
        productItemsWithQuantity: productResult[1],
    });
});

router.get('/category/', async (req, res) => {
    const categoryTreeResult = await Report.getCategoryTreeReport();
    const topCategoryLeafNodes = await Report.getTopCategoryLeafNodes();
    res.render('reports/category_report', {
        categoryItems: topCategoryLeafNodes[0],
        categoryItemCount: topCategoryLeafNodes[0].length,
        categoryitemsWithQuantity: topCategoryLeafNodes[1],
        treeItems: categoryTreeResult[0],
        treeItemParents: categoryTreeResult[1],
        treeItemCount: categoryTreeResult[0].length,
    });
});

module.exports = router;
