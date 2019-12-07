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


const getProductsFromCategory = async (req, res, categoryId) => {
    try {
        const query = `select product_id, title, min_selling_price, image_url 
                            from ProductBasicView natural join ProductCategory
                            where category_id = $1 
                            order by min_selling_price 
                            limit 99`;
        const values = [categoryId];
        const out = await connection.query(query, values);
        const result = out.rows.map((el) => {
            const o = { ...el };
            o.id = o.product_id;
            o.show = true;
            o.price = o.min_selling_price - 0;
            o.image = o.image_url;
            return o;
        });
        return { result, topprice: result.length === 0 ? 10000 : result[result.length - 1].price };
    } catch (err) {
        helper.errorResponse(res, err.message);
        return null;
    }
};

const getProductsFromQuery = async (req, res, searchQuery) => {
    try {
        const query = `select product_id, title, min_selling_price, image_url 
                            from ProductBasicView
                            where title like $1
                            order by min_selling_price 
                            limit 99`;
        const values = [
            `%${searchQuery
                .replace('!', '!!')
                .replace('%', '!%')
                .replace('_', '!_')
                .replace('[', '![')}%`];

        const out = await connection.query(query, values);
        const result = out.rows.map((el) => {
            const o = { ...el };
            o.id = o.product_id;
            o.show = true;
            o.price = o.min_selling_price - 0;
            o.image = o.image_url;
            return o;
        });
        return { result, topprice: result.length === 0 ? 10000 : result[result.length - 1].price };
    } catch (err) {
        helper.errorResponse(res, err.message);
        return null;
    }
};

module.exports = { getAllItems, getProductsFromCategory, getProductsFromQuery };
