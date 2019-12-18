const router = require('express').Router();
const auth = require('../utils/auth');


router.get('/', auth.sessionChecker, (req, res) => {
    res.render('index', { loggedIn: false });
});

module.exports = router;
