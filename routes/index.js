const express = require('express');
const Auth = require('../utils/auth');

const router = express.Router();


router.use(Auth.userTypeMiddleware);

router.use('/', require('./root'));
router.use('/category/', require('./category'));
router.use('/item/', require('./item'));
router.use('/cart/', require('./cart'));
router.use('/checkout/', require('./checkout'));
router.use('/order/', require('./order'));
router.use('/user/', require('./user'));
router.use('/api/', require('./api'));
router.use('/admin/', require('./admin'));

module.exports = router;
