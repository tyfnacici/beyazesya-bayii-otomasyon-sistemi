const express = require("express");
const router = express.Router();
const connection = require("../service/connection.js");
const {
  musterileriGetir,
  musteriOlustur,
  musteriGuncelle,
} = require("../controllers/musteri-controller.js");

router.get("/", musterileriGetir);

router.post("/", musteriOlustur);

router.patch("/:id", musteriGuncelle);

module.exports = router;
