const connection = require("../service/connection.js");

exports.musterileriGetir = async (req, res) => {
  const q = "SELECT * FROM musteriler";
  connection.query(q, (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Kullanıcı bulunamadı." });
    }
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
  const id = req.params.id;
  const values = req.body;
  const q = "UPDATE musteriler SET ? WHERE id = ?";
  connection.query(q, [values, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.affectedRows === 0) {
      return res.status(404).json({ error: "Kullanıcı bulunamadı." });
    }
    return res
      .status(200)
      .json({ message: "Kullanıcı başarıyla güncellendi." });
  });
};

exports.tekMusteriGetir = async (req, res) => {
  const id = req.params.id;
  const q = "SELECT * FROM musteriler WHERE id = ?";
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Kullanıcı bulunamadı." });
    }
    return res.json(data);
  });
};

exports.musteriSil = async (req, res) => {
  const id = req.params.id;
  const q = "DELETE FROM musteriler WHERE id = ?";
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.affectedRows === 0) {
      return res.status(404).json({ error: "Kullanıcı bulunamadı." });
    }
    return res.status(200).json({ message: "Kullanıcı başarıyla silindi." });
  });
};

exports.musterileriFiltrele = async (req, res) => {
  const { keyword } = req.params;
  const search = `%${keyword}%`;
  const q = `
    SELECT * 
    FROM musteriler 
    WHERE ad LIKE ? 
      OR soyad LIKE ? 
      OR adres LIKE ? 
      OR telefon_numarasi LIKE ?
  `;
  connection.query(q, [search, search, search, search], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Kullanıcı bulunamadı." });
    }
    return res.status(200).json({ data });
  });
};
