const express = require('express');
const session = require('express-session');
const cors = require('cors');
const Ouch = require('ouch');
const bodyParser = require('body-parser')
const auth = require('./utils/auth')

/* Make all variables from our .env file available in our process */
require('dotenv').config();

/* Init express */
const app = express();

/* Set view engine */
app.set('view engine', 'ejs');

/* Setup the middlewares & configs */
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json())
app.use(cors());
app.use(session({
    key:'user_sid',
    secret: 'test',
    resave: false,
    cookie: { maxAge: 86400000}, // 1 day
    rolling:true
  }));


/*This middleware will check if user's cookie is still saved in browser and user is not set, then automatically log the user out.*/
/* This usually happens when you stop your express server after login, your cookie still remains saved in the browser. */ 
app.use((req, res, next) => {
    if (req.session.cookie && !req.session.user) {
        res.clearCookie('user_sid');
    }
    next();
});


/*Middleware to save the sessions in the database. customer and session tables will be updated if a new session get created;*/
app.use((req,res,next)=>{
    auth.saveSession(req)
    next()
 }) 


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
