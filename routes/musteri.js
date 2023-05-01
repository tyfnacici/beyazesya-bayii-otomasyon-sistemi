const express = require("express");
const router = express.Router();

const {
  musterileriGetir,
  musteriOlustur,
  musteriGuncelle,
  tekMusteriGetir,
  musteriSil,
} = require("../controllers/musteri-controller.js");

router.get("/", musterileriGetir);

router.post("/", musteriOlustur);

router.patch("/:id", musteriGuncelle);

router.get("/:id", tekMusteriGetir);

router.delete("/:id", musteriSil);

module.exports = router;
