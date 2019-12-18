const pool = require('../config/db');

const saveSession = async (req) => {
    const queryString = 'CALL assignSession($1)';
    const values = [req.sessionID];
    await pool.query(queryString, values);
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
