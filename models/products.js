const connection = require('../config/db');
const helper = require('./helper');


const getAllItems = (req, res) => {
    if (connection.connect) {
        const queryString = 'SELECT * FROM product;';
        connection.query(queryString, (err, rows) => {
            if (err) {
                helper.errorResponse(res, err);
            } else {
                helper.successResponse(res, rows.rows);
            }
        });
    } else {
        helper.successResponse(res, 'Database connection error');
    }
};


module.exports = { getAllItems };
