const string = require("2/string.js");
const connection = require("../service/connection.js");

//Body işlemleri

exports.musterileriGetir = async (req, res) => {
  const q = "SELECT * FROM musteriler;";
  connection.query(q, (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Kullanıcı bulunamadı." });
    }
    return res.json(data);
  });
};

exports.musteriOlustur = async (req, res) => {
  const q = `INSERT INTO musteriler (ad, soyad) VALUES (?);`;
  const values = [req.body.ad, req.body.soyad];
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
  const keyword = req.params.keyword;
  const select = req.params.select;

  let q;
  let params;
  switch (select) {
    case "ad":
      q = `SELECT * FROM musteriler WHERE ad LIKE ?`;
      params = "%" + keyword + "%";
      break;
    case "soyad":
      q = `SELECT * FROM musteriler WHERE soyad LIKE ?`;
      params = "%" + keyword + "%";
      break;
    case "adres":
      q = `SELECT
            adresler_musteriler.musteriler_id,
            adresler.id,
            musteriler.ad,
            musteriler.soyad,
            adresler.adres 
            FROM 
            adresler_musteriler
            join adresler ON adresler_musteriler.adresler_id = adresler.id
            join musteriler ON musteriler.id = adresler_musteriler.musteriler_id
            WHERE 
            adresler.adres  LIKE ?;`;
      params = "%" + keyword + "%";
      break;
    case "telefon":
      q = `SELECT
            telefon_nolar_musteriler.musteriler_id,
            telefon_nolar.id,
            musteriler.ad,
            musteriler.soyad,
            telefon_nolar.tel_no
            FROM 
            telefon_nolar_musteriler
            join telefon_nolar ON telefon_nolar_musteriler.telefon_nolar_id = telefon_nolar.id
            join musteriler ON musteriler.id = telefon_nolar_musteriler.musteriler_id
            WHERE 
            telefon_nolar.tel_no  LIKE ?;`;
      params = "%" + keyword + "%";
      break;
    default:
      q = `SELECT * FROM musteriler WHERE ad LIKE ?  OR soyad LIKE ? `;
      params = ["%" + keyword + "%", "%" + keyword + "%"];
      break;
  }

  connection.query(q, [params], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Kullanıcı bulunamadı." });
    }
    return res.status(200).json({ data });
  });
};

//Adres işlemleri

exports.musteriAdresleriniGetir = async (req, res) => {
  const id = req.params.id;
  const q = `SELECT
  adresler_musteriler.musteriler_id,
  adresler.id,
  adresler.adres
  FROM 
  adresler_musteriler 
  join adresler ON adresler_musteriler.adresler_id = adresler.id
  WHERE 
  musteriler_id = ?;`;
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Adres bulunamadı." });
    }
    return res.json(data);
  });
};

exports.musteriAdresEkle = async (req, res) => {
  const id = req.params.id;
  const values = [req.body.adres];
  const q = `INSERT INTO adresler (adres) VALUES (?); 
  INSERT INTO adresler_musteriler (musteriler_id, adresler_id) VALUES (?, LAST_INSERT_ID());`;
  connection.query(q, [values, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    return res.json("Adres başarıyla oluşturuldu.");
  });
};

exports.musteriAdresGuncelle = async (req, res) => {
  const id = req.params.id;
  const values = req.body;
  const q = `UPDATE adresler SET ? WHERE id = ?;`;
  connection.query(q, [values, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.affectedRows === 0) {
      return res.status(404).json({ error: "Adres bulunamadı." });
    }
    return res.status(200).json({ message: "Adres başarıyla güncellendi." });
  });
};

exports.musteriAdresSil = async (req, res) => {
  const id = req.params.id;
  const q = `DELETE FROM adresler_musteriler
  WHERE adresler_id = ?;
  DELETE FROM adresler WHERE id = ?;`;
  connection.query(q, [id, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.affectedRows === 0) {
      return res.status(404).json({ error: "Adres bulunamadı." });
    }
    return res.status(200).json({ message: "Adres başarıyla silindi." });
  });
};

//Telefon işlemleri
exports.musteriTelefonlariniGetir = async (req, res) => {
  const id = req.params.id;
  const q = `SELECT
  telefon_nolar_musteriler.musteriler_id,
  telefon_nolar.id,
  telefon_nolar.tel_no
  FROM 
  telefon_nolar_musteriler
  join telefon_nolar ON telefon_nolar_musteriler.telefon_nolar_id = telefon_nolar.id
  WHERE 
  musteriler_id = ? ;`;
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "Telefon bulunamadı." });
    }
    return res.json(data);
  });
};

exports.musteriTelefonEkle = async (req, res) => {
  const id = req.params.id;
  const q = `INSERT INTO telefon_nolar (tel_no) VALUES (?);
  INSERT INTO telefon_nolar_musteriler (musteriler_id, telefon_nolar_id) VALUES (?, LAST_INSERT_ID());`;
  const values = [req.body.tel_no];
  connection.query(q, [values, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    return res.json("Telefon başarıyla oluşturuldu.");
  });
};

exports.musteriTelefonGuncelle = async (req, res) => {
  const id = req.params.id;
  const values = req.body;
  const q = `UPDATE telefon_nolar SET ? WHERE id = ?;`;
  connection.query(q, [values, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.affectedRows === 0) {
      return res.status(404).json({ error: "Telefon bulunamadı." });
    }
    return res.status(200).json({ message: "Telefon başarıyla güncellendi." });
  });
};

exports.musteriTelefonSil = async (req, res) => {
  const id = req.params.id;
  const q = `DELETE FROM telefon_nolar_musteriler WHERE  telefon_nolar_id = ?;
  DELETE FROM telefon_nolar WHERE id = ?;`;
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.affectedRows === 0) {
      return res.status(404).json({ error: "Telefon bulunamadı." });
    }
    return res.status(200).json({ message: "Telefon başarıyla silindi." });
  });
};
