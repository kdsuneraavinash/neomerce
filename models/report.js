const connection = require('../config/db');


const getProductCounts = async () => {
    const query = `select product.product_id, product.title,sum(orderitem.quantity) as quantity,sum(orderitem.quantity)*sum(variant.selling_price)  as income 
    from product, variant, orderitem
    where orderitem.variant_id = variant.variant_id and variant.product_id = product.product_id
    group by product.product_id
    order by quantity desc limit 10`;

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
    select category.category_id,category.title,category.parent_id,sum(categoryjoin.quantity) as quantity,sum(categoryjoin.income) as income
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
    // console.log(out.rows);
    const items = [];
    const treeItems = [];
    const treeItemParents = [];
    out.rows.forEach((i) => {
        const item = [];
        const treeItem = [];
        const treeItemParent = [];

        item.push(i.category_id);
        item.push(i.title);
        item.push(i.parent_id);
        item.push(i.quantity);
        item.push(i.income);

        treeItem.push(i.title);
        treeItem.push(i.quantity);
        treeItem.push(i.income);

        treeItemParent.push(i.category_id);
        treeItemParent.push(i.parent_id);

        items.push(item);
        treeItems.push(treeItem);
        treeItemParents.push(treeItemParent);
    });
    console.log('treeItems: ');
    console.log(treeItems);
    console.log('parents: ');
    console.log(treeItemParents);

    return [items, out.rowCount, treeItems, treeItemParents, treeItems.length];
};

module.exports = { getProductCounts, getCategoryReport };
