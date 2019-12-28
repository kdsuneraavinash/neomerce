const connection = require('../config/db');


const getProductCounts = async () => {
    const query = `select product.product_id, product.title,sum(orderitem.quantity) as quantity,sum(orderitem.quantity)*sum(variant.selling_price)  as income 
    from product, variant, orderitem
    where orderitem.variant_id = variant.variant_id and variant.product_id = product.product_id
    group by product.product_id
    order by quantity desc`;

    const out = await connection.query(query);
    // console.log(out.rows);
    const items = [];
    const itemsWithQuantity = [];
    out.rows.forEach((i) => {
        const item = [];
        item.push(i.product_id);
        item.push(i.title);
        item.push(i.quantity);
        item.push(i.income);

        items.push(item);

        itemsWithQuantity.push({
            label: i.title,
            value: parseInt(i.quantity, 10),
        });
    });
    return [items, out.rowCount, itemsWithQuantity];
};

const getCategoryReport = async () => {
    const query = `
    select category.category_id,category.title,category.parent_id,sum(categoryjoin.quantity),sum(categoryjoin.income) 
    from (
        select productdetails.product_id,productdetails.title,productdetails.quantity,productdetails.income,productcategory.category_id 
        from (
            select product.product_id, product.title,sum(orderitem.quantity) as quantity,sum(orderitem.quantity)*sum(variant.selling_price)  as income 
            from product, variant, orderitem
            where orderitem.variant_id = variant.variant_id and variant.product_id = product.product_id
            group by product.product_id
            order by quantity desc
        ) as productdetails
        join productcategory on productdetails.product_id=productcategory.product_id
    ) as categoryjoin 
    join category on categoryjoin.category_id=category.category_id
    group by category.category_id
`;

    const out = await connection.query(query);
    console.log(out.rows);
    return null;
};

module.exports = { getProductCounts, getCategoryReport };
