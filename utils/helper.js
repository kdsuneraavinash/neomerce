const errorResponse = (res, message) => {
    let failed = message;
    if (message.message) {
        failed = message.message;
    }
    res.json({
        code: 400,
        failed,
    });
};

const successResponse = (res, data) => {
    res.json({
        code: 200,
        data,
    });
};

module.exports = { errorResponse, successResponse };
