const express = require('express');
const router = express.Router();
const connection = require('../service/connection.js');

router.get('/', (req, res) => {
  const musteriGetir = 'SELECT * FROM musteriler';
  connection.query(musteriGetir, (err, results, fields) => {
    if (err) throw err;
    res.send(results);
  });
});

module.exports = router;