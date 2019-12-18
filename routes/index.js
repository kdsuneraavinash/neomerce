const express = require('express');

const router = express.Router();

router.use('/', require('./root'));
router.use('/category/', require('./category'));
router.use('/item/', require('./item'));
router.use('/cart/', require('./cart'));
router.use('/checkout/', require('./checkout'));
router.use('/order/', require('./order'));
router.use('/user/', require('./user'));

module.exports = router;
