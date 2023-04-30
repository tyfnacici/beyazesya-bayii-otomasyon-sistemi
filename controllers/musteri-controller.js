const connection = require("../service/connection.js");

exports.musterileriGetir = async (req, res) => {
  const q = "SELECT * FROM musteriler";
  connection.query(q, (error, data) => {
    if (error) return res.status(500).json({ message: error });
    return res.json(data);
  });
};

exports.musteriOlustur = async (req, res) => {
  const q = `INSERT INTO musteriler (ad, soyad, adres, telefon_numarasi) VALUES (?)`;
  const values = [
    req.body.ad,
    req.body.soyad,
    req.body.adres,
    req.body.telefon_numarasi,
  ];
  connection.query(q, [values], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    return res.json("Müşteri başarıyla oluşturuldu.");
  });
};

exports.musteriGuncelle = async (req, res) => {
  const { id } = req.params.id;
  const values = req.body;
  const q = "UPDATE musteriler SET ? WHERE id = ?";
  connection.query(q, [values, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    return res.json(data);
  });
};
