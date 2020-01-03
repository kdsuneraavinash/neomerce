const express = require('express');
const session = require('express-session');
const cors = require('cors');
const Ouch = require('ouch');
const bodyParser = require('body-parser');
const helper = require('./utils/helper');

/* Make all variables from our .env file available in our process */
require('dotenv').config();

const auth = require('./utils/auth');

/* Init express */
const app = express();

/* Set view engine */
app.set('view engine', 'ejs');

app.use(async (req, res, next) => {
    console.log(`LOG: Handling request for ${req.protocol}://${req.get('host')}${req.originalUrl}`);
    next();
});

/* Setup the middlewares & configs */
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cors());
app.use(session({
    saveUninitialized: true,
    key: 'user_sid',
    secret: 'test',
    resave: false,
    cookie: { maxAge: 86400000 }, // 1 day
    rolling: true,
}));


/*
Middleware to save the sessions in the database.
customer and session tables will be updated if a new session get created
*/
app.use(async (req, res, next) => {
    await auth.saveSession(req, res);
    next();
});


/* Define the static files and routes */
app.use('/css', express.static('public/css'));
app.use('/js', express.static('public/js'));
app.use('/fonts', express.static('public/fonts'));
app.use('/img', express.static('public/img'));
app.use(require('./routes'));

app.get('*', (req, res) => {
    res.status(404).render('error', { code: 404, failed: 'OOPS! Not found' });
});

app.use((err, req, res) => {
    (new Ouch()).pushHandler(new Ouch.handlers.CallbackHandler((next, exception,
        inspector, run, request, response) => {
        helper.errorResponse(response, 'Internal Server Error', 500);
    }))
        .handleException(err, req, res,
            () => {
                console.log(`Error occurred: ${err}`);
            });
});

/* Listen on the port for requests */
app.listen(process.env.PORT || 3000, () => {
    console.log('Express server listening on port %d in %s mode', process.env.PORT, app.settings.env);
});
module.exports = app;
