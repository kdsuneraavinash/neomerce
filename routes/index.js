const express = require('express');

const router = express.Router();

router.use('/', require('./root'));
router.use('/category/', require('./category'));
router.use('/item/', require('./item'));
router.use('/cart/', require('./cart'));
router.use('/checkout/', require('./checkout'));

module.exports = router;
