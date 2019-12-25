const connection = require('../config/db');


const getProductAttributes = async (req, res, productId) => {
    const query = `select attribute_name as key, attribute_value as value 
                    from ProductAttribute
                    where product_id = $1`;
    const out = await connection.query(query, [productId]);
    return out.rows;
};

const getVariantAttributes = async (req, res, productId) => {
    const query = `select variant_id, attribute_name as key, attribute_value as value
                    from VariantAttribute natural join Variant
                    where product_id = $1`;
    const out = await connection.query(query, [productId]);
    return out.rows;
};

const getProduct = async (req, res, productId) => {
    const query = `select product_id, title, description, weight_kilos, brand 
                            from Product
                            where product_id = $1`;
    const out = await connection.query(query, [productId]);

    if (out.rows.length === 0) throw Error('No such product');
    const result = out.rows[0];

    result.attributes = await getProductAttributes(req, res, productId);
    return result;
};

const getProductsFromCategory = async (req, res, categoryId) => {
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
};


const getRelatedProducts = async (req, res, productId, limit) => {
    const query = `select distinct ProductBasicView.product_id, 
                        ProductBasicView.title, 
                        ProductBasicView.min_selling_price, 
                        ProductBasicView.image_url
                    from ProductBasicView, ProductCategory as child, ProductCategory as parent
                    where parent.product_id = $1 and 
                            parent.category_id = child.category_id and
                            parent.category_id not in (select distinct parent_id from category where parent_id is not null) and
                            child.product_id = ProductBasicView.product_id and
                            ProductBasicView.product_id != $1
                    order by ProductBasicView.min_selling_price
                    limit $2;`;
    const values = [productId, limit];
    const out = await connection.query(query, values);
    return out.rows;
};

const getRecentProducts = async (req, res, limit) => {
    const query = `select *
                    from ProductBasicView natural join Product
                    order by added_date
                    limit $1;`;
    const out = await connection.query(query, [limit]);
    return out.rows;
};

const getProductsFromQuery = async (req, res, searchQuery) => {
    const query = `select product_id, title, min_selling_price, image_url 
                            from ProductBasicView natural left outer join ProductTag
                            where tag_id in (select tag_id from tag where tag like $1) or title like $1
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
};


const getVariants = async (req, res, productId) => {
    const query = `select variant_id, quantity, title, selling_price, listed_price
                            from Variant
                            where product_id = $1`;
    const out = await connection.query(query, [productId]);
    const result = out.rows.map((el) => {
        const o = { ...el };
        o.id = o.variant_id;
        o.price = o.selling_price - 0;
        o.old_price = o.listed_price;
        o.amount = o.quantity;
        return o;
    });

    const attributes = await getVariantAttributes(req, res, productId);
    return { result, attributes };
};

module.exports = {
    getProduct,
    getProductsFromCategory,
    getProductsFromQuery,
    getVariants,
    getRelatedProducts,
    getRecentProducts,
};
