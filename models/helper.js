const errorResponse = (res, message) => {
    res.json({
        code: 400,
        failed: message,
    });
};

const successResponse = (res, data) => {
    res.json({
        code: 200,
        data,
    });
};

module.exports = { errorResponse, successResponse };
