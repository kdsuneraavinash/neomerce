const errorResponse = (res, message, code) => {
    let failed = message;
    if (message.message) {
        failed = message.message;
    }
    res.render('error', {
        code: code || 400,
        failed,
    });
};

module.exports = { errorResponse };
