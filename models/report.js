const connection = require('../config/db');


const getProductCounts = async () => {
    const query = `select product.product_id, product.title,sum(orderitem.quantity) as quantity,sum(orderitem.quantity)*sum(variant.selling_price)  as income 
                    from product, variant, orderitem
                    where 
                        orderitem.variant_id = variant.variant_id and 
                        variant.product_id = product.product_id
                    group by product.product_id
                    order by quantity desc limit 10`;

    const out = await connection.query(query);
    const items = [];
    const itemsWithQuantity = [];
    out.rows.forEach((value, index) => {
        items.push([index + 1, value.title, value.quantity, value.income]);
        itemsWithQuantity.push({ label: `#${index + 1}`, value: value.quantity - 0 });
    });
    return [items, itemsWithQuantity];
};


const getTopCategoryLeafNodes = async () => {
    const query = `
        select allcategories.category_id,allcategories.title,allcategories.quantity,allcategories.income 
    from (
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
        ) as allcategories 
        join (select * from category where category_id not in (select distinct parent_id from category where parent_id is not null)) as leafnodes
        on allcategories.category_id = leafnodes.category_id
        order by quantity desc limit 10
    `;
    const out = await connection.query(query);
    const items = [];
    const itemsWithQuantity = [];
    out.rows.forEach((value) => {
        items.push([value.title, value.quantity, value.income]);
        itemsWithQuantity.push({ label: value.title, value: value.quantity - 0 });
    });
    return [items, itemsWithQuantity];
};


const getCategoryTreeReport = async () => {
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
    const treeItems = [];
    const treeItemParents = [];
    out.rows.forEach((value) => {
        treeItems.push([value.title, value.quantity, value.income]);
        treeItemParents.push([value.category_id, value.parent_id]);
    });
    return [treeItems, treeItemParents];
};


module.exports = { getProductCounts, getCategoryTreeReport, getTopCategoryLeafNodes };
