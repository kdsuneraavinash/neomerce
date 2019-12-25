const connection = require('../config/db');

const getCities = async () => {
    const query = 'select city from city';
    const out = await connection.query(query, []);
    return out.rows.map((v) => v.city);
};

module.exports = { getCities };
