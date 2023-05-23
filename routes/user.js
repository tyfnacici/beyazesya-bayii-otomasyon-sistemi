const express = require("express");
const router = express.Router();

const { checkAuth, checkAdmin } = require("../service/check-auth.js");

const {
  signup,
  login,
  listAllUsers,
  deleteUser,
  tekKulaniciGetir,
  updateUser,
  userAdresleriniGetir,
  userAdresEkle,
  userAdresGuncelle,
  userAdresSil,
  userTelefonlariniGetir,
  userTelefonEkle,
  userTelefonGuncelle,
  userTelefonSil,
} = require("../controllers/user-controller.js");

router.post("/signup", signup);
router.post("/login", login);
router.get("/", checkAdmin, listAllUsers);
router.get("/sil", deleteUser);
router.get("/:id", tekKulaniciGetir);
router.patch("/:id", updateUser);

//Adres işlemleri
router.get("/adres/:id", userAdresleriniGetir);
router.post("/adres/:id", userAdresEkle);
router.patch("/adres/:id", userAdresGuncelle);
router.delete("/adres/:id", userAdresSil);

//Telefon işlemleri
router.get("/telefon/:id", userTelefonlariniGetir);
router.post("/telefon/:id", userTelefonEkle);
router.patch("/telefon/:id", userTelefonGuncelle);
router.delete("/telefon/:id", userTelefonSil);

module.exports = router;
