const router = require('express').Router();
const Report = require('../models/report');
const Admin = require('../models/admin');

const adminAuthChecker = async (req, res, next) => {
    req.name = 'Guest';
    if (req.session.user && req.session.cookie) {
        const { permission, name } = await Report.reportViewPermissionChecker(req.sessionID);
        if (permission) {
            req.name = name;
            next();
            return;
        }
    }
    // TODO: Enable Auth Checker
    // res.redirect('/');
    next();
};

router.use(adminAuthChecker);

router.get('/example/', async (req, res) => {
    res.render('reports/example', { name: req.name });
});

router.get('/sales/', async (req, res) => {
    const date = new Date();
    const year = date.getFullYear();
    const month = date.getMonth();
    const quarter = Math.floor(month / 3);
    const quarterReport = await Report.getProductQuarterReport(year, quarter);
    const products = await Report.getProductCounts();
    const sales = await Report.getSalesReport();
    const quarterlySales = await Report.getQuarterlySalesReport();
    res.render('reports/sales_report',
        {
            products, name: req.name, sales, quarterlySales, quarterReport,
        });
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

        res.render('reports/product_report', {
            visitedItems,
            orderedItems,
            productData,
            variantData,
            monthlyData,
            name: req.name,
        });
    } catch (error) {
        res.redirect('/admin/product?error=Product retrieval failed');
    }
});

router.get('/category/', async (req, res) => {
    const { categoryData, categoryParents, tree } = await Report.getCategoryTreeReport();
    const topCategoryData = await Report.getTopCategoryLeafNodes();
    res.render('reports/category_report', {
        topCategoryData,
        categoryData,
        categoryParents,
        tree,
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
        res.redirect(`/admin/time?error=${error}`);
    }
});


router.get('/order/', async (req, res) => {
    const orders = await Report.getOrderReport();
    res.render('reports/order_report', { name: req.name, orders });
});

router.get('/addproducts/', async (req, res) => {
    try {
        const products = await Admin.getAllProducts();
        const categories = await Admin.getAllLeafCategories();
        res.render('reports/add_products', {
            name: req.name,
            error: req.query.error,
            success: req.query.success,
            categories,
            products,
        });
    } catch (error) {
        res.redirect(`/admin/addproducts?error=${error}`);
    }
});

router.get('/addvariants/', async (req, res) => {
    try {
        const products = await Admin.getAllProducts();
        const categories = await Admin.getAllCategories();
        res.render('reports/add_variants', {
            name: req.name,
            error: req.query.error,
            success: req.query.success,
            products,
            categories,
        });
    } catch (error) {
        res.redirect(`/admin/addvariants?error=${error}`);
    }
});

router.post('/add/product/', async (req, res) => {
    try {
        await Admin.addProduct(
            req.body.title,
            req.body.description,
            req.body.weight,
            req.body.brand,
            req.body.default_variant_title,
            req.body.default_variant_quantity,
            req.body.default_variant_sku_id,
            req.body.default_variant_listed_price,
            req.body.default_variant_selling_price,
            req.body.default_image_url,
            req.body.default_leaf_category_id,
        );
        res.redirect('/admin/addproducts?success=Product added successfully');
    } catch (error) {
        res.redirect(`/admin/addproducts?error=${error}`);
    }
});

router.post('/add/variant/', async (req, res) => {
    try {
        await Admin.addVariant(
            req.body.product,
            req.body.variant_title,
            req.body.variant_quantity,
            req.body.variant_sku_id,
            req.body.variant_listed_price,
            req.body.variant_selling_price,
        );
        res.redirect('/admin/addvariants?success=Variant added successfully');
    } catch (error) {
        res.redirect(`/admin/addvariants?error=${error}`);
    }
});

router.post('/add/category/', async (req, res) => {
    try {
        await Admin.addCategory(
            req.body.parent,
            req.body.category,
        );
        res.redirect('/admin/addvariants?success=Category added successfully');
    } catch (error) {
        res.redirect(`/admin/addvariants?error=${error}`);
    }
});

router.post('/add/image/', async (req, res) => {
    try {
        await Admin.addImage(
            req.body.product,
            req.body.image,
        );
        res.redirect('/admin/addvariants?success=Image added successfully');
    } catch (error) {
        res.redirect(`/admin/addvariants?error=${error}`);
    }
});

router.post('/add/tags/', async (req, res) => {
    try {
        const ignored = await Admin.addTags(
            req.body.product,
            req.body.tags.split(' '),
        );
        if (ignored.length) {
            throw Error(`Adding failed. Ignored: ${ignored.join(', ')}`);
        }
        res.redirect('/admin/addproducts?success=Tags added successfully');
    } catch (error) {
        res.redirect(`/admin/addproducts?error=${error}`);
    }
});


module.exports = router;
