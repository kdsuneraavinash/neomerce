const router = require('express').Router()
const UUID = require('uuid/v4')
const User = require('../models/user')



router.get('/register',(req,res)=>{

    res.render('register')

    // TODO remove register button after log in


})


router.post('/register',async (req,res)=>{


    // TODO validation here

    console.log(req.body)
    const {body : {username,password,firstName,lastName,addressLine1,addressLine2,city,postalCode}} = req;
    try {
        const result = await User.createUser(req.sessionID,username,firstName,lastName,addressLine1,addressLine2,city,postalCode,password)
        if(true){
            req.session.user = true;
            // send dashboard
        }else{
            //redirect sign up
        }
    } catch (error) {
        console.log(error)
        // redirect sign up
    }
    
    






})












module.exports = router;