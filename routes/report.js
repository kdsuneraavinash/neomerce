const router = require('express').Router();

router.get('/example/', async (req, res) => {
    res.render('reports/sales_report');
});

module.exports = router;
