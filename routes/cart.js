const router = require('express').Router();

router.get('/', (req, res) => {
    res.render('cart');
});

module.exports = router;
