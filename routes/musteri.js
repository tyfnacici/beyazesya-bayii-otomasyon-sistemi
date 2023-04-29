const express = require("express");
const router = express.Router();
const connection = require("../service/connection.js");

router.get("/", async (req, res) => {
  const musteriGetir = "SELECT * FROM musteriler";
  try {
    connection.query(musteriGetir, (results) => {
      res.send(results);
    });
  } catch (error) {
    res.status(500).json({ message: error})
  }
});

router.post("/", async (req, res) => {
  try {
    const { ad, soyad, adres, telefon } = req.body;
    console.log(req.body)
    const musteriOlustur = `INSERT INTO musteriler (ad, soyad, adres, telefon_numarasi) VALUES (${ad}, ${soyad}, ${adres}, ${telefon})`;
    connection.query(musteriOlustur, (results) => {
      res.send(results);
    });
  } catch (error) {
    res.status(500).json({ message: error });
  }
});

module.exports = router;
