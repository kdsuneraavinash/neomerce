const router = require('express').Router()
const User = require('../models/user')
const bcrypt = require('bcrypt')



/* GET endpoint for user registration. Render the user registration page upon request */
router.get('/register',(req,res)=>{

    res.render('register')

    


})

/* POST endpoint for user registration.*/
router.post('/register',async (req,res)=>{

    // TODO validation here

    console.log(req.body)
    const {body : {username,password,firstName,lastName,addressLine1,addressLine2,city,postalCode}} = req;
    let encryptedPassword = bcrypt.hashSync(password,10)
    try {
        const result = await User.createUser(req.sessionID,username,firstName,lastName,addressLine1,addressLine2,city,postalCode,encryptedPassword)
        if(result){
            req.session.user = true;
            res.redirect('/')
            // send dashboard
        }else{
            res.render('register')
            //redirect sign up
        }
    } catch (error) {
        console.log(error)
        res.render('register')
        // redirect sign up
    }

})

router.get('/logout',(req,res)=>{
    if (req.session.user && req.session.cookie) {
        console.log('HERE destroy')
        res.clearCookie('user_sid');
        req.session.destroy()
        res.redirect('/')
    } else {
        console.log('HERE')
        res.render('index')
    }



})


router.get('/login',(req,res)=>{

    res.render('login')

    // TODO remove register button after log in


})


router.post('/login',async (req,res)=>{

    const{body:{username,password}} = req
    console.log(username)
    console.log(password)
    try {
        let result1 = await User.validatePassword(username,password)
        console.log(result1)
        if(!result1){
            res.redirect('/')
        }else{
            console.log('pass')
            try {
                let result2 = await User.assignCustomerId(req.sessionID,username)
                if(result2){
                    req.session.user = true;
                    res.redirect('/')
                }else{
                    res.redirect('/login')
                }
            } catch (error) {
                console.log(error)
            }
            
        }
    } catch (error) {
        console.log(error)
    }

})


router.get('/check/:username',async (req,res)=>{
    let result = await User.checkUsername(req.params.username)
    if(result){
        res.send('Username Exist')
    }else{
        res.send('Username Valid')
    }

})















module.exports = router;