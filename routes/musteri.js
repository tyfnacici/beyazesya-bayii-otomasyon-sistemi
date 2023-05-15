const express = require("express");
const router = express.Router();

const {
  musterileriGetir,
  musteriOlustur,
  musteriGuncelle,
  tekMusteriGetir,
  musteriSil,
  musterileriFiltrele,
  musteriAdresleriniGetir,
  musteriAdresEkle,
  musteriAdresGuncelle,
  musteriAdresSil,
  musteriTelefonlariniGetir,
  musteriTelefonEkle,
  musteriTelefonGuncelle,
  musteriTelefonSil,
} = require("../controllers/musteri-controller.js");

//Body işlemleri
router.get("/kisi", musterileriGetir);

router.post("/kisi", musteriOlustur);

router.patch("/kisi/:id", musteriGuncelle);

router.get("/kisi/:id", tekMusteriGetir);

router.delete("/kisi/:id", musteriSil);

router.get("/kisi/filter/:select/:keyword/", musterileriFiltrele);

//Adres işlemleri
router.get("/adres/:id", musteriAdresleriniGetir);

router.post("/adres/:id", musteriAdresEkle);

router.patch("/adres/:id", musteriAdresGuncelle);

router.delete("/adres/:id", musteriAdresSil);

//Telefon işlemleri

router.get("/telefon/:id", musteriTelefonlariniGetir);

router.post("/telefon/:id", musteriTelefonEkle);

router.patch("/telefon/:id", musteriTelefonGuncelle);

router.delete("/telefon/:id", musteriTelefonSil);

module.exports = router;
