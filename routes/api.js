const router = require('express').Router();
const City = require('./../models/city');
const User = require('./../models/user');

router.get('/cities/', async (req, res) => {
    const result = await City.getCities(req.query.search);
    res.json(result);
});

router.get('/email/:email', async (req, res) => {
    const result = await User.emailExists(req.params.email);
    res.json({ result, email: req.params.email });
});

router.get('/city/:city', async (req, res) => {
    const result = await City.cityExists(req.params.city);
    res.json(result);
});

module.exports = router;
