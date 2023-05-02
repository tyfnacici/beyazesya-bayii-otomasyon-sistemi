const express = require("express");
const musteri = require("./musteri.js");
const urun = require("./urun.js");
const siparis = require("./siparis.js");

const router = express.Router();

router.get("/", (req, res) => {
  res.send("Hello World!");
});

router.use("/api/musteri", musteri);
router.use("/api/siparis", siparis);
router.use("/api/urun", urun);

module.exports = router;
