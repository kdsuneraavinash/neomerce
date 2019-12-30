const bcrypt = require('bcrypt');
const pool = require('../config/db');


const createUser = async (sessionID, email, firstName, lastName, addressLine1, addressLine2,
    city, postalCode, password, telephoneNumber) => {
    const queryString = 'CALL createUser($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)';
    const values = [sessionID, email, firstName, lastName, addressLine1, addressLine2,
        city, postalCode, new Date(), password, telephoneNumber];
    await pool.query(queryString, values);
    return true;
};


const validatePassword = async (email, password) => {
    const queryString = `SELECT accountcredential.password 
                            from userinformation join accountcredential using(customer_id)
                            where userinformation.email = $1`;
    const values = [email];
    const out = await pool.query(queryString, values);
    if (out.rows[0] && bcrypt.compareSync(password, out.rows[0].password)) {
        return true;
    }
    return false;
};


const assignCustomerId = async (sessionID, email) => {
    const queryString = 'CALL assignCustomerId($1, $2)';
    const values = [sessionID, email];
    await pool.query(queryString, values);
    return true;
};


const emailExists = async (email) => {
    const queryString = 'SELECT email from userinformation where email = $1';
    const values = [email];
    const out = await pool.query(queryString, values);
    return out.rows.length !== 0;
};


const userInfo = async (sessionId) => {
    const queryString = `select account_type, 
                            email, 
                            (first_name || ' ' || last_name) as name, 
                            (addr_line1 || ', ' || addr_line2 || ', ' || city || '. ' || postcode) as address
                            from session join userinformation using(customer_id) join customer using(customer_id)
                            where session_id = $1`;
    const values = [sessionId];
    const out = await pool.query(queryString, values);
    return out.rows[0];
};


const recentProducts = async (sessionId) => {
    const queryString = `select * from (
                            select distinct on (product_id) product_id, min_selling_price, title, image_url, visited_date
                                from productbasicview natural join visitedproduct natural join session 
                                where session_id = $1
                            ) as tbl order by visited_date desc limit 10`;
    const values = [sessionId];
    const out = await pool.query(queryString, values);
    return out.rows;
};


module.exports = {
    createUser,
    validatePassword,
    assignCustomerId,
    emailExists,
    recentProducts,
    userInfo,
};
