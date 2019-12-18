const connection = require('../config/db');


const getImages = async (req, res, productId) => {
    const query = `select image_url 
                            from ProductImage
                            where product_id = $1`;
    const values = [productId];
    const out = await connection.query(query, values);
    const result = out.rows.map((v) => v.image_url);
    return result;
};


module.exports = { getImages };
