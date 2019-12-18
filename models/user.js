const bcrypt = require('bcrypt');
const pool = require('../config/db');


const createUser = async (sessionID, email, firstName, lastName, addressLine1, addressLine2,
    city, postalCode, password) => {
    const queryString = 'CALL createUser($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)';
    const values = [sessionID, email, firstName, lastName, addressLine1, addressLine2,
        city, postalCode, new Date(), password];
    await pool.query(queryString, values);
    return true;
};


const validatePassword = async (username, password) => {
    const queryString = `SELECT accountcredential.password from userinformation,accountcredential where 
                        userinformation.email=$1 and userinformation.customer_id=accountcredential.customer_id`;
    const values = [username];
    const out = await pool.query(queryString, values);
    if (out.rows[0] && bcrypt.compareSync(password, out.rows[0].password)) {
        return true;
    }
    return false;
};


const assignCustomerId = async (sessionID, username) => {
    const queryString = 'CALL assignCustomerId($1,$2)';
    const values = [sessionID, username];
    await pool.query(queryString, values);
    return true;
};


const checkUsername = async (username) => {
    const queryString = 'SELECT email from userinformation where email=$1';
    const values = [username];
    const out = await pool.query(queryString, values);
    return out.rows[0];
};


module.exports = {
    createUser, validatePassword, assignCustomerId, checkUsername,
};
