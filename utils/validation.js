const Joi = require('@hapi/joi')
const helper = require('../utils/helper')
const City = require('../models/city')

const validateRegistration = async (req,res,next) => {
    const {body:{email,password,retype_password,firstName,lastName,addressLine1,addressLine2,telephoneNumber,city,postalCode}} = req
    const cityList = await City.getAllCities()
    const schema = Joi.object({
        email: Joi.string().email({ minDomainSegments: 2, tlds: { allow: ['com', 'net'] } }).required(),
        password:Joi.string().pattern(new RegExp('^[a-zA-Z0-9]{3,30}$')).required(),
        retype_password:Joi.any().valid(Joi.ref('password')).required(),
        first_name:Joi.string().max(255).required(),
        last_name: Joi.string().max(255).required(),
        addr_line1:Joi.string().required().max(255),
        addr_line2:Joi.string().required().max(255),
        phone_number:Joi.string().max(15).required(),
        city:Joi.string().valid(...cityList).required().max(127),
        postalCode:Joi.string().required()
    })

    try{
        await schema.validateAsync({email:email,password:password,retype_password:retype_password,first_name:firstName,last_name:lastName,addr_line1:addressLine1,addr_line2:addressLine2,phone_number:telephoneNumber,postalCode:postalCode,city:'Horana'})
        next()
    }catch(err){
        helper.errorResponse(res,err)
    }
    
}


module.exports = {validateRegistration}