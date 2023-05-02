const express = require("express");
const router = express.Router();

const {
  urunleriGetir,
  urunOlustur,
  urunGuncelle,
  tekUrunGetir,
  urunSil,
  urunleriFiltrele,
} = require("../controllers/urun-controller.js");

router.get("/", urunleriGetir);

router.post("/", urunOlustur);

router.patch("/:id", urunGuncelle);

router.get("/:id", tekUrunGetir);

router.delete("/:id", urunSil);

router.get("/filter/:keyword", urunleriFiltrele);

module.exports = router;
