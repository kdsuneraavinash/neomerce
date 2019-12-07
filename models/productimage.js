const connection = require('../config/db');
const helper = require('./helper');


const getImages = async (req, res, productId) => {
    try {
        const query = `select image_url 
                            from ProductImage
                            where product_id = $1`;
        const values = [productId];
        const out = await connection.query(query, values);
        const result = out.rows.map((v) => v.image_url);
        return result;
    } catch (err) {
        helper.errorResponse(res, err.message);
        return null;
    }
};


module.exports = { getImages };
