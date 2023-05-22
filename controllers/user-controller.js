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
