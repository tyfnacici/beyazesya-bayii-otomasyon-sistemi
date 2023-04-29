const express = require('express');
const musteri = require("./musteri.js");

const router = express.Router();

router.get('/', (req, res) => {
  res.send('Hello World!');
});

router.use('/api/musteri', musteri);

module.exports = router;