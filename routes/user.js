const router = require('express').Router();
const bcrypt = require('bcrypt');
const User = require('../models/user');
const Order = require('../models/order');
const helper = require('../utils/helper');
const validator = require('../utils/validation');


/* GET endpoint for user registration. Render the user registration page upon request */
router.get('/register', async (req, res) => {
    res.render('register', {
        error: req.query.error,
        userData: req.userData,
    });
});

/* POST endpoint for user registration. */
router.post('/register', validator.validateRegistration, async (req, res) => {
    const {
        body: {
            email, password, firstName, lastName,
            addressLine1, addressLine2, city, postalCode, telephoneNumber, birthday,
        },
    } = req;
    const encryptedPassword = bcrypt.hashSync(password, 10);
    try {
        const bdayParts = birthday.split('/');
        const birthdayParsed = new Date(parseInt(bdayParts[2], 10),
            parseInt(bdayParts[1], 10) - 1,
            parseInt(bdayParts[0], 10));
        const success = await User.createUser(req.sessionID, email, firstName, lastName,
            addressLine1, addressLine2, city, postalCode, encryptedPassword, telephoneNumber,
            birthdayParsed);
        if (success) {
            req.session.user = true;
            res.redirect('/user/profile');
        } else {
            res.redirect('register');
        }
    } catch (error) {
        res.redirect(`register?error=${error}`);
    }
});

router.get('/logout', (req, res) => {
    if (req.session.user && req.session.cookie) {
        res.clearCookie('user_sid');
        req.session.destroy();
    }
    res.redirect((req.query.redirect ? req.query.redirect : '/'));
});


router.get('/login', (req, res) => {
    res.render('login', { error: req.query.error, redirect: req.query.redirect, userData: req.userData });
});


router.post('/login', validator.validateLogin, async (req, res) => {
    const { body: { email, password } } = req;
    try {
        const passwordValidated = await User.validatePassword(email, password);
        if (!passwordValidated) {
            res.redirect(`/user/login?error=Email or password invalid&redirect=${req.body.redirect}`);
        } else {
            const assigned = await User.assignCustomerId(req.sessionID, email);
            if (assigned) {
                req.session.user = true;
                const accountType = await User.userType(req.sessionID);
                if (accountType === 'admin') {
                    res.redirect('/admin');
                } else {
                    res.redirect(req.body.redirect);
                }
            } else {
                res.redirect(`/user/login?error=Something went wrong&redirect=${req.body.redirect}`);
            }
        }
    } catch (error) {
        helper.errorResponse(res, error);
    }
});


router.get('/profile', async (req, res) => {
    if (req.session.user == null) {
        res.redirect('/');
        return;
    }
    const recentOrders = await Order.getRecentOrders(req.sessionID);
    const recentProducts = await User.recentProducts(req.sessionID);
    const userInfo = await User.userInfo(req.sessionID);
    res.render('profile', {
        userData: req.userData,
        recentProducts,
        userInfo,
        recentOrders,
    });
});

module.exports = router;
