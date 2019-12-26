const connection = require('../config/db');



const createOrder = async(sessionID) => {

    const createOrderQueryString = 'CALL placeOrder($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)'
    const createOrderValues = [sessionID,'Lahiru','Udayanga','lahiru@gmail.com','0775930399','shop_pickup','5B','POl','Colombo','12400','cash']
    await connection.query(createOrderQueryString,createOrderValues)








}


module.exports = {createOrder}