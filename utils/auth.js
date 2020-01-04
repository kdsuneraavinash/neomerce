const pool = require('../config/db');
const helper = require('../utils/helper');
const Cart = require('../models/cart');
const User = require('../models/user');

const saveSession = async (req, res, next) => {
    const queryString = 'CALL assignSession($1)';
    const values = [req.sessionID];
    try {
        await pool.query(queryString, values);
        next();
    } catch (err) {
        helper.errorResponse(res, err);
    }
};

const userTypeMiddleware = async (req, res, next) => {
    if (req.session.cookie && req.session.user && req.sessionID) {
        const userType = await User.userType(req.sessionID);
        req.userData = { loggedIn: true, userType, cartItems: 0 };
    } else {
        req.userData = { loggedIn: false, userType: 'guest', cartItems: 0 };
    }
    if (req.sessionID) {
        req.userData.cartItems = await Cart.countCartItems(req.sessionID);
    }
    next();
};

module.exports = {
    saveSession,
    userTypeMiddleware,
};
