const pool = require('../config/db')
const UUID = require('uuid/v4')


const saveSession = (req,res)=> {

    const queryString = 'CALL assign_session($1)'
    const values = [req.sessionID]
    //console.log('saveSession called')
    pool.query(queryString,values, (err, result) => {
        if (err) {
            // console.log(err)
        } else {
            //console.log('Session created')
        }
    })
}


// middleware function to check for logged-in users
var sessionChecker = (req, res, next) => {
    console.log(req.session.cookie)
    if (req.session.user && req.session.cookie) {
        res.render('dashboard');
    } else {
        next();
    }    
};











module.exports = {saveSession,sessionChecker}