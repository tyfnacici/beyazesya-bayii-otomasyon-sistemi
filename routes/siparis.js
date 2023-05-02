const express = require("express");// npm express tanımlandı
const router = express.Router(); // express router tanımlandı

const {
    siparisleriGetir,
    siparisleriOlustur,
    siparisleriGuncelle,
    siparisleriGetir,
    siparisleriSil,
    siparisleriFiltrele,
  } = require("../controllers/siparis-controller.js");//controle siparis-controller.js dosyası tanımlandı

router.get("/", siparisleriGetir);  //get isteği ile siparisleriGetir fonksiyonu çağırıldı

router.post("/", siparisleriOlustur); // post isteği ile siparisleriOlustur fonksiyonu çağırıldı

router.patch("/:id", siparisleriGuncelle); // patch isteği ile siparisleriGuncelle fonksiyonu çağırıldı

router.get("/:id", siparisleriGetir); // get isteği ile siparisleriGetir fonksiyonu çağırıldı

router.delete("/:id", siparisleriSil); // delete isteği ile siparisleriSil fonksiyonu çağırıldı

router.get("/filter/:keyword", siparisleriFiltrele); //  get isteği ile siparisleriFiltrele fonksiyonu çağırıldı

module.exports = router;