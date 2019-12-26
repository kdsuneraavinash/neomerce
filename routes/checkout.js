const router = require('express').Router();
const Cart = require('../models/cart')

router.get('/', async (req, res) => {

    let result =await Cart.checkStock(req.sessionID)

    if(result == null){
        
        let proceedCheckOutObj =await Cart.proceedCheckOut(req.sessionID,req.session.user)

        res.render('checkout', {
            loggedIn: req.session.user != null,
            proceedCheckOutObj:proceedCheckOutObj
        });































    }else{
        res.redirect(`/cart?error=${result}`)
    }



























    
  
});

module.exports = router;
