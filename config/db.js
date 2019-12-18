const { Pool } = require('pg');

const pool = new Pool({
    user: 'neomerce_app',
    host: 'localhost',
    database: 'neomerce',
    password: 'password',
    port: 5432,
});

module.exports = pool;
