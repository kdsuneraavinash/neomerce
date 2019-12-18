const router = require('express').Router();
const bcrypt = require('bcrypt');
const User = require('../models/user');
const helper = require('../utils/helper');


/* GET endpoint for user registration. Render the user registration page upon request */
router.get('/register', (req, res) => {
    res.render('register');
});

/* POST endpoint for user registration. */
router.post('/register', async (req, res) => {
    // TODO validation here
    const {
        body: {
            username, password, firstName, lastName, addressLine1, addressLine2, city, postalCode,
        },
    } = req;
    const encryptedPassword = bcrypt.hashSync(password, 10);
    try {
        const success = await User.createUser(req.sessionID, username, firstName, lastName,
            addressLine1, addressLine2, city, postalCode, encryptedPassword);
        if (success) {
            req.session.user = true;
            res.redirect('/');
        } else {
            res.render('register');
        }
    } catch (error) {
        helper.errorResponse(res, error);
    }
});

router.get('/logout', (req, res) => {
    if (req.session.user && req.session.cookie) {
        res.clearCookie('user_sid');
        req.session.destroy();
    }
    res.redirect('/');
});


router.get('/login', (req, res) => {
    res.render('login');
});


router.post('/login', async (req, res) => {
    const { body: { username, password } } = req;
    try {
        const passwordValidated = await User.validatePassword(username, password);
        if (!passwordValidated) {
            // TODO: Notify that password is invalid
            res.redirect('/user/login');
        } else {
            try {
                const assigned = await User.assignCustomerId(req.sessionID, username);
                if (assigned) {
                    req.session.user = true;
                    res.redirect('/');
                } else {
                    res.redirect('/user/login');
                }
            } catch (error) {
                helper.errorResponse(res, error);
            }
        }
    } catch (error) {
        helper.errorResponse(res, error);
    }
});


router.get('/check/:username', async (req, res) => {
    try {
        const result = await User.checkUsername(req.params.username);
        if (result) {
            res.send('Username Exist');
        } else {
            res.send('Username Valid');
        }
    } catch (error) {
        res.send('Error Occurred');
    }
});


module.exports = router;
