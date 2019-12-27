const router = require('express').Router();

router.get('/example/', async (req, res) => {
    res.render('reports/example');
});

module.exports = router;
