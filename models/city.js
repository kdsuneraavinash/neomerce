const connection = require('../config/db');

const getCities = async (search) => {
    const query = `select city, delivery_days, delivery_charge 
                    from city natural join citytype 
                    where lower(city.city) like $1
                    limit 5`;
    const values = [
        `%${search
            .replace('!', '!!')
            .replace('%', '!%')
            .replace('_', '!_')
            .replace('[', '![')}%`];
    const out = await connection.query(query, values);
    return out.rows;
};

const cityExists = async (city) => {
    const queryString = 'select city, delivery_days, delivery_charge from city natural join citytype where city = $1';
    const values = [city];
    const out = await connection.query(queryString, values);
    return {
        result: out.rows.length !== 0,
        data: out.rows,
    };
};

module.exports = { getCities, cityExists };
