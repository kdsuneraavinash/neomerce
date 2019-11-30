const router = require('express').Router();

router.get('/show/', (req, res) => {
    res.render('single-product');
});

module.exports = router;
