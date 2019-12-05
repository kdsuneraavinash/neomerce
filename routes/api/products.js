const router = require('express').Router();
const Products = require('../../models/products');

router.get('/', (req, res) => {
    Products.getAllItems(req, res);
});

module.exports = router;
