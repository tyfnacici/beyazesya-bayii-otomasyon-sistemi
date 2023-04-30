const express = require("express");
const router = express.Router();
const connection = require("../service/connection.js");

router.get("/", async (req, res) => {
  try {
    const musteriGetir = "SELECT * FROM musteriler";
    connection.query(musteriGetir, (error, results, fields) => {
      res.send(results);
    });
  } catch (error) {
    res.status(500).json({ message: error})
  }
});

router.post("/", async (req, res) => {
  try {
    const { ad, soyad, adres, telefon_numarasi } = req.body;
    const musteriOlustur = `INSERT INTO musteriler (ad, soyad, adres, telefon_numarasi) VALUES (${ad}, ${soyad}, ${adres}, ${telefon_numarasi})`;
     connection.query(musteriOlustur, (error, results, fields) => {
      res.send(results);
     });
  } catch (error) {
    res.status(500).json({ message: error });
  }
});

module.exports = router;
