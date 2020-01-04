const express = require('express');
const helmet = require('helmet');
const session = require('express-session');
const PgSession = require('connect-pg-simple')(session);
const cors = require('cors');
const Ouch = require('ouch');
const bodyParser = require('body-parser');
const helper = require('./utils/helper');

/* Make all variables from our .env file available in our process */
require('dotenv').config();

const pool = require('./config/db');
const auth = require('./utils/auth');

/* Init express */
const app = express();

/* Init helmet */
app.use(helmet());

/* Set view engine */
app.set('view engine', 'ejs');

/* Setup the middlewares & configs */
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cors());
app.use(session({
    store: new PgSession({
        pool,
        tableName: 'session_data',
    }),
    saveUninitialized: false,
    secret: process.env.SESSION_SECRET,
    resave: false,
    cookie: { maxAge: 30 * 24 * 60 * 60 * 1000 },
}));


/*
Middleware to save the sessions in the database.
customer and session tables will be updated if a new session get created
*/
app.use(auth.saveSession);


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
