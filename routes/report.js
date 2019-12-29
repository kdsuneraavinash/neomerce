const router = require('express').Router();
const Report = require('../models/report');

router.get('/example/', async (req, res) => {
    res.render('reports/example');
});

router.get('/sales/', async (req, res) => {
    const { products, productVsQuantity } = await Report.getProductCounts();
    res.render('reports/sales_report', {
        products,
        productVsQuantity,
    });
});

router.get('/product/', async (req, res) => {
    const productId = req.query.id;
    if (!productId) {
        const products = await Report.getProducts();
        res.render('reports/product_report_overview', { products, error: req.query.error });
        return;
    }

    try {
        const { productData, variantData } = await Report.getProductData(productId);
        const productVisitedReport = await Report.getProductVisitedCountReport(productId);
        const productOrderedReport = await Report.getProductOrderedCountReport(productId);
        productVisitedReport.unshift({ date: productData.added_date, value: 0 });
        productOrderedReport.unshift({ date: productData.added_date, value: 0 });
        res.render('reports/product_report', {
            visitedItems: productVisitedReport,
            orderedItems: productOrderedReport,
            productData,
            variantData,
        });
    } catch (error) {
        res.redirect(`/report/product?error=${error}`);
    }
});

router.get('/category/', async (req, res) => {
    const { categoryData, categoryParents } = await Report.getCategoryTreeReport();
    const {
        topCategoryData,
        topCategoryVsQuantity,
        topCategoryVsIncome,
    } = await Report.getTopCategoryLeafNodes();
    res.render('reports/category_report', {
        topCategoryData,
        topCategoryVsQuantity,
        topCategoryVsIncome,
        categoryData,
        categoryParents,
    });
});


router.get('/time/', async (req, res) => {
    try {
        const timerange = req.query.daterange;
        if (timerange == null) {
            res.render('reports/time_report', { error: req.query.error, timerange: null });
            return;
        }
        const [time1str, time2str] = timerange.split('-');
        if (time1str === undefined || time2str === undefined) {
            throw Error('Invalid data format');
        }
        const time1 = new Date(time1str);
        const time2 = new Date(time2str);
        const { products, productVsQuantity } = await Report.getPopularProductsBetweenDates(time1,
            time2);
        res.render('reports/time_report', {
            products,
            productVsQuantity,
            error: req.query.error,
            timerange,
        });
    } catch (error) {
        res.redirect(`/report/time?error=${error}`);
    }
});


router.get('/order/', async (req, res) => {
    res.render('reports/order_report');
});

module.exports = router;
