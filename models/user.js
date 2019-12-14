const pool = require('../config/db')
const bcrypt = require('bcrypt')


const createUser = async (sessionID,email,firstName,lastName,addressLine1,addressLine2,city,postalCode,password) => {
    const queryString = 'CALL create_user($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)'
    const values = [sessionID,email,firstName,lastName,addressLine1,addressLine2,city,postalCode,new Date(),password]
    return new Promise((resolve,reject)=>{
      pool.query(queryString,values,(err, rows) => {
        if (err) {
          reject(err)
        } else {
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
          console.log(err)
        } else {
          if(bcrypt.compareSync(password,rows.rows[0].password)){
            resolve(true)
          }else{
            resolve(false)
          }
          
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
          console.log('yaay')
          resolve(true)
        }
      })
  
    })
  }
  
  
  const checkUsername = async (username) => {

    const queryString = 'SELECT email from userinformation where email=$1'
    const values = [username]
    return new Promise((resolve,reject)=>{
      pool.query(queryString,values,(err, rows) => {
        if (err) {
          reject(err)
        } else {
          resolve(rows.rows[0])
        }
      })
  
    })
    


  }


  module.exports  = {createUser,validatePassword,assignCustomerId,checkUsername}