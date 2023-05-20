require("dotenv").config();
const express = require("express");
const api = require("./routes/index.js"); // routes klasöründeki index.js dosyası tanımlandı
const connection = require("./service/connection.js"); // service klasöründeki connection.js dosyası tanımlandı
const cors = require("cors");

const app = express(); // express uygulaması oluşturuldu
const port = process.env.PORT || 3000; // 3000 portunu kullanacak
app.use(express.json());
app.use(
  cors({
    origin: "*",
  })
);

connection.connect((err) => {
  if (err) throw err;
  console.log("Connected!");
  app.listen(port, () => {
    console.log(`App started running on ${port}`);
  });
});

app.use("/", api);

//Uygulama kapatıldığında tüm bağlantıları kapatır
process.on("SIGINT", () => {
  connection.end((err) => {
    console.log(err);
    process.exit(1);
  });
  console.log("\nBağlantılar sonlandırılıyor...");
  process.exit(0);
});
