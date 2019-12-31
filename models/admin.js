const connection = require('../config/db');

const getAllProducts = async () => {
    const query = 'select product_id, title from product order by added_date desc';
    const out = await connection.query(query);
    return out.rows;
};

const getAllLeafCategories = async () => {
    const query = `select category_id, title from category 
                        where category_id not in 
                                (select parent_id from category where parent_id is not null)`;
    const out = await connection.query(query);
    return out.rows;
};

const getAllCategories = async () => {
    const query = 'select category_id, title from category';
    const out = await connection.query(query);
    return out.rows;
};

const addProduct = async (title, description, weight, brand,
    variantTitle, variantQuantity, variantSKU, variantListed, variantSelling, image, category) => {
    const query = 'CALL addProduct($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)';
    const values = [null, null, title, description, weight, brand,
        variantTitle, variantQuantity, variantSKU, variantListed, variantSelling, image, category];
    await connection.query(query, values);
};

const addVariant = async (product,
    variantTitle,
    variantQuantity,
    variantSkuId,
    variantListedPrice,
    revariantSellingPrice) => {
    const query = 'CALL addVariant($1, $2, $3, $4, $5, $6)';
    const values = [product, variantTitle, variantQuantity, variantSkuId,
        variantListedPrice, revariantSellingPrice];
    await connection.query(query, values);
};

const addCategory = async (parent, category) => {
    const query = 'insert into Category values (default, $1, $2)';
    const values = [category, parent];
    await connection.query(query, values);
};

const addImage = async (product, image) => {
    const query = 'insert into ProductImage values (default, $1, $2)';
    const values = [product, image];
    await connection.query(query, values);
};

const addTags = async (product, tags) => {
    const ignored = [];
    tags.forEach(async (tag) => {
        try {
            const query = 'call addTagToCategory($1, $2)';
            const values = [product, tag];
            await connection.query(query, values);
        } catch (error) {
            ignored.push(tag);
        }
    });
    return ignored;
};

module.exports = {
    getAllProducts,
    getAllLeafCategories,
    addProduct,
    addVariant,
    getAllCategories,
    addCategory,
    addImage,
    addTags,
};
