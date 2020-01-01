const connection = require('../config/db');

const createCategoryDataset = (categoryData, categoryParents) => {
    for (let i = 0; i < categoryData.length; i += 1) {
        categoryParents[i].push(categoryData[i]);
    }

    function traverse(parent) {
        const nodes = categoryParents
            .filter((v) => v[1] === parent.id)
            .map((v) => ({
                id: v[0],
                value: v[4][2],
                name: v[4][0],
                fixed: parent.id === null,
            }));
        // eslint-disable-next-line no-param-reassign
        parent.children = nodes;
        nodes.forEach(((node) => {
            traverse(node);
        }));
        return nodes;
    }

    const topNodes = traverse({ id: null });

    for (let i = 0; i < categoryData.length; i += 1) {
        categoryParents[i].pop();
    }

    return topNodes;
};

const orderCategoryNodes = (rows) => {
    let categoryData = rows.map((value) => [value.title, value.quantity - 0, value.income]);
    let categoryParents = rows.map((value) => [value.category_id, value.parent_id]);

    // Algorithm to reorganize tree nodes
    const orderedCategoryData = [];
    const orderedCategoryParents = [];

    for (let i = 0; i < categoryData.length; i += 1) {
        categoryParents[i].push(i);
    }

    function preOrderHelper(root, level) {
        // eslint-disable-next-line no-param-reassign
        level += 1;
        if (root !== null) {
            root.push(level);
            orderedCategoryData.push(root);
            // eslint-disable-next-line no-param-reassign
            [root] = root;
        }
        categoryParents.filter((v) => v[1] === root).forEach((v) => preOrderHelper(v, level));
    }

    preOrderHelper(null, -1);

    orderedCategoryData.forEach((parent) => {
        orderedCategoryParents.push(categoryData[parent[2]]);
    });

    categoryParents = orderedCategoryData;
    categoryData = orderedCategoryParents;

    return { categoryData, categoryParents };
};

const fillMissingMonths = (monthlyData) => {
    // Fill missing months
    const monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
    const monthDataMonths = monthlyData.map((v) => v.month - 0);
    for (let month = 1; month <= 12; month += 1) {
        if (monthDataMonths.indexOf(month) === -1) {
            monthlyData.push({ month, visits: 0, orders: 0 });
        }
    }
    monthlyData.sort((a, b) => a.month - b.month);
    monthlyData.forEach((v) => {
        // eslint-disable-next-line no-param-reassign
        v.index = v.month;
        // eslint-disable-next-line no-param-reassign
        v.month = monthNames[v.month - 1];
    });

    return monthlyData;
};


const dateDataField = (a, b) => ({ date: new Date(a), value: b - 0 });


const getQuarterlySalesReport = async () => {
    const query = `select extract(year from order_date) as year_of_date,
                        extract(quarter from order_date) as quarter, 
                        sum(orderitem.quantity) as number_of_sales
                    from orderitem 
                    join variant using(variant_id)
                    join orderdata using(order_id)
                    group by year_of_date,quarter`;
    const out = await connection.query(query);
    const quarterlySales = out.rows.map(
        // eslint-disable-next-line prefer-template
        (value) => ({ label: (value.year_of_date + ' - Q' + value.quarter), value: value.number_of_sales }),
    );
    return quarterlySales;
};

const getSalesReport = async () => {
    const query = `select Date(order_date),
                        sum(orderitem.quantity) as number_of_sales
                    from orderitem 
                    join variant using(variant_id)
                    join orderdata using(order_id)
                    group by Date(order_date)
                    order by Date(order_date)`;
    const out = await connection.query(query);
    const sales = out.rows.map(
        (value) => dateDataField(value.date, value.number_of_sales),
    );
    return sales;
};

const getProductCounts = async () => {
    const query = `select product.product_id, 
                        product.title, 
                        sum(orderitem.quantity) as quantity, 
                        sum(variant.selling_price*orderitem.quantity) as income
                    from product 
                        join variant using(product_id) 
                        join orderitem using(variant_id)
                    group by product.product_id
                    order by quantity desc limit 10`;
    const out = await connection.query(query);
    // eslint-disable-next-line no-param-reassign
    out.rows.forEach((v, i) => { v.index = i + 1; });
    return out.rows;
};


const getTopCategoryLeafNodes = async () => {
    const query = `select category_id, 
                        category.parent_id,
                        category.title,
                        sum(orderitem.quantity) as quantity, 
                        sum(variant.selling_price*orderitem.quantity) as income
                    from category
                        join productcategory using(category_id)
                        join variant using(product_id)
                        join orderitem using(variant_id)
                    where category_id not in (
                        select parent_id from category where parent_id is not null
                        )
                    group by category_id
                    order by quantity desc
                    limit 10;`;
    const out = await connection.query(query);
    return out.rows;
};


const getCategoryTreeReport = async () => {
    const query = `select category_id, 
                        category.parent_id,
                        category.title,
                        sum(orderitem.quantity) as quantity, 
                        sum(variant.selling_price*orderitem.quantity) as income
                    from category
                        join productcategory using(category_id)
                        join variant using(product_id)
                        join orderitem using(variant_id)
                    group by category_id`;
    const out = await connection.query(query);
    const { categoryData, categoryParents } = orderCategoryNodes(out.rows);
    const tree = createCategoryDataset(categoryData, categoryParents);
    return { categoryData, categoryParents, tree };
};


const getProductVisitedCountReport = async (productId) => {
    const query = `select date(visited_date) as  visited_day,
                        count(*)
                    from visitedproduct 
                    where product_id=$1 
                    group by visited_day
                    order by visited_day`;
    const out = await connection.query(query, [productId]);
    const productVisits = out.rows.map((value) => dateDataField(value.visited_day, value.count));
    return productVisits;
};


const getProductOrderedCountReport = async (productId) => {
    const query = `select date(orderdata.order_date) as order_day, 
                        count(orderitem.quantity) as sells
                    from orderdata 
                        join orderitem using(order_id) 
                        join variant using(variant_id)
                    where product_id=$1
                    group by order_day
                    order by order_day`;
    const out = await connection.query(query, [productId]);
    const productOrders = out.rows.map(
        (value) => dateDataField(value.order_day, value.sells),
    );
    return productOrders;
};

const getOrderReport = async () => {
    const query = `select date(order_date) as date ,
                        count(order_id) as order_count 
                    from orderdata
                    group by date
                    order by date`;
    const out = await connection.query(query);
    const productOrders = out.rows.map(
        (value) => dateDataField(value.date, value.order_count),
    );
    return productOrders;
};

const getAllOrders = async () => {
    const query = 'select order_id from orderdata;';
    const out = await connection.query(query);
    return out.rows;
};

const getProductMonthlyOrdersReport = async (productId) => {
    const query = `select * from
                (
                    select to_char(visited_date,'mm') as month,
                        count(*) as visits
                    from visitedproduct
                    where product_id=$1
                    group by month
                ) as visits_month full outer join
                (    
                    select to_char(orderdata.order_date, 'mm') as month,
                        count(*) as orders
                    from orderdata
                        join orderitem using(order_id)
                        join variant using(variant_id)
                    where product_id=$1
                    group by month
                ) as orders_month using(month)`;
    const out = await connection.query(query, [productId]);
    return fillMissingMonths(out.rows);
};

const getProductData = async (productId) => {
    const query1 = 'select * from product where product_id = $1';
    const out1 = await connection.query(query1, [productId]);
    const query2 = 'select * from Variant where product_id = $1';
    const out2 = await connection.query(query2, [productId]);
    return {
        productData: out1.rows[0],
        variantData: out2.rows,
    };
};

const getProducts = async () => {
    const query = 'select * from productbasicview order by added_date';
    const out = await connection.query(query);
    return out.rows;
};


const getPopularProductsBetweenDates = async (date1, date2) => {
    const query = `select product.product_id, 
                        product.title, 
                        sum(orderitem.quantity) as quantity,
                        sum(variant.selling_price*orderitem.quantity) as income
                    from product 
                        join variant using(product_id) 
                        join orderitem using(variant_id) 
                        join orderdata using(order_id)
                    where orderdata.order_date between $1 and $2
                    group by product.product_id
                    order by quantity desc limit 10`;

    const out = await connection.query(query, [date1, date2]);
    // eslint-disable-next-line no-param-reassign
    out.rows.forEach((v, i) => { v.index = i + 1; });
    return out.rows;
};

const reportViewPermissionChecker = async (sessionID) => {
    try {
        const queryString = `SELECT first_name || ' ' || last_name as name, account_type='admin' as permission 
                                from customer 
                                    join session using(customer_id)
                                    join userinformation using(customer_id)
                                where session_id=$1`;
        const values = [sessionID];
        const result = await connection.query(queryString, values);
        return result.rows[0] ? result.rows[0] : { permission: false, name: 'Guest' };
    } catch (e) {
        return { permission: false, name: 'Guest' };
    }
};

const getProductQuarterReport = async (year, quarter) => {
    const query = `select product_id, product.title, sum(orderitem.quantity) as quantity, 
        sum(orderitem.quantity*variant.selling_price) as income from 
        (select order_id from orderdata
        where extract(quarter from orderdata.order_date)=$1 and 
        extract(year from orderdata.order_date)=$2) as req_orders
            join orderitem using(order_id)
            join variant using(variant_id)
            join product using(product_id)
        group by product_id, product.title`;
    const out = await connection.query(query, [quarter + 1, year]);
    return out.rows;
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
    getProductMonthlyOrdersReport,
    reportViewPermissionChecker,
    getProductQuarterReport,
    getOrderReport,
    getSalesReport,
    getQuarterlySalesReport,
    getAllOrders,
};
