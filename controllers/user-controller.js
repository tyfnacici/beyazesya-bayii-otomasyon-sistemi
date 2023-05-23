const bcryptjs = require("bcryptjs");
const jwt = require("jsonwebtoken");
const connection = require("../service/connection.js");

exports.signup = async (req, res) => {
  const { username, password, rol, ad, soyad, unvan_id, maas } = req.body;
  const salt = await bcryptjs.genSalt(10);
  const hashedPassword = await bcryptjs.hash(password, salt);
  const q2 =
    "INSERT INTO users (username, password_hash, rol, ad, soyad, unvan_id, maas) VALUES (?, ?, ?, ?, ?, ?, ?)";
  connection.query(
    q2,
    [username, hashedPassword, rol, ad, soyad, unvan_id, maas],
    (error, data) => {
      if (error) return res.status(500).json({ message: error });
      res.status(201).json({
        message: "User created",
      });
    }
  );
};

exports.listAllUsers = async (req, res) => {
  const q = "SELECT * FROM users";
  connection.query(q, (error, data) => {
    if (error) return res.status(500).json({ message: error });
    res.json(data);
  });
};

exports.login = async (req, res) => {
  const { username, password } = req.body;
  const q = "SELECT * FROM users WHERE username = ?";
  connection.query(q, [username], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    if (data.length === 0) {
      return res.status(404).json({ error: "User not found." });
    }
    const user = data[0];
    const isPasswordCorrect = bcryptjs.compare(password, user.password_hash);
    if (!isPasswordCorrect) {
      return res.status(401).json({ error: "Password is incorrect." });
    }
    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
      },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );
    return res.status(200).json({ token });
  });
};

exports.deleteUser = async (req, res) => {
  const { id } = req.query;
  const q = `DELETE FROM adresler_users WHERE users_id = ?;
  DELETE FROM adresler WHERE id = (
  SELECT 
  adresler_id
  FROM
  adresler_users
  WHERE 
  users_id = ?
  );
  DELETE FROM telefon_nolar_users WHERE users_id = ?;
  DELETE FROM telefon_nolar WHERE id = (
  SELECT 
  telefon_nolar_id
  FROM
  telefon_nolar_users
  WHERE 
  users_id = ?
  );
  DELETE FROM magazalar_users WHERE users_id = ?;
  DELETE FROM users WHERE id = ?;`;
  connection.query(q, [id, id, id, id, id, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    res.json({ message: "User deleted" });
  });
};

exports.tekKulaniciGetir = async (req, res) => {
  const { id } = req.params;
  const q = "SELECT * FROM users WHERE id = ?";
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    res.json(data);
  });
};

exports.updateUser = async (req, res) => {
  const { id } = req.params;
  const { username, password, rol, ad, soyad, unvan_id, maas } = req.body;
  const salt = await bcryptjs.genSalt(10);
  const hashedPassword = await bcryptjs.hash(password, salt);
  const q =
    "UPDATE users SET username = ?, password_hash = ?, rol = ?, ad = ?, soyad = ?, unvan_id = ?, maas = ? WHERE id = ?";
  connection.query(
    q,
    [username, hashedPassword, rol, ad, soyad, unvan_id, maas, id],
    (error, data) => {
      if (error) return res.status(500).json({ message: error });
      res.json({ message: "User updated" });
    }
  );
};

//Adres işlemleri

exports.userAdresleriniGetir = async (req, res) => {
  const { id } = req.params;
  const q = `SELECT
  adresler_users.users_id,
  adresler.id,
  adresler.adres
  FROM 
  adresler_users 
  join adresler ON adresler_users.adresler_id = adresler.id
  WHERE 
  users_id = ?;`;
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    res.json(data);
  });
};

exports.userAdresEkle = async (req, res) => {
  const { id } = req.params;
  const { adres } = req.body;
  const q = "INSERT INTO adresler (adres) VALUES (?)";
  connection.query(q, [adres], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    const q2 =
      "INSERT INTO adresler_users (adresler_id, users_id) VALUES (?, ?)";
    connection.query(q2, [data.insertId, id], (error, data) => {
      if (error) return res.status(500).json({ message: error });
      res.json({ message: "Adres eklendi" });
    });
  });
};

exports.userAdresGuncelle = async (req, res) => {
  const { id } = req.params;
  const { adres } = req.body;
  const q = "UPDATE adresler SET adres = ? WHERE id = ?";
  connection.query(q, [adres, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    res.json({ message: "Adres güncellendi" });
  });
};

exports.userAdresSil = async (req, res) => {
  const { id } = req.params;
  const q = "DELETE FROM adresler_users WHERE adresler_id = ?";
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    const q2 = "DELETE FROM adresler WHERE id = ?";
    connection.query(q2, [id], (error, data) => {
      if (error) return res.status(500).json({ message: error });
      res.json({ message: "Adres silindi" });
    });
  });
};

//Telefon işlemleri

exports.userTelefonlariniGetir = async (req, res) => {
  const { id } = req.params;
  const q = `SELECT
  telefon_nolar_users.users_id,
  telefon_nolar.id,
  telefon_nolar.tel_no
  FROM 
  telefon_nolar_users 
  join telefon_nolar ON telefon_nolar_users.telefon_nolar_id = telefon_nolar.id
  WHERE 
  users_id = ?;`;
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    res.json(data);
  });
};

exports.userTelefonEkle = async (req, res) => {
  const { id } = req.params;
  const { tel_no } = req.body;
  const q = "INSERT INTO telefon_nolar (tel_no) VALUES (?)";
  connection.query(q, [tel_no], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    const q2 =
      "INSERT INTO telefon_nolar_users (telefon_nolar_id, users_id) VALUES (?, ?)";
    connection.query(q2, [data.insertId, id], (error, data) => {
      if (error) return res.status(500).json({ message: error });
      res.json({ message: "Telefon eklendi" });
    });
  });
};

exports.userTelefonGuncelle = async (req, res) => {
  const { id } = req.params;
  const { tel_no } = req.body;
  const q = "UPDATE telefon_nolar SET tel_no = ? WHERE id = ?";
  connection.query(q, [tel_no, id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    res.json({ message: "Telefon güncellendi" });
  });
};

exports.userTelefonSil = async (req, res) => {
  const { id } = req.params;
  const q = "DELETE FROM telefon_nolar_users WHERE telefon_nolar_id = ?";
  const q2 = "DELETE FROM telefon_nolar WHERE id = ?";
  connection.query(q, [id], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    connection.query(q2, [id], (error, data) => {
      if (error) return res.status(500).json({ message: error });
      res.json({ message: "Telefon silindi" });
    });
  });
};
