const pool = require('../config/db')
const UUID = require('uuid/v4')


const saveSession = (req,res)=> {
    const queryString = 'CALL assign_session($1)'
    const values = [req.sessionID]
    pool.query(queryString,values, (err, result) => {
        if (err) {
            console.log(err)
        } else {
            // console.log('Working fine')
        }
    })
}


// middleware function to check for logged-in users
var sessionChecker = (req, res, next) => {
    console.log(req.session.cookie)
    if (req.session.user && req.session.cookie) {
        let loggedIn = true
        res.render('index',{'loggedIn':loggedIn});
    } else {
        next();
    }    
};


module.exports = {saveSession,sessionChecker}