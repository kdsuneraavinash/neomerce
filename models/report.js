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
        items.push([index + 1, value.title, value.quantity, value.income, value.product_id]);
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
        order by quantity desc
    `;
    const out = await connection.query(query);
    const items = [];
    const itemsWithQuantity = [];
    const itemsWithIncome = [];
    out.rows.forEach((value) => {
        items.push([value.title, value.category_id, value.quantity, value.income]);
        itemsWithQuantity.push({ label: value.title, value: value.quantity - 0 });
        itemsWithIncome.push({ label: value.title, value: value.income - 0 });
    });
    return [items, itemsWithQuantity, itemsWithIncome];
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


const getProductVisitedCountReport = async (productId) => {
    const query = `
    select ROW_NUMBER() over(order by visited_date) as count, visited_date 
        from visitedproduct 
        where product_id=$1 order by visited_date limit 100;
        `;

    const out = await connection.query(query, [productId]);
    const productVisits = [];
    out.rows.forEach((value) => {
        productVisits.push({
            date: new Date(value.visited_date),
            value: value.count - 0,
        });
    });

    productVisits.push({
        date: new Date(),
        value: (productVisits.length) ? productVisits[productVisits.length - 1].value : 0,
    });
    return productVisits;
};


const getProductOrderedCountReport = async (productId) => {
    const query = `
            select orderdata.order_date
                from orderdata join orderitem using(order_id) join variant using(variant_id)
                where product_id=$1 order by order_date;
        `;

    const out = await connection.query(query, [productId]);
    const productOrders = [];
    out.rows.forEach((value, index) => {
        productOrders.push({
            date: new Date(value.order_date),
            value: index + 1,
        });
    });
    productOrders.push({
        date: new Date(),
        value: (productOrders.length) ? productOrders[productOrders.length - 1].value : 0,
    });
    return productOrders;
};

const getProductData = async (productId) => {
    const out = {};

    let query = 'select * from product where product_id=$1';

    [out.productData] = (await connection.query(query, [productId])).rows;

    query = `select variant_id, quantity, title, selling_price, listed_price
                from Variant
                where product_id = $1`;
    out.variantData = (await connection.query(query, [productId])).rows;
    return out;
};

const getProducts = async () => {
    const query = 'select * from productbasicview order by added_date';
    const out = await connection.query(query);
    return out.rows;
};


const getPopularProductsBetweenDates = async (date1, date2) => {
    const query = `select product.product_id, product.title, sum(orderitem.quantity) as quantity, sum(orderitem.quantity)*sum(variant.selling_price)  as income 
                        from product join variant using(product_id) join orderitem using(variant_id) join orderdata using (order_id) 
                        where orderdata.order_date between $1 and $2
                        group by product.product_id
                        order by quantity desc limit 10`;

    const out = await connection.query(query, [date1, date2]);
    const items = [];
    const itemsWithQuantity = [];
    out.rows.forEach((value, index) => {
        items.push([index + 1, value.title, value.quantity, value.income, value.product_id]);
        itemsWithQuantity.push({ label: `#${index + 1}`, value: value.quantity - 0 });
    });
    return [items, itemsWithQuantity];
};

module.exports = {
    getProductCounts,
    getCategoryTreeReport,
    getTopCategoryLeafNodes,
    getProductVisitedCountReport,
    getProductOrderedCountReport,
    getProductData,
    getProducts,
    getPopularProductsBetweenDates,
};
