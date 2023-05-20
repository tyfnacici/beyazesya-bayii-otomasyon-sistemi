const express = require("express");
const router = express.Router();

const { checkAuth, checkAdmin } = require("../service/check-auth.js");

const {
  signup,
  login,
  listAllUsers,
  deleteUser,
} = require("../controllers/user-controller.js");

router.post("/signup", signup);
router.post("/login", login);
router.get("/", checkAdmin, listAllUsers);
router.get("/sil", deleteUser);

module.exports = router;
