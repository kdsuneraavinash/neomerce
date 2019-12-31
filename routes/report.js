const router = require('express').Router();
const Report = require('../models/report');

// const adminAuthChecker = async (req, res, next) => {
//     if (req.session.user && req.session.cookie) {
//         const { permission, name } = await Report.reportViewPermissionChecker(req.sessionID);
//         if (permission) {
//             req.name = name;
//             next();
//             return;
//         }
//     }
//     res.redirect('/');
// };

// router.use(adminAuthChecker);

router.get('/example/', async (req, res) => {
    res.render('reports/example', { name: req.name });
});

router.get('/sales/', async (req, res) => {
    const products = await Report.getProductCounts();
    const sales = await Report.getSalesReport();
    const quarterlySales = await Report.getQuarterlySalesReport();
    res.render('reports/sales_report', { products, name: req.name, sales: sales, quarterlySales: quarterlySales });
});

router.get('/product/', async (req, res) => {
    const productId = req.query.id;
    if (!productId) {
        const products = await Report.getProducts();
        res.render('reports/product_report_overview', { products, error: req.query.error, name: req.name });
        return;
    }

    try {
        const { productData, variantData } = await Report.getProductData(productId);
        const visitedItems = await Report.getProductVisitedCountReport(productId);
        const orderedItems = await Report.getProductOrderedCountReport(productId);
        const monthlyData = await Report.getProductMonthlyOrdersReport(productId);

        visitedItems.forEach((value, index) => {
            if (index === 0) return;
            visitedItems[index].value += visitedItems[index - 1].value;
        });
        orderedItems.forEach((value, index) => {
            if (index === 0) return;
            orderedItems[index].value += orderedItems[index - 1].value;
        });

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

        res.render('reports/product_report', {
            visitedItems,
            orderedItems,
            productData,
            variantData,
            monthlyData,
            name: req.name,
        });
    } catch (error) {
        res.redirect(`/report/product?error=${error}`);
    }
});

router.get('/category/', async (req, res) => {
    const { categoryData, categoryParents } = await Report.getCategoryTreeReport();
    const topCategoryData = await Report.getTopCategoryLeafNodes();
    res.render('reports/category_report', {
        topCategoryData,
        categoryData,
        categoryParents,
        name: req.name,
    });
});


router.get('/time/', async (req, res) => {
    try {
        const timerange = req.query.daterange;
        if (timerange == null) {
            res.render('reports/time_report', { error: req.query.error, timerange: null, name: req.name });
            return;
        }
        const [time1str, time2str] = timerange.split('-');
        if (time1str === undefined || time2str === undefined) {
            throw Error('Invalid data format');
        }
        const time1 = new Date(time1str);
        const time2 = new Date(time2str);
        const products = await Report.getPopularProductsBetweenDates(time1,
            time2);
        res.render('reports/time_report', {
            products,
            error: req.query.error,
            timerange,
            name: req.name,
        });
    } catch (error) {
        res.redirect(`/report/time?error=${error}`);
    }
});


router.get('/order/', async (req, res) => {
    const orders = await Report.getOrderReport();
    res.render('reports/order_report', { name: res.name, orders: orders });
});

module.exports = router;
