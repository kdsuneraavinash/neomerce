const router = require('express').Router();

router.get('/', (req, res) => {
    res.render('category');
});

module.exports = router;
