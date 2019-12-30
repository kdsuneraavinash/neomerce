const connection = require('../config/db');

const getCities = async (search) => {
    const query = `select city, delivery_days, delivery_charge 
                    from city natural join citytype 
                    where lower(city.city) like lower($1)
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


const getAllCities = async ()=> {
    const queryString = 'SELECT city from city'
    const result = await connection.query(queryString)
    let cities=[];
    result.rows.forEach(element => {
        cities.push(element.city)
    });
    return cities
}

module.exports = { getCities, cityExists ,getAllCities};
