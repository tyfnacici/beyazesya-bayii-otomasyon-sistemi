require("dotenv").config();
const express = require("express");
const api = require("./routes/index.js");
const connection = require("./service/connection.js");

const app = express();
const port = process.env.PORT || 3000;
app.use(express.json());

connection.getConnection((err) => {
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
