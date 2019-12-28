const router = require('express').Router();
const Report = require('../models/report');

router.get('/example/', async (req, res) => {
    res.render('reports/example');
});
router.get('/product/', async (req, res) => {
    const productResult = await Report.getProductCounts();
    const categoryResult = await Report.getCategoryReport();
    // console.log(productResult[2]);
    res.render('reports/productReport', {
        productItems: productResult[0],
        productItemCount: productResult[1],
        productItemsWithQuantity: productResult[2],
        categoryItems: categoryResult[0],
        categoryItemCount: categoryResult[1],
    });
});

module.exports = router;
