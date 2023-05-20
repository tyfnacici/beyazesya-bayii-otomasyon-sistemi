const jwt = require("jsonwebtoken");
const connection = require("./connection.js");

exports.checkAuth = (req, res, next) => {
  try {
    const token = req.headers.authorization.split(" ")[1];
    if (!token) {
      return res.status(401).json({
        message: "You are not authorized",
      });
    }
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return error;
  }
};

exports.checkAdmin = (req, res, next) => {
  try {
    const token = req.headers.authorization.split(" ")[1];
    if (!token) {
      return res.status(401).json({
        message: "User Not Found",
      });
    }
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.body = decoded;
    const { username } = decoded;
    const q = "SELECT rol FROM users WHERE username = ?";
    connection.query(q, [username], (error, data) => {
      if (error) return res.status(500).json({ message: "Server Error1" });
      if (data[0].rol === 0) {
        // Access the value of rol from data array
        next();
      } else {
        return res.status(401).json({ message: "You are not authorized" });
      }
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Server Error2" });
  }
};
