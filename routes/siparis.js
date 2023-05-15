const express = require("express"); // npm express tanımlandı
const router = express.Router(); // express router tanımlandı

const {
  musteriSiparisleriGetir,
  musteriSiparisOlustur,
  musteriSiparisGuncelle,
  musteriTekSiparisGetir,
  musteriSiparisSil,
  musteriSiparisleriFiltrele,
  magzaSiparisleriGetir,
  magzaSiparisOlustur,
  //   magzaSiparisGuncelle,
  //   magzaTekSiparisGetir,
  //   magzaSiparisSil,
  //   magzaSiparisleriFiltrele,
} = require("../controllers/siparis-controller.js"); //controle siparis-controller.js dosyası tanımlandı

// //müşteri sipariş işlemleri
router.get("/musteri", musteriSiparisleriGetir); //get isteği ile siparisleriGetir fonksiyonu çağırıldı

router.post("/musteri", musteriSiparisOlustur); // post isteği ile siparisleriOlustur fonksiyonu çağırıldı

router.patch("/musteri/:id", musteriSiparisGuncelle); // patch isteği ile siparisleriGuncelle fonksiyonu çağırıldı

router.get("/musteri/:id", musteriTekSiparisGetir); // get isteği ile siparisleriGetir fonksiyonu çağırıldı

router.delete("/musteri/:id", musteriSiparisSil); // delete isteği ile siparisleriSil fonksiyonu çağırıldı

router.get("/musteri/filter/:select/:keyword", musteriSiparisleriFiltrele); //  get isteği ile siparisleriFiltrele fonksiyonu çağırıldı

// //mağaza sipariş işlemleri
router.get("/magaza", magzaSiparisleriGetir); // get isteği ile siparisleriGetir fonksiyonu çağırıldı

router.post("/magaza", magzaSiparisOlustur); // post isteği ile siparisleriOlustur fonksiyonu çağırıldı

// router.patch("/magaza/:id", magzaSiparisGuncelle); // patch isteği ile siparisleriGuncelle fonksiyonu çağırıldı

// router.get("/magaza/:id", magzaTekSiparisGetir); // get isteği ile siparisleriGetir fonksiyonu çağırıldı

// router.delete("/magaza/:id", magzaSiparisSil); // delete isteği ile siparisleriSil fonksiyonu çağırıldı

// router.get("/magaza/filter/:select&keyword", magzaSiparisleriFiltrele); //  get isteği ile siparisleriFiltrele fonksiyonu çağırıldı

module.exports = router;
