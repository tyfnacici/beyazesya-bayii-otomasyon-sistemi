const express = require("express");
const router = express.Router();

const {
  signup,
  login,
  listAllUsers,
} = require("../controllers/user-controller.js");

router.post("/signup", signup);
router.post("/login", login);
router.get("/", listAllUsers);

module.exports = router;
