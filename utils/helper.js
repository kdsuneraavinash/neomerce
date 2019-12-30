const errorResponse = (res, message) => {
    let failed = message;
    if (message.message) {
        failed = message.message;
    }
    res.render('error', {
        code: 400,
        failed,
    });
};

module.exports = { errorResponse };
