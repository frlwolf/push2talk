
const express = require("express");

const app = express()

app.use(express.json());
app.post('/login', (req, res, next) => {
    res.json({ token: "123456" });
});

module.exports = app;
