const connection = require("../service/connection.js");

exports.urunleriGetir = async (req, res) => {
  const q = "SELECT * FROM urunler";
  connection.query(q, (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Ürün bulunamadı." });
    }
    return res.json(data);
  });
};

exports.urunOlustur = async (req, res) => {
  const q = `INSERT INTO urunler (urun_adi, marka, kategori, fiyat, ureticiden_satinalim_fiyati) VALUES (?)`;
  const values = [
    req.body.urun_adi,
    req.body.marka,
    req.body.kategori,
    req.body.fiyat,
    req.body.ureticiden_satinalim_fiyati,
  ];
  connection.query(q, [values], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    return res.json("Ürün başarıyla oluşturuldu.");
  });
};

exports.urunGuncelle = async (req, res) => {
  const id = req.params.id;
  const values = req.body;
  const q = "UPDATE urunler SET ? WHERE id = ?";
  connection.query(q, [values, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.affectedRows === 0) {
      return res.status(404).json({ error: "Ürün bulunamadı." });
    }
    return res.status(200).json({ message: "Ürün başarıyla güncellendi." });
  });
};

exports.tekUrunGetir = async (req, res) => {
  const id = req.params.id;
  const q = "SELECT * FROM urunler WHERE id = ?";
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Ürün bulunamadı." });
    }
    return res.json(data);
  });
};

exports.urunSil = async (req, res) => {
  const id = req.params.id;
  const q = "DELETE FROM urunler WHERE id = ?";
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.affectedRows === 0) {
      return res.status(404).json({ error: "Ürün bulunamadı." });
    }
    return res.status(200).json({ message: "Ürün başarıyla silindi." });
  });
};

exports.urunleriFiltrele = async (req, res) => {
  const { keyword } = req.params;
  const search = `%${keyword}%`;
  const q = `
    SELECT * 
    FROM urunler 
    WHERE urun_adi LIKE ? 
      OR marka LIKE ? 
      OR kategori LIKE ? 
      OR fiyat LIKE ?
      OR ureticiden_satinalim_fiyati LIKE ?
  `;
  connection.query(
    q,
    [search, search, search, search, search],
    (error, data) => {
      if (error) return res.status(500).json({ message: error });
      if (data.length === 0) {
        return res.status(404).json({ error: "Ürün bulunamadı." });
      }
      return res.status(200).json({ data });
    }
  );
};
