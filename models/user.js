const pool = require('../config/db')




const createUser = async (sessionID,email,firstName,lastName,addressLine1,addressLine2,city,postalCode,password) => {
    //const {body : {username,email,password}} = req;
    //const queryString = 'INSERT into userinformation(customer_id,email,first_name,last_name,addr_line1,addr_line2,city,postcode,dob,last_login) values ($1,$2,$3,$4,$5,$6,$7,$8,NOW(),NOW())'
    const queryString = 'CALL create_user($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
    const values = [sessionID,email,firstName,lastName,addressLine1,addressLine2,city,postalCode,new Date(),password]
    return new Promise((resolve,reject)=>{
      pool.query(queryString,values,(err, rows) => {
        if (err) {
          reject(err)
        } else {
          //req.session.user = {'username':username,'email':email,'password':password}
          resolve(true)
        }
      })
  
    })
  
  }


  const validatePassword = async(username,password) => {
    const queryString = 'SELECT accountcredential.password from userinformation,accountcredential where userinformation.email=$1 and userinformation.customer_id=accountcredential.customer_id'
    const values = [username]
    return new Promise((resolve,reject)=>{
      pool.query(queryString,values,(err, rows) => {
        if (err) {
          reject(err)
        } else {
          //req.session.user = {'username':username,'email':email,'password':password}
          //bcrypt compare
          resolve(rows.rows[0].password)
        }
      })
  
    })
  }


  const assignCustomerId = async (sessionID,username)=> {
    let queryString = 'CALL assign_customer_id($1,$2)'
    const values = [sessionID,username]
    return new Promise((resolve,reject)=>{
      pool.query(queryString,values,(err, rows) => {
        if (err) {
          reject(err)
        } else {
          //req.session.user = {'username':username,'email':email,'password':password}
          //bcrypt compare
          console.log('yaay')
          resolve(true)
        }
      })
  
    })
  }  




  module.exports  = {createUser,validatePassword,assignCustomerId}