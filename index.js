const express = require('express');
const session = require('express-session');
const cors = require('cors');

/* Make all variables from our .env file available in our process */
require('dotenv').config();

/* Init express */
const app = express();

/* Set view engine */
app.set('view engine', 'ejs');

/* Setup the middlewares & configs */
app.use(cors());
app.use(session({
    secret: process.env.SESSION_SECRET,
    cookie: { maxAge: 60000 },
    resave: false,
    saveUninitialized: false,
}));

/* Define the static files and routes */
app.use('/css', express.static('public/css'));
app.use('/js', express.static('public/js'));
app.use('/fonts', express.static('public/fonts'));
app.use('/img', express.static('public/img'));
app.use(require('./routes'));

const port = process.env.PORT || 3000;
const address = process.env.SERVER_ADDRESS || '127.0.0.1';

/* Listen on the port for requests */
app.listen(port, address, () => console.log(`Server running on http://${address}:${port}`));


module.exports = app;
