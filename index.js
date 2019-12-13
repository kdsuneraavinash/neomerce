const express = require('express');
const session = require('express-session');
const cors = require('cors');
const Ouch = require('ouch');
const bodyParser = require('body-parser')
const pgSession = require('connect-pg-simple')(session)
const pool = require('./config/db')
const auth = require('./utils/auth')

/* Make all variables from our .env file available in our process */
require('dotenv').config();

/* Init express */
const app = express();

/* Set view engine */
app.set('view engine', 'ejs');

/* Setup the middlewares & configs */
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());
app.use(session({
    key:'user_sid',
    // store: new pgSession({
    //   pool : pool,                // Connection pool
    //   tableName : 'sess'   // Use another table-name than the default "session" one
    // }),
    secret: 'test',
    resave: false,
    cookie: { maxAge: 600000}, // 30 days
    rolling:true
  }));


app.use((req, res, next) => {
    if (req.session.cookie && !req.session.user) {
        res.clearCookie('user_sid');
    }
    next();
});



app.use((req,res,next)=>{
    console.log(req.sessionID)
    auth.saveSession(req)
    next()
 }) 

// middleware function to check for logged-in users
var sessionChecker = (req, res, next) => {
    console.log(req.session.cookie)
    if (req.session.user && req.session.cookie) {
        res.redirect('/dashboard');
    } else {
        next();
    }    
};





/* Define the static files and routes */
app.use('/css', express.static('public/css'));
app.use('/js', express.static('public/js'));
app.use('/fonts', express.static('public/fonts'));
app.use('/img', express.static('public/img'));
app.use(require('./routes'));

const port = process.env.PORT || 3000;
const address = process.env.SERVER_ADDRESS || '127.0.0.1';

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, _) => {
    (new Ouch()).pushHandler(new Ouch.handlers.PrettyPageHandler('orange'))
        .handleException(err, req, res,
            () => {
                console.log(`Error occurred: ${err}`);
            });
});

/* Listen on the port for requests */
app.listen(port, address, () => console.log(`Server running on http://${address}:${port}`));

module.exports = app;
