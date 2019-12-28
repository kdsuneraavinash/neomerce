const connection = require('../config/db');


const getProductCounts = async () => {
    const query = 'select product.product_id, product.title,sum(orderitem.quantity) as quantity from product,variant,orderitem where orderitem.variant_id = variant.variant_id and variant.product_id = product.product_id group by product.product_id order by quantity desc limit 10';
    const out = await connection.query(query);
    // console.log(out.rows);
    const items = [];
    const itemsWithQuantity = [];
    out.rows.forEach((i) => {
        const item = [];
        item.push(i.product_id);
        item.push(i.title);
        item.push(i.quantity);
        items.push(item);

        itemsWithQuantity.push({
            label: i.title,
            value: parseInt(i.quantity, 10),
        });
    });
    return [items, out.rowCount, itemsWithQuantity];
};


module.exports = { getProductCounts };
