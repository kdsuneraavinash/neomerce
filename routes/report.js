const router = require('express').Router();
const Report = require('../models/report');

router.get('/example/', async (req, res) => {
    res.render('reports/example');
});
router.get('/product/', async (req, res) => {
    const result = await Report.getProductCounts();
    console.log(result[2]);
    res.render('reports/product', {
        items: result[0],
        itemCount: result[1],
        itemsWithQuantity: result[2],
    });
});

module.exports = router;
