const connection = require('../config/db');
const helper = require('./helper');


const getChildren = async (req, res, categoryId) => {
    try {
        const text = 'SELECT * FROM category WHERE parent_id IS NOT DISTINCT FROM $1';
        const values = [categoryId === undefined ? null : categoryId];
        const out = await connection.query(text, values);
        return out.rows;
    } catch (err) {
        helper.errorResponse(res, err.message);
        return null;
    }
};

const getDetails = async (req, res, categoryId) => {
    try {
        const text = 'SELECT title, parent_id FROM category WHERE category_id = $1';
        const values = [categoryId];
        const out = await connection.query(text, values);
        if (out.rows.length === 0) throw Error('No category found');
        return out.rows[0];
    } catch (err) {
        helper.errorResponse(res, err.message);
        return null;
    }
};


module.exports = { getChildren, getDetails };
