const express = require('express');

const router = express.Router();

router.use('/', require('./root'));
router.use('/category/', require('./category'));
router.use('/item/', require('./item'));
router.use('/cart/', require('./cart'));

module.exports = router;
