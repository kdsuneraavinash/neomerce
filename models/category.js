const connection = require('../config/db');
const helper = require('./helper');


const getAllItems = (req, res, callback) => {
    if (connection.connect) {
        const queryString = 'SELECT * FROM category;';
        connection.query(queryString, (err, rows) => {
            if (err) {
                helper.errorResponse(res, err);
            } else {
                callback(rows.rows);
            }
        });
    } else {
        helper.errorResponse(res, 'Database connection error');
    }
};


const getChildren = (req, res, categoryId, callback) => {
    console.log(categoryId === undefined ? null : categoryId);
    if (connection.connect) {
        const query = {
            name: 'fetch-children-categories',
            text: 'SELECT * FROM category WHERE parent_id IS NOT DISTINCT FROM $1',
            values: [categoryId === undefined ? null : categoryId],
        };

        connection
            .query(query)
            .then((out) => callback(out.rows))
            .catch((e) => helper.errorResponse(res, e.stack));
    } else {
        helper.errorResponse(res, 'Database connection error');
    }
};


module.exports = { getAllItems, getChildren };
