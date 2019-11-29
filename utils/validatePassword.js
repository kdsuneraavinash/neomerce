const crypto = require('crypto');

const hashPassword = (password) => crypto.pbkdf2Sync(password, process.env.SALT, 10000, 512, 'sha512').toString('hex');


const validatePassword = (givenPassword, hashedPassword) => {
    const hash = hashPassword(givenPassword);
    return hash === hashedPassword;
};

module.exports = { validatePassword, hashPassword };
