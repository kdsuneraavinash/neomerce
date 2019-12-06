const connection = require('../config/db');
const helper = require('./helper');


const getChildren = (req, res, categoryId, callback) => {
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


module.exports = { getChildren };
