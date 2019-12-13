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











module.exports = {saveSession}