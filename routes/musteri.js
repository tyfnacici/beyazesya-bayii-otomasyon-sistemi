const express = require("express");
const router = express.Router();

const {
  musterileriGetir,
  musteriOlustur,
  musteriGuncelle,
  tekMusteriGetir,
  musteriSil,
  musterileriFiltrele,
} = require("../controllers/musteri-controller.js");

router.get("/", musterileriGetir);

router.post("/", musteriOlustur);

router.patch("/:id", musteriGuncelle);

router.get("/:id", tekMusteriGetir);

router.delete("/:id", musteriSil);

router.get("/filter/:keyword", musterileriFiltrele);

module.exports = router;
