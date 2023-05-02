const bcryptjs = require("bcryptjs");
const jwt = require("jsonwebtoken");
const connection = require("../service/connection.js");

exports.signup = async (req, res) => {
  const { username, password, role } = req.body;
  const salt = await bcryptjs.genSalt(10);
  const hashedPassword = await bcryptjs.hash(password, salt);
  const q =
    "INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)";
  connection.query(q, [username, hashedPassword, role], (error, data) => {
    if (error) return res.status(500).json({ message: error });
    res.status(201).json({
      message: "User created",
    });
  });
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
    return res.json({ token });
  });
};
