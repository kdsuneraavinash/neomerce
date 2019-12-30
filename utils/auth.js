const pool = require('../config/db');
const helper = require('../utils/helper');

const saveSession = async (req, res) => {
    const queryString = 'CALL assignSession($1)';
    const values = [req.sessionID];
    try {
        await pool.query(queryString, values);
    } catch (err) {
        helper.errorResponse(res, err);
    }
};


// middleware function to check for logged-in users
const sessionChecker = (req, res, next) => {
    if (req.session.user && req.session.cookie) {
        const loggedIn = true;
        res.render('index', { loggedIn });
    } else {
        next();
    }
};


module.exports = { saveSession, sessionChecker };
