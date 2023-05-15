const e = require("express");
const connection = require("../service/connection.js");

// Musteri siparisleri

exports.musteriSiparisleriGetir = async (req, res) => {
  const q = "SELECT * FROM siparisler WHERE siparis_turu = 'musteri';";
  connection.query(q, (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Sipariş bulunamadı." });
    }
    return res.json(data);
  });
};

exports.musteriSiparisOlustur = async (req, res) => {
  const q =
    "INSERT INTO musteriler_siparis (adet, musteriler_id, urunler_id) VALUES (?);";
  const values = [req.body.adet, req.body.musteri_id, req.body.urun_id];
  connection.query(q, [values], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    return res.json("Sipariş başarıyla oluşturuldu.");
  });
};

exports.musteriSiparisGuncelle = async (req, res) => {
  //değişecek
  const id = req.params.id;
  const values = req.body;
  const q = "UPDATE musteriler_siparis SET ? WHERE id = ?";
  connection.query(q, [values, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.affectedRows === 0) {
      return res.status(404).json({ error: "Sipariş bulunamadı." });
    }
    return res.status(200).json({ message: "Sipariş başarıyla güncellendi." });
  });
};

exports.musteriTekSiparisGetir = async (req, res) => {
  //test edilecek
  const id = req.params.id;
  const q =
    "SELECT * FROM siparisler WHERE siparis_turu = 'musteri' AND id = ?";
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Sipariş bulunamadı." });
    }
    return res.json(data);
  });
};

exports.musteriSiparisSil = async (req, res) => {
  const id = req.params.id;
  const q = `DELETE FROM siparisler_musteriler WHERE id = ?
   DELETE FROM siparisler WHERE id = ?;`;
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.affectedRows === 0) {
      return res.status(404).json({ error: "Sipariş bulunamadı." });
    }
    return res.status(200).json({ message: "Sipariş başarıyla silindi." });
  });
};

exports.musteriSiparisleriFiltrele = async (req, res) => {
  const keyword = req.params.keyword;
  const select = req.params.select;

  let q;
  let params;

  switch (select) {
    case "urun_adi":
      q = `SELECT * FROM siparisler WHERE urun_adi LIKE ?`;
      params = [`%${keyword}%`];
      break;

    case "magaza_adi":
      q = `SELECT * FROM siparisler WHERE magaza_adi LIKE ?`;
      params = [`%${keyword}%`];
      break;

    case "siparis_tarihi":
      q = `SELECT * FROM siparisler WHERE siparis_tarihi LIKE ?`;
      params = [`%${keyword}%`];
      break;

    case "sparis_turu":
      q = `SELECT * FROM siparisler WHERE sparis_turu LIKE ?`;
      params = [`%${keyword}%`];
      break;

    case "adet":
      q = `SELECT * FROM siparisler WHERE adet LIKE ?`;
      params = [`%${keyword}%`];
      break;

    case "fiyat":
      q = `SELECT * FROM siparisler WHERE fiyat LIKE ?`;
      params = [`%${keyword}%`];
      break;

    default:
      q = `SELECT * FROM siparisler WHERE 
        musteri_id LIKE ? 
        OR urun_id LIKE ? 
        OR siparis_tarihi LIKE ? 
        OR teslim_tarihi LIKE ? 
        OR siparis_durumu LIKE ?`;
      params = [
        `%${keyword}%`,
        `%${keyword}%`,
        `%${keyword}%`,
        `%${keyword}%`,
        `%${keyword}%`,
      ];
      break;
  }

  connection.query(q, [params], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.affectedRows === 0) {
      return res.status(404).json({ error: "Sipariş bulunamadı." });
    }
    return res.status(200).json(data);
  });
};

// Urun siparisleri

exports.magzaSiparisleriGetir = async (req, res) => {
  const q = "SELECT * FROM siparisler WHERE siparis_turu = 'magaza';";
  connection.query(q, (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Sipariş bulunamadı." });
    }
    return res.json(data);
  });
};

exports.magzaSiparisOlustur = async (req, res) => {
  // test edilecek
  const q =
    "INSERT INTO magazalar_siparis (adet, magaza_id, urunler_id) VALUES (?);";
  const values = [req.body.adet, req.body.magaza_id, req.body.urun_id];
  connection.query(q, [values], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    return res.json("Sipariş başarıyla oluşturuldu.");
  });
};
